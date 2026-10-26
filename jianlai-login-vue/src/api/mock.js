/**
 * 模拟山门接口（纯前端 mock，替换为真实 axios/fetch 即可）
 * 每个接口延迟 700~1100ms，便于展示按钮加载态。
 */
const delay = (ms) => new Promise((r) => setTimeout(r, ms))

/** 模拟偶发失败，方便看错误态：道号含「魔」即被拒 */
function guard(uid, scene) {
  if (String(uid).includes('魔')) {
    return Promise.reject(new Error(`${scene} · 此道号被剑气长城除名`))
  }
  return null
}

export async function login({ uid, pwd }) {
  await delay(700 + Math.random() * 400)
  const bad = guard(uid, '入山被拒')
  if (bad) return bad
  if (!uid || pwd.length < 6) throw new Error('道号或剑诀不合山规')
  return { ok: true, uid, token: 'mock-token-' + Date.now() }
}

export async function register({ uid, pwd, confirm, invite }) {
  await delay(700 + Math.random() * 400)
  const bad = guard(uid, '立派被拒')
  if (bad) return bad
  if (pwd !== confirm) throw new Error('两遍剑诀不同 · 心不静则剑不纯')
  return { ok: true, uid, invite: invite || '无' }
}

export async function resetPwd({ uid, pwd, confirm }) {
  await delay(700 + Math.random() * 400)
  const bad = guard(uid, '重铸被拒')
  if (bad) return bad
  if (pwd !== confirm) throw new Error('两遍剑诀不同 · 心不静则剑不纯')
  return { ok: true, uid }
}
