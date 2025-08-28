# Micro Note

チャットのような UI でメモを保存・管理するデスクトップアプリケーションです。

## 機能

- **チャット画面**: メッセージを入力してメモとして保存
- **メモ一覧画面**: 保存されたメモを時系列で表示
- **検索機能**: メモの内容を検索
- **お気に入り機能**: 重要なメモをお気に入りに登録
- **コピー機能**: メモの内容をクリップボードにコピー
- **CSS カスタマイズ**: チャット UI の見た目を自由に調整
- **SQLite 保存**: ローカルデータベースでメモを永続化

## 技術スタック

- **フロントエンド**: Vue 3 + Vite + Tailwind CSS
- **バックエンド**: Tauri (Rust)
- **データベース**: SQLite
- **開発環境**: Docker
- **UI**: モダンなグラデーションデザイン + アニメーション

## セットアップ

### 前提条件

- Docker
- Docker Compose

### 開発環境の起動

1. リポジトリをクローン

```bash
git clone https://github.com/shinya/micro-note.git
cd micro-note
```

2. Docker コンテナを起動

```bash
docker-compose up --build
```

3. ブラウザで `http://localhost:1420` にアクセス

### ローカル開発

1. 依存関係をインストール

```bash
npm install
```

2. アプリを起動

```bash
npm run tauri dev
```

## 使用方法

### チャット画面

- テキストエリアにメモしたい内容を入力
- **Enter キー**でメモを送信
- **Shift + Enter**で改行
- 送信ボタンでも送信可能

### メモ一覧画面

- 保存されたメモを時系列で表示
- 検索ボックスでメモを検索
- お気に入りボタンでメモをお気に入りに登録
- コピーボタンでメモの内容をクリップボードにコピー

### 設定画面

- **プリセットテーマ**: モダン、ミニマルなどから選択
- **カスタム CSS**: チャット UI の見た目を自由にカスタマイズ
- **設定の永続化**: カスタマイズした設定は自動保存
- **モード切替**: ダークモードやチャット部分の UI の向きを逆転可能

## CSS カスタマイズ例

### モダンテーマ

```css
.chat-message {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 20px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}
```

### ミニマルテーマ

```css
.chat-message {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  margin: 16px 0;
}
```

## ビルド

### デスクトップアプリケーション

```bash
npm run tauri build
```

ビルドされたアプリケーションは `src-tauri/target/release/` ディレクトリに生成されます。

### アプリケーションの起動

#### 方法 1: アプリケーションファイルから起動

```bash
open /path/to/micro-note/src-tauri/target/release/bundle/macos/Micro\ Note.app
```

#### 方法 2: ターミナルから直接起動

```bash
/path/to/micro-note/src-tauri/target/release/tauri-app
```

#### 方法 3: DMG ファイルからインストール

1. `src-tauri/target/release/bundle/dmg/Micro Note_0.1.0_aarch64.dmg` をダブルクリック
2. マウントされたディスクイメージから `Micro Note.app` を `Applications` フォルダにドラッグ&ドロップ
3. `Applications` フォルダから `Micro Note.app` を起動

### トラブルシューティング

#### アプリが起動しない場合

**推奨される起動方法：**

1. **ターミナルから直接起動**（最も確実）

   ```bash
   /path/to/micro-note/src-tauri/target/release/tauri-app
   ```

2. **アプリケーションファイルから起動**

   - アプリを起動した時に表示されるセキュリティダイアログで「許可」をクリック
   - または **システム設定** → **プライバシーとセキュリティ** でアプリケーションの許可設定を確認

3. **開発モードで起動**（デバッグ用）
   ```bash
   npm run tauri dev
   ```

**注意：** アプリは正常に動作していますが、GUI ウィンドウの表示に問題がある場合があります。ターミナルから起動することを推奨します。

## ライセンス

MIT License
