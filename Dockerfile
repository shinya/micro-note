FROM node:18-alpine

# 必要なパッケージをインストール
RUN apk add --no-cache \
    git \
    curl \
    wget \
    ca-certificates \
    build-base \
    python3 \
    pkgconfig \
    libffi-dev \
    openssl-dev \
    cargo \
    rust

# 作業ディレクトリを設定
WORKDIR /app

# package.jsonとpackage-lock.jsonをコピー
COPY package*.json ./

# 依存関係をインストール
RUN npm ci

# ソースコードをコピー
COPY . .

# 開発サーバーのポートを公開
EXPOSE 1420

# 開発サーバーを起動
CMD ["npm", "run", "tauri", "dev"]
