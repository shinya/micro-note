#!/bin/bash

# Micro Note Windows版ビルド環境セットアップスクリプト
# クロスコンパイルに必要なツールをインストールします

set -e

# スクリプトのディレクトリを取得し、プロジェクトルートに移動
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔧 Micro Note Windows版ビルド環境をセットアップ中..."

# Homebrewのチェック
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrewがインストールされていません"
    echo "   以下のコマンドでインストールしてください:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo "📦 必要なツールをインストール中..."

# mingw-w64のインストール
echo "🔨 mingw-w64をインストール中..."
brew install mingw-w64

# llvmのインストール
echo "🔨 llvmをインストール中..."
brew install llvm

# nsisのインストール
echo "🔨 nsisをインストール中..."
brew install nsis

# RustのWindowsターゲットの追加
echo "🦀 RustのWindowsターゲットを追加中..."
if ! command -v rustup &> /dev/null; then
    echo "📦 rustupをインストール中..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
fi

rustup target add x86_64-pc-windows-gnu

echo "✅ セットアップが完了しました！"
echo ""
echo "📋 インストールされたツール:"
echo "   - mingw-w64: $(x86_64-w64-mingw32-gcc --version | head -n1)"
echo "   - llvm: $(llvm-rc --version 2>&1 | head -n1)"
echo "   - nsis: $(makensis -VERSION)"
echo "   - Rust Windows target: $(rustup target list --installed | grep windows)"
echo ""
echo "🚀 これで ./scripts/build-windows.sh を実行してWindows版をビルドできます！"
