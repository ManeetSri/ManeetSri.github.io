import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { seoContent } from './seo-plugin.js'
import { securityHeaders } from './security-headers-plugin.js'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), seoContent(), securityHeaders()],
  // Files stay files instead of data: URIs, so the Content Security Policy can stay strict
  build: { assetsInlineLimit: 0 },
})
