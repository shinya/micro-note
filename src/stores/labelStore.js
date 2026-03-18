import { invoke, isTauri } from '@tauri-apps/api/core'
import { ref, computed } from 'vue'

const labels = ref([])
const isLoading = ref(false)

const fetchLabels = async () => {
  if (!isTauri) {
    labels.value = [
      { id: 'mock-1', name: 'タスク', color: '#3B82F6', sort_order: 0 },
      { id: 'mock-2', name: 'コマンド', color: '#EF4444', sort_order: 1 },
    ]
    return
  }

  try {
    isLoading.value = true
    const result = await invoke('get_labels')
    labels.value = Array.isArray(result) ? result : []
  } catch {
    labels.value = []
  } finally {
    isLoading.value = false
  }
}

const saveLabel = async (name, color) => {
  if (!isTauri) {
    labels.value.push({
      id: Date.now().toString(),
      name,
      color,
      sort_order: labels.value.length,
    })
    return
  }

  await invoke('save_label', { name, color })
  await fetchLabels()
}

const updateLabel = async (id, name, color) => {
  if (!isTauri) {
    const label = labels.value.find(l => l.id === id)
    if (label) {
      label.name = name
      label.color = color
    }
    return
  }

  await invoke('update_label', { id, name, color })
  await fetchLabels()
}

const deleteLabel = async id => {
  if (!isTauri) {
    labels.value = labels.value.filter(l => l.id !== id)
    return
  }

  await invoke('delete_label', { id })
  await fetchLabels()
}

if (isTauri) {
  fetchLabels()
}

export function useLabelStore() {
  return {
    labels,
    isLoading: computed(() => isLoading.value),
    fetchLabels,
    saveLabel,
    updateLabel,
    deleteLabel,
  }
}
