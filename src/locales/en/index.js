export default {
  // Common
  common: {
    save: 'Save',
    cancel: 'Cancel',
    delete: 'Delete',
    edit: 'Edit',
    add: 'Add',
    search: 'Search',
    loading: 'Loading...',
    error: 'Error',
    success: 'Success',
    confirm: 'Confirm',
    back: 'Back',
    next: 'Next',
    previous: 'Previous',
    close: 'Close',
    open: 'Open',
    yes: 'Yes',
    no: 'No',
    ok: 'OK',
    copy: 'Copy',
    export: 'Export',
    import: 'Import',
    reset: 'Reset',
    apply: 'Apply',
    settings: 'Settings',
    help: 'Help',
    about: 'About',
  },

  // Navigation
  navigation: {
    chat: 'Chat',
    notes: 'Notes',
    settings: 'Settings',
  },

  // Chat
  chat: {
    title: 'Chat',
    subtitle: 'Chat with AI and save notes',
    placeholder: 'Enter content you want to save as a note...',
    send: 'Send',
    newMessage: 'New message',
    thinking: 'AI is thinking...',
    saveAsNote: 'Save as Note',
    noteSaved: 'Note saved successfully',
    noteSaveError: 'Failed to save note',
    enterToSend: 'Enter to send',
    shiftEnterNewline: 'Shift + Enter for new line',
    characterCount: '{count} characters',
    savedAsNote: 'Saved as note',
    createFirstNote: 'Create your first note',
    createFirstNoteDescription:
      'Enter the content you want to save in the text area below',
  },

  // Notes
  notes: {
    title: 'Notes',
    subtitle: 'Manage and search your saved notes',
    searchPlaceholder: 'Search notes...',
    noNotes: 'No notes yet',
    noNotesMessage: 'Create notes in the chat screen',
    noSearchResults: 'No search results',
    noSearchResultsMessage: 'Try different keywords',
    favorite: 'Favorite',
    unfavorite: 'Unfavorite',
    copyToClipboard: 'Copy to clipboard',
    copiedToClipboard: 'Copied to clipboard',
    clickToCopy: 'Click to copy',
    deleteNote: 'Delete Note',
    deleteConfirm: 'Are you sure you want to delete this note?',
    deleteConfirmMessage: 'This action cannot be undone.',
    exportToCSV: 'Export to CSV',
    exportSuccess: '{count} notes exported successfully',
    exportError: 'Export failed',
    exportCanceled: 'Export canceled',
    exportNoNotes: 'No notes to export',
    exportNoData: 'No data to export',
    exportDialogTitle: 'Save CSV File',
    exportHeaders: {
      id: 'ID',
      content: 'Content',
      timestamp: 'Created At',
      favorite: 'Favorite',
      yes: 'Yes',
      no: 'No',
    },
    deleteError: 'Failed to delete note',
    copyError: 'Failed to copy to clipboard',
  },

  // Settings
  settings: {
    title: 'Settings',
    subtitle: 'Customize your application settings',
    chatUICustomization: 'Chat UI Customization',
    chatUICustomizationDescription:
      'Customize the appearance of the chat screen with CSS',
    presetThemes: 'Preset Themes',
    customCSS: 'Custom CSS',
    customCSSDescription:
      'CSS changes are applied immediately. Click Save to persist.',
    reset: 'Reset',
    save: 'Save',
    saving: 'Saving...',
    export: 'Export',
    exporting: 'Exporting...',
    exportSuccess: 'Export successful',
    exportError: 'Export failed',
    dataExport: 'Data Export',
    dataExportDescription: 'Export all your notes to CSV format',
    saved: 'Saved',
    saveSuccess: 'Settings saved successfully',
    saveError: 'Failed to save settings',
    preview: 'Preview',
    previewDescription:
      'The selected theme will be applied to the preview above. Changing the theme will change the appearance of the chat screen.',
    previewMessage: 'This is a preview message',
    otherSettings: 'Other Settings',
    darkMode: 'Dark Mode',
    darkModeDescription: 'Enable dark theme',
    animations: 'Animations',
    animationsDescription: 'Enable UI animations',

    reverseMode: 'Reverse Mode',
    reverseModeDescription:
      'Move input field to bottom and display notes in reverse order',
    language: 'Language',
    languageDescription: 'Select your preferred language',
    languages: {
      en: 'English',
      ja: 'Japanese',
    },
  },

  // Themes
  themes: {
    default: {
      name: 'Default',
      description: 'Simple and refined design',
    },
    modern: {
      name: 'Modern',
      description: 'Uses gradients and shadows extensively',
    },
    minimal: {
      name: 'Minimal',
      description: 'Simple design emphasizing whitespace',
    },
    dark: {
      name: 'Dark',
      description: 'Dark theme based design',
    },
  },

  // Time formats
  time: {
    justNow: 'Just now',
    minutesAgo: '{count} minutes ago',
    hoursAgo: '{count} hours ago',
    daysAgo: '{count} days ago',
    today: 'Today',
    yesterday: 'Yesterday',
  },

  // Errors
  errors: {
    general: 'An error occurred',
    network: 'Network error',
    fileNotFound: 'File not found',
    permissionDenied: 'Permission denied',
    invalidInput: 'Invalid input',
    unknown: 'Unknown error',
  },
}
