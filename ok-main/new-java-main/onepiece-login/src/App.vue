<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import jollyRoger from './assets/jolly-roger.jpg'
import luffyBg from './assets/luffy-bg.gif'
import Register from './Register.vue'
import { api } from './api'

const view = ref('login')

/* ---------- 海贼团配色主题 ---------- */
const THEMES = {
  straw:      { '--straw':'#f6a623', '--straw-dark':'#d6841a', '--sea':'#1b6fb3', '--sea-deep':'#0d3b5c', '--paper':'#f3e3c3', '--paper-dark':'#e3caa0', '--red':'#c0392b', '--jolly':'#1a1a1a', '--ink':'#2a1a0f' },
  redhair:    { '--straw':'#e13b3b', '--straw-dark':'#a81f1f', '--sea':'#7a1f1f', '--sea-deep':'#3a0d0d', '--paper':'#f3dcd0', '--paper-dark':'#e0c0ad', '--red':'#b71c1c', '--jolly':'#111111', '--ink':'#3a1610' },
  blackbeard: { '--straw':'#8e44ad', '--straw-dark':'#5e2d75', '--sea':'#2c3e50', '--sea-deep':'#0d1117', '--paper':'#d9d4e0', '--paper-dark':'#bcb6c8', '--red':'#6c3483', '--jolly':'#000000', '--ink':'#221826' },
  whitebeard: { '--straw':'#34495e', '--straw-dark':'#1f2d3d', '--sea':'#2c7fb8', '--sea-deep':'#0d3b5c', '--paper':'#f5f5f5', '--paper-dark':'#e2e2e2', '--red':'#c0392b', '--jolly':'#222222', '--ink':'#1d2a33' }
}
const CREWS = [
  { key: 'straw', name: '草帽团' },
  { key: 'redhair', name: '红发团' },
  { key: 'blackbeard', name: '黑胡子' },
  { key: 'whitebeard', name: '白胡子' }
]

const currentCrew = ref('straw')
const themeVars = computed(() => THEMES[currentCrew.value])
function selectCrew(key) {
  currentCrew.value = key
  blip(660)
}

/* ---------- 音效 (Web Audio 合成，无版权风险) ---------- */
const soundOn = ref(false)
let audioCtx = null
let oceanGain = null
function initAudio() {
  const AC = window.AudioContext || window.webkitAudioContext
  audioCtx = new AC()
  const size = audioCtx.sampleRate * 2
  const buf = audioCtx.createBuffer(1, size, audioCtx.sampleRate)
  const d = buf.getChannelData(0)
  let last = 0
  for (let i = 0; i < size; i++) {
    const w = Math.random() * 2 - 1
    last = (last + 0.02 * w) / 1.02
    d[i] = last * 3.5
  }
  const noise = audioCtx.createBufferSource()
  noise.buffer = buf
  noise.loop = true
  const lp = audioCtx.createBiquadFilter()
  lp.type = 'lowpass'
  lp.frequency.value = 550
  oceanGain = audioCtx.createGain()
  oceanGain.gain.value = 0
  noise.connect(lp).connect(oceanGain).connect(audioCtx.destination)
  noise.start()
}
function blip(freq) {
  if (!soundOn.value || !audioCtx) return
  const o = audioCtx.createOscillator()
  const g = audioCtx.createGain()
  o.type = 'square'
  o.frequency.value = freq || 520
  g.gain.setValueAtTime(0.0001, audioCtx.currentTime)
  g.gain.exponentialRampToValueAtTime(0.15, audioCtx.currentTime + 0.02)
  g.gain.exponentialRampToValueAtTime(0.0001, audioCtx.currentTime + 0.18)
  o.connect(g).connect(audioCtx.destination)
  o.start()
  o.stop(audioCtx.currentTime + 0.2)
}
function toggleSound() {
  if (!audioCtx) initAudio()
  if (audioCtx.state === 'suspended') audioCtx.resume()
  soundOn.value = !soundOn.value
  if (oceanGain) oceanGain.gain.linearRampToValueAtTime(soundOn.value ? 0.12 : 0, audioCtx.currentTime + 0.5)
  if (soundOn.value) blip(720)
}

