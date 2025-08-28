import { createI18n } from 'vue-i18n'
import en from '../locales/en'
import ja from '../locales/ja'

// サポートされている言語
export const supportedLocales = {
  en: 'English',
  ja: '日本語'
}

// デフォルト言語
export const defaultLocale = 'en'

// 言語ファイルの動的インポート
const messages = {
  en,
  ja
}

// i18nインスタンスの作成
const i18n = createI18n({
  legacy: false, // Composition APIを使用
  locale: defaultLocale,
  fallbackLocale: defaultLocale,
  messages,
  missingWarn: false,
  fallbackWarn: false
})

// 言語を変更する関数
export function setLocale(locale) {
  if (supportedLocales[locale]) {
    i18n.global.locale.value = locale
    localStorage.setItem('micro-note-language', locale)

    // HTMLのlang属性を更新
    document.documentElement.lang = locale

    // グローバル設定を更新
    if (window.microNoteSettings) {
      window.microNoteSettings.language = locale
    }
  }
}

// 保存された言語を読み込む関数
export function loadSavedLocale() {
  const savedLocale = localStorage.getItem('micro-note-language')
  if (savedLocale && supportedLocales[savedLocale]) {
    setLocale(savedLocale)
  } else {
    // ブラウザの言語を検出
    const browserLocale = navigator.language.split('-')[0]
    if (supportedLocales[browserLocale]) {
      setLocale(browserLocale)
    }
  }
}

// 現在の言語を取得する関数
export function getCurrentLocale() {
  return i18n.global.locale.value
}

// 言語名を取得する関数
export function getLocaleName(locale) {
  return supportedLocales[locale] || locale
}

export default i18n
