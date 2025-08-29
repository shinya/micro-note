<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-indigo-50">
    <div class="max-w-6xl mx-auto p-6">
      <!-- 検索とフィルター -->
      <div class="bg-white rounded-2xl shadow-lg p-6 mb-6">
        <div class="flex flex-col sm:flex-row gap-4">
          <!-- 検索バー -->
          <div class="flex-1">
            <div class="relative">
              <input
                v-model="searchQuery"
                type="text"
                :placeholder="$t('notes.searchPlaceholder')"
                class="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all duration-200"
              />
              <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
          </div>

          <!-- フィルターボタン -->
          <div class="flex gap-2">
            <button
              @click="showFavorites = !showFavorites"
              :class="[
                'px-6 py-3 rounded-xl font-medium transition-all duration-200',
                showFavorites
                  ? 'bg-blue-600 text-white shadow-lg'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              ]"
            >
              <span class="flex items-center space-x-2">
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                </svg>
                <span>{{ $t('notes.favorite') }}</span>
              </span>
            </button>


          </div>
        </div>
      </div>



      <!-- メモ一覧 -->
      <div class="space-y-3">
        <div
          v-for="note in filteredNotes"
          :key="note.id"
          class="note-item bg-white rounded-xl shadow-md p-3 hover:shadow-lg transition-all duration-200 cursor-pointer"
          @click="copyToClipboard(note.content)"
          :title="$t('notes.clickToCopy')"
        >
          <div class="flex items-center">
            <!-- お気に入りボタン（左端） -->
            <div class="flex-shrink-0 mr-3" @click.stop>
              <button
                @click="toggleFavorite(note.id, !note.is_favorite)"
                class="p-1.5 rounded-md transition-all duration-200 bg-gray-50 hover:bg-gray-100"
              >
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                  <path
                    :fill="note.is_favorite ? '#ffcc00' : 'currentColor'"
                    d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
                  />
                </svg>
              </button>
            </div>

            <!-- メモ内容 -->
            <div class="flex-1">
              <p class="text-gray-900 whitespace-pre-wrap leading-normal text-sm mb-2">{{ note.content }}</p>
              <div class="flex items-center space-x-3 text-xs text-gray-400">
                <span class="text-xs">{{ formatTime(note.timestamp) }}</span>
                <span class="flex items-center space-x-1">
                  <svg class="w-2.5 h-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span class="text-xs">{{ note.id.slice(0, 8) }}</span>
                </span>
              </div>
            </div>

            <!-- 削除ボタン（右端） -->
            <div class="flex-shrink-0 ml-3" @click.stop>
              <button
                @click="() => { console.log('Delete button clicked for note:', note.id); deleteNote(note.id); }"
                class="p-1.5 text-red-400 bg-red-50 hover:bg-red-100 rounded-md transition-all duration-200"
                :title="$t('notes.deleteNote')"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </div>
          </div>
        </div>

        <!-- メモがない場合 -->
        <div
          v-if="filteredNotes.length === 0"
          class="text-center py-12 bg-white rounded-2xl shadow-lg"
        >
          <div class="w-16 h-16 bg-gradient-to-r from-blue-100 to-indigo-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          </div>
          <h3 class="text-lg font-medium text-gray-900 mb-2">
            {{ searchQuery ? $t('notes.noSearchResults') : $t('notes.noNotes') }}
          </h3>
          <p class="text-gray-500">
            {{ searchQuery ? $t('notes.noSearchResultsMessage') : $t('notes.noNotesMessage') }}
          </p>
        </div>
      </div>
    </div>

    <!-- トースト通知 -->
    <div
      v-if="showToast"
      class="fixed bottom-4 left-4 z-50 transform transition-all duration-300 ease-in-out"
      :class="showToast ? 'translate-y-0 opacity-100' : 'translate-y-full opacity-0'"
    >
      <div class="bg-green-500 text-white px-6 py-4 rounded-lg shadow-lg flex items-center space-x-3">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
        </svg>
        <span class="font-medium">{{ toastMessage }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useNoteStore } from '../stores/noteStore'
import { invoke, isTauri } from '@tauri-apps/api/core'
import { writeTextFile } from '@tauri-apps/plugin-fs'
import { save } from '@tauri-apps/plugin-dialog'

const noteStore = useNoteStore()
const searchQuery = ref('')
const showFavorites = ref(false)
const showToast = ref(false)
const toastMessage = ref('')

const { t } = useI18n()

const filteredNotes = computed(() => {
  let notes = noteStore.notes.value || []

  if (showFavorites.value) {
    notes = noteStore.favoriteNotes.value || []
  }

  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase()
    notes = notes.filter(note =>
      note.content.toLowerCase().includes(query)
    )
  }

  return notes
})

const toggleFavorite = async (id, isFavorite) => {
  try {
    await noteStore.updateFavorite(id, isFavorite)
  } catch (error) {
    console.error('Failed to update favorite:', error)
  }
}

const deleteNote = async (id) => {
  console.log('deleteNote called with id:', id)
  console.log('deleteNote function is defined:', typeof deleteNote)

  // Custom confirmation dialog
  const note = noteStore.notes.value?.find(n => n.id === id)
  if (!note) {
    console.error('Note not found:', id)
    return
  }

  const message = `${t('notes.deleteConfirm')}\n\n${t('notes.deleteConfirmMessage')}`

  // In Tauri applications, confirm() might be restricted,
  // so we proceed with deletion directly or perform a simple confirmation
  try {
    console.log('Proceeding with deletion...')
    await noteStore.deleteNote(id)
    console.log('Note deleted successfully:', id)
  } catch (error) {
    console.error('Failed to delete note:', error)
    showToastMessage(t('notes.deleteError'))
  }
}

const copyToClipboard = async (text) => {
  try {
    if (navigator.clipboard) {
      await navigator.clipboard.writeText(text)
    } else {
      // Fallback
      const textArea = document.createElement('textarea')
      textArea.value = text
      document.body.appendChild(textArea)
      textArea.select()
      document.execCommand('copy')
      document.body.removeChild(textArea)
    }
    showToastMessage(t('notes.copiedToClipboard'))
  } catch (error) {
    console.error('Failed to copy to clipboard:', error)
    showToastMessage(t('notes.copyError'))
  }
}

const showToastMessage = (message) => {
  toastMessage.value = message
  showToast.value = true

  // Hide toast after 3 seconds
  setTimeout(() => {
    showToast.value = false
  }, 3000)
}

const formatTime = (timestamp) => {
  return new Date(timestamp).toLocaleString('ja-JP')
}



const loadNotes = async () => {
  try {
    console.log('NotesView: Loading notes...')
    await noteStore.fetchNotes()
    console.log('NotesView: Notes loaded, current state:', {
      notes: noteStore.notes,
      notesLength: noteStore.notes?.value?.length || 0,
      filteredNotes: filteredNotes.value,
      filteredLength: filteredNotes.value?.length || 0
    })

    // 各ノートの詳細も確認
    if (filteredNotes.value && Array.isArray(filteredNotes.value)) {
      console.log('NotesView: Individual notes:')
      filteredNotes.value.forEach((note, index) => {
        console.log(`  Note ${index}:`, note)
      })
    }
  } catch (error) {
    console.error('Failed to load notes:', error)
  }
}

onMounted(async () => {
  console.log('NotesView: Component mounted')
  await loadNotes()

  // Force refresh (for debugging)
  setTimeout(async () => {
    console.log('NotesView: Forcing refresh after 1 second...')
    await loadNotes()
  }, 1000)
})
</script>

<style scoped>
.note-item {
  word-break: break-all;
}
</style>