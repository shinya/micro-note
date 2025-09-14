#!/bin/bash

# Micro Note 最終ビルドスクリプト
# 調査結果に基づいた正しいビルド方法

set -e

# 色付きの出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Micro Note 最終ビルドスクリプト ===${NC}"
echo -e "${BLUE}調査結果に基づいた正しいビルド方法${NC}"
echo ""

# ステップ1: 設定ファイルの確認
echo -e "${YELLOW}=== ステップ 1: 設定ファイルの確認 ===${NC}"
echo -e "${BLUE}tauri.conf.jsonの構文を確認中...${NC}"
if jq empty src-tauri/tauri.conf.json 2>/dev/null; then
    echo -e "${GREEN}✓ tauri.conf.jsonの構文は正しいです${NC}"
else
    echo -e "${RED}❌ tauri.conf.jsonに構文エラーがあります${NC}"
    exit 1
fi

# bundle.resourcesの設定確認
if jq -e '.bundle.resources' src-tauri/tauri.conf.json >/dev/null; then
    echo -e "${GREEN}✓ bundle.resourcesが設定されています${NC}"
else
    echo -e "${RED}❌ bundle.resourcesが設定されていません${NC}"
    exit 1
fi
echo ""

# ステップ2: フロントエンドのビルド
echo -e "${YELLOW}=== ステップ 2: フロントエンドのビルド ===${NC}"
echo -e "${BLUE}フロントエンドをビルド中...${NC}"
npm run build
echo -e "${GREEN}✓ フロントエンドのビルドが完了しました${NC}"

# フロントエンドファイルの確認
if [ -f "dist/index.html" ]; then
    echo -e "${GREEN}✓ index.htmlが存在します${NC}"
else
    echo -e "${RED}❌ index.htmlが見つかりません${NC}"
    exit 1
fi
echo ""

# ステップ3: Tauriアプリのビルド
echo -e "${YELLOW}=== ステップ 3: Tauriアプリのビルド ===${NC}"
echo -e "${BLUE}Tauriアプリをビルド中...${NC}"
npm run tauri build
echo -e "${GREEN}✓ Tauriアプリのビルドが完了しました${NC}"

# フロントエンドファイルのバンドル確認
echo -e "${BLUE}フロントエンドファイルのバンドルを確認中...${NC}"
APP_PATH="src-tauri/target/release/bundle/macos/Micro Note.app"
if find "$APP_PATH" -name "*.html" | grep -q "index.html"; then
    echo -e "${GREEN}✓ フロントエンドファイルが正しくバンドルされています${NC}"
else
    echo -e "${RED}❌ フロントエンドファイルがバンドルされていません${NC}"
    exit 1
fi
echo ""

# ステップ4: 公証の実行（環境変数が設定されている場合）
echo -e "${YELLOW}=== ステップ 4: 公証の実行 ===${NC}"
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
echo ""

# ステップ5: 最終確認
echo -e "${YELLOW}=== ステップ 5: 最終確認 ===${NC}"
echo -e "${BLUE}アプリの状態を確認中...${NC}"
./verify_app.sh
echo ""

# ステップ6: アプリのテスト
echo -e "${YELLOW}=== ステップ 6: アプリのテスト ===${NC}"
echo -e "${BLUE}アプリを起動してテスト中...${NC}"
open "$APP_PATH"
sleep 3

# プロセスの確認
if ps aux | grep "Micro Note" | grep -v grep >/dev/null; then
    echo -e "${GREEN}✅ アプリが正常に起動しています！${NC}"
else
    echo -e "${YELLOW}⚠️  アプリが起動していない可能性があります${NC}"
    echo -e "${BLUE}コマンドラインから実行してみてください：${NC}"
    echo -e "${BLUE}  \"$APP_PATH/Contents/MacOS/tauri-app\"${NC}"
fi
echo ""

echo -e "${GREEN}=== ビルド完了 ===${NC}"
echo -e "${GREEN}アプリパス: $APP_PATH${NC}"
echo -e "${GREEN}DMGパス: src-tauri/target/release/bundle/dmg/Micro Note_0.1.0_aarch64.dmg${NC}"
echo ""
echo -e "${BLUE}=== 使用方法 ===${NC}"
echo -e "${BLUE}1. アプリを起動: open \"$APP_PATH\"${NC}"
echo -e "${BLUE}2. DMGをマウント: open \"src-tauri/target/release/bundle/dmg/Micro Note_0.1.0_aarch64.dmg\"${NC}"
echo -e "${BLUE}3. アプリの状態確認: ./verify_app.sh${NC}"
