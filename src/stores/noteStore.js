import { invoke, isTauri } from '@tauri-apps/api/core'
import { ref, computed } from 'vue'

// シンプルな状態管理
const notes = ref([])
const isLoading = ref(false)
const error = ref(undefined)

// 基本的なアクション
const fetchNotes = async () => {
  if (!isTauri) {
    // Not in Tauri, using mock data
    notes.value = [
      {
        id: '1',
        content: 'テストメモ1',
        timestamp: new Date().toISOString(),
        is_favorite: false,
      },
    ]
    return
  }

  try {
    isLoading.value = true
    error.value = undefined

    const result = await invoke('get_notes')

    if (Array.isArray(result)) {
      // データの検証とフィルタリング
      const validNotes = result.filter(note => {
        const isValid =
          note &&
          typeof note === 'object' &&
          note.id &&
          note.content &&
          note.timestamp

        return isValid
      })

      notes.value = validNotes
    } else {
      notes.value = []
    }
  } catch (error_) {
    // Failed to fetch notes
    error.value = error_.message
    notes.value = []
  } finally {
    isLoading.value = false
  }
}

const saveNote = async content => {
  if (!isTauri) {
    const mockNote = {
      id: Date.now().toString(),
      content,
      timestamp: new Date().toISOString(),
      is_favorite: false,
    }
    notes.value.unshift(mockNote)
    return mockNote
  }

  const timestamp = new Date().toISOString()
  await invoke('save_note', { content, timestamp })

  // 保存後に再取得
  await fetchNotes()
}

const updateFavorite = async (id, isFavorite) => {
  if (!isTauri) {
    const note = notes.value.find(n => n.id === id)
    if (note) note.is_favorite = isFavorite
    return
  }

  await invoke('update_note_favorite', { id, isFavorite })
  await fetchNotes()
}

const deleteNote = async id => {
  if (!isTauri) {
    notes.value = notes.value.filter(n => n.id !== id)
    return
  }

  await invoke('delete_note', { id })
  await fetchNotes()
}

// 計算された値
const filteredNotes = computed(() => {
  return [...notes.value].sort(
    (a, b) => new Date(b.timestamp) - new Date(a.timestamp)
  )
})

const favoriteNotes = computed(() => {
  return notes.value.filter(note => note.is_favorite)
})

// 初期化時にメモを取得
if (isTauri) {
  fetchNotes()
}

export function useNoteStore() {
  return {
    // 状態
    notes,
    isLoading: computed(() => isLoading.value),
    error: computed(() => error.value),

    // 計算された値
    filteredNotes,
    favoriteNotes,

    // アクション
    fetchNotes,
    saveNote,
    updateFavorite,
    deleteNote,
  }
}
