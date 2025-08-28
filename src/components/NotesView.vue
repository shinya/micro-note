<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 via-white to-indigo-50">
    <div class="max-w-6xl mx-auto p-6">
      <!-- ヘッダー -->
      <div class="text-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">{{ $t('notes.title') }}</h1>
        <p class="text-gray-600">{{ $t('notes.subtitle') }}</p>
      </div>

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
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                </svg>
                <span>{{ $t('notes.favorite') }}</span>
              </span>
            </button>

            <!-- エクスポートボタン -->
            <button
              @click="exportToCSV"
              :disabled="filteredNotes.length === 0"
              :class="[
                'px-6 py-3 rounded-xl font-medium transition-all duration-200 flex items-center space-x-2',
                filteredNotes.length === 0
                  ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                  : 'bg-green-600 text-white hover:bg-green-700 shadow-lg'
              ]"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              <span>{{ $t('notes.exportToCSV') }}</span>
            </button>
          </div>
        </div>
      </div>



      <!-- メモ一覧 -->
      <div class="space-y-4">
        <div
          v-for="note in filteredNotes"
          :key="note.id"
          class="bg-white rounded-2xl shadow-lg p-6 hover:shadow-xl transition-all duration-200"
        >
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <p class="text-gray-900 whitespace-pre-wrap leading-relaxed mb-3">{{ note.content }}</p>
              <div class="flex items-center space-x-4 text-sm text-gray-500">
                <span>{{ formatTime(note.timestamp) }}</span>
                <span class="flex items-center space-x-1">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span>{{ note.id.slice(0, 8) }}</span>
                </span>
              </div>
            </div>

            <!-- アクションボタン -->
            <div class="flex items-center space-x-2 ml-4">
              <!-- お気に入りボタン -->
              <button
                @click="toggleFavorite(note.id, !note.is_favorite)"
                :class="[
                  'p-2 rounded-lg transition-all duration-200',
                  note.is_favorite
                    ? 'text-red-500 bg-red-50 hover:bg-red-100'
                    : 'text-gray-400 bg-gray-50 hover:bg-gray-100'
                ]"
              >
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" />
                </svg>
              </button>

              <!-- コピーボタン -->
              <button
                @click="copyToClipboard(note.content)"
                class="p-2 text-gray-400 bg-gray-50 hover:bg-gray-100 rounded-lg transition-all duration-200"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                </svg>
              </button>

              <!-- 削除ボタン -->
              <button
                @click="() => { console.log('Delete button clicked for note:', note.id); deleteNote(note.id); }"
                class="p-2 text-red-400 bg-red-50 hover:bg-red-100 rounded-lg transition-all duration-200"
                :title="$t('notes.deleteNote')"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
    alert(t('notes.deleteError'))
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
    alert(t('notes.copiedToClipboard'))
  } catch (error) {
    console.error('Failed to copy to clipboard:', error)
    alert(t('notes.copyError'))
  }
}

const formatTime = (timestamp) => {
  return new Date(timestamp).toLocaleString('ja-JP')
}

const exportToCSV = async () => {
  if (filteredNotes.value.length === 0) {
    alert(t('notes.exportNoNotes'))
    return
  }

  try {
    // CSV headers
    const headers = ['ID', t('notes.csvContent'), t('notes.csvTimestamp'), t('notes.csvFavorite')]

    // Create CSV data
    const csvData = filteredNotes.value.map(note => [
      note.id,
      // Escape line breaks and commas in content
      `"${note.content.replace(/"/g, '""').replace(/\n/g, ' ')}"`,
      formatTime(note.timestamp),
      note.is_favorite ? t('common.yes') : t('common.no')
    ])

    // Create CSV string
    const csvContent = [
      headers.join(','),
      ...csvData.map(row => row.join(','))
    ].join('\n')

    // Add BOM for UTF-8 encoding
    const BOM = '\uFEFF'
    const csvString = BOM + csvContent

    if (isTauri()) {
      // For Tauri application
      try {
        const now = new Date()
        const dateStr = now.toISOString().slice(0, 19).replace(/:/g, '-')
        const defaultFileName = `micro-notes-${dateStr}.csv`

        // Show file save dialog
        const filePath = await save({
          title: t('notes.exportDialogTitle'),
          filters: [
            {
              name: 'CSV Files',
              extensions: ['csv']
            }
          ],
          defaultPath: defaultFileName
        })

        if (filePath) {
          await writeTextFile(filePath, csvString)
          alert(t('notes.exportSuccess', { count: filteredNotes.value.length, path: filePath }))
        } else {
          alert(t('notes.exportCanceled'))
        }
      } catch (error) {
        console.error('Tauri CSV export failed:', error)
        alert(t('notes.exportError', { error: error }))
      }
    } else {
      // For web browser
      const now = new Date()
      const dateStr = now.toISOString().slice(0, 19).replace(/:/g, '-')
      const fileName = `micro-notes-${dateStr}.csv`

      // Blobの作成とダウンロード
      const blob = new Blob([csvString], { type: 'text/csv;charset=utf-8;' })
      const link = document.createElement('a')

      if (link.download !== undefined) {
        const url = URL.createObjectURL(blob)
        link.setAttribute('href', url)
        link.setAttribute('download', fileName)
        link.style.visibility = 'hidden'
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
        URL.revokeObjectURL(url)

        // Success message
        alert(t('notes.exportSuccess', { count: filteredNotes.value.length }))
      } else {
        // Fallback for older browsers
        window.open('data:text/csv;charset=utf-8,' + encodeURIComponent(csvString))
      }
    }
  } catch (error) {
    console.error('CSV export failed:', error)
    alert(t('notes.exportError'))
  }
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
