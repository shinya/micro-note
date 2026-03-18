<template>
  <div class="dark:bg-gray-800">
    <div class="p-6 space-y-6">
      <!-- テーマ選択 -->
      <div class="space-y-3">
        <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">
          {{ $t('settings.presetThemes') }}
        </h4>
        <div class="grid grid-cols-3 gap-2">
          <button
            v-for="theme in presetThemes"
            :key="theme.name"
            class="px-3 py-2 rounded-lg border-2 transition-all duration-200 text-center text-sm"
            :class="[
              currentTheme === theme.name
                ? 'border-blue-500 bg-blue-50 font-medium text-blue-700 dark:bg-blue-500/30 dark:border-blue-400 dark:text-blue-200'
                : 'border-gray-200 bg-white hover:border-gray-300 hover:bg-gray-50 text-gray-900 dark:bg-gray-700 dark:border-gray-500 dark:hover:border-gray-400 dark:hover:bg-gray-600 dark:text-gray-100',
            ]"
            @click="applyTheme(theme)"
          >
            <div class="flex items-center justify-center space-x-2">
              <div class="w-3 h-3 rounded-full" :class="[theme.color]"></div>
              <span>{{ theme.name }}</span>
            </div>
          </button>
        </div>
      </div>

      <!-- トグル設定群 -->
      <div class="space-y-4">
        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">
              {{ $t('settings.darkMode') }}
            </h4>
            <p class="text-xs text-gray-500 dark:text-gray-300">
              {{ $t('settings.darkModeDescription') }}
            </p>
          </div>
          <button
            class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors"
            :class="[darkMode ? 'bg-blue-600' : 'bg-gray-200 dark:bg-gray-600']"
            @click="toggleDarkMode"
          >
            <span
              class="inline-block h-4 w-4 transform rounded-full bg-white transition-transform"
              :class="[darkMode ? 'translate-x-6' : 'translate-x-1']"
            ></span>
          </button>
        </div>

        <div class="flex items-center justify-between">
          <div>
            <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">
              {{ $t('settings.reverseMode') }}
            </h4>
            <p class="text-xs text-gray-500 dark:text-gray-300">
              {{ $t('settings.reverseModeDescription') }}
            </p>
          </div>
          <button
            class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors"
            :class="[
              reverseMode ? 'bg-blue-600' : 'bg-gray-200 dark:bg-gray-600',
            ]"
            @click="toggleReverseMode"
          >
            <span
              class="inline-block h-4 w-4 transform rounded-full bg-white transition-transform"
              :class="[reverseMode ? 'translate-x-6' : 'translate-x-1']"
            ></span>
          </button>
        </div>
      </div>

      <!-- ラベル管理 -->
      <div class="space-y-3 pt-4 border-t border-gray-200 dark:border-gray-600">
        <div>
          <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">
            {{ $t('settings.labels') }}
          </h4>
          <p class="text-xs text-gray-500 dark:text-gray-300">
            {{ $t('settings.labelsDescription') }}
          </p>
        </div>

        <!-- 新規ラベル追加フォーム -->
        <div class="flex items-center gap-2">
          <input
            v-model="newLabelName"
            type="text"
            :placeholder="$t('settings.labelName')"
            class="flex-1 text-sm px-3 py-1.5 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-500 dark:text-gray-100 dark:placeholder-gray-400"
            @keydown.enter="addLabel"
          />
          <input
            v-model="newLabelColor"
            type="color"
            class="w-8 h-8 rounded cursor-pointer border border-gray-200 dark:border-gray-500"
          />
          <button
            :disabled="!newLabelName.trim()"
            class="px-3 py-1.5 text-xs font-medium rounded-lg text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
            @click="addLabel"
          >
            {{ $t('settings.addLabel') }}
          </button>
        </div>

        <!-- ラベル一覧 -->
        <div
          v-if="labelStore.labels.value && labelStore.labels.value.length > 0"
          class="space-y-2"
        >
          <div
            v-for="label in labelStore.labels.value"
            :key="label.id"
            class="flex items-center gap-2 px-3 py-2 bg-gray-50 dark:bg-gray-700 rounded-lg"
          >
            <template v-if="editingLabelId === label.id">
              <input
                v-model="editingLabelName"
                type="text"
                class="flex-1 text-sm px-2 py-1 border border-gray-200 rounded dark:bg-gray-600 dark:border-gray-500 dark:text-gray-100"
                @keydown.enter="saveEditLabel"
                @keydown.escape="cancelEditLabel"
              />
              <input
                v-model="editingLabelColor"
                type="color"
                class="w-7 h-7 rounded cursor-pointer border border-gray-200 dark:border-gray-500"
              />
              <button
                class="p-1 text-green-600 hover:text-green-700 dark:text-green-400"
                :title="$t('common.save')"
                @click="saveEditLabel"
              >
                <svg
                  class="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M5 13l4 4L19 7"
                  />
                </svg>
              </button>
              <button
                class="p-1 text-gray-400 hover:text-gray-600 dark:text-gray-400 dark:hover:text-gray-200"
                :title="$t('common.cancel')"
                @click="cancelEditLabel"
              >
                <svg
                  class="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </button>
            </template>
            <template v-else>
              <span
                class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                :style="{
                  backgroundColor: label.color,
                  color: getTextColorForLabel(label.color),
                }"
              >
                {{ label.name }}
              </span>
              <div class="flex-1"></div>
              <button
                class="p-1 text-gray-400 hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
                :title="$t('settings.editLabel')"
                @click="startEditLabel(label)"
              >
                <svg
                  class="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                  />
                </svg>
              </button>
              <button
                class="p-1 text-gray-400 hover:text-red-500 transition-colors"
                :title="$t('settings.deleteLabel')"
                @click="removeLabel(label.id)"
              >
                <svg
                  class="w-4 h-4"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                  />
                </svg>
              </button>
            </template>
          </div>
        </div>
        <p v-else class="text-xs text-gray-400 dark:text-gray-500">
          {{ $t('settings.noLabels') }}
        </p>
      </div>

      <!-- 言語 -->
      <div class="flex items-center justify-between">
        <div>
          <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">
            {{ $t('settings.language') }}
          </h4>
          <p class="text-xs text-gray-500 dark:text-gray-300">
            {{ $t('settings.languageDescription') }}
          </p>
        </div>
        <select
          v-model="currentLanguage"
          class="px-3 py-1.5 text-sm border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-500 dark:text-gray-100"
          @change="changeLanguage"
        >
          <option value="en">{{ $t('settings.languages.en') }}</option>
          <option value="ja">{{ $t('settings.languages.ja') }}</option>
        </select>
      </div>

      <!-- データエクスポート -->
      <div
        class="flex items-center justify-between pt-4 border-t border-gray-200 dark:border-gray-600"
      >
        <div>
          <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">
            {{ $t('settings.dataExport') }}
          </h4>
          <p class="text-xs text-gray-500 dark:text-gray-300">
            {{ $t('settings.dataExportDescription') }}
          </p>
        </div>
        <button
          :disabled="exportButtonLoading"
          class="px-4 py-1.5 text-sm font-medium rounded-lg transition-all duration-200 flex items-center space-x-1.5"
          :class="[
            exportButtonLoading
              ? 'bg-gray-400 cursor-not-allowed text-white'
              : 'text-white bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700',
          ]"
          @click="exportToCSV"
        >
          <svg
            v-if="exportButtonLoading"
            class="animate-spin h-4 w-4 text-white"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle
              class="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              stroke-width="4"
            ></circle>
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            ></path>
          </svg>
          <svg
            v-else
            class="w-4 h-4"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
            />
          </svg>
          <span>{{ exportButtonText }}</span>
        </button>
      </div>

      <!-- データインポート -->
      <div class="flex items-center justify-between">
        <div>
          <h4 class="text-sm font-medium text-gray-900 dark:text-gray-100">
            {{ $t('settings.dataImport') }}
          </h4>
          <p class="text-xs text-gray-500 dark:text-gray-300">
            {{ $t('settings.dataImportDescription') }}
          </p>
        </div>
        <button
          :disabled="importButtonLoading"
          class="px-4 py-1.5 text-sm font-medium rounded-lg transition-all duration-200 flex items-center space-x-1.5"
          :class="[
            importButtonLoading
              ? 'bg-gray-400 cursor-not-allowed text-white'
              : 'text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700',
          ]"
          @click="importFromCSV"
        >
          <svg
            v-if="importButtonLoading"
            class="animate-spin h-4 w-4 text-white"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle
              class="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              stroke-width="4"
            ></circle>
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            ></path>
          </svg>
          <svg
            v-else
            class="w-4 h-4"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"
            />
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
import { useLabelStore } from '../stores/labelStore'
import { useNoteStore } from '../stores/noteStore'

