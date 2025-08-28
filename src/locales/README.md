# 言語ファイル追加ガイド

このディレクトリには、アプリケーションの多言語対応用の言語ファイルが格納されています。

## ディレクトリ構造

```
src/locales/
├── en/          # 英語（ベース言語）
│   └── index.js
├── ja/          # 日本語
│   └── index.js
└── README.md    # このファイル
```

## 新しい言語を追加する手順

### 1. 言語ディレクトリを作成

```bash
mkdir src/locales/[言語コード]
```

例：フランス語の場合

```bash
mkdir src/locales/fr
```

### 2. 言語ファイルを作成

`src/locales/[言語コード]/index.js` を作成し、以下の構造で翻訳を追加：

```javascript
export default {
  // Common
  common: {
    save: "保存",
    cancel: "キャンセル",
    // ... 他の翻訳
  },

  // Navigation
  navigation: {
    chat: "チャット",
    notes: "メモ一覧",
    settings: "設定",
  },

  // ... 他のセクション
};
```

### 3. i18n 設定を更新

`src/i18n/index.js` を編集：

```javascript
// 1. 言語ファイルをインポート
import fr from "../locales/fr";

// 2. サポートされている言語に追加
export const supportedLocales = {
  en: "English",
  ja: "日本語",
  fr: "Français", // 追加
};

// 3. メッセージに追加
const messages = {
  en,
  ja,
  fr, // 追加
};
```

### 4. 設定画面に言語オプションを追加

`src/components/SettingsView.vue` の言語選択部分に新しい言語を追加：

```html
<select v-model="currentLanguage" @change="changeLanguage">
  <option value="en">{{ $t('settings.languages.en') }}</option>
  <option value="ja">{{ $t('settings.languages.ja') }}</option>
  <option value="fr">{{ $t('settings.languages.fr') }}</option>
  <!-- 追加 -->
</select>
```

### 5. 言語名の翻訳を追加

各言語ファイルの `settings.languages` セクションに新しい言語名を追加：

```javascript
// 英語ファイル (en/index.js)
settings: {
  languages: {
    en: 'English',
    ja: 'Japanese',
    fr: 'French'  // 追加
  }
}

// 日本語ファイル (ja/index.js)
settings: {
  languages: {
    en: 'English',
    ja: '日本語',
    fr: 'フランス語'  // 追加
  }
}

// フランス語ファイル (fr/index.js)
settings: {
  languages: {
    en: 'Anglais',
    ja: 'Japonais',
    fr: 'Français'  // 追加
  }
}
```

## 翻訳のベストプラクティス

1. **一貫性を保つ**: 同じ概念には同じ翻訳を使用
2. **コンテキストを考慮**: 文脈に応じて適切な翻訳を選択
3. **プレースホルダーを使用**: 動的な値には `{variable}` 形式を使用
4. **複数形に対応**: 必要に応じて複数形の翻訳を提供
5. **テストする**: 実際のアプリケーションで翻訳をテスト

## 言語コード

- `en`: 英語 (English)
- `ja`: 日本語 (Japanese)
- `fr`: フランス語 (French)
- `de`: ドイツ語 (German)
- `es`: スペイン語 (Spanish)
- `zh`: 中国語 (Chinese)
- `ko`: 韓国語 (Korean)

## 注意事項

- ベース言語（英語）の翻訳キーを基準として、他の言語ファイルも同じ構造を維持してください
- 新しい翻訳キーを追加する場合は、すべての言語ファイルに追加してください
- 翻訳が見つからない場合は、フォールバックとして英語が使用されます
