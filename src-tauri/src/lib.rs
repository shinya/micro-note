use rusqlite::Connection;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::sync::Mutex;
use tauri::{Manager, State};

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
    fn new(db_path: PathBuf) -> Result<Self, String> {
        if let Some(parent) = db_path.parent() {
            std::fs::create_dir_all(parent).map_err(|e| {
                format!("Failed to create data directory {:?}: {}", parent, e)
            })?;
        }

        let db = Connection::open(&db_path).map_err(|e| {
            format!("Failed to open database {:?}: {}", db_path, e)
        })?;

        db.execute(
            "CREATE TABLE IF NOT EXISTS notes (
                id TEXT PRIMARY KEY,
                content TEXT NOT NULL,
                timestamp TEXT NOT NULL,
                is_favorite INTEGER NOT NULL DEFAULT 0
            )",
            [],
        )
        .map_err(|e| format!("Failed to create table: {}", e))?;

        println!("Database initialized at {:?}", db_path);
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

    let notes = stmt
        .query_map([], |row| {
            Ok(Note {
                id: row.get(0)?,
                content: row.get(1)?,
                timestamp: row.get(2)?,
                is_favorite: row.get::<_, i32>(3)? != 0,
            })
        })
        .map_err(|e| e.to_string())?;

    let mut result = Vec::new();
    for note in notes {
        result.push(note.map_err(|e| e.to_string())?);
    }

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
async fn delete_note(id: String, state: State<'_, AppState>) -> Result<(), String> {
    let db = state.db.lock().unwrap();

    db.execute("DELETE FROM notes WHERE id = ?1", rusqlite::params![id])
        .map_err(|e| e.to_string())?;

    Ok(())
}

#[derive(Debug, Deserialize)]
struct ImportNote {
    content: String,
    timestamp: String,
    is_favorite: bool,
}

#[tauri::command]
async fn import_notes(
    notes: Vec<ImportNote>,
    state: State<'_, AppState>,
) -> Result<u32, String> {
    let db = state.db.lock().unwrap();
    let mut count: u32 = 0;

    for note in &notes {
        let id = Uuid::new_v4().to_string();
        db.execute(
            "INSERT INTO notes (id, content, timestamp, is_favorite) VALUES (?1, ?2, ?3, ?4)",
            rusqlite::params![
                id,
                note.content,
                note.timestamp,
                if note.is_favorite { 1i32 } else { 0i32 }
            ],
        )
        .map_err(|e| e.to_string())?;
        count += 1;
    }

    println!("Imported {} notes successfully", count);
    Ok(count)
}

#[tauri::command]
async fn copy_to_clipboard(text: String) -> Result<(), String> {
    #[cfg(target_os = "macos")]
    {
        use std::io::Write;
        use std::process::Command;
        let mut child = Command::new("pbcopy")
            .stdin(std::process::Stdio::piped())
            .spawn()
            .map_err(|e| e.to_string())?;

        if let Some(mut stdin) = child.stdin.take() {
            stdin
                .write_all(text.as_bytes())
                .map_err(|e| e.to_string())?;
        }

        child.wait().map_err(|e| e.to_string())?;
    }

    #[cfg(target_os = "windows")]
    {
        use std::io::Write;
        use std::process::Command;
        let mut child = Command::new("clip")
            .stdin(std::process::Stdio::piped())
            .spawn()
            .map_err(|e| e.to_string())?;

        if let Some(mut stdin) = child.stdin.take() {
            stdin
                .write_all(text.as_bytes())
                .map_err(|e| e.to_string())?;
        }

        child.wait().map_err(|e| e.to_string())?;
    }

    #[cfg(target_os = "linux")]
    {
        use std::io::Write;
        use std::process::Command;
        let mut child = Command::new("xclip")
            .args(&["-selection", "clipboard"])
            .stdin(std::process::Stdio::piped())
            .spawn()
            .map_err(|e| e.to_string())?;

        if let Some(mut stdin) = child.stdin.take() {
            stdin
                .write_all(text.as_bytes())
                .map_err(|e| e.to_string())?;
        }

        child.wait().map_err(|e| e.to_string())?;
    }

    Ok(())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_positioner::init())
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_window_state::Builder::new().build())
        .setup(|app| {
            let app_data_dir = app.path().app_data_dir().map_err(|e| {
                format!("Failed to get app data directory: {}", e)
            })?;
            let db_path = app_data_dir.join("notes.db");

            let app_state = AppState::new(db_path).map_err(|e| {
                format!("Failed to initialize database: {}", e)
            })?;

            app.manage(app_state);
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            save_note,
            get_notes,
            update_note_favorite,
            delete_note,
            copy_to_clipboard,
            import_notes
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
