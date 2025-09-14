#!/bin/bash

# Micro Note 完全ビルドスクリプト
# フロントエンドファイルを含む完全なアプリをビルドし、署名・公証を行う

set -e

# スクリプトのディレクトリを取得し、プロジェクトルートに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# 色付きの出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Micro Note 完全ビルドスクリプト ===${NC}"

# ステップ1: フロントエンドのビルド
echo -e "${YELLOW}=== ステップ 1: フロントエンドのビルド ===${NC}"
npm run build
echo -e "${GREEN}✓ フロントエンドのビルドが完了しました${NC}"

# ステップ2: Tauriアプリのビルド
echo -e "${YELLOW}=== ステップ 2: Tauriアプリのビルド ===${NC}"
npm run tauri build
echo -e "${GREEN}✓ Tauriアプリのビルドが完了しました${NC}"

# ステップ3: フロントエンドファイルの手動コピー
echo -e "${YELLOW}=== ステップ 3: フロントエンドファイルの手動コピー ===${NC}"
APP_PATH="src-tauri/target/release/bundle/macos/Micro Note.app"
RESOURCES_PATH="$APP_PATH/Contents/Resources"

if [ -d "$RESOURCES_PATH" ]; then
    echo -e "${BLUE}フロントエンドファイルをコピー中...${NC}"
    cp -r dist/* "$RESOURCES_PATH/"
    echo -e "${GREEN}✓ フロントエンドファイルのコピーが完了しました${NC}"
else
    echo -e "${RED}❌ リソースディレクトリが見つかりません: $RESOURCES_PATH${NC}"
    exit 1
fi

# ステップ4: アプリの再署名
echo -e "${YELLOW}=== ステップ 4: アプリの再署名 ===${NC}"
echo -e "${BLUE}アプリを再署名中...${NC}"
codesign --force --deep --sign "Developer ID Application: SHINYA SAITA (RNGXZZHG98)" "$APP_PATH"
echo -e "${GREEN}✓ アプリの再署名が完了しました${NC}"

# ステップ5: 公証の実行（環境変数が設定されている場合）
echo -e "${YELLOW}=== ステップ 5: 公証の実行 ===${NC}"
if [ -n "$APPLE_ID" ] && [ -n "$APPLE_PASSWORD" ] && [ -n "$APPLE_TEAM_ID" ]; then
    echo -e "${BLUE}公証を実行中...${NC}"
    ./notarize.sh
    echo -e "${GREEN}✓ 公証が完了しました${NC}"
else
    echo -e "${YELLOW}⚠️  公証をスキップします（環境変数が設定されていません）${NC}"
    echo -e "${BLUE}公証を実行するには、以下の環境変数を設定してください：${NC}"
    echo -e "${BLUE}  export APPLE_ID=\"your-apple-id@example.com\"${NC}"
    echo -e "${BLUE}  export APPLE_PASSWORD=\"your-app-specific-password\"${NC}"
    echo -e "${BLUE}  export APPLE_TEAM_ID=\"YOUR_TEAM_ID\"${NC}"
fi

# ステップ6: 最終確認
echo -e "${YELLOW}=== ステップ 6: 最終確認 ===${NC}"
echo -e "${BLUE}アプリの状態を確認中...${NC}"
./verify_app.sh
echo -e "${GREEN}✓ 最終確認が完了しました${NC}"

echo -e "${GREEN}=== ビルド完了 ===${NC}"
echo -e "${GREEN}アプリパス: $APP_PATH${NC}"
echo -e "${GREEN}アプリを起動するには: open \"$APP_PATH\"${NC}"
