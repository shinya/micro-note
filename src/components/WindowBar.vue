<template>
  <div class="custom-window-bar bg-gray-100 dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700">
    <div class="flex items-center justify-between px-4">
      <!-- 左側: ウィンドウコントロールボタン -->
      <div class="flex items-center space-x-2">
        <button
          @click="closeWindow"
          class="w-3 h-3 bg-red-500 rounded-full hover:bg-red-600 transition-colors duration-200 flex items-center justify-center group"
          title="閉じる"
          data-tauri-drag-region="false"
        >
          <svg class="w-2 h-2 text-red-500 group-hover:text-white opacity-0 group-hover:opacity-100 transition-opacity duration-200" fill="currentColor" viewBox="0 0 24 24">
            <path d="M6 6l12 12M6 18L18 6"/>
          </svg>
        </button>
        <button
          @click="minimizeWindow"
          class="w-3 h-3 bg-yellow-500 rounded-full hover:bg-yellow-600 transition-colors duration-200 flex items-center justify-center group"
          title="最小化"
          data-tauri-drag-region="false"
        >
          <svg class="w-2 h-2 text-yellow-500 group-hover:text-white opacity-0 group-hover:opacity-100 transition-opacity duration-200" fill="currentColor" viewBox="0 0 24 24">
            <path d="M6 12h12"/>
          </svg>
        </button>
        <button
          @click="maximizeWindow"
          class="w-3 h-3 bg-green-500 rounded-full hover:bg-green-600 transition-colors duration-200 flex items-center justify-center group"
          title="最大化"
          data-tauri-drag-region="false"
        >
          <svg class="w-2 h-2 text-green-500 group-hover:text-white opacity-0 group-hover:opacity-100 transition-opacity duration-200" fill="currentColor" viewBox="0 0 24 24">
            <path d="M8 3H5a2 2 0 00-2 2v3m18 0V5a2 2 0 00-2-2h-3m0 18h3a2 2 0 002-2v-3M3 16v3a2 2 0 002 2h3"/>
          </svg>
        </button>
      </div>

      <!-- 中央: アプリタイトル（ドラッグ可能エリア） -->
      <div class="flex-1 text-center drag-area" data-tauri-drag-region="true">
        <h1 class="app-title text-sm font-semibold text-gray-800 dark:text-white py-1">Micro Note</h1>
      </div>

      <!-- 右側: スペーサー（左右対称にするため） -->
      <div class="w-20" data-tauri-drag-region="true"></div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

// Tauri環境かどうかを判定
const isTauriEnv = ref(false)
const appWindow = ref(null)

// 初期化時にTauri環境をチェック
onMounted(async () => {
  try {
    // Tauri v2の正しいインポート方法
    const { getCurrentWindow } = await import('@tauri-apps/api/window')
    console.log('WindowBar: Imported getCurrentWindow:', getCurrentWindow)

    // 現在のウィンドウを取得
    const currentWindow = getCurrentWindow()
    console.log('WindowBar: Current window:', currentWindow)

    if (currentWindow) {
      appWindow.value = currentWindow
      isTauriEnv.value = true
      console.log('WindowBar: Tauri環境で動作中')
      console.log('WindowBar: appWindow object:', appWindow.value)
    } else {
      console.error('WindowBar: 現在のウィンドウを取得できませんでした')
      isTauriEnv.value = false
    }

  } catch (error) {
    console.log('WindowBar: ブラウザ環境で動作中:', error.message)
    isTauriEnv.value = false
  }
})

// ウィンドウコントロール関数
const closeWindow = async () => {
  if (isTauriEnv.value && appWindow.value) {
    try {
      await appWindow.value.close()
    } catch (error) {
      console.error('ウィンドウを閉じる際にエラーが発生しました:', error)
    }
  } else {
    console.log('ブラウザ環境ではウィンドウを閉じることができません')
  }
}

const minimizeWindow = async () => {
  if (isTauriEnv.value && appWindow.value) {
    try {
      await appWindow.value.minimize()
    } catch (error) {
      console.error('ウィンドウを最小化する際にエラーが発生しました:', error)
    }
  } else {
    console.log('ブラウザ環境ではウィンドウを最小化することができません')
  }
}

const maximizeWindow = async () => {
  if (isTauriEnv.value && appWindow.value) {
    try {
      const isMaximized = await appWindow.value.isMaximized()
      if (isMaximized) {
        await appWindow.value.unmaximize()
      } else {
        await appWindow.value.maximize()
      }
    } catch (error) {
      console.error('ウィンドウの最大化/復元時にエラーが発生しました:', error)
    }
  } else {
    console.log('ブラウザ環境ではウィンドウの最大化/復元ができません')
  }
}
</script>

<style scoped>

.dark .app-title {
  font-size: 12px;
  color: #f0f0f0;
}

.custom-window-bar {
  user-select: none; /* テキスト選択を無効化 */
  position: fixed; /* 固定位置に設定 */
  top: 0; /* 最上部に配置 */
  left: 0; /* 左端に配置 */
  right: 0; /* 右端まで広げる */
  z-index: 1000; /* 他の要素より前面に表示 */
  background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%);
  border-bottom: 1px solid #e2e8f0;
}

.dark .custom-window-bar {
  background: linear-gradient(135deg, #334155 0%, #1e293b 100%);
  border-bottom: 1px solid #475569;
}

/* ドラッグ可能エリア */
.drag-area {
  cursor: grab; /* ドラッグ可能を示すカーソル */
  padding: 0;
}

.drag-area:active {
  cursor: grabbing; /* ドラッグ中はgrabbingカーソル */
}

/* ボタンはドラッグ不可 */
.custom-window-bar button {
  cursor: pointer;
}

.custom-window-bar button:hover {
  transform: scale(1.1);
  transition: transform 0.1s ease;
}

/* ボタンのアクティブ状態 */
.custom-window-bar button:active {
  transform: scale(0.95);
}

/* ドラッグ可能エリアのホバー効果 */
.drag-area:hover {
  background-color: rgba(0, 0, 0, 0.05);
  border-radius: 8px;
  transition: background-color 0.2s ease;
}

.drag-area:hover:active {
  background-color: rgba(0, 0, 0, 0.1);
}

/* macOS風のボタンスタイル */
.custom-window-bar button {
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.2s ease;
}

.custom-window-bar button:hover {
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
}

/* タイトルテキストもドラッグ可能にする */
.drag-area h1 {
  pointer-events: none; /* テキストの選択を防ぐ */
}
</style>
