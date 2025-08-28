use rusqlite::{Connection, Result};
use serde::{Deserialize, Serialize};
use std::sync::Mutex;
use tauri::State;

use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize)]
struct Note {
    id: String,
    content: String,
    timestamp: String,
    is_favorite: bool,
}

struct AppState {
    db: Mutex<Connection>,
}

impl AppState {
    fn new() -> Result<Self> {
        let db = Connection::open("notes.db")?;

        // テーブルを作成
        db.execute(
            "CREATE TABLE IF NOT EXISTS notes (
                id TEXT PRIMARY KEY,
                content TEXT NOT NULL,
                timestamp TEXT NOT NULL,
                is_favorite INTEGER NOT NULL DEFAULT 0
            )",
            [],
        )?;

        Ok(AppState { db: Mutex::new(db) })
    }
}

#[tauri::command]
async fn save_note(
    content: String,
    timestamp: String,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let db = state.db.lock().unwrap();
    let id = Uuid::new_v4().to_string();

    db.execute(
        "INSERT INTO notes (id, content, timestamp, is_favorite) VALUES (?1, ?2, ?3, ?4)",
        rusqlite::params![id, content, timestamp, 0i32],
    )
    .map_err(|e| e.to_string())?;

    Ok(())
}

#[tauri::command]
async fn get_notes(state: State<'_, AppState>) -> Result<Vec<Note>, String> {
    let db = state.db.lock().unwrap();

    let mut stmt = db
        .prepare("SELECT id, content, timestamp, is_favorite FROM notes ORDER BY timestamp DESC")
        .map_err(|e| e.to_string())?;

    println!("Database query prepared successfully");

            let notes = stmt
            .query_map([], |row| {
                let id: String = row.get(0)?;
                let content: String = row.get(1)?;
                let timestamp: String = row.get(2)?;
                let is_favorite_int: i32 = row.get(3)?;

                println!("Processing row - id: {}, content: {}, timestamp: {}, is_favorite_int: {}",
                        id, content, timestamp, is_favorite_int);

                Ok(Note {
                    id,
                    content,
                    timestamp,
                    is_favorite: is_favorite_int != 0,
                })
            })
            .map_err(|e| e.to_string())?;

    let mut result = Vec::new();
    for note in notes {
        let note = note.map_err(|e| e.to_string())?;
        println!("Note processed successfully: {:?}", note);
        result.push(note);
    }

    println!("Total notes returned: {}", result.len());
    Ok(result)
}

#[tauri::command]
async fn update_note_favorite(
    id: String,
    is_favorite: bool,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let db = state.db.lock().unwrap();

    db.execute(
        "UPDATE notes SET is_favorite = ?1 WHERE id = ?2",
        rusqlite::params![if is_favorite { 1i32 } else { 0i32 }, id],
    )
    .map_err(|e| e.to_string())?;

    Ok(())
}

#[tauri::command]
async fn delete_note(
    id: String,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let db = state.db.lock().unwrap();

    db.execute(
        "DELETE FROM notes WHERE id = ?1",
        rusqlite::params![id],
    )
    .map_err(|e| e.to_string())?;

    println!("Note deleted successfully: {}", id);
    Ok(())
}

#[tauri::command]
async fn copy_to_clipboard(text: String) -> Result<(), String> {
    // クリップボードにコピー（macOS用）
    #[cfg(target_os = "macos")]
    {
        use std::process::Command;
        use std::io::Write;
        let mut child = Command::new("pbcopy")
            .stdin(std::process::Stdio::piped())
            .spawn()
            .map_err(|e| e.to_string())?;

        if let Some(mut stdin) = child.stdin.take() {
            stdin.write_all(text.as_bytes()).map_err(|e| e.to_string())?;
        }

        child.wait().map_err(|e| e.to_string())?;
    }

    // Windows用
    #[cfg(target_os = "windows")]
    {
        use std::process::Command;
        use std::io::Write;
        let mut child = Command::new("clip")
            .stdin(std::process::Stdio::piped())
            .spawn()
            .map_err(|e| e.to_string())?;

        if let Some(mut stdin) = child.stdin.take() {
            stdin.write_all(text.as_bytes()).map_err(|e| e.to_string())?;
        }

        child.wait().map_err(|e| e.to_string())?;
    }

    // Linux用
    #[cfg(target_os = "linux")]
    {
        use std::process::Command;
        use std::io::Write;
        let mut child = Command::new("xclip")
            .args(&["-selection", "clipboard"])
            .stdin(std::process::Stdio::piped())
            .spawn()
            .map_err(|e| e.to_string())?;

        if let Some(mut stdin) = child.stdin.take() {
            stdin.write_all(text.as_bytes()).map_err(|e| e.to_string())?;
        }

        child.wait().map_err(|e| e.to_string())?;
    }

    Ok(())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let app_state = AppState::new().expect("Failed to initialize database");

    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .manage(app_state)
        .invoke_handler(tauri::generate_handler![
            save_note,
            get_notes,
            update_note_favorite,
            delete_note,
            copy_to_clipboard
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
