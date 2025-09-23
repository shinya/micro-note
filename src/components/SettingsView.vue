<template>
  <div class="max-w-5xl mx-auto dark:bg-gray-900 min-h-screen">
    <div
      class="bg-white/80 backdrop-blur-md rounded-2xl shadow-xl border border-white/20 overflow-hidden dark:bg-gray-800/80 dark:border-gray-700"
    >
      <!-- 設定ヘッダー -->
      <div
        class="px-8 py-6 border-b border-gray-100 bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-gray-700 dark:to-gray-800 dark:border-gray-600 dark:bg-gradient-to-r dark:from-gray-800 dark:to-gray-900"
      >
        <div class="flex items-center space-x-3">
          <div
            class="w-10 h-10 bg-gradient-to-r from-blue-600 to-indigo-600 rounded-xl flex items-center justify-center"
          >
            <svg
              class="w-6 h-6 text-white"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
              />
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
              />
            </svg>
          </div>
          <div>
            <h2
              class="text-xl font-bold text-gray-900 dark:text-gray-100 dark:text-white"
            >
              {{ $t('settings.title') }}
            </h2>
            <p
              class="text-sm text-gray-600 dark:text-gray-300 dark:text-gray-200"
            >
              {{ $t('settings.subtitle') }}
            </p>
          </div>
        </div>
      </div>

      <!-- 設定コンテンツ -->
      <div class="p-8 space-y-8 dark:bg-gray-900">
        <!-- CSSカスタマイズセクション -->
        <div class="space-y-6">
          <div class="border-b border-gray-200 pb-4 dark:border-gray-600">
            <h3
              class="text-lg font-semibold text-gray-900 mb-2 dark:text-gray-100"
            >
              {{ $t('settings.chatUICustomization') }}
            </h3>
            <p class="text-sm text-gray-600 dark:text-gray-300">
              {{ $t('settings.chatUICustomizationDescription') }}
            </p>
          </div>

          <!-- プリセットテーマ -->
          <div class="space-y-4">
            <h4 class="text-md font-medium text-gray-900 dark:text-gray-100">
              {{ $t('settings.presetThemes') }}
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <button
                v-for="theme in presetThemes"
                :key="theme.name"
                class="p-4 rounded-xl border-2 transition-all duration-200 text-left"
                :class="[
                  currentTheme === theme.name
                    ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/20 dark:border-blue-400'
                    : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50 dark:border-gray-600 dark:hover:border-gray-500 dark:hover:bg-gray-700/50 dark:bg-gray-800',
                ]"
                @click="applyTheme(theme)"
              >
                <div class="flex items-center space-x-3 mb-2">
                  <div
                    class="w-4 h-4 rounded-full"
                    :class="[theme.color]"
                  ></div>
                  <span class="font-medium text-gray-900 dark:text-gray-100">
                    {{ theme.name }}
                  </span>
                </div>
                <p class="text-sm text-gray-600 dark:text-gray-300">
                  {{ theme.description }}
                </p>
              </button>
            </div>
          </div>
        </div>

        <!-- その他の設定 -->
        <div class="space-y-6">
          <div class="border-b border-gray-200 pb-4 dark:border-gray-600">
            <h3
              class="text-lg font-semibold text-gray-900 mb-2 dark:text-gray-100"
            >
              {{ $t('settings.otherSettings') }}
            </h3>
          </div>

          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <div>
                <h4
                  class="text-md font-medium text-gray-900 dark:text-gray-100"
                >
                  {{ $t('settings.darkMode') }}
                </h4>
                <p class="text-sm text-gray-600 dark:text-gray-300">
                  {{ $t('settings.darkModeDescription') }}
                </p>
              </div>
              <button
                class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors"
                :class="[darkMode ? 'bg-blue-600' : 'bg-gray-200']"
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
                <h4
                  class="text-md font-medium text-gray-900 dark:text-gray-100"
                >
                  {{ $t('settings.animations') }}
                </h4>
                <p class="text-sm text-gray-600 dark:text-gray-300">
                  {{ $t('settings.animationsDescription') }}
                </p>
              </div>
              <button
                class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors"
                :class="[animations ? 'bg-blue-600' : 'bg-gray-200']"
                @click="toggleAnimations"
              >
                <span
                  class="inline-block h-4 w-4 transform rounded-full bg-white transition-transform"
                  :class="[animations ? 'translate-x-6' : 'translate-x-1']"
                ></span>
              </button>
            </div>

            <!-- リバースモード -->
            <div class="flex items-center justify-between">
              <div>
                <h4
                  class="text-md font-medium text-gray-900 dark:text-gray-100"
                >
                  {{ $t('settings.reverseMode') }}
                </h4>
                <p class="text-sm text-gray-600 dark:text-gray-300">
                  {{ $t('settings.reverseModeDescription') }}
                </p>
              </div>
              <button
                class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors"
                :class="[reverseMode ? 'bg-blue-600' : 'bg-gray-200']"
                @click="toggleReverseMode"
              >
                <span
                  class="inline-block h-4 w-4 transform rounded-full bg-white transition-transform"
                  :class="[reverseMode ? 'translate-x-6' : 'translate-x-1']"
                ></span>
              </button>
            </div>

            <!-- 言語選択 -->
            <div class="flex items-center justify-between">
              <div>
                <h4
                  class="text-md font-medium text-gray-900 dark:text-gray-100"
                >
                  {{ $t('settings.language') }}
                </h4>
                <p class="text-sm text-gray-600 dark:text-gray-300">
                  {{ $t('settings.languageDescription') }}
                </p>
              </div>
              <select
                v-model="currentLanguage"
                class="px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 dark:bg-gray-800 dark:border-gray-600 dark:text-gray-100"
                @change="changeLanguage"
              >
                <option value="en">{{ $t('settings.languages.en') }}</option>
                <option value="ja">{{ $t('settings.languages.ja') }}</option>
              </select>
            </div>

            <!-- データエクスポート -->
            <div class="flex items-center justify-between">
              <div>
                <h4
                  class="text-md font-medium text-gray-900 dark:text-gray-100"
                >
                  {{ $t('settings.dataExport') }}
                </h4>
                <p class="text-sm text-gray-600 dark:text-gray-300">
                  {{ $t('settings.dataExportDescription') }}
                </p>
              </div>
              <button
                :disabled="exportButtonLoading"
                class="px-4 py-2 text-sm font-medium rounded-lg transition-all duration-200 shadow-md hover:shadow-lg flex items-center space-x-2"
                :class="[
                  exportButtonLoading
                    ? 'bg-gray-400 cursor-not-allowed text-white'
                    : 'text-white bg-gradient-to-r from-green-600 to-emerald-600 hover:from-green-700 hover:to-emerald-700',
                ]"
                @click="exportToCSV"
              >
                <svg
                  v-if="exportButtonLoading"
                  class="animate-spin -ml-1 mr-2 h-4 w-4 text-white"
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
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useI18n } from 'vue-i18n'

