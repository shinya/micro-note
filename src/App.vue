<script setup>
import { ref, onMounted } from 'vue'
import TimelineView from './components/TimelineView.vue'
import SettingsModal from './components/SettingsModal.vue'
import WindowBar from './components/WindowBar.vue'

const showSettings = ref(false)
const darkMode = ref(false)
const searchQuery = ref('')
const showFavorites = ref(false)

// Load and apply settings function
const loadAndApplySettings = () => {
  // Load settings from localStorage
  const savedDarkMode = localStorage.getItem('micro-note-dark-mode')
  const savedCustomCSS = localStorage.getItem('micro-note-custom-css')
  const savedReverseMode = localStorage.getItem('micro-note-reverse-mode')

  // Apply dark mode setting
  if (savedDarkMode !== null) {
    darkMode.value = savedDarkMode === 'true'
  }

  // Apply reverse mode setting
  if (savedReverseMode !== null) {
    window.microNoteSettings = window.microNoteSettings || {}
    window.microNoteSettings.reverseMode = savedReverseMode === 'true'
  }

  // Apply classes to HTML element
  const html = document.documentElement
  if (darkMode.value) {
    html.classList.add('dark')
    html.setAttribute('data-theme', 'dark')
  } else {
    html.classList.remove('dark')
    html.setAttribute('data-theme', 'light')
  }

  // Apply custom CSS
  if (savedCustomCSS) {
    const existingStyle = document.getElementById('custom-chat-css')
    if (existingStyle) {
      existingStyle.remove()
    }

    const style = document.createElement('style')
    style.id = 'custom-chat-css'
    style.textContent = savedCustomCSS
    document.head.appendChild(style)
  }

  // Update global settings
  window.microNoteSettings = {
    darkMode: darkMode.value,
    reverseMode: savedReverseMode === 'true' || false,
    customCSS: savedCustomCSS || ''
  }
}

// Get settings from settings screen and apply (monitor changes in settings screen)
const updateSettings = () => {
  if (window.microNoteSettings) {
    darkMode.value = window.microNoteSettings.darkMode || false

    const html = document.documentElement
    if (darkMode.value) {
      html.classList.add('dark')
      html.setAttribute('data-theme', 'dark')
    } else {
      html.classList.remove('dark')
      html.setAttribute('data-theme', 'light')
    }
  }
}

onMounted(() => {
  // Load and apply settings on app startup
  loadAndApplySettings()

  // Monitor settings changes (check every 1 second)
  setInterval(() => {
    updateSettings()
  }, 1000)
})
</script>

<template>
  <div class="app-container min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-100 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
    <!-- カスタムウィンドウバー -->
    <WindowBar />

    <!-- ヘッダー -->
    <header class="fixed-header bg-white/80 backdrop-blur-md shadow-lg border-b border-white/20 z-40 dark:bg-gray-800/80 dark:border-gray-700">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center space-x-3">
            <div class="w-8 h-8 bg-gradient-to-r from-blue-600 to-indigo-600 rounded-xl flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <h1
              :class="[
                'text-xl font-bold',
                darkMode
                  ? 'text-white'
                  : 'bg-gradient-to-r from-gray-900 to-gray-600 bg-clip-text text-transparent'
              ]"
            >
              Micro Note
            </h1>
          </div>

          <div class="flex items-center space-x-2 flex-1 max-w-sm ml-6">
            <div class="relative flex-1">
              <input
                v-model="searchQuery"
                type="text"
                :placeholder="$t('notes.searchPlaceholder')"
                class="w-full pl-8 pr-3 py-1.5 text-sm border border-gray-200 rounded-lg bg-white/60 focus:bg-white focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all duration-200 dark:bg-gray-700/60 dark:border-gray-600 dark:text-gray-200 dark:focus:bg-gray-700 dark:placeholder-gray-400"
              />
              <svg class="absolute left-2.5 top-1/2 transform -translate-y-1/2 w-3.5 h-3.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
          </div>

          <nav class="flex items-center space-x-1">
            <button
              @click="showFavorites = !showFavorites"
              class="p-2 rounded-xl transition-all duration-200"
              :class="showFavorites
                ? 'text-yellow-500 bg-yellow-50 dark:bg-yellow-500/20'
                : 'text-gray-600 hover:text-gray-900 hover:bg-white/60 dark:text-gray-200 dark:hover:text-white dark:hover:bg-gray-700/60'"
              :title="$t('notes.favorite')"
            >
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
              </svg>
            </button>
            <button
              @click="showSettings = !showSettings"
              class="p-2 rounded-xl transition-all duration-200 text-gray-600 hover:text-gray-900 hover:bg-white/60 dark:text-gray-200 dark:hover:text-white dark:hover:bg-gray-700/60"
              :title="$t('navigation.settings')"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
            </button>
          </nav>
        </div>
      </div>
    </header>

    <!-- メインコンテンツ -->
    <main class="main-content max-w-7xl mx-auto overflow-hidden">
      <TimelineView :searchQuery="searchQuery" :showFavorites="showFavorites" />
    </main>

    <!-- 設定モーダル -->
    <SettingsModal v-model="showSettings" />
  </div>
</template>

<style>
/* グローバルスタイル */
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

main {
  margin: 0;
  padding: 0;
}

/* 角丸ウィンドウのスタイル */
.app-container {
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

/* macOS風の角丸ウィンドウ */
@media (prefers-color-scheme: light) {
  .app-container {
    background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
  }
}

@media (prefers-color-scheme: dark) {
  .app-container {
    background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
  }
}

/* 固定ヘッダーのスタイル */
.fixed-header {
  position: fixed;
  top: 29px; /* WindowBarの高さ分下げる */
  left: 0;
  right: 0;
  z-index: 40;
}

/* メインコンテンツの位置調整 */
.main-content {
  padding-top: 94px; /* WindowBar + Header の高さ分のパディング */
  height: 100vh;
}

/* カスタムスクロールバー */
::-webkit-scrollbar {
  width: 8px;
}

::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.05);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.3);
}
</style>
