# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Micro Note is a desktop note-taking app with a chat-like UI, built with **Vue 3 + Tauri (Rust)** and **SQLite** for local storage. It supports dark mode, i18n (English/Japanese), CSS theme customization, and favorites.

## Commands

```bash
npm install              # Install frontend dependencies
npm run tauri dev        # Run app in development mode (Vite dev server on port 1420 + Tauri window)
npm run tauri build      # Build production desktop app (output: src-tauri/target/release/bundle/)
npm run dev              # Start Vite dev server only (no Tauri window)
npm run build            # Build frontend only
```

## Architecture

### Frontend (`src/`)
- **App.vue** — Root component with header (logo + gear icon), settings loading from localStorage, renders TimelineView + SettingsModal
- **components/TimelineView.vue** — Unified timeline: input area (chat-style), search/filter bar, note list with copy/favorite/delete actions on each card
- **components/SettingsModal.vue** — Modal wrapper around SettingsView (backdrop, Escape to close, scroll lock)
- **components/SettingsView.vue** — Theme presets, custom CSS editor, dark mode, language selection, CSV export/import
- **components/WindowBar.vue** — Custom frameless window title bar (macOS-style)
- **stores/noteStore.js** — Composable store (Vue 3 Composition API) wrapping Tauri `invoke` calls; falls back to mock data outside Tauri
- **i18n/index.js** + **locales/{en,ja}/index.js** — vue-i18n setup with browser locale detection

### Backend (`src-tauri/`)
- **src/lib.rs** — All backend logic: SQLite init (using `app_data_dir()`), Tauri commands (`save_note`, `get_notes`, `update_note_favorite`, `delete_note`, `copy_to_clipboard`, `import_notes`)
- **src/main.rs** — Minimal entry point calling lib.rs
- **tauri.conf.json** — App config: frameless transparent window (800x600), dev server URL, bundle settings

### Database Schema (SQLite, auto-created)
```sql
CREATE TABLE notes (
    id TEXT PRIMARY KEY,        -- UUID
    content TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    is_favorite INTEGER NOT NULL DEFAULT 0
);
```

### Key Patterns
- Settings (theme, dark mode, language, custom CSS) are persisted in **localStorage**, not the database
- The Tauri window is **frameless with custom decorations** — WindowBar.vue handles drag and close/minimize
- Frontend communicates with Rust via `invoke()` from `@tauri-apps/api/core` (Tauri v2 path)
- Rust dependencies use `tauri::State<AppState>` to share the SQLite connection across commands
- `tauri-plugin-window-state` persists window position/size across restarts
- Windows builds are automated via GitHub Actions on Release creation (`.github/workflows/build-windows.yml`)