import { setLocale, getCurrentLocale } from '../i18n'

const { t } = useI18n()

const currentTheme = ref(t('themes.default.name'))
const darkMode = ref(false)
const animations = ref(true)
const reverseMode = ref(false)
const currentLanguage = ref(getCurrentLocale())
const exportButtonText = ref(t('settings.export'))
const exportButtonLoading = ref(false)

// Create a function to get preset themes with current translations
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
    css: `
.chat-message {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  color: white !important;
  border-radius: 20px !important;
  box-shadow: 0 10px 25px rgba(0,0,0,0.2) !important;
  border: none !important;
}

.chat-message p {
  color: white !important;
}

.chat-input {
  background: rgba(255,255,255,0.95) !important;
  backdrop-filter: blur(10px) !important;
  border: 1px solid rgba(255,255,255,0.3) !important;
  box-shadow: 0 8px 32px rgba(0,0,0,0.1) !important;
}

.chat-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  color: white !important;
  border-radius: 16px !important;
  padding: 24px !important;
  margin-bottom: 16px !important;
}

.chat-header h1,
.chat-header p {
  color: white !important;
}`,
  },
  {
    name: t('themes.minimal.name'),
    description: t('themes.minimal.description'),
    color: 'bg-gray-500',
    css: `
.chat-message {
  background: #f8fafc !important;
  border: 2px solid #e2e8f0 !important;
  border-radius: 12px !important;
  margin: 20px 0 !important;
  box-shadow: none !important;
}

.chat-input {
  background: white !important;
  border: 2px solid #e2e8f0 !important;
  border-radius: 12px !important;
  box-shadow: none !important;
}

.chat-header {
  background: #f1f5f9 !important;
  border: 2px solid #e2e8f0 !important;
  border-radius: 12px !important;
  margin-bottom: 20px !important;
}`,
  },
  {
    name: t('themes.dark.name'),
    description: t('themes.dark.description'),
    color: 'bg-gray-800',
    css: `
.chat-message {
  background: #1e293b !important;
  color: #e2e8f0 !important;
  border: 1px solid #475569 !important;
  border-radius: 16px !important;
}

.chat-message p {
  color: #e2e8f0 !important;
}

.chat-input {
  background: #334155 !important;
  border: 1px solid #475569 !important;
  color: #e2e8f0 !important;
}

.chat-input textarea {
  background: #1e293b !important;
  color: #e2e8f0 !important;
  border: 1px solid #475569 !important;
}

.chat-header {
  background: #0f172a !important;
  color: #e2e8f0 !important;
  border: 1px solid #475569 !important;
  border-radius: 16px !important;
}

.chat-header h1,
.chat-header p {
  color: #e2e8f0 !important;
}`,
  },
]

// Create a computed property for preset themes that updates when locale changes
const presetThemes = computed(() => getPresetThemes())

