import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// 后端 Spring Boot 地址（application-dev.properties 里 server.port=8081）
const BACKEND = 'http://127.0.0.1:8081'

export default defineConfig({
  base: './',
  plugins: [vue()],
  server: {
    host: '127.0.0.1',
    port: 5173,
    open: false,
    // 前端 /api/** 全部转发到后端，避免跨域
    proxy: {
      '/api': {
        target: BACKEND,
        changeOrigin: true
      }
    }
  },
  preview: {
    port: 4173,
    proxy: {
      '/api': {
        target: BACKEND,
        changeOrigin: true
      }
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets'
  }
})
