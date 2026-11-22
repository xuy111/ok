import { reactive } from 'vue'
import api from './api'

/**
 * 极简全局状态（不引 Pinia，够用）：
 * - user：登录用户（来自 localStorage）
 * - profile：后端 /user/profile 的档案（境界、收服数、成就、笔记…）
 */
export const store = reactive({
  user: {},
  profile: null,
  loading: false
})

export function loadUser() {
  try {
    store.user = JSON.parse(localStorage.getItem('doupo_user') || '{}')
  } catch (e) {
    store.user = {}
  }
  return store.user
}

export function isAdmin() {
  return store.user && store.user.role === 0
}

/** 拉取（或刷新）个人档案；未登录时静默失败 */
export async function loadProfile() {
  if (!store.user || !store.user.token) return null
  store.loading = true
  try {
    const res = await api.profile()
    if (res && res.code === 200) {
      store.profile = res.data
      // 顺带把 role / nickname 同步回本地
      store.user = Object.assign({}, store.user, {
        nickname: res.data.nickname,
        role: res.data.role
      })
      localStorage.setItem('doupo_user', JSON.stringify(store.user))
    }
  } catch (e) {
    // 登录态失效：清空档案，避免页面继续显示「已收服 0 / 境界 斗者」这种假数据
    if (e && e.code === 401) {
      store.profile = null
      store.user = {}
    }
  } finally {
    store.loading = false
  }
  return store.profile
}

/**
 * 收服/放生接口已经返回最新的 ids 与数量，先就地更新，
 * 不依赖第二次 /user/profile 是否成功，界面立刻能变。
 */
export function applyCollect(data) {
  if (!data) return
  if (!store.profile) store.profile = { ids: [], notes: {}, collectCount: 0 }
  if (Array.isArray(data.ids)) store.profile.ids = data.ids
  if (typeof data.count === 'number') store.profile.collectCount = data.count
}

/** 已收服的 id 集合（用于卡片上的「已收服」标记） */
export function collectedIds() {
  return (store.profile && store.profile.ids) || []
}

export function realmText() {
  return store.profile && store.profile.realm ? store.profile.realm.name : '斗者'
}
