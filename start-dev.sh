#!/bin/bash

# 環境変数を設定
export PATH="$HOME/.cargo/bin:$PATH"

# プロジェクトディレクトリに移動
cd "$(dirname "$0")"

# 開発サーバーを起動
npm run tauri dev
