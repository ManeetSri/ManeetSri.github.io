import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { seoContent } from './seo-plugin.js'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), seoContent()],
})
