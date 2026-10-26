/**
 * 极简请求封装（fetch，无第三方依赖）
 * 后端统一返回 { code, msg, data }，code !== 200 视为失败并抛出 msg
 * - 已登录时自动带 Authorization: Bearer <accessToken>
 * - 遇到 401 自动用 refreshToken 续期一次并重放原请求，续期失败才清令牌
 */
import {
  loadToken,
  saveToken,
  clearToken,
  loadRefreshToken,
  saveRefreshToken
} from '../composables/useRemember'

const BASE = import.meta.env.VITE_API_BASE || '/api'

function authHeaders() {
  const token = loadToken()
  return token ? { Authorization: 'Bearer ' + token } : {}
}

/** 并发时只发一次续期请求 */
let refreshing = null

function doRefresh() {
  if (refreshing) return refreshing
  const rt = loadRefreshToken()
  if (!rt) {
    clearToken()
    return Promise.reject(new Error('剑诀令牌已失效 · 请重新入山'))
  }
  refreshing = fetch(BASE + '/auth/refresh', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refreshToken: rt })
  })
    .then(async (res) => {
      const data = await res.json().catch(() => null)
      if (!res.ok || !data || data.code !== 200) {
        clearToken()
        throw new Error((data && data.msg) || '剑诀令牌已失效 · 请重新入山')
      }
      saveToken(data.data.token)
      saveRefreshToken(data.data.refreshToken)
      return data.data.token
    })
    .finally(() => {
      refreshing = null
    })
  return refreshing
}

async function handle(res) {
  let data = null
  try {
    data = await res.json()
  } catch (e) {
    throw new Error('山门回信格式有误 · 请检查后端接口')
  }
  if (res.status === 401) {
    clearToken()
    throw new Error(data.msg || '剑诀令牌已失效 · 请重新入山')
  }
  if (!res.ok || data.code !== 200) {
    throw new Error(data.msg || '山门未应 · 请稍后再试')
  }
  return data
}

async function request(path, options = {}) {
  const send = () =>
    fetch(BASE + path, {
      ...options,
      headers: { ...authHeaders(), ...(options.headers || {}) }
    }).catch(() => {
      throw new Error('山门无响应 · 请确认后端已启动（127.0.0.1:8081）')
    })

  let res = await send()
  if (res.status === 401) {
    try {
      await doRefresh()
      res = await send()
    } catch (e) {
      clearToken()
      throw e
    }
  }
  return handle(res)
}

export function post(path, body = {}) {
  return request(path, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  })
}

export function get(path) {
  return request(path, { method: 'GET' })
}
