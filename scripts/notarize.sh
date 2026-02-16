#!/bin/bash

# Micro Note アプリの公証（Notarization）スクリプト
# 使用方法: ./notarize.sh

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

# アプリのパス
APP_PATH="src-tauri/target/release/bundle/macos/Micro Note.app"
APP_NAME="Micro Note"

echo -e "${BLUE}=== Micro Note アプリ公証スクリプト ===${NC}"

# 環境変数のチェック
check_env_vars() {
    echo -e "${YELLOW}環境変数をチェック中...${NC}"

    if [ -z "$APPLE_ID" ]; then
        echo -e "${RED}エラー: APPLE_ID が設定されていません${NC}"
        echo "export APPLE_ID=\"your-apple-id@example.com\""
        exit 1
    fi

    if [ -z "$APPLE_PASSWORD" ]; then
        echo -e "${RED}エラー: APPLE_PASSWORD が設定されていません${NC}"
        echo "export APPLE_PASSWORD=\"your-app-specific-password\""
        exit 1
    fi

    if [ -z "$APPLE_TEAM_ID" ]; then
        echo -e "${RED}エラー: APPLE_TEAM_ID が設定されていません${NC}"
        echo "export APPLE_TEAM_ID=\"YOUR_TEAM_ID\""
        exit 1
    fi

    echo -e "${GREEN}✓ 環境変数が正しく設定されています${NC}"
}

# アプリの存在確認
check_app_exists() {
    echo -e "${YELLOW}アプリの存在を確認中...${NC}"

    if [ ! -d "$APP_PATH" ]; then
        echo -e "${RED}エラー: アプリが見つかりません: $APP_PATH${NC}"
        echo "まず 'npm run tauri build' を実行してください"
        exit 1
    fi

    echo -e "${GREEN}✓ アプリが見つかりました${NC}"
}

# ZIPファイルの作成
create_zip() {
    echo -e "${YELLOW}公証用のZIPファイルを作成中...${NC}" >&2

    ZIP_PATH="Micro Note.zip"

    if [ -f "$ZIP_PATH" ]; then
        echo -e "${BLUE}既存のZIPファイルを削除中...${NC}" >&2
        rm "$ZIP_PATH"
    fi

    # 絶対パスを使用してZIPファイルを作成
    FULL_APP_PATH=$(realpath "$APP_PATH")
    FULL_ZIP_PATH="$(pwd)/$ZIP_PATH"

    echo -e "${BLUE}アプリパス: $FULL_APP_PATH${NC}" >&2
    echo -e "${BLUE}ZIPパス: $FULL_ZIP_PATH${NC}" >&2

    echo -e "${YELLOW}ditto コマンドを実行中...${NC}" >&2
    ditto -c -k --keepParent "$FULL_APP_PATH" "$FULL_ZIP_PATH"

    local ditto_exit_code=$?
    echo -e "${BLUE}ditto の終了コード: $ditto_exit_code${NC}" >&2

    if [ $ditto_exit_code -ne 0 ]; then
        echo -e "${RED}エラー: ditto コマンドが失敗しました (終了コード: $ditto_exit_code)${NC}" >&2
        exit 1
    fi

    if [ ! -f "$FULL_ZIP_PATH" ]; then
        echo -e "${RED}エラー: ZIPファイルの作成に失敗しました${NC}" >&2
        echo -e "${RED}アプリパス: $FULL_APP_PATH${NC}" >&2
        echo -e "${RED}ZIPパス: $FULL_ZIP_PATH${NC}" >&2
        exit 1
    fi

    echo -e "${GREEN}✓ ZIPファイルが作成されました: $FULL_ZIP_PATH${NC}" >&2
    echo -e "${BLUE}ファイルサイズ: $(ls -lh "$FULL_ZIP_PATH" | awk '{print $5}')${NC}" >&2

    # 関数の戻り値としてZIPファイルのパスのみを返す
    echo "$FULL_ZIP_PATH"
}

