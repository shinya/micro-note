<script setup>
import { ref, onMounted, watch } from 'vue'
import ChatView from './components/ChatView.vue'
import NotesView from './components/NotesView.vue'
import SettingsView from './components/SettingsView.vue'

const currentView = ref('chat')
const darkMode = ref(false)
const animations = ref(true)

const handleNoteAdded = () => {
  // メモが追加された時の処理
  console.log('Note added')
}

// 設定画面から設定を取得して適用
const updateSettings = () => {
  if (window.microNoteSettings) {
    darkMode.value = window.microNoteSettings.darkMode || false
    animations.value = window.microNoteSettings.animations || true

    // HTML要素にクラスを適用
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
  // 初期設定を適用
  updateSettings()

  // 設定の変更を監視（1秒ごとにチェック）
  setInterval(() => {
    updateSettings()
  }, 1000)
})
</script>

<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-100 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
    <!-- ヘッダー -->
    <header class="bg-white/80 backdrop-blur-md shadow-lg border-b border-white/20 sticky top-0 z-50 dark:bg-gray-800/80 dark:border-gray-700">
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
                <span>チャット</span>
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
                <span>メモ一覧</span>
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
                <span>設定</span>
              </div>
            </button>
          </nav>
        </div>
      </div>
    </header>

    <!-- メインコンテンツ -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
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
