<template>
  <div class="dark:bg-gray-800">
    <div class="p-6 space-y-6">
      <!-- テーマ選択 -->
      <div class="space-y-3">
        <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">{{ $t('settings.presetThemes') }}</h4>
        <div class="grid grid-cols-3 gap-2">
          <button
            v-for="theme in presetThemes"
            :key="theme.name"
            @click="applyTheme(theme)"
            :class="[
              'px-3 py-2 rounded-lg border-2 transition-all duration-200 text-center text-sm',
              currentTheme === theme.name
                ? 'border-blue-500 bg-blue-50 font-medium text-blue-700 dark:bg-blue-500/30 dark:border-blue-400 dark:text-blue-200'
                : 'border-gray-200 bg-white hover:border-gray-300 hover:bg-gray-50 text-gray-900 dark:bg-gray-700 dark:border-gray-500 dark:hover:border-gray-400 dark:hover:bg-gray-600 dark:text-gray-100'
            ]"
          >
            <div class="flex items-center justify-center space-x-2">
              <div :class="['w-3 h-3 rounded-full', theme.color]"></div>
              <span>{{ theme.name }}</span>
            </div>
          </button>
        </div>
      </div>

      <!-- トグル設定群 -->
      <div class="space-y-4">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">{{ $t('settings.darkMode') }}</h4>
            <p class="text-xs text-gray-500 dark:text-gray-300">{{ $t('settings.darkModeDescription') }}</p>
          </div>
          <button
            @click="toggleDarkMode"
            :class="[
              'relative inline-flex h-6 w-11 items-center rounded-full transition-colors',
              darkMode ? 'bg-blue-600' : 'bg-gray-200 dark:bg-gray-600'
            ]"
          >
            <span
              :class="[
                'inline-block h-4 w-4 transform rounded-full bg-white transition-transform',
                darkMode ? 'translate-x-6' : 'translate-x-1'
              ]"
            ></span>
          </button>
        </div>

        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">{{ $t('settings.reverseMode') }}</h4>
            <p class="text-xs text-gray-500 dark:text-gray-300">{{ $t('settings.reverseModeDescription') }}</p>
          </div>
          <button
            @click="toggleReverseMode"
            :class="[
              'relative inline-flex h-6 w-11 items-center rounded-full transition-colors',
              reverseMode ? 'bg-blue-600' : 'bg-gray-200 dark:bg-gray-600'
            ]"
          >
            <span
              :class="[
                'inline-block h-4 w-4 transform rounded-full bg-white transition-transform',
                reverseMode ? 'translate-x-6' : 'translate-x-1'
              ]"
            ></span>
          </button>
        </div>
      </div>

      <!-- 言語 -->
      <div class="flex items-center justify-between">
        <div>
          <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">{{ $t('settings.language') }}</h4>
          <p class="text-xs text-gray-500 dark:text-gray-300">{{ $t('settings.languageDescription') }}</p>
        </div>
        <select
          v-model="currentLanguage"
          @change="changeLanguage"
          class="px-3 py-1.5 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-500 dark:text-gray-100"
        >
          <option value="en">{{ $t('settings.languages.en') }}</option>
          <option value="ja">{{ $t('settings.languages.ja') }}</option>
        </select>
      </div>

      <!-- データエクスポート -->
      <div class="flex items-center justify-between pt-4 border-t border-gray-200 dark:border-gray-600">
        <div>
          <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">{{ $t('settings.dataExport') }}</h4>
          <p class="text-xs text-gray-500 dark:text-gray-300">{{ $t('settings.dataExportDescription') }}</p>
        </div>
        <button
          @click="exportToCSV"
          :disabled="exportButtonLoading"
          :class="[
            'px-4 py-1.5 text-sm font-medium rounded-lg transition-all duration-200 flex items-center space-x-1.5',
            exportButtonLoading
              ? 'bg-gray-400 cursor-not-allowed text-white'
              : 'text-white bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700'
          ]"
        >
          <svg v-if="exportButtonLoading" class="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          <span>{{ exportButtonText }}</span>
        </button>
      </div>

      <!-- データインポート -->
      <div class="flex items-center justify-between">
        <div>
          <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">{{ $t('settings.dataImport') }}</h4>
          <p class="text-xs text-gray-500 dark:text-gray-300">{{ $t('settings.dataImportDescription') }}</p>
        </div>
        <button
          @click="importFromCSV"
          :disabled="importButtonLoading"
          :class="[
            'px-4 py-1.5 text-sm font-medium rounded-lg transition-all duration-200 flex items-center space-x-1.5',
            importButtonLoading
              ? 'bg-gray-400 cursor-not-allowed text-white'
              : 'text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700'
          ]"
        >
          <svg v-if="importButtonLoading" class="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" />
          </svg>
          <span>{{ importButtonText }}</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { setLocale, getCurrentLocale } from '../i18n'
