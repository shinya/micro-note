<template>
  <div class="max-w-5xl mx-auto dark:bg-gray-900 min-h-screen">
    <div class="bg-white/80 backdrop-blur-md rounded-2xl shadow-xl border border-white/20 overflow-hidden dark:bg-gray-800/80 dark:border-gray-700">
      <!-- 設定ヘッダー -->
      <div class="px-8 py-6 border-b border-gray-100 bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-gray-700 dark:to-gray-800 dark:border-gray-600 dark:bg-gradient-to-r dark:from-gray-800 dark:to-gray-900">
        <div class="flex items-center space-x-3">
          <div class="w-10 h-10 bg-gradient-to-r from-blue-600 to-indigo-600 rounded-xl flex items-center justify-center">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
          </div>
          <div>
            <h2 class="text-xl font-bold text-gray-900 dark:text-gray-100 dark:text-white">{{ $t('settings.title') }}</h2>
            <p class="text-sm text-gray-600 dark:text-gray-300 dark:text-gray-200">{{ $t('settings.subtitle') }}</p>
          </div>
        </div>
      </div>

      <!-- 設定コンテンツ -->
      <div class="p-8 space-y-8 dark:bg-gray-900">
        <!-- CSSカスタマイズセクション -->
        <div class="space-y-6">
          <div class="border-b border-gray-200 pb-4 dark:border-gray-600">
            <h3 class="text-lg font-semibold text-gray-900 mb-2 dark:text-gray-100">{{ $t('settings.chatUICustomization') }}</h3>
            <p class="text-sm text-gray-600 dark:text-gray-300">{{ $t('settings.chatUICustomizationDescription') }}</p>
          </div>

          <!-- プリセットテーマ -->
          <div class="space-y-4">
            <h4 class="text-md font-medium text-gray-900 dark:text-gray-100">{{ $t('settings.presetThemes') }}</h4>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <button
                v-for="theme in presetThemes"
                :key="theme.name"
                @click="applyTheme(theme)"
                :class="[
                  'p-4 rounded-xl border-2 transition-all duration-200 text-left',
                  currentTheme === theme.name
                    ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/20 dark:border-blue-400'
                    : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50 dark:border-gray-600 dark:hover:border-gray-500 dark:hover:bg-gray-700/50 dark:bg-gray-800'
                ]"
              >
                <div class="flex items-center space-x-3 mb-2">
                  <div :class="['w-4 h-4 rounded-full', theme.color]"></div>
                  <span class="font-medium text-gray-900 dark:text-gray-100">{{ theme.name }}</span>
                </div>
                <p class="text-sm text-gray-600 dark:text-gray-300">{{ theme.description }}</p>
              </button>
            </div>
          </div>

          <!-- カスタムCSSエディター -->
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <h4 class="text-md font-medium text-gray-900 dark:text-gray-100">{{ $t('settings.customCSS') }}</h4>
              <div class="flex space-x-2">
                <button
                  @click="resetCustomCSS"
                  class="px-3 py-1 text-sm text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors dark:text-gray-300 dark:hover:text-gray-100 dark:hover:bg-gray-700"
                >
                  {{ $t('settings.reset') }}
                </button>
                <button
                  @click="saveCustomCSS"
                  :disabled="saveButtonLoading"
                  :class="[
                    'px-4 py-2 text-sm font-medium rounded-lg transition-all duration-200 shadow-md hover:shadow-lg flex items-center space-x-2',
                    saveButtonLoading
                      ? 'bg-gray-400 cursor-not-allowed'
                      : 'text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700'
                  ]"
                >
                  <svg v-if="saveButtonLoading" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  <svg v-else class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                  </svg>
                  <span>{{ saveButtonText }}</span>
                </button>
              </div>
            </div>

            <div class="relative">
              <textarea
                v-model="customCSS"
                rows="12"
                class="block w-full rounded-xl border border-gray-200 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 resize-none font-mono text-sm dark:bg-gray-800 dark:border-gray-600 dark:text-gray-100 dark:placeholder-gray-400 pl-14"
                placeholder="/* カスタムCSSを入力してください */
.chat-message {
  /* メッセージのスタイル */
}

