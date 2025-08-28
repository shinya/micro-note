// Prevents additional console window on Windows in release, DO NOT REMOVE!!
// Temporarily disabled for debugging
// #![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    tauri_app_lib::run()
}