import { useNoteStore } from '../stores/noteStore'

const { t } = useI18n()
const noteStore = useNoteStore()

const currentTheme = ref(t('themes.default.name'))
const customCSS = ref('')
const darkMode = ref(false)
const reverseMode = ref(false)
const currentLanguage = ref(getCurrentLocale())
const exportButtonText = ref(t('settings.export'))
const exportButtonLoading = ref(false)
const importButtonText = ref(t('settings.import'))
const importButtonLoading = ref(false)

const getPresetThemes = () => [
  {
    name: t('themes.default.name'),
    description: t('themes.default.description'),
    color: 'bg-blue-500',
    css: ''
  },
  {
    name: t('themes.modern.name'),
    description: t('themes.modern.description'),
    color: 'bg-purple-500',
    css: `/* Modern - light */
.chat-message {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  color: white !important;
  border-radius: 20px !important;
  box-shadow: 0 10px 25px rgba(0,0,0,0.15) !important;
  border: none !important;
}
.chat-message p { color: white !important; }
.chat-message span { color: rgba(255,255,255,0.7) !important; }
.chat-input {
  background: rgba(255,255,255,0.95) !important;
  backdrop-filter: blur(10px) !important;
  border: 1px solid rgba(255,255,255,0.3) !important;
  box-shadow: 0 8px 32px rgba(0,0,0,0.1) !important;
}
/* Modern - dark */
.dark .chat-message {
  background: linear-gradient(135deg, #4c51bf 0%, #553c9a 100%) !important;
  box-shadow: 0 10px 25px rgba(0,0,0,0.4) !important;
}
.dark .chat-input {
  background: rgba(30,41,59,0.95) !important;
  border: 1px solid #475569 !important;
}
.dark .chat-input textarea,
.dark .chat-input .input-area {
  background: #1e293b !important;
  color: #e2e8f0 !important;
}`
  },
  {
    name: t('themes.minimal.name'),
    description: t('themes.minimal.description'),
    color: 'bg-gray-400',
    css: `/* Minimal - light */
.chat-message {
  background: #f8fafc !important;
  border: 2px solid #e2e8f0 !important;
  border-radius: 12px !important;
  box-shadow: none !important;
}
.chat-input {
  background: white !important;
  border: 2px solid #e2e8f0 !important;
  border-radius: 12px !important;
  box-shadow: none !important;
}
/* Minimal - dark */
.dark .chat-message {
  background: #1e293b !important;
  border: 2px solid #334155 !important;
  color: #e2e8f0 !important;
}
.dark .chat-message p { color: #e2e8f0 !important; }
.dark .chat-message span { color: #94a3b8 !important; }
.dark .chat-input {
  background: #0f172a !important;
  border: 2px solid #334155 !important;
}
.dark .chat-input textarea,
.dark .chat-input .input-area {
  background: #1e293b !important;
  color: #e2e8f0 !important;
  border-color: #334155 !important;
}`
  }
]

const presetThemes = computed(() => getPresetThemes())

