<script setup>
import { ref, computed, onMounted } from 'vue'
import jollyRoger from './assets/jolly-roger.jpg'
import luffyBg from './assets/luffy-bg.gif'
import { api } from './api'

const emit = defineEmits(['back'])

/* ---------- 海贼团配色主题 ---------- */
const THEMES = {
  straw:      { '--straw':'#f6a623', '--straw-dark':'#d6841a', '--sea':'#1b6fb3', '--sea-deep':'#0d3b5c', '--paper':'#f3e3c3', '--paper-dark':'#e3caa0', '--red':'#c0392b', '--ink':'#2a1a0f' },
  redhair:    { '--straw':'#e13b3b', '--straw-dark':'#a81f1f', '--sea':'#7a1f1f', '--sea-deep':'#3a0d0d', '--paper':'#f3dcd0', '--paper-dark':'#e0c0ad', '--red':'#b71c1c', '--ink':'#3a1610' },
  blackbeard: { '--straw':'#8e44ad', '--straw-dark':'#5e2d75', '--sea':'#2c3e50', '--sea-deep':'#0d1117', '--paper':'#d9d4e0', '--paper-dark':'#bcb6c8', '--red':'#6c3483', '--ink':'#221826' },
  whitebeard: { '--straw':'#34495e', '--straw-dark':'#1f2d3d', '--sea':'#2c7fb8', '--sea-deep':'#0d3b5c', '--paper':'#f5f5f5', '--paper-dark':'#e2e2e2', '--red':'#c0392b', '--ink':'#1d2a33' }
}
const CREWS = [
  { key: 'straw', name: '草帽团' },
  { key: 'redhair', name: '红发团' },
  { key: 'blackbeard', name: '黑胡子' },
  { key: 'whitebeard', name: '白胡子' }
]

const currentCrew = ref('straw')
const themeVars = computed(() => THEMES[currentCrew.value])
function selectCrew(key) { currentCrew.value = key }

/* ---------- 注册表单 ---------- */
const name = ref('')
const pass = ref('')
const pass2 = ref('')
const crew = ref('straw')
const posterName = computed(() => name.value.trim() || '新船员 · 无名海贼')

/* ---------- 图形验证码 ---------- */
const captchaCode = ref('')
const captchaInput = ref('')
const captchaCanvas = ref(null)

function genCaptcha() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  let s = ''
  for (let i = 0; i < 4; i++) s += chars[Math.floor(Math.random() * chars.length)]
  captchaCode.value = s
  drawCaptcha()
}
function drawCaptcha() {
  const c = captchaCanvas.value
  if (!c) return
  const ctx = c.getContext('2d')
  const w = (c.width = 100), h = (c.height = 36)
  ctx.clearRect(0, 0, w, h)
  ctx.fillStyle = '#f3e3c3'
  ctx.fillRect(0, 0, w, h)
  for (let i = 0; i < 5; i++) {
    ctx.strokeStyle = `rgba(${(60 + Math.random() * 120) | 0},${(40 + Math.random() * 100) | 0},20,${0.3 + Math.random() * 0.3})`
    ctx.beginPath()
    ctx.moveTo(Math.random() * w, Math.random() * h)
    ctx.lineTo(Math.random() * w, Math.random() * h)
    ctx.stroke()
  }
  for (let i = 0; i < 28; i++) {
    ctx.fillStyle = 'rgba(0,0,0,.15)'
    ctx.fillRect(Math.random() * w, Math.random() * h, 1.5, 1.5)
  }
  const code = captchaCode.value
  ctx.font = 'bold 22px Georgia, serif'
  ctx.textBaseline = 'middle'
  for (let i = 0; i < code.length; i++) {
    ctx.save()
    ctx.translate(16 + i * 21, 18 + (Math.random() * 4 - 2))
    ctx.rotate((Math.random() - 0.5) * 0.5)
    ctx.fillStyle = `hsl(${Math.random() * 360}, 55%, 35%)`
    ctx.fillText(code[i], 0, 0)
    ctx.restore()
  }
}
onMounted(genCaptcha)

const toast = ref('⚓ 欢迎加入伟大航道的旅程…')
const toastShow = ref(false)
const loading = ref(false)