# 公証の送信
submit_for_notarization() {
    local zip_path="$1"

    echo -e "${YELLOW}Appleに公証を送信中...${NC}" >&2
    echo -e "${BLUE}ZIPファイル: $zip_path${NC}" >&2
    echo -e "${BLUE}Apple ID: $APPLE_ID${NC}" >&2
    echo -e "${BLUE}Team ID: $APPLE_TEAM_ID${NC}" >&2
    echo -e "${BLUE}Password: ${APPLE_PASSWORD:0:4}**** (マスク済み)${NC}" >&2

    # 公証の送信（出力を一時ファイルに保存）
    local temp_output=$(mktemp)
    echo -e "${BLUE}一時ファイル: $temp_output${NC}" >&2

    echo -e "${YELLOW}notarytool submit コマンドを実行中...${NC}" >&2
    xcrun notarytool submit "$zip_path" \
        --apple-id "$APPLE_ID" \
        --password "$APPLE_PASSWORD" \
        --team-id "$APPLE_TEAM_ID" \
        --wait \
        --output-format json > "$temp_output" 2>&1

    local exit_code=$?
    echo -e "${BLUE}notarytool submit の終了コード: $exit_code${NC}" >&2

    # 出力内容を表示
    echo -e "${BLUE}=== notarytool submit の出力 ===${NC}" >&2
    cat "$temp_output" >&2
    echo -e "${BLUE}=== 出力終了 ===${NC}" >&2

    # エラーチェック
    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}エラー: 公証の送信に失敗しました (終了コード: $exit_code)${NC}" >&2
        echo -e "${RED}詳細なエラー情報:${NC}" >&2
        cat "$temp_output" >&2
        rm "$temp_output"
        echo -e "${RED}=== 公証送信で失敗しました ===${NC}" >&2
        exit 1
    fi

    # JSONからRequest UUIDとステータスを抽出
    echo -e "${YELLOW}Request UUIDとステータスを抽出中...${NC}" >&2
    local request_uuid=$(jq -r '.id' "$temp_output" 2>/dev/null)
    local status=$(jq -r '.status' "$temp_output" 2>/dev/null)
    echo -e "${BLUE}抽出されたRequest UUID: $request_uuid${NC}" >&2
    echo -e "${BLUE}抽出されたステータス: $status${NC}" >&2

    if [ -z "$request_uuid" ] || [ "$request_uuid" = "null" ]; then
        echo -e "${RED}エラー: Request UUIDの取得に失敗しました${NC}" >&2
        echo -e "${BLUE}jqのエラー出力:${NC}" >&2
        jq -r '.id' "$temp_output" 2>&1 || true
        rm "$temp_output"
        exit 1
    fi

    if [ "$status" = "Accepted" ]; then
        echo -e "${GREEN}✓ 公証が承認されました！Request UUID: $request_uuid${NC}" >&2
    else
        echo -e "${YELLOW}公証のステータス: $status${NC}" >&2
    fi

    rm "$temp_output"
    echo "$request_uuid"
}

# 公証の結果確認
check_notarization_status() {
    local request_uuid="$1"

    echo -e "${YELLOW}公証の結果を確認中...${NC}" >&2
    echo -e "${BLUE}Request UUID: $request_uuid${NC}" >&2

    # 公証結果の確認（出力を一時ファイルに保存）
    local temp_output=$(mktemp)
    echo -e "${BLUE}一時ファイル: $temp_output${NC}" >&2

    echo -e "${YELLOW}notarytool info コマンドを実行中...${NC}" >&2
    xcrun notarytool info "$request_uuid" \
        --apple-id "$APPLE_ID" \
        --password "$APPLE_PASSWORD" \
        --team-id "$APPLE_TEAM_ID" \
        --output-format json > "$temp_output" 2>&1

    local exit_code=$?
    echo -e "${BLUE}notarytool info の終了コード: $exit_code${NC}" >&2

    # 出力内容を表示
    echo -e "${BLUE}=== notarytool info の出力 ===${NC}" >&2
    cat "$temp_output" >&2
    echo -e "${BLUE}=== 出力終了 ===${NC}" >&2

    # エラーチェック
    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}エラー: 公証結果の確認に失敗しました (終了コード: $exit_code)${NC}" >&2
        rm "$temp_output"
        return 1
    fi

    # JSONからステータスを抽出
    echo -e "${YELLOW}ステータスを抽出中...${NC}" >&2
    local status=$(jq -r '.status' "$temp_output" 2>/dev/null)
    echo -e "${BLUE}抽出されたステータス: $status${NC}" >&2

    if [ "$status" = "Accepted" ]; then
        echo -e "${GREEN}✓ 公証が承認されました！${NC}" >&2
        rm "$temp_output"
        return 0
    else
        echo -e "${RED}エラー: 公証が拒否されました。Status: $status${NC}" >&2
        echo -e "${BLUE}jqのエラー出力:${NC}" >&2
        jq -r '.status' "$temp_output" 2>&1 || true
        rm "$temp_output"
        return 1
    fi
}