/* ---------- 名字实时同步到通缉令 ---------- */
const user = ref('')
const pass = ref('')
const posterName = computed(() => user.value.trim() || 'MONKEY·D·LUFFY 蒙奇·D·路飞')

/* ---------- 登录 (对接 Spring Boot 后端) ---------- */
const toast = ref('⚓ 即将启航，前往伟大航道…')
const toastShow = ref(false)
const loading = ref(false)

/* ---------- 登录态 (JWT) ---------- */
const loggedUser = ref(localStorage.getItem('crew_user') || '')

async function checkSession() {
  if (!localStorage.getItem('crew_token')) return
  try {
    const data = await api.info()
    loggedUser.value = data.data.username
  } catch (e) {
    /* token 失效或后端未启动时忽略，交由 auth-expired 事件处理 */
  }
}

function onAuthExpired() {
  loggedUser.value = ''
  toast.value = '⚓ 登录已过期，请重新上船！'
  toastShow.value = true
}

onMounted(() => {
  checkSession()
  window.addEventListener('auth-expired', onAuthExpired)
})
onBeforeUnmount(() => {
  window.removeEventListener('auth-expired', onAuthExpired)
})

function logout() {
  localStorage.removeItem('crew_token')
  localStorage.removeItem('crew_user')
  loggedUser.value = ''
  toast.value = '⚓ 已下船，期待下次启航！'
  toastShow.value = true
}

