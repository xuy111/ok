// 统一的前后端请求封装
// - 集中管理后端地址
// - 自动携带 JWT token
// - 统一处理 { code, msg, data } 返回结构与 401 过期
const BASE = 'http://localhost:8081/api'

function getToken(tokenKey) {
  return localStorage.getItem(tokenKey || 'crew_token') || ''
}

/**
 * @param path 请求路径
 * @param opts { method, body, tokenKey, authExpire }
 *   - tokenKey: 使用的 token 存储键，后台管理用 'admin_token'
 *   - authExpire: 401 时是否触发前台登录过期事件，后台管理用 false
 */
async function request(path, { method = 'GET', body, tokenKey, authExpire = true } = {}) {
  const headers = {}
  if (body) headers['Content-Type'] = 'application/json'
  const token = getToken(tokenKey)
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
    if (data && data.code === 401 && authExpire) {
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
  info: () => request('/user/info'),

  /* ---------- 首页相关接口 ---------- */
  // 分级分类搜索（分页）：keyword 关键词，category 大类，subcategory 子类，page/size 分页
  search: (params = {}) => {
    const qs = new URLSearchParams()
    if (params.keyword) qs.set('keyword', params.keyword)
    if (params.category) qs.set('category', params.category)
    if (params.subcategory) qs.set('subcategory', params.subcategory)
    if (params.page) qs.set('page', params.page)
    if (params.size) qs.set('size', params.size)
    return request('/home/search?' + qs.toString())
  },
  // 首页推荐/热门内容
  recommend: (limit = 8) => request('/home/recommend?limit=' + limit),
  // 分级分类目录
  categories: () => request('/home/categories'),
  // 按海贼团查询船员（crew 为空返回全部）
  crew: (crew = '') => request('/home/crew' + (crew ? '?crew=' + encodeURIComponent(crew) : '')),
  // 按海域查询岛屿（region 为空返回全部）
  island: (region = '') => request('/home/island' + (region ? '?region=' + encodeURIComponent(region) : '')),
  // 悬赏榜（crew 为空返回全部）
  bounty: (crew = '') => request('/home/bounty' + (crew ? '?crew=' + encodeURIComponent(crew) : '')),
  // 航海日志时间线
  timeline: () => request('/home/timeline'),

  /* ---------- 收藏（我的航海日志） ---------- */
  favorite: (contentId) => request('/home/favorite?contentId=' + contentId, { method: 'POST' }),
  unfavorite: (contentId) => request('/home/unfavorite?contentId=' + contentId, { method: 'POST' }),
  favorites: () => request('/home/favorites'),
  favoriteCheck: (contentId) => request('/home/favorite/check?contentId=' + contentId),

  /* ---------- 后台管理（独立管理员鉴权） ---------- */
  adminLogin: (username, password) => request('/admin/login', { method: 'POST', body: { username, password }, tokenKey: 'admin_token', authExpire: false }),
  adminContentList: (keyword = '') => request('/admin/content/list' + (keyword ? '?keyword=' + encodeURIComponent(keyword) : ''), { tokenKey: 'admin_token', authExpire: false }),
  adminContentSave: (payload) => request('/admin/content/save', { method: 'POST', body: payload, tokenKey: 'admin_token', authExpire: false }),
  adminContentDelete: (id) => request('/admin/content/' + id, { method: 'DELETE', tokenKey: 'admin_token', authExpire: false }),
  adminTimelineList: () => request('/admin/timeline/list', { tokenKey: 'admin_token', authExpire: false }),
  adminTimelineSave: (payload) => request('/admin/timeline/save', { method: 'POST', body: payload, tokenKey: 'admin_token', authExpire: false }),
  adminTimelineDelete: (id) => request('/admin/timeline/' + id, { method: 'DELETE', tokenKey: 'admin_token', authExpire: false })
}