# 公証の結果をアプリに添付
staple_notarization() {
    echo -e "${YELLOW}公証の結果をアプリに添付中...${NC}"
    echo -e "${BLUE}アプリパス: $APP_PATH${NC}"

    echo -e "${YELLOW}stapler staple コマンドを実行中...${NC}"
    xcrun stapler staple "$APP_PATH"

    local exit_code=$?
    echo -e "${BLUE}stapler staple の終了コード: $exit_code${NC}"

    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ 公証の結果がアプリに添付されました${NC}"
    else
        echo -e "${RED}エラー: 公証の結果の添付に失敗しました (終了コード: $exit_code)${NC}"
        exit 1
    fi
}

# 最終確認
final_verification() {
    echo -e "${YELLOW}最終確認中...${NC}"
    echo -e "${BLUE}アプリパス: $APP_PATH${NC}"

    # Gatekeeperの確認
    echo -e "${YELLOW}Gatekeeperの確認中...${NC}"
    local gatekeeper_result=$(spctl -a -v "$APP_PATH" 2>&1)
    echo -e "${BLUE}Gatekeeperの結果: $gatekeeper_result${NC}"

    if echo "$gatekeeper_result" | grep -q "accepted"; then
        echo -e "${GREEN}✓ Gatekeeperがアプリを承認しました${NC}"
    else
        echo -e "${YELLOW}⚠ Gatekeeperがアプリを承認していません${NC}"
    fi

    # 公証の確認
    echo -e "${YELLOW}公証の確認中...${NC}"
    local staple_result=$(xcrun stapler validate "$APP_PATH" 2>&1)
    echo -e "${BLUE}公証の確認結果: $staple_result${NC}"

    if echo "$staple_result" | grep -q "valid"; then
        echo -e "${GREEN}✓ 公証が有効です${NC}"
    else
        echo -e "${YELLOW}⚠ 公証が無効または確認できません${NC}"
    fi
}

# クリーンアップ
cleanup() {
    echo -e "${YELLOW}クリーンアップ中...${NC}"

    if [ -f "Micro Note.zip" ]; then
        echo -e "${BLUE}ZIPファイルを削除中: Micro Note.zip${NC}"
        rm "Micro Note.zip"
        echo -e "${GREEN}✓ 一時ファイルを削除しました${NC}"
    else
        echo -e "${BLUE}削除するZIPファイルはありません${NC}"
    fi
}

# メイン処理
main() {
    echo -e "${BLUE}公証プロセスを開始します...${NC}"

    # 環境変数のチェック
    echo -e "${YELLOW}=== ステップ 1: 環境変数のチェック ===${NC}"
    check_env_vars
    echo -e "${GREEN}✓ ステップ 1 完了${NC}"

    # アプリの存在確認
    echo -e "${YELLOW}=== ステップ 2: アプリの存在確認 ===${NC}"
    check_app_exists
    echo -e "${GREEN}✓ ステップ 2 完了${NC}"

    # ZIPファイルの作成
    echo -e "${YELLOW}=== ステップ 3: ZIPファイルの作成 ===${NC}"
    zip_path=$(create_zip)
    echo -e "${GREEN}✓ ステップ 3 完了: $zip_path${NC}"

    # 公証の送信
    echo -e "${YELLOW}=== ステップ 4: 公証の送信 ===${NC}"
    echo -e "${BLUE}ZIPファイルパス: $zip_path${NC}"
    request_uuid=$(submit_for_notarization "$zip_path")
    echo -e "${GREEN}✓ ステップ 4 完了: $request_uuid${NC}"

    # 公証の結果をアプリに添付
    echo -e "${YELLOW}=== ステップ 5: 公証の結果をアプリに添付 ===${NC}"
    staple_notarization
    echo -e "${GREEN}✓ ステップ 5 完了${NC}"

    # 最終確認
    echo -e "${YELLOW}=== ステップ 6: 最終確認 ===${NC}"
    final_verification
    echo -e "${GREEN}✓ ステップ 6 完了${NC}"

    echo -e "${GREEN}=== 公証が完了しました！ ===${NC}"
    echo -e "${GREEN}アプリは正常に公証され、配布可能です。${NC}"

    # クリーンアップ
    echo -e "${YELLOW}=== ステップ 7: クリーンアップ ===${NC}"
    cleanup
    echo -e "${GREEN}✓ ステップ 7 完了${NC}"
}

# エラーハンドリング
cleanup_on_error() {
    local exit_code=$?
    echo -e "${RED}=== エラーが発生しました (終了コード: $exit_code) ===${NC}"
    echo -e "${RED}スクリプトが異常終了しました${NC}"
    echo -e "${RED}デバッグ情報を保持するため、クリーンアップをスキップします${NC}"
    exit $exit_code
}

# 正常終了時のみクリーンアップを実行
trap cleanup_on_error ERR

# スクリプトの実行
main "$@"
