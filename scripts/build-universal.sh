#!/bin/bash

# Micro Note Universal Build Script
# Intel Mac と Apple Silicon Mac の両方に対応するユニバーサルビルドを作成

set -e  # エラー時に停止

# スクリプトのディレクトリを取得し、プロジェクトルートに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# 色付きのログ出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 環境変数ファイルの確認
if [ ! -f ".env.notarization" ]; then
    log_error ".env.notarization ファイルが見つかりません"
    log_info "署名と公証のための環境変数を設定してください"
    exit 1
fi

# 環境変数を読み込み
source .env.notarization

# 必要な環境変数の確認
if [ -z "$APPLE_ID" ] || [ -z "$APPLE_PASSWORD" ] || [ -z "$APPLE_TEAM_ID" ]; then
    log_error "必要な環境変数が設定されていません"
    log_info "APPLE_ID, APPLE_PASSWORD, APPLE_TEAM_ID を設定してください"
    exit 1
fi

log_info "ユニバーサルビルドを開始します..."

# フロントエンドのビルド
log_info "フロントエンドをビルド中..."
npm run build

if [ $? -ne 0 ]; then
    log_error "フロントエンドのビルドに失敗しました"
    exit 1
fi

log_success "フロントエンドのビルドが完了しました"

# ユニバーサルビルドの実行
log_info "ユニバーサルビルドを実行中..."
npm run tauri build -- --target universal-apple-darwin

if [ $? -ne 0 ]; then
    log_error "ユニバーサルビルドに失敗しました"
    exit 1
fi

log_success "ユニバーサルビルドが完了しました"

# ビルド結果の確認
APP_PATH="src-tauri/target/universal-apple-darwin/release/bundle/macos/Micro Note.app"
DMG_PATH="src-tauri/target/universal-apple-darwin/release/bundle/dmg/Micro Note_0.1.1_universal.dmg"

if [ -d "$APP_PATH" ]; then
    log_success "アプリバンドルが作成されました: $APP_PATH"

    # アーキテクチャの確認
    log_info "アーキテクチャを確認中..."
    file "$APP_PATH/Contents/MacOS/tauri-app"

    # 署名の確認
    log_info "署名を確認中..."
    codesign -dv --verbose=4 "$APP_PATH"

    # 公証の確認
    log_info "公証を確認中..."
    spctl -a -v "$APP_PATH"

else
    log_error "アプリバンドルが見つかりません: $APP_PATH"
    exit 1
fi

if [ -f "$DMG_PATH" ]; then
    log_success "DMGファイルが作成されました: $DMG_PATH"

    # DMGの署名確認
    log_info "DMGの署名を確認中..."
    codesign -dv --verbose=4 "$DMG_PATH"

else
    log_warning "DMGファイルが見つかりません: $DMG_PATH"
fi

# ビルド結果のサマリー
log_success "=== ビルド完了 ==="
log_info "アプリバンドル: $APP_PATH"
if [ -f "$DMG_PATH" ]; then
    log_info "DMGファイル: $DMG_PATH"
fi

# ファイルサイズの表示
if [ -d "$APP_PATH" ]; then
    APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
    log_info "アプリサイズ: $APP_SIZE"
fi

if [ -f "$DMG_PATH" ]; then
    DMG_SIZE=$(du -sh "$DMG_PATH" | cut -f1)
    log_info "DMGサイズ: $DMG_SIZE"
fi

log_success "ユニバーサルビルドが正常に完了しました！"
log_info "Intel Mac と Apple Silicon Mac の両方で動作します"
