/**
 * 「记住此山」本地记忆：道号存 localStorage
 * 真实项目里替换为 token / user store 即可
 */
const KEY = 'jianlai:uid'

export function saveUid(uid) {
  try {
    localStorage.setItem(KEY, String(uid || '').trim())
  } catch (e) {
    /* 隐私模式下忽略 */
  }
}

export function loadUid() {
  try {
    return localStorage.getItem(KEY) || ''
  } catch (e) {
    return ''
  }
}

export function clearUid() {
  try {
    localStorage.removeItem(KEY)
  } catch (e) {
    /* noop */
  }
}

/* ===== 令牌（后端 /api/auth/login 返回的 token） ===== */
const TOKEN_KEY = 'jianlai:token'

export function saveToken(token) {
  try {
    if (token) localStorage.setItem(TOKEN_KEY, token)
  } catch (e) {
    /* noop */
  }
}

export function loadToken() {
  try {
    return localStorage.getItem(TOKEN_KEY) || ''
  } catch (e) {
    return ''
  }
}

export function clearToken() {
  try {
    localStorage.removeItem(TOKEN_KEY)
    localStorage.removeItem(REFRESH_KEY)
  } catch (e) {
    /* noop */
  }
}

/* ===== 刷新令牌 ===== */
const REFRESH_KEY = 'jianlai:refresh'

export function saveRefreshToken(token) {
  try {
    if (token) localStorage.setItem(REFRESH_KEY, token)
  } catch (e) {
    /* noop */
  }
}

export function loadRefreshToken() {
  try {
    return localStorage.getItem(REFRESH_KEY) || ''
  } catch (e) {
    return ''
  }
}
