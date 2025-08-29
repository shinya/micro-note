<script setup>
import { ref, onMounted, watch } from 'vue'
import ChatView from './components/ChatView.vue'
import NotesView from './components/NotesView.vue'
import SettingsView from './components/SettingsView.vue'
import WindowBar from './components/WindowBar.vue'

const currentView = ref('chat')
const darkMode = ref(false)
const animations = ref(true)

const handleNoteAdded = () => {
  // Note added handler
  console.log('Note added')
}

// Load and apply settings function
const loadAndApplySettings = () => {
  // Load settings from localStorage
  const savedDarkMode = localStorage.getItem('micro-note-dark-mode')
  const savedAnimations = localStorage.getItem('micro-note-animations')
  const savedCustomCSS = localStorage.getItem('micro-note-custom-css')
  const savedReverseMode = localStorage.getItem('micro-note-reverse-mode')

  // Apply dark mode setting
  if (savedDarkMode !== null) {
    darkMode.value = savedDarkMode === 'true'
  }

  // Apply animation setting
  if (savedAnimations !== null) {
    animations.value = savedAnimations === 'true'
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

  if (animations.value) {
    html.classList.add('animations-enabled')
    html.setAttribute('data-animations', 'enabled')
  } else {
    html.classList.remove('animations-enabled')
    html.setAttribute('data-animations', 'disabled')
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
    animations: animations.value,
    reverseMode: savedReverseMode === 'true' || false,
    customCSS: savedCustomCSS || ''
  }
}

// Get settings from settings screen and apply (monitor changes in settings screen)
const updateSettings = () => {
  if (window.microNoteSettings) {
    darkMode.value = window.microNoteSettings.darkMode || false
    animations.value = window.microNoteSettings.animations || true
    // Note: reverseMode is handled in ChatView component

    // Apply classes to HTML element
    const html = document.documentElement
    if (darkMode.value) {
      html.classList.add('dark')
      html.setAttribute('data-theme', 'dark')
    } else {
      html.classList.remove('dark')
      html.setAttribute('data-theme', 'light')
    }

    if (animations.value) {
      html.classList.add('animations-enabled')
      html.setAttribute('data-animations', 'enabled')
    } else {
      html.classList.remove('animations-enabled')
      html.setAttribute('data-animations', 'disabled')
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

          <nav class="flex items-center space-x-2">
            <button
              @click="currentView = 'chat'"
              :class="[
                'px-4 py-2 text-sm font-medium rounded-xl transition-all duration-200',
                currentView === 'chat'
                  ? 'bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-lg shadow-blue-500/25'
                  : 'text-gray-600 hover:text-gray-900 hover:bg-white/60 dark:text-gray-200 dark:hover:text-white dark:hover:bg-gray-700/60'
              ]"
            >
              <div class="flex items-center space-x-2">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                </svg>
                <span>{{ $t('navigation.chat') }}</span>
              </div>
            </button>

            <button
              @click="currentView = 'notes'"
              :class="[
                'px-4 py-2 text-sm font-medium rounded-xl transition-all duration-200',
                currentView === 'notes'
                  ? 'bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-lg shadow-blue-500/25'
                  : 'text-gray-600 hover:text-gray-900 hover:bg-white/60 dark:text-gray-200 dark:hover:text-white dark:hover:bg-gray-700/60'
              ]"
            >
              <div class="flex items-center space-x-2">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                </svg>
                <span>{{ $t('navigation.notes') }}</span>
              </div>
            </button>

            <button
              @click="currentView = 'settings'"
              :class="[
                'px-4 py-2 text-sm font-medium rounded-xl transition-all duration-200',
                currentView === 'settings'
                  ? 'bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-lg shadow-blue-500/25'
                  : 'text-gray-600 hover:text-gray-900 hover:bg-white/60 dark:text-gray-200 dark:hover:text-white dark:hover:bg-gray-700/60'
              ]"
            >
              <div class="flex items-center space-x-2">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
                <span>{{ $t('navigation.settings') }}</span>
              </div>
            </button>
          </nav>
        </div>
      </div>
    </header>

    <!-- メインコンテンツ -->
    <main class="main-content max-w-7xl mx-auto">
      <!-- チャット画面 -->
      <ChatView v-if="currentView === 'chat'" @note-added="handleNoteAdded" />

      <!-- メモ一覧画面 -->
      <NotesView v-else-if="currentView === 'notes'" />

      <!-- 設定画面 -->
      <SettingsView v-else-if="currentView === 'settings'" />
    </main>
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