const applyTheme = theme => {
  currentTheme.value = theme.name
  // テーマのCSSを直接適用
  if (theme.css) {
    const existingStyle = document.querySelector('#theme-css')
    if (existingStyle) {
      existingStyle.remove()
    }

    const style = document.createElement('style')
    style.id = 'theme-css'
    style.textContent = theme.css
    document.head.append(style)
  }
  // 設定を保存
  saveSettings()
}

const saveSettings = async () => {
  try {
    localStorage.setItem('micro-note-current-theme', currentTheme.value)
    localStorage.setItem('micro-note-dark-mode', darkMode.value)
    localStorage.setItem('micro-note-animations', animations.value)
    localStorage.setItem('micro-note-reverse-mode', reverseMode.value)

    // Publish settings globally (accessible from other components)
    window.microNoteSettings = {
      darkMode: darkMode.value,
      animations: animations.value,
      reverseMode: reverseMode.value,
    }
  } catch {
    // Failed to save settings
  }
}

const toggleDarkMode = () => {
  darkMode.value = !darkMode.value
  applyDarkMode()
  saveSettings()
}

const toggleAnimations = () => {
  animations.value = !animations.value
  applyAnimations()
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
    // Get notes from the store
    const { invoke } = await import('@tauri-apps/api/core')
    const notes = await invoke('get_notes')

    if (!notes || notes.length === 0) {
      alert(t('notes.exportNoData'))
      return
    }

    // Create CSV content
    const headers = [
      t('notes.exportHeaders.id'),
      t('notes.exportHeaders.content'),
      t('notes.exportHeaders.timestamp'),
      t('notes.exportHeaders.favorite'),
    ]

    const csvContent = [
      headers.join(','),
      ...notes.map(note =>
        [
          `"${note.id}"`,
          `"${note.content.replaceAll('"', '""')}"`,
          `"${note.timestamp}"`,
          note.is_favorite
            ? t('notes.exportHeaders.yes')
            : t('notes.exportHeaders.no'),
        ].join(',')
      ),
    ].join('\n')

    // Create and download file
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
    const link = document.createElement('a')
    const url = URL.createObjectURL(blob)
    link.setAttribute('href', url)
    link.setAttribute(
      'download',
      `micro-note-export-${new Date().toISOString().split('T')[0]}.csv`
    )
    link.style.visibility = 'hidden'
    document.body.append(link)
    link.click()
    link.remove()

    exportButtonText.value = t('settings.exportSuccess')
    setTimeout(() => {
      exportButtonText.value = t('settings.export')
    }, 2000)
  } catch {
    // CSV export failed
    alert(t('notes.exportError'))
    exportButtonText.value = t('settings.exportError')
    setTimeout(() => {
      exportButtonText.value = t('settings.export')
    }, 2000)
  } finally {
    exportButtonLoading.value = false
  }
}

const changeLanguage = event => {
  const newLocale = event.target.value
  setLocale(newLocale)

  // Update current theme name to match new language
  const currentThemeName = currentTheme.value
  const updatedThemes = getPresetThemes()
  const matchingTheme = updatedThemes.find(
    theme => theme.name === currentThemeName
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

const applyAnimations = () => {
  const html = document.documentElement
  if (animations.value) {
    html.classList.add('animations-enabled')
    html.dataset.animations = 'enabled'
  } else {
    html.classList.remove('animations-enabled')
    html.dataset.animations = 'disabled'
  }
}

onMounted(() => {
  // Load saved settings
  const savedTheme = localStorage.getItem('micro-note-current-theme')
  const savedDarkMode = localStorage.getItem('micro-note-dark-mode')
  const savedAnimations = localStorage.getItem('micro-note-animations')
  const savedReverseMode = localStorage.getItem('micro-note-reverse-mode')

  if (savedTheme) {
    // Try to find the theme by name
    const themes = getPresetThemes()
    const matchingTheme = themes.find(theme => theme.name === savedTheme)
    if (matchingTheme) {
      currentTheme.value = matchingTheme.name
      // 保存されたテーマのCSSを適用
      if (matchingTheme.css) {
        const existingStyle = document.querySelector('#theme-css')
        if (existingStyle) {
          existingStyle.remove()
        }
        const style = document.createElement('style')
        style.id = 'theme-css'
        style.textContent = matchingTheme.css
        document.head.append(style)
      }
    } else {
      currentTheme.value = savedTheme
    }
  }

  if (savedDarkMode !== null) {
    darkMode.value = savedDarkMode === 'true'
  }

  if (savedAnimations !== null) {
    animations.value = savedAnimations === 'true'
  }

  if (savedReverseMode !== null) {
    reverseMode.value = savedReverseMode === 'true'
  }

  // Apply initial settings
  applyDarkMode()
  applyAnimations()

  // Publish global settings
  window.microNoteSettings = {
    darkMode: darkMode.value,
    animations: animations.value,
    reverseMode: reverseMode.value,
  }
})
</script>

<style scoped>
/* 設定画面専用のスタイル */
.chat-header,
.chat-message,
.chat-input {
  transition: all 0.3s ease;
}

/* プレビューエリアのスタイル */
.preview-area {
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}
</style>