const applyTheme = (theme) => {
  currentTheme.value = theme.name
  customCSS.value = theme.css
  applyCustomCSS()
  saveSettings()
}

const applyCustomCSS = () => {
  const existingStyle = document.getElementById('custom-chat-css')
  if (existingStyle) {
    existingStyle.remove()
  }
  if (customCSS.value.trim()) {
    const style = document.createElement('style')
    style.id = 'custom-chat-css'
    style.textContent = customCSS.value
    document.head.appendChild(style)
  }
}

const saveSettings = () => {
  localStorage.setItem('micro-note-custom-css', customCSS.value)
  localStorage.setItem('micro-note-current-theme', currentTheme.value)
  localStorage.setItem('micro-note-dark-mode', darkMode.value)
  localStorage.setItem('micro-note-reverse-mode', reverseMode.value)

  window.microNoteSettings = {
    darkMode: darkMode.value,
    reverseMode: reverseMode.value,
    customCSS: customCSS.value
  }
}

const toggleDarkMode = () => {
  darkMode.value = !darkMode.value
  applyDarkMode()
  saveSettings()
}

const toggleReverseMode = () => {
  reverseMode.value = !reverseMode.value
  saveSettings()
}

const exportToCSV = async () => {
  exportButtonLoading.value = true
  exportButtonText.value = t('settings.exporting')

  try {
    const { invoke } = await import('@tauri-apps/api/core')
    const { save } = await import('@tauri-apps/plugin-dialog')
    const { writeTextFile } = await import('@tauri-apps/plugin-fs')

    const notes = await invoke('get_notes')

    if (!notes || notes.length === 0) {
      alert(t('notes.exportNoData'))
      return
    }

    const defaultName = `micro-note-export-${new Date().toISOString().split('T')[0]}.csv`
    const filePath = await save({
      defaultPath: defaultName,
      filters: [{ name: 'CSV', extensions: ['csv'] }]
    })

    if (!filePath) {
      return
    }

    const csvContent = '\uFEFF' + [
      'id,content,timestamp,is_favorite',
      ...notes.map(note => [
        `"${note.id}"`,
        `"${note.content.replace(/"/g, '""')}"`,
        `"${note.timestamp}"`,
        note.is_favorite ? '1' : '0'
      ].join(','))
    ].join('\n')

    await writeTextFile(filePath, csvContent)

    exportButtonText.value = t('settings.exportSuccess')
    setTimeout(() => {
      exportButtonText.value = t('settings.export')
    }, 2000)

  } catch (error) {
    console.error('CSV export failed:', error)
    alert(t('notes.exportError'))
    exportButtonText.value = t('settings.exportError')
    setTimeout(() => {
      exportButtonText.value = t('settings.export')
    }, 2000)
  } finally {
    exportButtonLoading.value = false
  }
}

const parseCSV = (text) => {
  const rows = []
  let current = ''
  let inQuotes = false
  let fields = []

  for (let i = 0; i < text.length; i++) {
    const char = text[i]

    if (inQuotes) {
      if (char === '"') {
        if (i + 1 < text.length && text[i + 1] === '"') {
          current += '"'
          i++
        } else {
          inQuotes = false
        }
      } else {
        current += char
      }
    } else {
      if (char === '"') {
        inQuotes = true
      } else if (char === ',') {
        fields.push(current)
        current = ''
      } else if (char === '\n' || (char === '\r' && text[i + 1] === '\n')) {
        if (char === '\r') i++
        fields.push(current)
        current = ''
        rows.push(fields)
        fields = []
      } else {
        current += char
      }
    }
  }

  if (current !== '' || fields.length > 0) {
    fields.push(current)
    rows.push(fields)
  }

  return rows
}

