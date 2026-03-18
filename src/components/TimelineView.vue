<template>
  <div class="h-full bg-gradient-to-br from-blue-50 via-white to-indigo-50">
    <div class="max-w-4xl mx-auto h-full flex flex-col">
      <!-- 入力エリア（標準モード: 上部） -->
      <div
        v-if="!reverseMode"
        class="px-8 py-6 bg-white chat-input border-b border-gray-100"
      >
        <form class="space-y-4" @submit.prevent="sendMessage">
          <!-- ラベル選択 -->
          <div
            v-if="labelStore.labels.value && labelStore.labels.value.length > 0"
            class="flex items-center gap-2"
          >
            <select
              v-model="selectedLabelId"
              class="text-xs px-2 py-1 border border-gray-200 rounded-lg bg-white focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-gray-200"
            >
              <option :value="undefined">{{ $t('notes.noLabel') }}</option>
              <option
                v-for="label in labelStore.labels.value"
                :key="label.id"
                :value="label.id"
              >
                {{ label.name }}
              </option>
            </select>
            <span
              v-if="selectedLabelId"
              class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
              :style="{
                backgroundColor:
                  (
                    labelStore.labels.value.find(
                      l => l.id === selectedLabelId
                    ) || {}
                  ).color || '#6B7280',
                color: getTextColor(
                  (
                    labelStore.labels.value.find(
                      l => l.id === selectedLabelId
                    ) || {}
                  ).color
                ),
              }"
            >
              {{
                (
                  labelStore.labels.value.find(l => l.id === selectedLabelId) ||
                  {}
                ).name
              }}
            </span>
          </div>
          <div class="relative">
            <textarea
              ref="messageInput"
              v-model="newMessage"
              rows="3"
              class="input-area block w-full rounded-2xl border-gray-200 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 resize-none transition-all duration-200 text-gray-900 placeholder-gray-400"
              :placeholder="$t('chat.placeholder')"
              @keydown="handleKeydown"
            ></textarea>
            <button
              type="submit"
              :disabled="!newMessage.trim()"
              class="absolute bottom-3 right-3 inline-flex items-center justify-center w-10 h-10 rounded-xl shadow-lg text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 focus:outline-none focus:ring-2 focus:ring-blue-500/50 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
            >
              <svg
                class="w-5 h-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                />
              </svg>
            </button>
          </div>
          <div class="flex items-center justify-between text-xs text-gray-500">
            <div class="flex items-center space-x-4">
              <span class="flex items-center space-x-1">
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
                    d="M13 10V3L4 14h7v7l9-11h-7z"
                  />
                </svg>
                <span>{{ $t('chat.enterToSend') }}</span>
              </span>
              <span class="flex items-center space-x-1">
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
                    d="M7 16l-4-4m0 0l4-4m-4 4h18"
                  />
                </svg>
                <span>{{ $t('chat.shiftEnterNewline') }}</span>
              </span>
            </div>
            <span class="text-blue-600 font-medium">
              {{ $t('chat.characterCount', { count: newMessage.length }) }}
            </span>
          </div>
        </form>
      </div>

      <!-- メモ一覧（スクロール可能） -->
      <div
        class="flex-1 overflow-y-auto bg-gradient-to-b from-gray-50/50 to-white/50 chat-messages"
      >
        <div class="px-6 py-4 space-y-3">
          <template
            v-for="note in filteredNotes"
            :key="note?.id || Math.random()"
          >
            <div
              v-if="note && note.id && note.content"
              class="note-item flex items-center gap-3"
            >
              <!-- お気に入りボタン（左） -->
              <button
                class="flex-shrink-0 p-1.5 rounded-lg transition-all duration-200"
                :class="
                  note.is_favorite
                    ? 'text-yellow-500 hover:bg-yellow-50'
                    : 'text-gray-300 hover:text-yellow-500 hover:bg-yellow-50'
                "
                @click.stop="toggleFavorite(note.id, !note.is_favorite)"
              >
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                  <path
                    d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
                  />
                </svg>
              </button>

              <!-- メモカード（中央） -->
              <div
                class="flex-1 min-w-0 bg-white rounded-2xl px-5 py-3 shadow-md border border-gray-100 chat-message cursor-pointer hover:shadow-lg transition-shadow duration-200"
                :title="$t('notes.clickToCopy')"
                @click="copyToClipboard(note.content)"
              >
                <!-- ラベルバッジ / ラベル付替え -->
                <div
                  v-if="
                    labelStore.labels.value &&
                    labelStore.labels.value.length > 0
                  "
                  class="relative inline-block mb-1"
                >
                  <button
                    v-if="getLabelForNote(note)"
                    class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium transition-opacity hover:opacity-80"
                    :style="{
                      backgroundColor: getLabelForNote(note).color,
                      color: getTextColor(getLabelForNote(note).color),
                    }"
                    @click.stop="toggleLabelPopup(note.id)"
                  >
                    {{ getLabelForNote(note).name }}
                  </button>
                  <button
                    v-else
                    class="inline-flex items-center px-1.5 py-0.5 rounded-full text-xs text-gray-400 border border-dashed border-gray-300 hover:border-gray-400 hover:text-gray-500 transition-colors"
                    @click.stop="toggleLabelPopup(note.id)"
                  >
                    +
                  </button>
                  <!-- ラベル選択ポップアップ -->
                  <div
                    v-if="labelPopupNoteId === note.id"
                    class="absolute left-0 top-full mt-1 z-50 bg-white dark:bg-gray-700 rounded-lg shadow-lg border border-gray-200 dark:border-gray-600 py-1 min-w-[120px]"
                  >
                    <button
                      class="w-full text-left px-3 py-1.5 text-xs text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-600"
                      @click.stop="changeNoteLabel(note.id, undefined)"
                    >
                      {{ $t('notes.noLabel') }}
                    </button>
                    <button
                      v-for="label in labelStore.labels.value"
                      :key="label.id"
                      class="w-full text-left px-3 py-1.5 text-xs hover:bg-gray-100 dark:hover:bg-gray-600 flex items-center gap-2"
                      @click.stop="changeNoteLabel(note.id, label.id)"
                    >
                      <span
                        class="w-3 h-3 rounded-full flex-shrink-0"
                        :style="{ backgroundColor: label.color }"
                      ></span>
                      <span class="dark:text-gray-200">{{ label.name }}</span>
                    </button>
                  </div>
                </div>
                <p
                  class="text-gray-900 whitespace-pre-wrap leading-relaxed text-sm"
                >
                  {{ note.content }}
                </p>
                <span class="text-xs text-gray-400 mt-1.5 block">
                  {{ formatTime(note.timestamp) }}
                </span>
              </div>

              <!-- 削除ボタン（右） -->
              <button
                class="flex-shrink-0 p-1.5 rounded-lg text-gray-300 hover:text-red-500 hover:bg-red-50 transition-all duration-200"
                :title="$t('notes.deleteNote')"
                @click.stop="deleteNote(note.id)"
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
            </div>
          </template>

          <!-- メモがない場合 -->
          <div v-if="filteredNotes.length === 0" class="text-center py-12">
            <div
              class="w-16 h-16 bg-gradient-to-r from-blue-100 to-indigo-100 rounded-full flex items-center justify-center mx-auto mb-4"
            >
              <svg
                class="w-8 h-8 text-blue-500"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                />
              </svg>
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">
              {{
                props.searchQuery
                  ? $t('notes.noSearchResults')
                  : $t('chat.createFirstNote')
              }}
            </h3>
            <p class="text-gray-500">
              {{
                props.searchQuery
                  ? $t('notes.noSearchResultsMessage')
                  : $t('chat.createFirstNoteDescription')
              }}
            </p>
          </div>
        </div>
      </div>

      <!-- 入力エリア（リバースモード: 下部） -->
      <div
        v-if="reverseMode"
        class="px-8 py-6 bg-white chat-input border-t border-gray-100"
      >
        <form class="space-y-4" @submit.prevent="sendMessage">
          <!-- ラベル選択 -->
          <div
            v-if="labelStore.labels.value && labelStore.labels.value.length > 0"
            class="flex items-center gap-2"
          >
            <select
              v-model="selectedLabelId"
              class="text-xs px-2 py-1 border border-gray-200 rounded-lg bg-white focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-gray-200"
            >
              <option :value="undefined">{{ $t('notes.noLabel') }}</option>
              <option
                v-for="label in labelStore.labels.value"
                :key="label.id"
                :value="label.id"
              >
                {{ label.name }}
              </option>
            </select>
            <span
              v-if="selectedLabelId"
              class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
              :style="{
                backgroundColor:
                  (
                    labelStore.labels.value.find(
                      l => l.id === selectedLabelId
                    ) || {}
                  ).color || '#6B7280',
                color: getTextColor(
                  (
                    labelStore.labels.value.find(
                      l => l.id === selectedLabelId
                    ) || {}
                  ).color
                ),
              }"
            >
              {{
                (
                  labelStore.labels.value.find(l => l.id === selectedLabelId) ||
                  {}
                ).name
              }}
            </span>
          </div>
          <div class="relative">
            <textarea
              ref="messageInputReverse"
              v-model="newMessage"
              rows="3"
              class="input-area block w-full rounded-2xl border-gray-200 shadow-sm focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 resize-none transition-all duration-200 text-gray-900 placeholder-gray-400"
              :placeholder="$t('chat.placeholder')"
              @keydown="handleKeydown"
            ></textarea>
            <button
              type="submit"
              :disabled="!newMessage.trim()"
              class="absolute bottom-3 right-3 inline-flex items-center justify-center w-10 h-10 rounded-xl shadow-lg text-white bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 focus:outline-none focus:ring-2 focus:ring-blue-500/50 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
            >
              <svg
                class="w-5 h-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                />
              </svg>
            </button>
          </div>
          <div class="flex items-center justify-between text-xs text-gray-500">
            <div class="flex items-center space-x-4">
              <span class="flex items-center space-x-1">
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
                    d="M13 10V3L4 14h7v7l9-11h-7z"
                  />
                </svg>
                <span>{{ $t('chat.enterToSend') }}</span>
              </span>
              <span class="flex items-center space-x-1">
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
                    d="M7 16l-4-4m0 0l4-4m-4 4h18"
                  />
                </svg>
                <span>{{ $t('chat.shiftEnterNewline') }}</span>
              </span>
            </div>
            <span class="text-blue-600 font-medium">
              {{ $t('chat.characterCount', { count: newMessage.length }) }}
            </span>
          </div>
        </form>
      </div>
    </div>

    <!-- トースト通知 -->
    <div
      v-if="showToast"
      class="fixed bottom-4 left-4 z-50 transform transition-all duration-300 ease-in-out"
      :class="
        showToast ? 'translate-y-0 opacity-100' : 'translate-y-full opacity-0'
      "
    >
      <div
        class="bg-green-500 text-white px-6 py-4 rounded-lg shadow-lg flex items-center space-x-3"
      >
        <svg
          class="w-5 h-5"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M5 13l4 4L19 7"
          ></path>
        </svg>
        <span class="font-medium">{{ toastMessage }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import { useI18n } from 'vue-i18n'

import { useLabelStore } from '../stores/labelStore'
import { useNoteStore } from '../stores/noteStore'

const props = defineProps({
  searchQuery: { type: String, default: '' },
  showFavorites: { type: Boolean, default: false },
  labelFilter: { type: String, default: undefined },
})

const { t } = useI18n()
const noteStore = useNoteStore()
const labelStore = useLabelStore()

// Input state
const newMessage = ref('')
const messageInput = ref(undefined)
const messageInputReverse = ref(undefined)
const selectedLabelId = ref(undefined)

// Label change popup
const labelPopupNoteId = ref(undefined)

// UI state
const reverseMode = ref(false)
const showToast = ref(false)
const toastMessage = ref('')

// Label helpers
const getLabelForNote = note => {
  if (!note.label_id) return undefined
  return labelStore.labels.value.find(l => l.id === note.label_id)
}

const getTextColor = bgColor => {
  if (!bgColor) return '#FFFFFF'
  const hex = bgColor.replace('#', '')
  const r = Number.parseInt(hex.slice(0, 2), 16)
  const g = Number.parseInt(hex.slice(2, 4), 16)
  const b = Number.parseInt(hex.slice(4, 6), 16)
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  return luminance > 0.5 ? '#1F2937' : '#FFFFFF'
}

const toggleLabelPopup = noteId => {
  labelPopupNoteId.value =
    labelPopupNoteId.value === noteId ? undefined : noteId
}

const changeNoteLabel = async (noteId, labelId) => {
  try {
    await noteStore.updateNoteLabel(noteId, labelId)
  } catch {
    // silent
  }
  labelPopupNoteId.value = undefined
}

// Filtered and sorted notes
const filteredNotes = computed(() => {
  let notes = noteStore.notes.value || []
  if (props.showFavorites) {
    notes = noteStore.favoriteNotes.value || []
  }
  if (props.searchQuery.trim()) {
    const query = props.searchQuery.toLowerCase()
    notes = notes.filter(note => note.content.toLowerCase().includes(query))
  }
  if (props.labelFilter !== undefined) {
    notes =
      props.labelFilter === '__none__'
        ? notes.filter(note => !note.label_id)
        : notes.filter(note => note.label_id === props.labelFilter)
  }
  if (reverseMode.value) {
    return [...notes].reverse()
  }
  return notes
})

// Reverse mode
const updateReverseModeState = () => {
  if (window.microNoteSettings) {
    const newReverseMode = window.microNoteSettings.reverseMode || false
    if (reverseMode.value !== newReverseMode) {
      reverseMode.value = newReverseMode
    }
  }
}

// Keyboard handling
const handleKeydown = event => {
  if (event.keyCode === 13) {
    if (event.shiftKey) return
    event.preventDefault()
    sendMessage()
  }
}

// Send message
const sendMessage = async () => {
  const content = newMessage.value.trim()
  if (!content) return

  try {
    await noteStore.saveNote(content, selectedLabelId.value)
    newMessage.value = ''
    selectedLabelId.value = undefined

    await nextTick()
    const input = messageInput.value || messageInputReverse.value
    if (input) {
      input.focus()
    }
  } catch {
    // silent
  }
}

// Note actions
const toggleFavorite = async (id, isFavorite) => {
  try {
    await noteStore.updateFavorite(id, isFavorite)
  } catch {
    // silent
  }
}

const deleteNote = async id => {
  const note = noteStore.notes.value?.find(n => n.id === id)
  if (!note) return

  try {
    await noteStore.deleteNote(id)
  } catch {
    showToastMessage(t('notes.deleteError'))
  }
}

const copyToClipboard = async text => {
  try {
    if (navigator.clipboard) {
      await navigator.clipboard.writeText(text)
    } else {
      const textArea = document.createElement('textarea')
      textArea.value = text
      document.body.append(textArea)
      textArea.select()
      document.execCommand('copy')
      textArea.remove()
    }
    showToastMessage(t('notes.copiedToClipboard'))
  } catch {
    showToastMessage(t('notes.copyError'))
  }
}

const showToastMessage = message => {
  toastMessage.value = message
  showToast.value = true
  setTimeout(() => {
    showToast.value = false
  }, 3000)
}

const formatTime = timestamp => {
  return new Date(timestamp).toLocaleString('ja-JP')
}

onMounted(async () => {
  await noteStore.fetchNotes()
  await labelStore.fetchLabels()
  updateReverseModeState()
  setInterval(() => {
    updateReverseModeState()
  }, 1000)

  // ラベルポップアップの外クリックで閉じる
  document.addEventListener('click', () => {
    labelPopupNoteId.value = undefined
  })
})
</script>

<style scoped>
.input-area {
  padding: 10px;
  background-color: #f0f0f0;
}

.note-item {
  word-break: break-all;
}

.dark .input-area {
  background-color: #303641;
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
</style>
