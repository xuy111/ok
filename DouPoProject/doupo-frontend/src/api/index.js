import axios from 'axios'

/**
 * 统一请求层
 * - baseURL = /api，开发环境由 vite 代理到 http://localhost:8080
 * - 后端返回体固定为 { code, msg, data }，这里把整个包装层透传给调用方
 * - 前台令牌取自 localStorage.doupo_user，后台令牌取自 localStorage.doupo_admin
 */
const service = axios.create({
  baseURL: '/api',
  timeout: 15000
})

function readUser(key) {
  try {
    return JSON.parse(localStorage.getItem(key) || 'null')
  } catch (e) {
    return null
  }
}

service.interceptors.request.use(config => {
  const key = config.adminAuth ? 'doupo_admin' : 'doupo_user'
  const user = readUser(key)
  if (user && user.token) {
    config.headers.Authorization = 'Bearer ' + user.token
  }
  delete config.adminAuth
  return config
})

/** 登录态失效：清本地会话并广播，由 App.vue 统一跳登录页 */
function sessionExpired(isAdmin) {
  try {
    if (isAdmin) {
      localStorage.removeItem('doupo_admin')
      window.dispatchEvent(new CustomEvent('doupo:admin-expired'))
    } else {
      localStorage.removeItem('doupo_user')
      window.dispatchEvent(new CustomEvent('doupo:auth-expired'))
    }
  } catch (e) { /* 忽略 */ }
}

function isAdminRequest(config) {
  return !!(config && (config.adminAuth || String(config.url || '').indexOf('/admin') === 0))
}

function toError(code, msg, isAdmin) {
  const e = new Error(msg || '请求失败')
  e.code = code
  if (code === 401 || code === 403) sessionExpired(isAdmin)
  return e
}

/**
 * 后端统一返回 { code, msg, data }，即使业务失败（401/403/500）HTTP 状态也是 200。
 * 所以这里必须自己判断 code，否则「未登录」会被当成成功，前端就会出现
 * 按钮显示已收服、实际一条都没写进数据库的假成功。
 */
service.interceptors.response.use(
  res => {
    const body = res.data
    if (body && typeof body.code === 'number' && body.code !== 200) {
      return Promise.reject(toError(body.code, body.msg, isAdminRequest(res.config)))
    }
    return body
  },
  err => {
    const body = err.response && err.response.data
    const status = err.response && err.response.status
    let msg = body && (body.msg || body.message)
    if (!msg) {
      if (err.code === 'ECONNABORTED' || /timeout/i.test(err.message || '')) {
        msg = '后端响应超时：请确认 MySQL 已启动（双击项目根目录的 启动.bat）'
      } else if (status) {
        msg = '请求失败（HTTP ' + status + '）'
      } else {
        msg = '连不上后端：请确认服务已启动（双击项目根目录的 启动.bat）'
      }
    }
    return Promise.reject(toError((body && body.code) || status || 0, msg, isAdminRequest(err.config)))
  }
)

export default {
  /* ---------------- 前台认证 ---------------- */
  register(data) {
    return service.post('/auth/register', data)
  },
  login(data) {
    return service.post('/auth/login', data)
  },
  me() {
    return service.get('/auth/me')
  },
  logout() {
    return service.post('/auth/logout')
  },

  /* ---------------- 首页展示 ---------------- */
  overview() {
    return service.get('/item/overview')
  },
  categories() {
    return service.get('/item/categories')
  },
  itemList(params) {
    return service.get('/item/list', { params })
  },
  itemDetail(id) {
    return service.get('/item/' + id)
  },

  /* ---------------- 互动玩法 ---------------- */
  profile() {
    return service.get('/user/profile')
  },
  sign() {
    return service.post('/user/sign')
  },
  saveTalent(data) {
    return service.post('/user/talent', data)
  },
  collection() {
    return service.get('/user/collection')
  },
  collect(itemId, note) {
    return service.post('/user/collect/' + itemId, { note: note || '' })
  },
  release(itemId) {
    return service.delete('/user/collect/' + itemId)
  },
  saveNote(itemId, note) {
    return service.put('/user/note/' + itemId, { note: note || '' })
  },
  drawInfo() {
    return service.get('/user/draw/info')
  },
  draw() {
    return service.post('/user/draw')
  },

  /* ---------------- 评论 ---------------- */
  comments(itemId) {
    return service.get('/item/' + itemId + '/comments')
  },
  addComment(itemId, content) {
    return service.post('/item/' + itemId + '/comments', { content })
  },

  /* ---------------- 关系图谱 ---------------- */
  graph() {
    return service.get('/graph')
  },

  /* ---------------- 后台管理（需管理员令牌） ---------------- */
  adminLogin(data) {
    return service.post('/admin/login', data)
  },
  adminMe() {
    return service.get('/admin/me', { adminAuth: true })
  },
  adminStats() {
    return service.get('/admin/stats', { adminAuth: true })
  },
  adminItems(params) {
    return service.get('/admin/items', { params, adminAuth: true })
  },
  adminAdd(data) {
    return service.post('/admin/items', data, { adminAuth: true })
  },
  adminUpdate(data) {
    return service.put('/admin/items', data, { adminAuth: true })
  },
  adminDelete(id) {
    return service.delete('/admin/items/' + id, { adminAuth: true })
  },
  adminUsers() {
    return service.get('/admin/users', { adminAuth: true })
  }
}
