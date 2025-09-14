#!/bin/bash

# Micro Note アプリの署名・公証確認スクリプト
# 使用方法: ./verify_app.sh [アプリパス]

set -e

# 色付きの出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# デフォルトのアプリパス
DEFAULT_APP_PATH="src-tauri/target/release/bundle/macos/Micro Note.app"

# アプリパスの設定
if [ $# -eq 0 ]; then
    APP_PATH="$DEFAULT_APP_PATH"
else
    APP_PATH="$1"
fi

echo -e "${BLUE}=== Micro Note アプリ署名・公証確認スクリプト ===${NC}"
echo -e "${BLUE}アプリパス: $APP_PATH${NC}"
echo ""

# アプリの存在確認
check_app_exists() {
    echo -e "${YELLOW}=== 1. アプリの存在確認 ===${NC}"

    if [ ! -d "$APP_PATH" ]; then
        echo -e "${RED}❌ エラー: アプリが見つかりません${NC}"
        echo -e "${RED}   パス: $APP_PATH${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ アプリが見つかりました${NC}"

    # アプリの基本情報
    local app_size=$(du -sh "$APP_PATH" | cut -f1)
    echo -e "${BLUE}   サイズ: $app_size${NC}"

    # 実行ファイルの確認
    local executable_path="$APP_PATH/Contents/MacOS/tauri-app"
    if [ -f "$executable_path" ]; then
        echo -e "${GREEN}✅ 実行ファイルが見つかりました${NC}"
        local exec_size=$(ls -lh "$executable_path" | awk '{print $5}')
        echo -e "${BLUE}   実行ファイルサイズ: $exec_size${NC}"
    else
        echo -e "${RED}❌ 実行ファイルが見つかりません${NC}"
        exit 1
    fi
    echo ""
}

# コード署名の確認
check_code_signing() {
    echo -e "${YELLOW}=== 2. コード署名の確認 ===${NC}"

    # アプリバンドルの署名確認
    echo -e "${CYAN}アプリバンドルの署名情報:${NC}"
    local bundle_signature=$(codesign -dv "$APP_PATH" 2>&1)
    echo "$bundle_signature"
    echo ""

    # 実行ファイルの署名確認
    echo -e "${CYAN}実行ファイルの署名情報:${NC}"
    local exec_path="$APP_PATH/Contents/MacOS/tauri-app"
    local exec_signature=$(codesign -dv "$exec_path" 2>&1)
    echo "$exec_signature"
    echo ""

    # 署名の詳細確認
    echo -e "${CYAN}署名の詳細情報:${NC}"
    codesign -dvvv "$APP_PATH" 2>&1 | while read line; do
        echo "   $line"
    done
    echo ""

    # 署名の検証
    echo -e "${CYAN}署名の検証:${NC}"
    if codesign --verify --deep --strict "$APP_PATH" 2>/dev/null; then
        echo -e "${GREEN}✅ 署名が有効です${NC}"
    else
        echo -e "${RED}❌ 署名の検証に失敗しました${NC}"
        codesign --verify --deep --strict "$APP_PATH" 2>&1 | while read line; do
            echo -e "${RED}   $line${NC}"
        done
    fi
    echo ""
}

# 公証の確認
check_notarization() {
    echo -e "${YELLOW}=== 3. 公証の確認 ===${NC}"

    # stapler validate で公証の確認
    echo -e "${CYAN}公証の検証:${NC}"
    local staple_result=$(xcrun stapler validate "$APP_PATH" 2>&1)
    echo "$staple_result"

    if echo "$staple_result" | grep -q "valid"; then
        echo -e "${GREEN}✅ 公証が有効です${NC}"
    else
        echo -e "${YELLOW}⚠️  公証の状態を確認中...${NC}"
    fi
    echo ""

    # 公証の詳細情報
    echo -e "${CYAN}公証の詳細情報:${NC}"
    xcrun stapler validate "$APP_PATH" 2>&1 | while read line; do
        echo "   $line"
    done
    echo ""
}

# Gatekeeperの確認
check_gatekeeper() {
    echo -e "${YELLOW}=== 4. Gatekeeperの確認 ===${NC}"

    echo -e "${CYAN}Gatekeeperの検証:${NC}"
    local gatekeeper_result=$(spctl -a -v "$APP_PATH" 2>&1)
    echo "$gatekeeper_result"

    if echo "$gatekeeper_result" | grep -q "accepted"; then
        echo -e "${GREEN}✅ Gatekeeperがアプリを承認しています${NC}"
    elif echo "$gatekeeper_result" | grep -q "rejected"; then
        echo -e "${RED}❌ Gatekeeperがアプリを拒否しています${NC}"
    else
        echo -e "${YELLOW}⚠️  Gatekeeperの状態が不明です${NC}"
    fi
    echo ""
}

# 証明書の確認
check_certificates() {
    echo -e "${YELLOW}=== 5. 証明書の確認 ===${NC}"

    echo -e "${CYAN}署名に使用された証明書:${NC}"
    local cert_info=$(codesign -d --extract-certificates "$APP_PATH" 2>/dev/null && security find-certificate -a -c "Developer ID Application" 2>/dev/null | head -20)
    if [ -n "$cert_info" ]; then
        echo "$cert_info"
    else
        echo -e "${YELLOW}   証明書情報の取得に失敗しました${NC}"
    fi
    echo ""

    # 証明書の有効性確認
    echo -e "${CYAN}証明書の有効性:${NC}"
    if codesign --verify --deep --strict "$APP_PATH" 2>/dev/null; then
        echo -e "${GREEN}✅ 証明書が有効です${NC}"
    else
        echo -e "${RED}❌ 証明書に問題があります${NC}"
    fi
    echo ""
}

# アプリの詳細情報
show_app_details() {
    echo -e "${YELLOW}=== 6. アプリの詳細情報 ===${NC}"

    # Info.plistの情報
    echo -e "${CYAN}アプリ情報 (Info.plist):${NC}"
    local info_plist="$APP_PATH/Contents/Info.plist"
    if [ -f "$info_plist" ]; then
        echo -e "${BLUE}   バンドルID: $(defaults read "$info_plist" CFBundleIdentifier 2>/dev/null || echo "取得失敗")${NC}"
        echo -e "${BLUE}   バージョン: $(defaults read "$info_plist" CFBundleShortVersionString 2>/dev/null || echo "取得失敗")${NC}"
        echo -e "${BLUE}   ビルド番号: $(defaults read "$info_plist" CFBundleVersion 2>/dev/null || echo "取得失敗")${NC}"
        echo -e "${BLUE}   アプリ名: $(defaults read "$info_plist" CFBundleName 2>/dev/null || echo "取得失敗")${NC}"
    else
        echo -e "${RED}   Info.plistが見つかりません${NC}"
    fi
    echo ""

    # アプリの構造
    echo -e "${CYAN}アプリの構造:${NC}"
    find "$APP_PATH" -type f -name "*.dylib" -o -name "*.framework" -o -name "*.bundle" | head -10 | while read file; do
        echo -e "${BLUE}   $file${NC}"
    done
    echo ""
}

# 総合評価
final_assessment() {
    echo -e "${YELLOW}=== 7. 総合評価 ===${NC}"

    local all_good=true

    # 署名の確認
    if ! codesign --verify --deep --strict "$APP_PATH" 2>/dev/null; then
        echo -e "${RED}❌ 署名に問題があります${NC}"
        all_good=false
    else
        echo -e "${GREEN}✅ 署名: OK${NC}"
    fi

    # 公証の確認
    local staple_result=$(xcrun stapler validate "$APP_PATH" 2>&1)
    if ! echo "$staple_result" | grep -q "valid"; then
        echo -e "${RED}❌ 公証に問題があります${NC}"
        all_good=false
    else
        echo -e "${GREEN}✅ 公証: OK${NC}"
    fi

    # Gatekeeperの確認
    local gatekeeper_result=$(spctl -a -v "$APP_PATH" 2>&1)
    if ! echo "$gatekeeper_result" | grep -q "accepted"; then
        echo -e "${RED}❌ Gatekeeperが承認していません${NC}"
        all_good=false
    else
        echo -e "${GREEN}✅ Gatekeeper: OK${NC}"
    fi

    echo ""
    if [ "$all_good" = true ]; then
        echo -e "${GREEN}🎉 アプリは正常に署名・公証されています！${NC}"
        echo -e "${GREEN}   配布可能な状態です。${NC}"
    else
        echo -e "${RED}⚠️  アプリに問題があります。${NC}"
        echo -e "${RED}   配布前に問題を解決してください。${NC}"
    fi
    echo ""
}

# 使用方法の表示
show_usage() {
    echo -e "${BLUE}使用方法:${NC}"
    echo -e "${BLUE}  $0 [アプリパス]${NC}"
    echo ""
    echo -e "${BLUE}例:${NC}"
    echo -e "${BLUE}  $0                                    # デフォルトパスを使用${NC}"
    echo -e "${BLUE}  $0 \"path/to/Micro Note.app\"         # 指定パスを使用${NC}"
    echo ""
}

# メイン処理
main() {
    # 引数の確認
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_usage
        exit 0
    fi

    echo -e "${PURPLE}アプリの署名・公証状態を確認します...${NC}"
    echo ""

    # 各チェックを実行
    check_app_exists
    check_code_signing
    check_notarization
    check_gatekeeper
    check_certificates
    show_app_details
    final_assessment

    echo -e "${BLUE}=== 確認完了 ===${NC}"
}

# スクリプトの実行
main "$@"
