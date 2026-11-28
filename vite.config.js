import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import mdx from '@mdx-js/rollup'
import remarkGfm from 'remark-gfm'
import remarkDsaBlocks from './scripts/remark-dsa-blocks.js'
import { seoContent } from './seo-plugin.js'
import { securityHeaders } from './security-headers-plugin.js'
import { pwa } from './pwa-plugin.js'
import { dsaExerciseWriter } from './scripts/dsa-exercise-writer.js'

// The console's code, and the exercise stubs its solution editor starts from
const isLearningConsole = (id) => id.includes('/src/dsa/') || id.includes('/dsa-swift/') || id.includes('/design-swift/')

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    // The private learning console's lessons are MDX, compiled before React sees them
    { enforce: 'pre', ...mdx({ remarkPlugins: [remarkGfm, remarkDsaBlocks] }) },
    react({ include: /\.(mdx|js|jsx)$/ }),
    seoContent(),
    securityHeaders(),
    pwa(),
    dsaExerciseWriter(),
  ],
  build: {
    // Files stay files instead of data: URIs, so the Content Security Policy can stay strict
    assetsInlineLimit: 0,
    // Firestore with offline persistence is about 620 kB. Only the private console loads it, on demand.
    chunkSizeWarningLimit: 650,
    // Gzipping all ~2,400 chunks only to print their sizes costs memory and time; Netlify's ~2 GB heap ran out
    reportCompressedSize: false,
    rollupOptions: {
      output: {
        // The console's chunks get their own folder, which _headers marks as never indexed
        chunkFileNames: (chunk) => (chunk.moduleIds.some(isLearningConsole) ? 'assets/dsa/[name]-[hash].js' : 'assets/[name]-[hash].js'),
      },
    },
  },
})
