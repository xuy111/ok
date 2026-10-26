/**
 * 山门接口：默认走真实后端（Spring Boot 8081，经 vite 代理 /api）
 * 把 .env 里 VITE_USE_MOCK 改成 true 即可切回本地 mock，方便无后端时演示
 */
import { get, post } from './http'
import * as mock from './mock'
import { loadRefreshToken } from '../composables/useRemember'

/** 续期：用 refreshToken 换新的一对令牌，返回新的 accessToken */
export function refresh() {
  if (USE_MOCK) return Promise.resolve('mock')
  return post('/auth/refresh', { refreshToken: loadRefreshToken() }).then((r) => r.data)
}

const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true'

/** 仗剑入山 */
export function login({ uid, pwd, remember }) {
  if (USE_MOCK) return mock.login({ uid, pwd })
  return post('/auth/login', { uid, pwd, remember }).then((r) => r.data)
}

/** 开宗立派 */
export function register({ uid, pwd, confirm, invite, sect, agree }) {
  if (USE_MOCK) return mock.register({ uid, pwd, confirm, invite })
  return post('/auth/register', { uid, pwd, confirm, invite, sect, agree }).then((r) => r.data)
}

/** 重铸剑诀 */
export function resetPwd({ uid, pwd, confirm }) {
  if (USE_MOCK) return mock.resetPwd({ uid, pwd, confirm })
  return post('/auth/reset', { uid, pwd, confirm }).then((r) => r.data)
}

/** 道号是否已被占用 */
export function checkUid(uid) {
  if (USE_MOCK) return Promise.resolve({ uid, exists: false })
  return get('/auth/check?uid=' + encodeURIComponent(uid)).then((r) => r.data)
}

/** 连通性自检 */
export function ping() {
  if (USE_MOCK) return Promise.resolve('mock')
  return get('/auth/ping').then((r) => r.data)
}

/** 山主个人信息（需 token） */
export function me() {
  if (USE_MOCK) return Promise.resolve({ uid: '陈平安', sect: '剑', invite: '骊珠洞天' })
  return get('/auth/me').then((r) => r.data)
}

/** 出山 */
export function logout() {
  if (USE_MOCK) return Promise.resolve('出山')
  return post('/auth/logout').then((r) => r.data)
}

/** 最近入山记录 */
export function logs(limit = 5) {
  if (USE_MOCK) return Promise.resolve([])
  return get('/auth/logs?limit=' + limit).then((r) => r.data || [])
}

/** 山门名录（分页 + 搜索） */
export function disciples({ page = 1, size = 10, kw = '' } = {}) {
  if (USE_MOCK) return Promise.resolve({ records: [], total: 0, pages: 0, current: 1 })
  return get(`/auth/disciples?page=${page}&size=${size}&kw=${encodeURIComponent(kw)}`).then(
    (r) => r.data || { records: [], total: 0, pages: 0, current: 1 }
  )
}

/** 山门统计：弟子总数 */
export function stats() {
  if (USE_MOCK) return Promise.resolve({ disciples: 0 })
  return get('/auth/stats').then((r) => r.data || {})
}
