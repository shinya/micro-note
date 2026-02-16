# Micro Note

![image](image.png)

チャットのような UI でメモを保存・管理するデスクトップアプリケーションです。

## 機能

- **タイムライン UI**: メモをチャット風のタイムラインで表示
- **検索**: メモの全文検索
- **お気に入り**: 重要なメモをお気に入りに登録・フィルタリング
- **ダークモード**: ライト / ダークテーマに対応
- **プリセットテーマ**: 複数のビジュアルテーマから選択、またはカスタム CSS を記述可能
- **データエクスポート / インポート**: CSV によるバックアップとリストア
- **多言語対応**: 日本語・英語
- **ウィンドウ状態の保持**: ウィンドウの位置とサイズを記憶

## 技術スタック

- **フロントエンド**: Vue 3 + Vite + Tailwind CSS
- **バックエンド**: Tauri 2 (Rust)
- **データベース**: SQLite
- **i18n**: vue-i18n

## 前提条件

- [Node.js](https://nodejs.org/) (v20+)
- [Rust](https://www.rust-lang.org/tools/install)
- Tauri v2 の前提環境（[ガイド参照](https://v2.tauri.app/start/prerequisites/)）

## 開発

```bash
npm install
npm run tauri dev
```

## ビルド

### macOS（Universal Build）

```bash
npm run tauri build -- --target universal-apple-darwin
```

ビルドされた `.app` と `.dmg` は `src-tauri/target/` 以下に生成されます。

### Windows

Windows ビルドは GitHub Actions により、Release の作成時に自動で実行されます。インストーラーは Release のアセットに添付されます。

## ライセンス

MIT License