function doLogin(name, pwd) {
  return api.login(name, pwd)
}
async function onSubmit() {
  const name = user.value.trim() || '无名船长'
  blip(520)
  loading.value = true
  toast.value = '⚓ 校验航海口令中…'
  toastShow.value = true
  try {
    const r = await doLogin(name, pass.value)
    blip(880)
    if (r.data && r.data.token) {
      localStorage.setItem('crew_token', r.data.token)
      localStorage.setItem('crew_user', name)
      loggedUser.value = name
    }
    toast.value = '⚓ ' + name + '，' + (r.msg || '伟大航道已为你敞开！')
  } catch (err) {
    blip(200)
    toast.value = '🌊 ' + err.message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div v-if="view === 'login'" class="page" :style="{ ...themeVars, '--bg': `url(${luffyBg})` }">
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

    <!-- 音效开关 -->
    <button class="sound-toggle" @click="toggleSound" title="海浪声 / 音效">
      {{ soundOn ? '🔊' : '🔇' }}
    </button>

    <!-- 登录态 -->
    <div v-if="loggedUser" class="user-badge">
      <span class="dot"></span>
      <span class="uname">⚓ {{ loggedUser }}</span>
      <button class="logout" @click="logout" title="退出登录">下船</button>
    </div>

    <!-- 罗盘 -->
    <svg class="compass" viewBox="0 0 100 100" aria-hidden="true">
      <circle cx="50" cy="50" r="46" fill="none" stroke="#fff" stroke-width="3" />
      <circle cx="50" cy="50" r="38" fill="none" stroke="#fff" stroke-width="1" stroke-dasharray="4 4" />
      <path d="M50 8 L56 50 L50 92 L44 50 Z" fill="#fff" />
      <path d="M8 50 L50 44 L92 50 L50 56 Z" fill="#fff" opacity=".6" />
      <circle class="compass-dot" cx="50" cy="50" r="5" />
    </svg>

    <!-- 恶魔果实 -->
    <svg class="fruit f1" viewBox="0 0 40 48"><path d="M20 14 C8 14 4 28 8 40 C12 48 28 48 32 40 C36 28 32 14 20 14Z" fill="#c0392b"/><path d="M20 14 C20 6 26 4 30 6" stroke="#7a4a1f" stroke-width="3" fill="none" stroke-linecap="round"/><path d="M27 5 C30 2 34 3 34 7" stroke="#3a8a3a" stroke-width="3" fill="none" stroke-linecap="round"/></svg>
    <svg class="fruit f2" viewBox="0 0 40 48"><path d="M20 14 C8 14 4 28 8 40 C12 48 28 48 32 40 C36 28 32 14 20 14Z" fill="#8e44ad"/><path d="M20 14 C20 6 26 4 30 6" stroke="#7a4a1f" stroke-width="3" fill="none" stroke-linecap="round"/><path d="M27 5 C30 2 34 3 34 7" stroke="#3a8a3a" stroke-width="3" fill="none" stroke-linecap="round"/></svg>
    <svg class="fruit f3" viewBox="0 0 40 48"><path d="M20 14 C8 14 4 28 8 40 C12 48 28 48 32 40 C36 28 32 14 20 14Z" fill="#1b6fb3"/><path d="M20 14 C20 6 26 4 30 6" stroke="#7a4a1f" stroke-width="3" fill="none" stroke-linecap="round"/><path d="M27 5 C30 2 34 3 34 7" stroke="#3a8a3a" stroke-width="3" fill="none" stroke-linecap="round"/></svg>

    <!-- 悬赏通缉令 (经典 WANTED 版式) -->
    <div class="poster">
      <div class="poster-frame">
        <h1 class="wanted-title">WANTED</h1>

        <!-- 通缉对象头像：草帽海贼团骷髅旗 -->
        <div class="portrait">
          <img class="jolly" :src="jollyRoger" alt="草帽海贼团" />
        </div>

        <div class="dead-or-alive">DEAD OR ALIVE</div>
        <div class="wname">{{ posterName }}</div>

        <div class="bounty">
          <span class="berry-sign">฿</span>
          <span class="amt">300,000,000</span>
          <span class="dash">-</span>
        </div>

        <div class="marine-line">
          <svg class="swirl" viewBox="0 0 60 16" aria-hidden="true">
            <path d="M4 8 q8 -8 16 0 t16 0 t16 0" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            <circle cx="4" cy="8" r="2.4" fill="currentColor"/>
          </svg>
          <span>MARINE</span>
          <svg class="swirl flip" viewBox="0 0 60 16" aria-hidden="true">
            <path d="M4 8 q8 -8 16 0 t16 0 t16 0" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            <circle cx="56" cy="8" r="2.4" fill="currentColor"/>
          </svg>
        </div>

        <div class="login-box">
          <div class="title">★ 入 舰 登 记 ★</div>
          <form id="loginForm" @submit.prevent="onSubmit">
            <div class="field">
              <label for="user">船长之名（将印上通缉令）</label>
              <input id="user" v-model="user" type="text" placeholder="输入你的名字 / 罗杰…" @focus="blip(440)" />
            </div>
            <div class="field">
              <label for="pass">航海口令</label>
              <input id="pass" v-model="pass" type="password" placeholder="守护 ONE PIECE 的密码" required @focus="blip(440)" />
            </div>
            <button class="btn" type="submit" :disabled="loading">{{ loading ? '启航中…' : '出 发 ！' }}</button>
          </form>
          <div class="foot">
            <a href="#">忘记口令？</a>
            <a href="#" @click.prevent="view = 'register'">招募新船员</a>
          </div>
        </div>
      </div>

      <div class="stamp">DEAD<br />OR<br />ALIVE</div>

      <div class="toast" :class="{ show: toastShow }">{{ toast }}</div>
    </div>
  </div>

  <Register v-else @back="view = 'login'" />
</template>

<!-- 全局基础样式 -->
<style>
  html, body, #app { height: 100%; margin: 0; }
  * { box-sizing: border-box; }
</style>

<!-- 组件样式 (保持原网页风格) -->
<style scoped>
  .page {
    font-family: "PingFang SC", "Microsoft YaHei", "Segoe UI", sans-serif;
    min-height: 100%;
    padding: 70px 16px 60px;
    overflow: auto;
    display: flex;
    align-items: center;
    justify-content: center;
    background-image:
      linear-gradient(180deg, rgba(10,20,30,.35) 0%, rgba(10,20,30,.55) 100%),
      var(--bg, none);
    background-size: cover, cover;
    background-position: center, center;
    background-color: #1a2a35;
    transition: background .6s;
    position: relative;
  }

  /* 顶部海贼团切换 */
  .crew-bar { position: absolute; top: 16px; left: 50%; transform: translateX(-50%); display: flex; gap: 10px; z-index: 20; flex-wrap: wrap; justify-content: center; }
  .crew-btn { border: 2px solid #fff; background: rgba(0,0,0,.28); color: #fff; padding: 7px 14px; border-radius: 20px; font-size: 12px; font-weight: 700; cursor: pointer; letter-spacing: 1px; backdrop-filter: blur(4px); transition: transform .15s, background .2s; }
  .crew-btn:hover { transform: translateY(-2px); }
  .crew-btn.active { background: #fff; color: var(--sea-deep); }

  .sound-toggle { position: absolute; top: 16px; right: 16px; z-index: 20; width: 44px; height: 44px; border-radius: 50%; border: 2px solid #fff; background: rgba(0,0,0,.28); color: #fff; font-size: 20px; cursor: pointer; display: grid; place-items: center; backdrop-filter: blur(4px); transition: transform .15s; }
  .sound-toggle:hover { transform: scale(1.08); }

  .user-badge {
    position: absolute; top: 20px; right: 72px; z-index: 20;
    display: flex; align-items: center; gap: 8px;
    background: rgba(0,0,0,.38); border: 2px solid #fff; border-radius: 22px;
    padding: 6px 8px 6px 12px; color: #fff; backdrop-filter: blur(4px);
  }
  .user-badge .dot { width: 8px; height: 8px; border-radius: 50%; background: #4ade80; box-shadow: 0 0 6px #4ade80; }
  .user-badge .uname { font-size: 13px; font-weight: 700; letter-spacing: 1px; }
  .user-badge .logout {
    border: none; background: #fff; color: #0d3b5c; font-size: 12px; font-weight: 800;
    padding: 4px 10px; border-radius: 14px; cursor: pointer; letter-spacing: 1px;
  }
  .user-badge .logout:hover { background: #ffe08a; }


  .compass { position: absolute; left: 6%; bottom: 14%; width: 130px; height: 130px; opacity: .35; z-index: 1; animation: spin 36s linear infinite; }
  .compass-dot { fill: var(--straw); }
  @keyframes spin { to { transform: rotate(360deg); } }

  /* 悬赏通缉令 */
  .poster {
    position: relative; width: 360px;
    background:
      repeating-linear-gradient(0deg, rgba(0,0,0,.02) 0 2px, transparent 2px 5px),
      linear-gradient(180deg, var(--paper) 0%, var(--paper-dark) 100%);
    border: 7px solid #fff; border-radius: 4px;
    box-shadow: 0 18px 50px rgba(0,0,0,.45), inset 0 0 0 2px var(--ink);
    padding: 18px 24px 24px; transform: rotate(-1.4deg); z-index: 5; transition: background .6s;
  }
  .poster::after { content: ""; position: absolute; inset: 7px; border: 1.5px dashed rgba(42,26,15,.35); border-radius: 3px; pointer-events: none; }

  .poster h1,
  .wanted-title {
    text-align: center; font-family: "Georgia", "STKaiti", serif; letter-spacing: 6px;
    font-size: 44px; color: var(--ink); font-weight: 900; margin: 6px 0 12px; line-height: 1;
    text-shadow: 2px 2px 0 rgba(255,255,255,.45);
  }

  /* 经典版式：内层粗边框包住海报主体 */
  .poster-frame {
    border: 3px solid var(--ink); padding: 14px 14px 16px;
    box-shadow: inset 0 0 0 1.5px var(--paper), inset 0 0 0 3px var(--ink);
  }

  /* 通缉对象头像：只裁剪展示草帽骷髅头部分 */
  .portrait {
    width: 200px; height: 170px; margin: 0 auto 10px;
    border: 3px solid var(--ink); overflow: hidden; background: #111;
    position: relative;
  }
  .jolly {
    position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover;
    transform: scale(2.55); transform-origin: 50% 38%; display: block;
    filter: sepia(.05) contrast(1.05);
  }

  .dead-or-alive {
    text-align: center; font-family: "Georgia", serif; font-weight: 900;
    font-size: 20px; letter-spacing: 4px; color: var(--ink); margin: 2px 0 4px;
  }
  .wname {
    text-align: center; font-family: "Georgia", "STKaiti", serif; font-weight: 900;
    font-size: 24px; letter-spacing: 1px; color: var(--ink); min-height: 28px; line-height: 1.2;
  }

  .bounty {
    display: flex; align-items: baseline; justify-content: center; gap: 4px;
    margin: 8px 0 2px; font-family: "Georgia", serif; color: var(--ink);
  }
  .bounty .berry-sign { font-size: 22px; font-weight: 900; }
  .bounty .amt { font-size: 30px; font-weight: 900; letter-spacing: 1px; }
  .bounty .dash { font-size: 30px; font-weight: 900; }

  .marine-line {
    display: flex; align-items: center; justify-content: flex-end; gap: 8px;
    margin-top: 6px; color: var(--ink);
  }
  .marine-line span {
    font-family: "Georgia", serif; font-weight: 900; font-size: 16px; letter-spacing: 3px;
  }
  .swirl { width: 44px; height: 14px; opacity: .8; }
  .swirl.flip { transform: scaleX(-1); }

  .stamp {
    position: absolute; top: -16px; right: -16px; width: 74px; height: 74px; background: var(--red); color: #fff;
    border-radius: 50%; display: grid; place-items: center; font-size: 12px; font-weight: 800; letter-spacing: 1px;
    text-align: center; line-height: 1.15; transform: rotate(15deg); box-shadow: 0 4px 10px rgba(0,0,0,.35);
    border: 2px dashed rgba(255,255,255,.7); transition: background .6s; z-index: 2;
  }

  .login-box { margin-top: 16px; border-top: 2px solid var(--ink); padding-top: 14px; }
  .login-box .title { text-align: center; font-size: 12px; letter-spacing: 4px; color: var(--red); font-weight: 800; margin-bottom: 12px; }
  .field { margin-bottom: 12px; }
  .field label { display: block; font-size: 12px; letter-spacing: 2px; color: var(--ink); margin-bottom: 5px; font-weight: 700; }
  .field input {
    width: 100%; padding: 10px 12px; border: 2px solid var(--ink); border-radius: 4px;
    background: rgba(255,255,255,.65); font-size: 14px; color: var(--ink); outline: none;
    transition: border-color .2s, box-shadow .2s;
  }
  .field input:focus { border-color: var(--sea); box-shadow: 0 0 0 3px rgba(27,111,179,.25); }
  .btn {
    width: 100%; margin-top: 4px; padding: 12px; border: none; border-radius: 4px;
    background: linear-gradient(180deg, var(--straw) 0%, var(--straw-dark) 100%);
    color: #fff; font-size: 16px; font-weight: 800; letter-spacing: 4px; cursor: pointer;
    box-shadow: 0 4px 0 var(--straw-dark), 0 8px 16px rgba(0,0,0,.3);
    transition: transform .08s, box-shadow .08s, background .6s;
  }
  .btn:hover { filter: brightness(1.05); }
  .btn:active { transform: translateY(4px); box-shadow: 0 0 0 var(--straw-dark), 0 3px 8px rgba(0,0,0,.3); }
  .btn:disabled { opacity: .7; cursor: default; }
  .foot { display: flex; justify-content: space-between; margin-top: 12px; font-size: 11px; color: var(--ink); }
  .foot a { color: var(--sea-deep); text-decoration: none; font-weight: 700; }
  .foot a:hover { text-decoration: underline; }

  .fruit { position: absolute; width: 26px; height: 30px; opacity: .85; z-index: 2; filter: drop-shadow(0 2px 3px rgba(0,0,0,.25)); }
  .fruit.f1 { top: 22%; right: 8%; animation: bob 4s ease-in-out infinite; }
  .fruit.f2 { bottom: 20%; right: 13%; animation: bob 5s ease-in-out infinite .6s; }
  .fruit.f3 { top: 30%; left: 7%; animation: bob 4.5s ease-in-out infinite .3s; }
  @keyframes bob { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-10px); } }

  .toast { position: absolute; bottom: -58px; left: 0; right: 0; text-align: center; color: #fff; font-size: 13px; opacity: 0; transition: opacity .3s; text-shadow: 0 1px 4px rgba(0,0,0,.5); }
  .toast.show { opacity: 1; }


  @media (max-width: 420px) {
    .poster { width: 92vw; }
    .compass { display: none; }
  }
</style>