async function doRegister(payload) {
  return api.register(payload)
}

async function onSubmit() {
  toastShow.value = true
  if (captchaInput.value.trim().toUpperCase() !== captchaCode.value) {
    toast.value = '🌊 验证码不正确，再试一次！'
    genCaptcha()
    captchaInput.value = ''
    return
  }
  if (pass.value.length < 6) {
    toast.value = '🌊 航海口令至少 6 位哦！'
    return
  }
  if (pass.value !== pass2.value) {
    toast.value = '🌊 两次口令不一致，再核对一下！'
    return
  }
  const nm = name.value.trim() || '无名船长'
  loading.value = true
  toast.value = '⚓ 正在登记船员名册…'
  try {
    const r = await doRegister({ user: nm, pass: pass.value, crew: crew.value })
    toast.value = '⚓ ' + nm + '，' + (r.msg || '船员名册已更新，去登录启航吧！')
  } catch (err) {
    toast.value = '🌊 ' + err.message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="page" :style="{ ...themeVars, '--bg': `url(${luffyBg})` }">
    <!-- 海贼团切换 -->
    <div class="crew-bar">
      <button
        v-for="c in CREWS"
        :key="c.key"
        class="crew-btn"
        :class="{ active: currentCrew === c.key }"
        @click="selectCrew(c.key)"
      >{{ c.name }}</button>
    </div>

    <!-- 返回登录 -->
    <button class="back-btn" @click="emit('back')" title="返回登录">← 登录</button>

    <!-- 恶魔果实 -->
    <svg class="fruit f1" viewBox="0 0 40 48"><path d="M20 14 C8 14 4 28 8 40 C12 48 28 48 32 40 C36 28 32 14 20 14Z" fill="#c0392b"/><path d="M20 14 C20 6 26 4 30 6" stroke="#7a4a1f" stroke-width="3" fill="none" stroke-linecap="round"/><path d="M27 5 C30 2 34 3 34 7" stroke="#3a8a3a" stroke-width="3" fill="none" stroke-linecap="round"/></svg>
    <svg class="fruit f2" viewBox="0 0 40 48"><path d="M20 14 C8 14 4 28 8 40 C12 48 28 48 32 40 C36 28 32 14 20 14Z" fill="#8e44ad"/><path d="M20 14 C20 6 26 4 30 6" stroke="#7a4a1f" stroke-width="3" fill="none" stroke-linecap="round"/><path d="M27 5 C30 2 34 3 34 7" stroke="#3a8a3a" stroke-width="3" fill="none" stroke-linecap="round"/></svg>
    <svg class="fruit f3" viewBox="0 0 40 48"><path d="M20 14 C8 14 4 28 8 40 C12 48 28 48 32 40 C36 28 32 14 20 14Z" fill="#1b6fb3"/><path d="M20 14 C20 6 26 4 30 6" stroke="#7a4a1f" stroke-width="3" fill="none" stroke-linecap="round"/><path d="M27 5 C30 2 34 3 34 7" stroke="#3a8a3a" stroke-width="3" fill="none" stroke-linecap="round"/></svg>

    <!-- 招募海报 -->
    <div class="poster">
      <div class="poster-frame">
        <h1 class="wanted-title">NEW CREW</h1>

        <div class="portrait">
          <img class="jolly" :src="jollyRoger" alt="草帽海贼团" />
        </div>

        <div class="dead-or-alive">JOIN THE GRAND LINE</div>
        <div class="wname">{{ posterName }}</div>

        <div class="login-box">
          <div class="title">★ 招 募 新 船 员 ★</div>
          <form @submit.prevent="onSubmit">
            <div class="field">
              <label for="reg-name">船长之名</label>
              <input id="reg-name" v-model="name" type="text" placeholder="给自己起个响亮的名字…" />
            </div>
            <div class="field">
              <label for="reg-pass">航海口令</label>
              <input id="reg-pass" v-model="pass" type="password" placeholder="至少 6 位，守护 ONE PIECE" required />
            </div>
            <div class="field">
              <label for="reg-pass2">确认口令</label>
              <input id="reg-pass2" v-model="pass2" type="password" placeholder="再输入一次口令" required />
            </div>
            <div class="field">
              <label for="reg-crew">选择海贼团</label>
              <select id="reg-crew" v-model="crew">
                <option v-for="c in CREWS" :key="c.key" :value="c.key">{{ c.name }}</option>
              </select>
            </div>
            <div class="field">
              <label for="reg-captcha">验证码</label>
              <div class="captcha-row">
                <input id="reg-captcha" v-model="captchaInput" type="text" maxlength="4" placeholder="输入右侧验证码" autocomplete="off" />
                <canvas ref="captchaCanvas" class="captcha-img" @click="genCaptcha" title="点击刷新验证码"></canvas>
              </div>
            </div>
            <button class="btn" type="submit" :disabled="loading">{{ loading ? '登记中…' : '上 船 ！' }}</button>
          </form>
          <div class="foot">
            <a href="#" @click.prevent="emit('back')">已有船员？返回登录</a>
          </div>
        </div>
      </div>

      <div class="stamp">WANTED<br />CREW</div>

      <div class="toast" :class="{ show: toastShow }">{{ toast }}</div>
    </div>
  </div>
</template>

<style scoped>
  .page {
    font-family: "PingFang SC", "Microsoft YaHei", "Segoe UI", sans-serif;
    min-height: 100vh;
    padding: 70px 16px 60px;
    display: flex;
    align-items: center;
    justify-content: center;
    background-image:
      linear-gradient(180deg, rgba(10,20,30,.35) 0%, rgba(10,20,30,.55) 100%),
      var(--bg, none);
    background-size: cover, cover;
    background-position: center, center;
    background-color: #1a2a35;
    position: relative;
  }

  .crew-bar { position: absolute; top: 16px; left: 50%; transform: translateX(-50%); display: flex; gap: 10px; z-index: 20; flex-wrap: wrap; justify-content: center; }
  .crew-btn { border: 2px solid #fff; background: rgba(0,0,0,.28); color: #fff; padding: 7px 14px; border-radius: 20px; font-size: 12px; font-weight: 700; cursor: pointer; letter-spacing: 1px; backdrop-filter: blur(4px); transition: transform .15s, background .2s; }
  .crew-btn:hover { transform: translateY(-2px); }
  .crew-btn.active { background: #fff; color: var(--sea-deep); }

  .back-btn { position: absolute; top: 16px; left: 16px; z-index: 20; padding: 8px 14px; border: 2px solid #fff; background: rgba(0,0,0,.28); color: #fff; border-radius: 20px; font-size: 12px; font-weight: 700; cursor: pointer; letter-spacing: 1px; backdrop-filter: blur(4px); transition: transform .15s; }
  .back-btn:hover { transform: translateX(-2px); }

  .poster {
    position: relative; width: 360px;
    background:
      repeating-linear-gradient(0deg, rgba(0,0,0,.02) 0 2px, transparent 2px 5px),
      linear-gradient(180deg, var(--paper) 0%, var(--paper-dark) 100%);
    border: 7px solid #fff; border-radius: 4px;
    box-shadow: 0 18px 50px rgba(0,0,0,.45), inset 0 0 0 2px var(--ink);
    padding: 18px 24px 24px; transform: rotate(-1.4deg); z-index: 5;
  }
  .poster::after { content: ""; position: absolute; inset: 7px; border: 1.5px dashed rgba(42,26,15,.35); border-radius: 3px; pointer-events: none; }

  .poster-frame {
    border: 3px solid var(--ink); padding: 14px 14px 16px;
    box-shadow: inset 0 0 0 1.5px var(--paper), inset 0 0 0 3px var(--ink);
  }

  .wanted-title {
    text-align: center; font-family: "Georgia", "STKaiti", serif; letter-spacing: 6px;
    font-size: 40px; color: var(--ink); font-weight: 900; margin: 6px 0 12px; line-height: 1;
    text-shadow: 2px 2px 0 rgba(255,255,255,.45);
  }

  .portrait {
    width: 150px; height: 130px; margin: 0 auto 10px;
    border: 3px solid var(--ink); overflow: hidden; background: #111; position: relative;
  }
  .jolly {
    position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover;
    transform: scale(2.55); transform-origin: 50% 38%; display: block;
    filter: sepia(.05) contrast(1.05);
  }

  .dead-or-alive {
    text-align: center; font-family: "Georgia", serif; font-weight: 900;
    font-size: 16px; letter-spacing: 3px; color: var(--ink); margin: 2px 0 4px;
  }
  .wname {
    text-align: center; font-family: "Georgia", "STKaiti", serif; font-weight: 900;
    font-size: 22px; letter-spacing: 1px; color: var(--ink); min-height: 26px; line-height: 1.2;
    margin-bottom: 6px;
  }

  .stamp {
    position: absolute; top: -16px; right: -16px; width: 74px; height: 74px; background: var(--red); color: #fff;
    border-radius: 50%; display: grid; place-items: center; font-size: 12px; font-weight: 800; letter-spacing: 1px;
    text-align: center; line-height: 1.15; transform: rotate(15deg); box-shadow: 0 4px 10px rgba(0,0,0,.35);
    border: 2px dashed rgba(255,255,255,.7); z-index: 2;
  }

  .login-box { margin-top: 8px; border-top: 2px solid var(--ink); padding-top: 14px; }
  .login-box .title { text-align: center; font-size: 12px; letter-spacing: 4px; color: var(--red); font-weight: 800; margin-bottom: 12px; }
  .field { margin-bottom: 12px; }
  .field label { display: block; font-size: 12px; letter-spacing: 2px; color: var(--ink); margin-bottom: 5px; font-weight: 700; }
  .field input,
  .field select {
    width: 100%; padding: 10px 12px; border: 2px solid var(--ink); border-radius: 4px;
    background: rgba(255,255,255,.65); font-size: 14px; color: var(--ink); outline: none;
    transition: border-color .2s, box-shadow .2s;
  }
  .field input:focus, .field select:focus { border-color: var(--sea); box-shadow: 0 0 0 3px rgba(27,111,179,.25); }

  .captcha-row { display: flex; gap: 8px; align-items: center; }
  .captcha-row input { flex: 1; }
  .captcha-img {
    width: 100px; height: 36px; flex: 0 0 100px; border: 2px solid var(--ink);
    border-radius: 4px; cursor: pointer; display: block; background: #f3e3c3;
  }
  .btn {
    width: 100%; margin-top: 4px; padding: 12px; border: none; border-radius: 4px;
    background: linear-gradient(180deg, var(--straw) 0%, var(--straw-dark) 100%);
    color: #fff; font-size: 16px; font-weight: 800; letter-spacing: 4px; cursor: pointer;
    box-shadow: 0 4px 0 var(--straw-dark), 0 8px 16px rgba(0,0,0,.3);
    transition: transform .08s, box-shadow .08s;
  }
  .btn:hover { filter: brightness(1.05); }
  .btn:active { transform: translateY(4px); box-shadow: 0 0 0 var(--straw-dark), 0 3px 8px rgba(0,0,0,.3); }
  .btn:disabled { opacity: .7; cursor: default; }
  .foot { display: flex; justify-content: center; margin-top: 12px; font-size: 11px; color: var(--ink); }
  .foot a { color: var(--sea-deep); text-decoration: none; font-weight: 700; }
  .foot a:hover { text-decoration: underline; }

  .fruit { position: absolute; width: 26px; height: 30px; opacity: .85; z-index: 2; filter: drop-shadow(0 2px 3px rgba(0,0,0,.25)); }
  .fruit.f1 { top: 22%; right: 8%; animation: bob 4s ease-in-out infinite; }
  .fruit.f2 { bottom: 20%; right: 13%; animation: bob 5s ease-in-out infinite .6s; }
  .fruit.f3 { top: 30%; left: 7%; animation: bob 4.5s ease-in-out infinite .3s; }
  @keyframes bob { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }

  .toast { position: absolute; bottom: -58px; left: 0; right: 0; text-align: center; color: #fff; font-size: 13px; opacity: 0; transition: opacity .3s; text-shadow: 0 1px 4px rgba(0,0,0,.5); }
  .toast.show { opacity: 1; }

  @media (max-width: 420px) { .poster { width: 92vw; } }
</style>
