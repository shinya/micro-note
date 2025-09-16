use rusqlite::{Connection, Result};
use serde::{Deserialize, Serialize};
use std::sync::Mutex;
use tauri::State;
use std::net::{TcpListener, SocketAddr};
use std::io;

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
        let app_data_dir = dirs::data_dir().unwrap().join("com.pemomomo.micro-note");
        std::fs::create_dir_all(&app_data_dir).unwrap();
        let db_path = app_data_dir.join("notes.db");
        let db = Connection::open(db_path)?;

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

            println!(
                "Processing row - id: {}, content: {}, timestamp: {}, is_favorite_int: {}",
                id, content, timestamp, is_favorite_int
            );

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
async fn delete_note(id: String, state: State<'_, AppState>) -> Result<(), String> {
    let db = state.db.lock().unwrap();

    db.execute("DELETE FROM notes WHERE id = ?1", rusqlite::params![id])
        .map_err(|e| e.to_string())?;

    println!("Note deleted successfully: {}", id);
    Ok(())
}

#[tauri::command]
async fn copy_to_clipboard(text: String) -> Result<(), String> {
    // クリップボードにコピー（macOS用）
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

    // Windows用
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

    // Linux用
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

/// 動的ポート割り当て機能
/// 30011-30030の範囲でポートを探し、見つからない場合は10000以降で空いているポートを探す
fn find_available_port() -> Result<u16, io::Error> {
    // まず30011-30030の範囲でポートを探す
    for port in 30011..=30030 {
        if let Ok(listener) = TcpListener::bind(SocketAddr::from(([127, 0, 0, 1], port))) {
            // ポートが使用可能であることを確認
            drop(listener); // リスナーを閉じてポートを解放
            return Ok(port);
        }
    }

    // 30011-30030で見つからない場合は、10000以降で空いているポートを探す
    for port in 10000..65535 {
        if let Ok(listener) = TcpListener::bind(SocketAddr::from(([127, 0, 0, 1], port))) {
            // ポートが使用可能であることを確認
            drop(listener); // リスナーを閉じてポートを解放
            return Ok(port);
        }
    }

    Err(io::Error::new(io::ErrorKind::AddrInUse, "No available ports found"))
}

/// ポート情報を取得するコマンド
#[tauri::command]
async fn get_port_info() -> Result<u16, String> {
    println!("ポート検索を開始します...");

    match find_available_port() {
        Ok(port) => {
            println!("利用可能なポートが見つかりました: {}", port);
            Ok(port)
        },
        Err(e) => {
            let error_msg = format!("ポート検索に失敗しました: {}", e);
            println!("{}", error_msg);
            Err(error_msg)
        }
    }
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let app_state = AppState::new().expect("Failed to initialize database");

    tauri::Builder::default()
        .plugin(tauri_plugin_positioner::init())
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_dialog::init())
        .manage(app_state)
        .invoke_handler(tauri::generate_handler![
            save_note,
            get_notes,
            update_note_favorite,
            delete_note,
            copy_to_clipboard,
            get_port_info
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
