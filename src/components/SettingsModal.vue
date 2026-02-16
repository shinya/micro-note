<template>
  <Teleport to="body">
    <div
      v-if="modelValue"
      class="fixed inset-0 z-50 flex items-center justify-center"
    >
      <!-- 背景オーバーレイ -->
      <div
        class="absolute inset-0 bg-black/50 backdrop-blur-sm"
        @click="close"
      ></div>

      <!-- モーダルコンテナ -->
      <div class="relative z-10 w-full max-w-lg max-h-[85vh] mx-4 rounded-2xl shadow-2xl bg-white dark:bg-gray-800 flex flex-col overflow-hidden">
        <!-- sticky ヘッダー -->
        <div class="flex items-center justify-between px-6 py-4 border-b border-gray-200 dark:border-gray-600 flex-shrink-0">
          <h2 class="text-lg font-bold text-gray-900 dark:text-white">{{ $t('settings.title') }}</h2>
          <button
            @click="close"
            class="p-1.5 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
          >
            <svg class="w-5 h-5 text-gray-500 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- スクロール可能なコンテンツ -->
        <div class="overflow-y-auto flex-1">
          <SettingsView />
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { watch, onMounted, onUnmounted } from 'vue'
import SettingsView from './SettingsView.vue'

const props = defineProps({
  modelValue: { type: Boolean, default: false }
})

const emit = defineEmits(['update:modelValue'])

const close = () => {
  emit('update:modelValue', false)
}

const handleKeydown = (e) => {
  if (e.key === 'Escape' && props.modelValue) {
    close()
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})

watch(() => props.modelValue, (isOpen) => {
  document.body.style.overflow = isOpen ? 'hidden' : ''
})
</script>
