# Micro Note

![image](image.png)

[日本語版はこちら](README_ja.md)

A desktop note-taking app with a chat-like UI, built with Tauri.

## Features

- **Timeline UI**: Notes are displayed in a chat-style timeline
- **Search**: Full-text search through notes
- **Favorites**: Mark and filter important notes
- **Dark Mode**: Light / dark theme support
- **Preset Themes**: Choose from multiple visual themes or write custom CSS
- **Data Export / Import**: CSV-based backup and restore
- **Multi-language**: English and Japanese
- **Window State Persistence**: Remembers window position and size

## Tech Stack

- **Frontend**: Vue 3 + Vite + Tailwind CSS
- **Backend**: Tauri 2 (Rust)
- **Database**: SQLite
- **i18n**: vue-i18n

## Prerequisites

- [Node.js](https://nodejs.org/) (v20+)
- [Rust](https://www.rust-lang.org/tools/install)
- Tauri v2 prerequisites ([see guide](https://v2.tauri.app/start/prerequisites/))

## Development

```bash
npm install
npm run tauri dev
```

## Build

### macOS (Universal Build)

```bash
npm run tauri build -- --target universal-apple-darwin
```

The built `.app` and `.dmg` files are generated under `src-tauri/target/`.

### Windows

Windows builds are automatically created via GitHub Actions when a new Release is published. The installer is attached to the Release assets.

## License

MIT License
