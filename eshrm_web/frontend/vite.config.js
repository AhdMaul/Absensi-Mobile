import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
  ],
  server: {
    port: 5173, 
    host: true, 
    allowedHosts: ['eshrm.jcode.my.id', 'eshrm-backend.jcode.my.id', 'api.jcode.my.id'], 
  },
})
