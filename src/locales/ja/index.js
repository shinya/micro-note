export default {
  // Common
  common: {
    save: '保存',
    cancel: 'キャンセル',
    delete: '削除',
    edit: '編集',
    add: '追加',
    search: '検索',
    loading: '読み込み中...',
    error: 'エラー',
    success: '成功',
    confirm: '確認',
    back: '戻る',
    next: '次へ',
    previous: '前へ',
    close: '閉じる',
    open: '開く',
    yes: 'はい',
    no: 'いいえ',
    ok: 'OK',
    copy: 'コピー',
    export: 'エクスポート',
    import: 'インポート',
    reset: 'リセット',
    apply: '適用',
    settings: '設定',
    help: 'ヘルプ',
    about: 'について'
  },

  // Navigation
  navigation: {
    chat: 'チャット',
    notes: 'メモ一覧',
    settings: '設定'
  },

  // Chat
  chat: {
    title: 'チャット',
    subtitle: 'AIとチャットしてメモを保存',
    placeholder: 'メモとして保存したい内容を入力してください...',
    send: '送信',
    newMessage: '新しいメッセージ',
    thinking: 'AIが考え中...',
    saveAsNote: 'メモとして保存',
    noteSaved: 'メモが保存されました',
    noteSaveError: 'メモの保存に失敗しました',
    enterToSend: 'Enter で送信',
    shiftEnterNewline: 'Shift + Enter で改行',
    characterCount: '{count} 文字',
    savedAsNote: 'メモとして保存済み',
    createFirstNote: '最初のメモを作成しましょう',
    createFirstNoteDescription: '下のテキストエリアにメモしたい内容を入力してください',

  },

  // Notes
  notes: {
    title: 'メモ一覧',
    subtitle: '保存されたメモを管理・検索できます',
    searchPlaceholder: 'メモを検索...',
    noNotes: 'メモがありません',
    noNotesMessage: 'チャット画面でメモを作成してみてください',
    noSearchResults: '検索結果がありません',
    noSearchResultsMessage: '別のキーワードで検索してみてください',
    favorite: 'お気に入り',
    unfavorite: 'お気に入り解除',
    copyToClipboard: 'クリップボードにコピー',
    copiedToClipboard: 'クリップボードにコピーしました',
    clickToCopy: 'クリックしてコピー',
    deleteNote: 'メモを削除',
    deleteConfirm: 'このメモを削除しますか？',
    deleteConfirmMessage: 'この操作は取り消せません。',
    exportToCSV: 'CSVエクスポート',
    exportSuccess: '{count}件のメモをCSVファイルでエクスポートしました',
    exportError: 'CSVエクスポートに失敗しました',
    exportCanceled: 'CSVエクスポートがキャンセルされました',
    exportNoNotes: 'エクスポートするメモがありません',
    exportNoData: 'エクスポートするデータがありません',
    exportDialogTitle: 'CSVファイルを保存',
    exportHeaders: {
      id: 'ID',
      content: '内容',
      timestamp: '作成日時',
      favorite: 'お気に入り',
      yes: 'はい',
      no: 'いいえ'
    },
    deleteError: 'メモの削除に失敗しました',
    copyError: 'コピーに失敗しました',

  },

  // Settings
  settings: {
    title: '設定',
    subtitle: 'アプリケーションのカスタマイズ設定',
    chatUICustomization: 'チャットUIカスタマイズ',
    chatUICustomizationDescription: 'チャット画面の見た目をCSSでカスタマイズできます',
    presetThemes: 'プリセットテーマ',
    customCSS: 'カスタムCSS',
    customCSSDescription: 'CSSの変更は即座に反映されます。保存ボタンを押すと永続化されます。',
    reset: 'リセット',
    save: '保存',
    saving: '保存中...',
    export: 'エクスポート',
    exporting: 'エクスポート中...',
    exportSuccess: 'エクスポート成功',
    exportError: 'エクスポート失敗',
    dataExport: 'データエクスポート',
    dataExportDescription: 'すべてのメモをCSV形式でエクスポート',
    saved: '保存完了',
    saveSuccess: '設定が保存されました',
    saveError: '設定の保存に失敗しました',
    preview: 'プレビュー',
    previewDescription: '上記のプレビューに選択したテーマが適用されます。テーマを変更すると、チャット画面の見た目が変わります。',
    previewMessage: 'これはプレビューメッセージです',
    otherSettings: 'その他の設定',
    darkMode: 'ダークモード',
    darkModeDescription: 'ダークテーマを有効にする',
    animations: 'アニメーション',
    animationsDescription: 'UIアニメーションを有効にする',

    reverseMode: 'リバースモード',
    reverseModeDescription: '入力欄を下端に移動し、メモを逆順で表示',
    language: '言語',
    languageDescription: 'お好みの言語を選択してください',
    languages: {
      en: 'English',
      ja: '日本語'
    }
  },

  // Themes
  themes: {
    default: {
      name: 'デフォルト',
      description: 'シンプルで洗練されたデザイン'
    },
    modern: {
      name: 'モダン',
      description: 'グラデーションとシャドウを多用'
    },
    minimal: {
      name: 'ミニマル',
      description: '余白を重視したシンプルなデザイン'
    },
    dark: {
      name: 'ダーク',
      description: 'ダークテーマベースのデザイン'
    }
  },

  // Time formats
  time: {
    justNow: '今',
    minutesAgo: '{count}分前',
    hoursAgo: '{count}時間前',
    daysAgo: '{count}日前',
    today: '今日',
    yesterday: '昨日'
  },

  // Errors
  errors: {
    general: 'エラーが発生しました',
    network: 'ネットワークエラー',
    fileNotFound: 'ファイルが見つかりません',
    permissionDenied: '権限がありません',
    invalidInput: '無効な入力です',
    unknown: '不明なエラー'
  }
}