const { t } = useI18n()
const noteStore = useNoteStore()
const labelStore = useLabelStore()

// Label management
const newLabelName = ref('')
const newLabelColor = ref('#3B82F6')
const editingLabelId = ref(undefined)
const editingLabelName = ref('')
const editingLabelColor = ref('')

const addLabel = async () => {
  const name = newLabelName.value.trim()
  if (!name) return
  try {
    await labelStore.saveLabel(name, newLabelColor.value)
    newLabelName.value = ''
    newLabelColor.value = '#3B82F6'
  } catch {
    // silent
  }
}

const startEditLabel = label => {
  editingLabelId.value = label.id
  editingLabelName.value = label.name
  editingLabelColor.value = label.color
}

const saveEditLabel = async () => {
  if (!editingLabelName.value.trim()) return
  try {
    await labelStore.updateLabel(
      editingLabelId.value,
      editingLabelName.value.trim(),
      editingLabelColor.value
    )
    editingLabelId.value = undefined
  } catch {
    // silent
  }
}

const cancelEditLabel = () => {
  editingLabelId.value = undefined
}

const removeLabel = async id => {
  try {
    await labelStore.deleteLabel(id)
  } catch {
    // silent
  }
}

const currentTheme = ref(t('themes.default.name'))
const customCSS = ref('')
const darkMode = ref(false)
const reverseMode = ref(false)
const currentLanguage = ref(getCurrentLocale())
const exportButtonText = ref(t('settings.export'))
const exportButtonLoading = ref(false)
const importButtonText = ref(t('settings.import'))
const importButtonLoading = ref(false)

