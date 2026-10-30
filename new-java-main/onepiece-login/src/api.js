// 统一的前后端请求封装
// - 集中管理后端地址
// - 自动携带 JWT token
// - 统一处理 { code, msg, data } 返回结构与 401 过期
const BASE = 'http://localhost:8081/api'

function getToken() {
  return localStorage.getItem('crew_token') || ''
}

async function request(path, { method = 'GET', body } = {}) {
  const headers = {}
  if (body) headers['Content-Type'] = 'application/json'
  const token = getToken()
  if (token) headers['Authorization'] = 'Bearer ' + token

  let res
  try {
    res = await fetch(BASE + path, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined
    })
  } catch (e) {
    throw new Error('无法连接后端，请确认服务已启动 (localhost:8081)')
  }

  let data = null
  try {
    data = await res.json()
  } catch (e) {
    data = null
  }

  if (!res.ok || !data || data.code !== 200) {
    if (data && data.code === 401) {
      localStorage.removeItem('crew_token')
      localStorage.removeItem('crew_user')
      window.dispatchEvent(new CustomEvent('auth-expired'))
    }
    throw new Error((data && data.msg) || ('请求失败 ' + res.status))
  }
  return data
}

export const api = {
  login: (user, pass) => request('/user/login', { method: 'POST', body: { user, pass } }),
  register: (payload) => request('/user/register', { method: 'POST', body: payload }),
  info: () => request('/user/info')
}
