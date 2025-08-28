<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-indigo-50">
    <div class="max-w-4xl mx-auto h-screen flex flex-col">
      <!-- デバッグ情報 -->
      <div v-if="showDebugInfo" class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-4 mx-8">
        <h3 class="text-sm font-medium text-yellow-800 mb-2">ChatView デバッグ情報</h3>
        <div class="text-xs text-yellow-700 space-y-1">
          <div>noteStore.notes: {{ typeof noteStore.notes }}</div>
          <div>noteStore.notes.value length: {{ noteStore.notes?.value?.length || 0 }}</div>
          <div>noteStore.notes.value: {{ JSON.stringify(noteStore.notes?.value) }}</div>
          <div>Filtered notes: {{ (noteStore.notes?.value || []).filter(note => note && note.id && note.content).length }}</div>
          <div>First note content: {{ noteStore.notes?.value?.[0]?.content || 'No content' }}</div>
        </div>
      </div>

      <!-- メッセージ入力エリア（上端固定） -->
      <div class="px-8 py-6 border-b border-gray-100 bg-white chat-input flex-shrink-0">
        <form @submit.prevent="sendMessage" class="space-y-4">
          <div class="relative">
            <textarea
              v-model="newMessage"
              ref="messageInput"
              rows="3"
              class="input-area block w-full rounded-2xl border-gray-200 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 resize-none transition-all duration-200 text-gray-900 placeholder-gray-400"
              placeholder="メモとして保存したい内容を入力してください..."
              @keydown="handleKeydown"
            ></textarea>

            <!-- 送信ボタン -->
            <button
              type="submit"
              :disabled="!newMessage.trim()"
              class="absolute bottom-3 right-3 inline-flex items-center justify-center w-10 h-10 rounded-xl shadow-lg text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 focus:outline-none focus:ring-2 focus:ring-blue-500/50 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
              </svg>
            </button>
          </div>

          <!-- ヘルプテキスト -->
          <div class="flex items-center justify-between text-xs text-gray-500">
            <div class="flex items-center space-x-4">
              <span class="flex items-center space-x-1">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
                <span>Enter で送信</span>
              </span>
              <span class="flex items-center space-x-1">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16l-4-4m0 0l4-4m-4 4h18" />
                </svg>
                <span>Shift + Enter で改行</span>
              </span>
            </div>

            <span class="text-blue-600 font-medium">
              {{ newMessage.length }} 文字
            </span>
          </div>
        </form>
      </div>

      <!-- メッセージ表示エリア（スクロール可能） -->
      <div class="flex-1 overflow-y-auto p-8 space-y-6 bg-gradient-to-b from-gray-50/50 to-white/50">
        <!-- メッセージ一覧 -->
        <template v-for="note in (noteStore.notes?.value || [])" :key="note?.id || Math.random()">
          <div
            v-if="note && note.id && note.content"
            class="flex items-start space-x-4"
          >
            <div class="flex-shrink-0">
              <div class="w-10 h-10 bg-gradient-to-r from-blue-500 to-indigo-600 rounded-full flex items-center justify-center">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              </div>
            </div>
            <div class="flex-1 min-w-0">
              <div class="bg-white rounded-2xl px-6 py-4 shadow-lg border border-gray-100 chat-message">
                <p class="text-gray-900 whitespace-pre-wrap leading-relaxed">{{ note.content }}</p>
              </div>
              <div class="mt-3 flex items-center space-x-3">
                <span class="text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded-full">
                  {{ formatTime(note.timestamp) }}
                </span>
                <span class="text-xs text-blue-600 bg-blue-50 px-2 py-1 rounded-full font-medium">
                  ✓ メモとして保存済み
                </span>
              </div>
            </div>
          </div>
        </template>

        <!-- メッセージがない場合 -->
        <div
          v-if="!noteStore.notes?.value || noteStore.notes?.value?.length === 0"
          class="text-center py-12"
        >
          <div class="w-16 h-16 bg-gradient-to-r from-blue-100 to-indigo-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
          </div>
          <h3 class="text-lg font-medium text-gray-900 mb-2">最初のメモを作成しましょう</h3>
          <p class="text-gray-500">下のテキストエリアにメモしたい内容を入力してください</p>
        </div>
      </div>


    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useNoteStore } from '../stores/noteStore'

const newMessage = ref('')
const messageInput = ref(null)
const noteStore = useNoteStore()
const showDebugInfo = ref(false)

// 設定画面からデバッグ情報の表示状態を取得
const updateDebugInfoState = () => {
  if (window.microNoteSettings) {
    showDebugInfo.value = window.microNoteSettings.debugInfo || false
  }
}





const handleKeydown = (event) => {
  // Enterキーが押された場合のみ処理
  if (event.keyCode === 13) {
    // Shift+Enterの場合は何もしない（改行を許可）
    if (event.shiftKey) {
      return
    }

    // 通常のEnterの場合は送信
    event.preventDefault()
    sendMessage()
  }
}

const sendMessage = async () => {
  const content = newMessage.value.trim()
  if (!content) return

  try {
    await noteStore.saveNote(content)
    newMessage.value = ''

    // 入力フィールドにフォーカスを戻す
    await nextTick()
    if (messageInput.value) {
      messageInput.value.focus()
    }
  } catch (error) {
    console.error('Failed to save note:', error)
    alert('メモの保存に失敗しました')
  }
}

const formatTime = (timestamp) => {
  return new Date(timestamp).toLocaleString('ja-JP')
}

const loadMessages = async () => {
  try {
    await noteStore.fetchNotes()
  } catch (error) {
    console.error('Failed to load messages:', error)
  }
}

onMounted(() => {
  loadMessages()

  // デバッグ情報の表示状態を初期化
  updateDebugInfoState()

  // 設定の変更を監視（1秒ごとにチェック）
  setInterval(() => {
    updateDebugInfoState()
  }, 1000)
})
</script>

<style scoped>

.input-area {
  padding: 10px;
}

/* カスタムスクロールバー */
.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: rgba(0, 0, 0, 0.05);
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.3);
}

/* アニメーション */
.message-enter-active {
  transition: all 0.3s ease;
}

.message-enter-from {
  opacity: 0;
  transform: translateY(20px);
}

.message-enter-to {
  opacity: 1;
  transform: translateY(0);
}
</style>