const importFromCSV = async () => {
  importButtonLoading.value = true
  importButtonText.value = t('settings.importing')

  try {
    const { invoke } = await import('@tauri-apps/api/core')
    const { open } = await import('@tauri-apps/plugin-dialog')
    const { readTextFile } = await import('@tauri-apps/plugin-fs')

    const filePath = await open({
      filters: [{ name: 'CSV', extensions: ['csv'] }],
      multiple: false
    })

    if (!filePath) {
      return
    }

    let content = await readTextFile(filePath)

    // BOM 除去
    if (content.charCodeAt(0) === 0xFEFF) {
      content = content.slice(1)
    }

    const rows = parseCSV(content)

    if (rows.length === 0) {
      alert(t('settings.importNoData'))
      return
    }

    // ヘッダー検証
    const header = rows[0].map(h => h.trim())
    const expectedHeader = ['id', 'content', 'timestamp', 'is_favorite']

    if (header.length !== 4 ||
        header[0] !== expectedHeader[0] ||
        header[1] !== expectedHeader[1] ||
        header[2] !== expectedHeader[2] ||
        header[3] !== expectedHeader[3]) {
      alert(t('settings.importInvalidFormat'))
      return
    }

    if (rows.length <= 1) {
      alert(t('settings.importNoData'))
      return
    }

    // データ行をパース
    const notes = []
    for (let i = 1; i < rows.length; i++) {
      const fields = rows[i]
      if (fields.length < 4) continue

      const contentField = fields[1]
      const timestamp = fields[2].trim()
      const isFavorite = fields[3].trim()

      if (!contentField || !timestamp) continue

      notes.push({
        content: contentField,
        timestamp: timestamp,
        is_favorite: isFavorite === '1'
      })
    }

    if (notes.length === 0) {
      alert(t('settings.importNoData'))
      return
    }

    const count = await invoke('import_notes', { notes })

    await noteStore.fetchNotes()

    alert(t('settings.importComplete', { count }))
    importButtonText.value = t('settings.importSuccess')
    setTimeout(() => {
      importButtonText.value = t('settings.import')
    }, 2000)

  } catch (error) {
    console.error('CSV import failed:', error)
    alert(t('settings.importError'))
    importButtonText.value = t('settings.importError')
    setTimeout(() => {
      importButtonText.value = t('settings.import')
    }, 2000)
  } finally {
    importButtonLoading.value = false
  }
}

const changeLanguage = (event) => {
  const newLocale = event.target.value
  setLocale(newLocale)

  // Update button text to new locale
  exportButtonText.value = t('settings.export')
  importButtonText.value = t('settings.import')

  const updatedThemes = getPresetThemes()
  const matchingTheme = updatedThemes.find(theme =>
    theme.css === customCSS.value
  )
  if (matchingTheme) {
    currentTheme.value = matchingTheme.name
  }

  saveSettings()
}

const applyDarkMode = () => {
  const html = document.documentElement
  if (darkMode.value) {
    html.classList.add('dark')
    html.setAttribute('data-theme', 'dark')
  } else {
    html.classList.remove('dark')
    html.setAttribute('data-theme', 'light')
  }
}

onMounted(() => {
  const savedCSS = localStorage.getItem('micro-note-custom-css')
  const savedTheme = localStorage.getItem('micro-note-current-theme')
  const savedDarkMode = localStorage.getItem('micro-note-dark-mode')
  const savedReverseMode = localStorage.getItem('micro-note-reverse-mode')

  if (savedCSS) {
    customCSS.value = savedCSS
  }

  if (savedTheme) {
    const themes = getPresetThemes()
    const matchingTheme = themes.find(theme =>
      theme.name === savedTheme ||
      theme.css === savedCSS
    )
    if (matchingTheme) {
      currentTheme.value = matchingTheme.name
    } else {
      currentTheme.value = savedTheme
    }
  }

  if (savedDarkMode !== null) {
    darkMode.value = savedDarkMode === 'true'
  }

  if (savedReverseMode !== null) {
    reverseMode.value = savedReverseMode === 'true'
  }

  applyCustomCSS()
  applyDarkMode()

  window.microNoteSettings = {
    darkMode: darkMode.value,
    reverseMode: reverseMode.value,
    customCSS: customCSS.value
  }
})
</script>