.chat-input {
  /* 入力フィールドのスタイル */
}

.chat-header {
  /* ヘッダーのスタイル */
}"
                @input="updateLineNumbers"
                @scroll="syncScroll"
                ref="cssTextarea"
              ></textarea>

              <!-- 行番号表示 -->
              <div class="absolute left-0 top-0 w-12 h-full bg-gray-50 border-r border-gray-200 rounded-l-xl pointer-events-none dark:bg-gray-700 dark:border-gray-600 overflow-hidden">
                <div
                  class="text-xs text-gray-400 text-right pr-2 pt-3 leading-6 dark:text-gray-500 transition-transform duration-100"
                  :style="{ transform: `translateY(${scrollOffset}px)` }"
                >
                  <div v-for="n in lineCount" :key="n" class="h-6 flex items-center justify-end">{{ n }}</div>
                </div>
              </div>
            </div>

            <p class="text-xs text-gray-500 dark:text-gray-400">
              {{ $t('settings.customCSSDescription') }}
            </p>
          </div>
        </div>

        <!-- プレビューセクション -->
        <div class="space-y-4">
          <h4 class="text-md font-medium text-gray-900">{{ $t('settings.preview') }}</h4>
          <div class="bg-gray-50 rounded-xl p-6 border border-gray-200 dark:bg-gray-800 dark:border-gray-600">
            <div class="max-w-md mx-auto">
              <!-- チャットヘッダーのプレビュー -->
              <div class="bg-white rounded-t-xl p-4 border-b border-gray-200 chat-header">
                <div class="flex items-center space-x-3">
                  <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
                    <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                    </svg>
                  </div>
                  <div>
                    <h5 class="font-medium text-gray-900">{{ $t('navigation.chat') }}</h5>
                    <p class="text-sm text-gray-500">{{ $t('settings.preview') }}</p>
                  </div>
                </div>
              </div>

              <!-- メッセージのプレビュー -->
              <div class="bg-white p-4 chat-message">
                <div class="flex items-start space-x-3">
                  <div class="w-6 h-6 bg-blue-500 rounded-full flex items-center justify-center flex-shrink-0">
                    <svg class="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                  </div>
                  <div class="bg-gray-100 rounded-lg px-3 py-2">
                    <p class="text-sm text-gray-900">{{ $t('settings.previewMessage') }}</p>
                  </div>
                </div>
              </div>

              <!-- 入力フィールドのプレビュー -->
              <div class="bg-white rounded-b-xl p-4 border-t border-gray-200 chat-input">
                <div class="flex space-x-2">
                  <input
                    type="text"
                    :placeholder="$t('chat.placeholder')"
                    class="flex-1 px-3 py-2 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
                    readonly
                  />
                  <button class="px-4 py-2 bg-blue-500 text-white rounded-lg text-sm">
                    {{ $t('chat.send') }}
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- プレビューの説明 -->
          <div class="text-center">
            <p class="text-sm text-gray-600 dark:text-gray-300">
              {{ $t('settings.previewDescription') }}
            </p>
          </div>
        </div>

        <!-- その他の設定 -->
        <div class="space-y-6">
          <div class="border-b border-gray-200 pb-4 dark:border-gray-600">
            <h3 class="text-lg font-semibold text-gray-900 mb-2 dark:text-gray-100">{{ $t('settings.otherSettings') }}</h3>
          </div>

          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <div>
                <h4 class="text-md font-medium text-gray-900 dark:text-gray-100">{{ $t('settings.darkMode') }}</h4>
                <p class="text-sm text-gray-600 dark:text-gray-300">{{ $t('settings.darkModeDescription') }}</p>
              </div>
              <button
                @click="toggleDarkMode"
                :class="[
                  'relative inline-flex h-6 w-11 items-center rounded-full transition-colors',
                  darkMode ? 'bg-blue-600' : 'bg-gray-200'
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
                <h4 class="text-md font-medium text-gray-900 dark:text-gray-100">{{ $t('settings.animations') }}</h4>
                <p class="text-sm text-gray-600 dark:text-gray-300">{{ $t('settings.animationsDescription') }}</p>
              </div>
              <button
                @click="toggleAnimations"
                :class="[
                  'relative inline-flex h-6 w-11 items-center rounded-full transition-colors',
                  animations ? 'bg-blue-600' : 'bg-gray-200'
                ]"
              >
                <span
                  :class="[
                    'inline-block h-4 w-4 transform rounded-full bg-white transition-transform',
                    animations ? 'translate-x-6' : 'translate-x-1'
                  ]"
                ></span>
              </button>
            </div>



            <!-- リバースモード -->
            <div class="flex items-center justify-between">
              <div>
                <h4 class="text-md font-medium text-gray-900 dark:text-gray-100">{{ $t('settings.reverseMode') }}</h4>
                <p class="text-sm text-gray-600 dark:text-gray-300">{{ $t('settings.reverseModeDescription') }}</p>
              </div>
              <button
                @click="toggleReverseMode"
                :class="[
                  'relative inline-flex h-6 w-11 items-center rounded-full transition-colors',
                  reverseMode ? 'bg-blue-600' : 'bg-gray-200'
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

            <!-- 言語選択 -->
            <div class="flex items-center justify-between">
              <div>
                <h4 class="text-md font-medium text-gray-900 dark:text-gray-100">{{ $t('settings.language') }}</h4>
                <p class="text-sm text-gray-600 dark:text-gray-300">{{ $t('settings.languageDescription') }}</p>
              </div>
              <select
                v-model="currentLanguage"
                @change="changeLanguage"
                class="px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 dark:bg-gray-800 dark:border-gray-600 dark:text-gray-100"
              >
                <option value="en">{{ $t('settings.languages.en') }}</option>
                <option value="ja">{{ $t('settings.languages.ja') }}</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 保存成功通知トースト -->
    <div
      v-if="showSaveSuccess"
      class="fixed bottom-4 left-4 z-50 transform transition-all duration-300 ease-in-out"
      :class="showSaveSuccess ? 'translate-y-0 opacity-100' : 'translate-y-full opacity-0'"
    >
      <div class="bg-green-500 text-white px-6 py-4 rounded-lg shadow-lg flex items-center space-x-3">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
        </svg>
        <span class="font-medium">{{ $t('settings.saveSuccess') }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { setLocale, getCurrentLocale } from '../i18n'

const { t } = useI18n()

const currentTheme = ref(t('themes.default.name'))
const customCSS = ref('')
const darkMode = ref(false)
const animations = ref(true)
const reverseMode = ref(false)
const lineCount = ref(12)
const scrollOffset = ref(0)
const cssTextarea = ref(null)
const showSaveSuccess = ref(false)
const saveButtonText = ref(t('settings.save'))
const saveButtonLoading = ref(false)
const currentLanguage = ref(getCurrentLocale())

// Create a function to get preset themes with current translations
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
}`
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
}`
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
}`
  }
]

// Create a computed property for preset themes that updates when locale changes
const presetThemes = computed(() => getPresetThemes())

const applyTheme = (theme) => {
  currentTheme.value = theme.name
  customCSS.value = theme.css
  applyCustomCSS()
  saveCustomCSS() // テーマ適用時に自動保存
}

const applyCustomCSS = () => {
  // 既存のカスタムCSSを削除
  const existingStyle = document.getElementById('custom-chat-css')
  if (existingStyle) {
    existingStyle.remove()
  }

  // 新しいカスタムCSSを適用
  if (customCSS.value.trim()) {
    const style = document.createElement('style')
    style.id = 'custom-chat-css'
    style.textContent = customCSS.value
    document.head.appendChild(style)
  }
}

const saveCustomCSS = async () => {
  // Start loading state
  saveButtonLoading.value = true
  saveButtonText.value = t('settings.saving')

  try {
    // Add a small delay for loading effect
    await new Promise(resolve => setTimeout(resolve, 500))

    localStorage.setItem('micro-note-custom-css', customCSS.value)
    localStorage.setItem('micro-note-current-theme', currentTheme.value)
    localStorage.setItem('micro-note-dark-mode', darkMode.value)
    localStorage.setItem('micro-note-animations', animations.value)
    localStorage.setItem('micro-note-reverse-mode', reverseMode.value)

    // Publish settings globally (accessible from other components)
    window.microNoteSettings = {
      darkMode: darkMode.value,
      animations: animations.value,
      reverseMode: reverseMode.value,
      customCSS: customCSS.value
    }

    // Show success notification
    showSaveSuccess.value = true
    saveButtonText.value = t('settings.saved')

    // Hide notification after 3 seconds
    setTimeout(() => {
      showSaveSuccess.value = false
    }, 3000)

    // Reset button text after 1 second
    setTimeout(() => {
      saveButtonText.value = t('settings.save')
    }, 1000)

  } catch (error) {
    console.error('Failed to save settings:', error)
    saveButtonText.value = t('settings.saveError')
  } finally {
    saveButtonLoading.value = false
  }
}

const resetCustomCSS = () => {
  customCSS.value = ''
  currentTheme.value = getPresetThemes()[0].name // Default theme
  darkMode.value = false
  animations.value = true
  reverseMode.value = false

  applyCustomCSS()
  applyDarkMode()
  applyAnimations()

  localStorage.removeItem('micro-note-custom-css')
  localStorage.removeItem('micro-note-current-theme')
  localStorage.removeItem('micro-note-dark-mode')
  localStorage.removeItem('micro-note-animations')
  localStorage.removeItem('micro-note-reverse-mode')

  // Update global settings too
  window.microNoteSettings = {
    darkMode: false,
    animations: true,
    reverseMode: false,
    customCSS: ''
  }
}

const toggleDarkMode = () => {
  darkMode.value = !darkMode.value
  applyDarkMode()
  saveCustomCSS()
}

const toggleAnimations = () => {
  animations.value = !animations.value
  applyAnimations()
  saveCustomCSS()
}

const toggleReverseMode = () => {
  reverseMode.value = !reverseMode.value
  saveCustomCSS()
}

const changeLanguage = (event) => {
  const newLocale = event.target.value
  setLocale(newLocale)

  // Update current theme name to match new language
  const currentThemeName = currentTheme.value
  const updatedThemes = getPresetThemes()
  const matchingTheme = updatedThemes.find(theme =>
    theme.name === currentThemeName ||
    theme.css === customCSS.value
  )
  if (matchingTheme) {
    currentTheme.value = matchingTheme.name
  }

  saveCustomCSS()
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

const applyAnimations = () => {
  const html = document.documentElement
  if (animations.value) {
    html.classList.add('animations-enabled')
    html.setAttribute('data-animations', 'enabled')
  } else {
    html.classList.remove('animations-enabled')
    html.setAttribute('data-animations', 'disabled')
  }
}

// Function to update line numbers
const updateLineNumbers = () => {
  if (customCSS.value) {
    const lines = customCSS.value.split('\n')
    lineCount.value = Math.max(lines.length, 12)
  } else {
    lineCount.value = 12
  }
}

// Function to sync scroll
const syncScroll = () => {
  if (cssTextarea.value) {
    scrollOffset.value = -cssTextarea.value.scrollTop
  }
}

// Monitor custom CSS changes
watch(customCSS, () => {
  applyCustomCSS()
  updateLineNumbers()
})

onMounted(() => {
  // Load saved settings
  const savedCSS = localStorage.getItem('micro-note-custom-css')
  const savedTheme = localStorage.getItem('micro-note-current-theme')
  const savedDarkMode = localStorage.getItem('micro-note-dark-mode')
  const savedAnimations = localStorage.getItem('micro-note-animations')
  const savedReverseMode = localStorage.getItem('micro-note-reverse-mode')

  if (savedCSS) {
    customCSS.value = savedCSS
  }

  if (savedTheme) {
    // Try to find the theme by name or CSS content
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

  if (savedAnimations !== null) {
    animations.value = savedAnimations === 'true'
  }

  if (savedReverseMode !== null) {
    reverseMode.value = savedReverseMode === 'true'
  }

  // Apply initial settings
  applyCustomCSS()
  applyDarkMode()
  applyAnimations()
  updateLineNumbers()

  // Publish global settings
  window.microNoteSettings = {
    darkMode: darkMode.value,
    animations: animations.value,
    reverseMode: reverseMode.value,
    customCSS: customCSS.value
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
