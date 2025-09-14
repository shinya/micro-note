#!/bin/bash

# 公証設定用のセットアップスクリプト
# 使用方法: ./setup_notarization.sh

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

echo -e "${BLUE}=== Micro Note 公証セットアップスクリプト ===${NC}"

# 環境変数ファイルの作成
create_env_file() {
    echo -e "${YELLOW}環境変数ファイルを作成中...${NC}"

    cat > .env.notarization << EOF
# Apple Developer Program 認証情報
# 以下の値を実際の値に置き換えてください

# Apple ID (例: your-email@example.com)
export APPLE_ID=""

# アプリ専用パスワード (Apple IDの2要素認証で生成)
# https://appleid.apple.com/account/manage で生成してください
export APPLE_PASSWORD=""

# 開発者チームID (Apple Developer Programで確認可能)
# https://developer.apple.com/account/ の Membership セクションで確認
export APPLE_TEAM_ID=""
EOF

    echo -e "${GREEN}✓ .env.notarization ファイルが作成されました${NC}"
}

# 使用方法の説明
show_usage() {
    echo -e "${BLUE}=== 使用方法 ===${NC}"
    echo ""
    echo -e "${YELLOW}1. 環境変数の設定:${NC}"
    echo "   .env.notarization ファイルを編集して、以下の値を設定してください："
    echo "   - APPLE_ID: あなたのApple ID"
    echo "   - APPLE_PASSWORD: アプリ専用パスワード"
    echo "   - APPLE_TEAM_ID: 開発者チームID"
    echo ""
    echo -e "${YELLOW}2. 環境変数の読み込み:${NC}"
    echo "   source .env.notarization"
    echo ""
    echo -e "${YELLOW}3. 公証の実行:${NC}"
    echo "   ./notarize.sh"
    echo ""
    echo -e "${BLUE}=== 重要な注意事項 ===${NC}"
    echo ""
    echo -e "${RED}• アプリ専用パスワードの作成:${NC}"
    echo "  1. https://appleid.apple.com/account/manage にアクセス"
    echo "  2. サインインして「App-Specific Passwords」セクションに移動"
    echo "  3. 「Generate an app-specific password」をクリック"
    echo "  4. ラベル（例: \"Micro Note Notarization\"）を入力"
    echo "  5. 生成されたパスワードを APPLE_PASSWORD に設定"
    echo ""
    echo -e "${RED}• 開発者チームIDの確認:${NC}"
    echo "  1. https://developer.apple.com/account/ にアクセス"
    echo "  2. サインインして「Membership」セクションに移動"
    echo "  3. Team ID を確認（例: RNGXZZHG98）"
    echo ""
    echo -e "${GREEN}設定が完了したら、'source .env.notarization' を実行してから './notarize.sh' を実行してください。${NC}"
}

# 必要なツールの確認
check_requirements() {
    echo -e "${YELLOW}必要なツールを確認中...${NC}"

    local missing_tools=()

    if ! command -v xcrun &> /dev/null; then
        missing_tools+=("xcrun")
    fi

    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi

    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${RED}エラー: 以下のツールが不足しています:${NC}"
        for tool in "${missing_tools[@]}"; do
            echo "  - $tool"
        done
        echo ""
        echo -e "${YELLOW}インストール方法:${NC}"
        if [[ " ${missing_tools[@]} " =~ " jq " ]]; then
            echo "  jq: brew install jq"
        fi
        echo "  xcrun: Xcode Command Line Tools (xcode-select --install)"
        exit 1
    fi

    echo -e "${GREEN}✓ 必要なツールが揃っています${NC}"
}

# メイン処理
main() {
    # 必要なツールの確認
    check_requirements

    # 環境変数ファイルの作成
    create_env_file

    # 使用方法の説明
    show_usage
}

# スクリプトの実行
main "$@"
