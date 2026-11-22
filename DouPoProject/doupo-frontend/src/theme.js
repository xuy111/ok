/**
 * 异火主色配置：同时用于卡片配色、筛选色块、主题强调色（--flame / --flame2）
 */
export const FIRE_COLORS = {
  gold: { label: '鎏金', hex: '#f5d76e', dim: '#c99a2e', rgb: '245,215,110' },
  black: { label: '墨黑', hex: '#9d8fc0', dim: '#4a4160', rgb: '157,143,192' },
  pink: { label: '净粉', hex: '#ff9ecb', dim: '#d0679f', rgb: '255,158,203' },
  green: { label: '青碧', hex: '#5fe0a0', dim: '#2f9c6a', rgb: '95,224,160' },
  blue: { label: '幽蓝', hex: '#5fb8ff', dim: '#2b7fd4', rgb: '95,184,255' },
  ice: { label: '霜白', hex: '#c2ecff', dim: '#7fc4e8', rgb: '194,236,255' },
  purple: { label: '紫辰', hex: '#c39bff', dim: '#8055d6', rgb: '195,155,255' },
  red: { label: '赤焰', hex: '#ff7a45', dim: '#c33d1c', rgb: '255,122,69' }
}

export const COLOR_KEYS = Object.keys(FIRE_COLORS)

export function colorOf(key) {
  return FIRE_COLORS[key] || FIRE_COLORS.gold
}

/** 切换整站的异火强调色（--flame / --flame2 / --flame-rgb） */
export function applyAccent(key) {
  const c = colorOf(key)
  const root = document.documentElement
  root.style.setProperty('--flame', c.hex)
  root.style.setProperty('--flame2', c.dim)
  root.style.setProperty('--flame-rgb', c.rgb)
  localStorage.setItem('doupo_accent', key)
}

export function loadAccent() {
  const key = localStorage.getItem('doupo_accent')
  if (key && FIRE_COLORS[key]) {
    applyAccent(key)
  }
}

/** 白昼 / 黑夜模式 */
export function applyTheme(mode) {
  document.body.classList.toggle('light', mode === 'light')
  localStorage.setItem('doupo_theme', mode)
}

export function loadTheme() {
  const mode = localStorage.getItem('doupo_theme') || 'dark'
  applyTheme(mode)
  return mode
}

/* ---------------- 背景模式：默认动态视频 / 桌面壁纸 ---------------- */
const BG_KEY = 'doupo_bg'

/** 切换全站背景：'default' = 动态视频，'wallpaper' = 桌面壁纸 */
export function applyBg(mode) {
  const on = mode === 'wallpaper'
  document.body.classList.toggle('wallpaper', on)
  localStorage.setItem(BG_KEY, on ? 'wallpaper' : 'default')
}

/** 启动时恢复上次的背景选择 */
export function loadBg() {
  const mode = localStorage.getItem(BG_KEY) || 'default'
  applyBg(mode)
  return mode
}
