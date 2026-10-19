import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// 部署到 GitHub Pages 子路径时，把下面 base 改成 '/你的仓库名/'
export default defineConfig({
  base: './',
  plugins: [vue()]
})
