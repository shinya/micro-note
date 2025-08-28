import { ref, computed } from 'vue'
import { invoke, isTauri } from '@tauri-apps/api/core'

// シンプルな状態管理
const notes = ref([])
const isLoading = ref(false)
const error = ref(null)

// 基本的なアクション
const fetchNotes = async () => {
  if (!isTauri) {
    console.log('Not in Tauri, using mock data')
    notes.value = [
      {
        id: '1',
        content: 'テストメモ1',
        timestamp: new Date().toISOString(),
        is_favorite: false
      }
    ]
    return
  }

  try {
    isLoading.value = true
    error.value = null

    console.log('Fetching notes from Tauri...')
    const result = await invoke('get_notes')
    console.log('Raw result from Tauri:', result)

                if (Array.isArray(result)) {
        console.log('Result is array, length:', result.length)
        console.log('Raw result from Tauri:', JSON.stringify(result, null, 2))

        // データの検証とフィルタリング
        const validNotes = result.filter(note => {
          const isValid = note &&
            typeof note === 'object' &&
            note.id &&
            note.content &&
            note.timestamp

          if (!isValid) {
            console.warn('Invalid note filtered out:', note)
          }

          return isValid
        })

        notes.value = validNotes
        console.log('Notes loaded successfully:', validNotes.length)
        console.log('Valid notes:', JSON.stringify(validNotes, null, 2))
        console.log('notes.value after assignment:', notes.value)
        console.log('notes.value length:', notes.value?.length)

        if (validNotes.length !== result.length) {
          console.warn(`Filtered out ${result.length - validNotes.length} invalid notes`)
        }
      } else {
        console.error('Invalid result from Tauri:', result)
        console.error('Result type:', typeof result)
        notes.value = []
      }
  } catch (err) {
    console.error('Failed to fetch notes:', err)
    error.value = err.message
    notes.value = []
  } finally {
    isLoading.value = false
  }
}

const saveNote = async (content) => {
  if (!isTauri) {
    const mockNote = {
      id: Date.now().toString(),
      content,
      timestamp: new Date().toISOString(),
      is_favorite: false
    }
    notes.value.unshift(mockNote)
    return mockNote
  }

  try {
    const timestamp = new Date().toISOString()
    await invoke('save_note', { content, timestamp })

    // 保存後に再取得
    await fetchNotes()
  } catch (err) {
    console.error('Failed to save note:', err)
    throw err
  }
}

const updateFavorite = async (id, isFavorite) => {
  if (!isTauri) {
    const note = notes.value.find(n => n.id === id)
    if (note) note.is_favorite = isFavorite
    return
  }

  try {
    await invoke('update_note_favorite', { id, isFavorite })
    await fetchNotes()
  } catch (err) {
    console.error('Failed to update favorite:', err)
    throw err
  }
}

const deleteNote = async (id) => {
  if (!isTauri) {
    notes.value = notes.value.filter(n => n.id !== id)
    return
  }

  try {
    await invoke('delete_note', { id })
    await fetchNotes()
  } catch (err) {
    console.error('Failed to delete note:', err)
    throw err
  }
}

// 計算された値
const filteredNotes = computed(() => {
  return [...notes.value].sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
})

const favoriteNotes = computed(() => {
  return notes.value.filter(note => note.is_favorite)
})

// 初期化時にメモを取得
if (isTauri) {
  console.log('NoteStore: Initializing in Tauri environment, fetching notes...')
  console.log('NoteStore: isTauri function:', typeof isTauri)
  console.log('NoteStore: isTauri result:', isTauri())
  fetchNotes()
} else {
  console.log('NoteStore: Initializing in non-Tauri environment, using mock data')
}

export function useNoteStore() {
  return {
    // 状態
    notes: notes,
    isLoading: computed(() => isLoading.value),
    error: computed(() => error.value),

    // 計算された値
    filteredNotes,
    favoriteNotes,

    // アクション
    fetchNotes,
    saveNote,
    updateFavorite,
    deleteNote
  }
}
