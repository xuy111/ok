/**
 * 全屏剑气遮罩的共享状态
 * 任意组件调用 openSlash() 即可触发斩屏
 */
import { reactive } from 'vue'

export const slash = reactive({
  active: false,
  word: '山门已开',
  tip: ''
})

let timer = null

export function openSlash(word = '山门已开', tip = '', ms = 2600) {
  slash.word = word
  slash.tip = tip
  slash.active = true
  clearTimeout(timer)
  timer = setTimeout(() => {
    slash.active = false
  }, ms)
}

export function closeSlash() {
  clearTimeout(timer)
  slash.active = false
}
