import { createApp } from 'vue'

import App from './App.vue'
import './style.css'
import i18n, { loadSavedLocale } from './i18n'

// 保存された言語を読み込み
loadSavedLocale()

createApp(App).use(i18n).mount('#app')