const getTextColorForLabel = bgColor => {
  if (!bgColor) return '#FFFFFF'
  const hex = bgColor.replace('#', '')
  const r = Number.parseInt(hex.slice(0, 2), 16)
  const g = Number.parseInt(hex.slice(2, 4), 16)
  const b = Number.parseInt(hex.slice(4, 6), 16)
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  return luminance > 0.5 ? '#1F2937' : '#FFFFFF'
}

const getPresetThemes = () => [
  {
    name: t('themes.default.name'),
    description: t('themes.default.description'),
    color: 'bg-blue-500',
    css: '',
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
}`,
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
}`,
  },
]

const presetThemes = computed(() => getPresetThemes())

const applyTheme = theme => {
  currentTheme.value = theme.name
  customCSS.value = theme.css
  applyCustomCSS()
  saveSettings()
}

const applyCustomCSS = () => {
  const existingStyle = document.querySelector('#custom-chat-css')
  if (existingStyle) {
    existingStyle.remove()
  }
  if (customCSS.value.trim()) {
    const style = document.createElement('style')
    style.id = 'custom-chat-css'
    style.textContent = customCSS.value
    document.head.append(style)
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
    customCSS: customCSS.value,
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
      filters: [{ name: 'CSV', extensions: ['csv'] }],
    })

    if (!filePath) {
      return
    }

    const csvContent = `\uFEFF${[
      'id,content,timestamp,is_favorite,label_id',
      ...notes.map(note =>
        [
          `"${note.id}"`,
          `"${note.content.replaceAll('"', '""')}"`,
          `"${note.timestamp}"`,
          note.is_favorite ? '1' : '0',
          note.label_id ? `"${note.label_id}"` : '',
        ].join(',')
      ),
    ].join('\n')}`

    await writeTextFile(filePath, csvContent)

    exportButtonText.value = t('settings.exportSuccess')
    setTimeout(() => {
      exportButtonText.value = t('settings.export')
    }, 2000)
  } catch {
    alert(t('notes.exportError'))
    exportButtonText.value = t('settings.exportError')
    setTimeout(() => {
      exportButtonText.value = t('settings.export')
    }, 2000)
  } finally {
    exportButtonLoading.value = false
  }
}

const parseCSV = text => {
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
      multiple: false,
    })

    if (!filePath) {
      return
    }

    let content = await readTextFile(filePath)

    // BOM 除去
    // eslint-disable-next-line unicorn/number-literal-case, unicorn/numeric-separators-style
    if (content.codePointAt(0) === 0xfeff) {
      content = content.slice(1)
    }

    const rows = parseCSV(content)

    if (rows.length === 0) {
      alert(t('settings.importNoData'))
      return
    }

    // ヘッダー検証（4列または5列を許容）
    const header = rows[0].map(h => h.trim())
    const baseHeader = ['id', 'content', 'timestamp', 'is_favorite']

    if (
      header.length < 4 ||
      header[0] !== baseHeader[0] ||
      header[1] !== baseHeader[1] ||
      header[2] !== baseHeader[2] ||
      header[3] !== baseHeader[3]
    ) {
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
        timestamp,
        is_favorite: isFavorite === '1',
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
  } catch {
    alert(t('settings.importError'))
    importButtonText.value = t('settings.importError')
    setTimeout(() => {
      importButtonText.value = t('settings.import')
    }, 2000)
  } finally {
    importButtonLoading.value = false
  }
}

const changeLanguage = event => {
  const newLocale = event.target.value
  setLocale(newLocale)

  // Update button text to new locale
  exportButtonText.value = t('settings.export')
  importButtonText.value = t('settings.import')

  const updatedThemes = getPresetThemes()
  const matchingTheme = updatedThemes.find(
    theme => theme.css === customCSS.value
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
    html.dataset.theme = 'dark'
  } else {
    html.classList.remove('dark')
    html.dataset.theme = 'light'
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
    const matchingTheme = themes.find(
      theme => theme.name === savedTheme || theme.css === savedCSS
    )
    currentTheme.value = matchingTheme ? matchingTheme.name : savedTheme
  }

  if (savedDarkMode !== null) {
    darkMode.value = savedDarkMode === 'true'
  }

  if (savedReverseMode !== null) {
    reverseMode.value = savedReverseMode === 'true'
  }

  applyCustomCSS()
  applyDarkMode()
  labelStore.fetchLabels()

  window.microNoteSettings = {
    darkMode: darkMode.value,
    reverseMode: reverseMode.value,
    customCSS: customCSS.value,
  }
})
</script>
