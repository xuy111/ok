<script setup>
import { ref } from 'vue'
import ShinChanDoodle from './components/ShinChanDoodle.vue'

// 后端接口地址（Spring Boot 默认 8081，可按需修改）
const API = 'http://localhost:8081/api'

const mode = ref('login') // 'login' | 'reg'
const loginUser = ref('')
const loginPwd = ref('')
const regUser = ref('')
const regPwd = ref('')
const regPwd2 = ref('')
const regSnack = ref('')
const toastMsg = ref('')
const loading = ref(false)
let toastTimer

function switchTab(which) {
  mode.value = which
}

function toast(msg) {
  toastMsg.value = msg
  clearTimeout(toastTimer)
  toastTimer = setTimeout(() => (toastMsg.value = ''), 2000)
}

async function doSubmit(type) {
  if (loading.value) return

  if (type === 'login') {
    if (!loginUser.value || !loginPwd.value) {
      toast('账号密码都要填哦～')
      return
    }
    loading.value = true
    try {
      const res = await fetch(`${API}/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ nickname: loginUser.value, password: loginPwd.value })
      })
      const data = await res.json()
      if (data.code === 200) {
        toast('欢迎回来，' + data.data.nickname + '！🎉')
      } else {
        toast(data.msg || '登录失败')
      }
    } catch (e) {
      toast('网络错误，后端连不上 😢')
    } finally {
      loading.value = false
    }
  } else {
    if (!regUser.value || !regPwd.value) {
      toast('昵称和密码不能空～')
      return
    }
    if (regPwd.value !== regPwd2.value) {
      toast('两次密码不一样啦！🙈')
      return
    }
    loading.value = true
    try {
      const res = await fetch(`${API}/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          nickname: regUser.value,
          password: regPwd.value,
          snack: regSnack.value
        })
      })
      const data = await res.json()
      if (data.code === 200) {
        toast('注册成功，' + data.data.nickname + ' 你好呀！✏️')
        // 清空表单并切到登录
        regUser.value = ''
        regPwd.value = ''
        regPwd2.value = ''
        regSnack.value = ''
        switchTab('login')
      } else {
        toast(data.msg || '注册失败')
      }
    } catch (e) {
      toast('网络错误，后端连不上 😢')
    } finally {
      loading.value = false
    }
  }
}
</script>

<template>
  <div class="card crayon">
    <ShinChanDoodle />

    <h1>动感光波·登录处</h1>
    <div class="subtitle">~ 小新喊你来玩啦 ~</div>

    <div class="tabs">
      <div class="tab" :class="{ active: mode === 'login' }" @click="switchTab('login')">登录</div>
      <div class="tab alt" :class="{ active: mode === 'reg' }" @click="switchTab('reg')">注册</div>
    </div>

    <!-- 登录 -->
    <form v-if="mode === 'login'" @submit.prevent="doSubmit('login')">
      <div class="field">
        <label>昵称 / 账号</label>
        <input v-model="loginUser" type="text" placeholder="比如：野原新之助" required>
      </div>
      <div class="field">
        <label>密码</label>
        <input v-model="loginPwd" type="password" placeholder="动感光波密码~" required>
      </div>
      <button class="btn" type="submit" :disabled="loading">咻~ 登录！</button>
      <div class="hint">忘记密码？<a @click="toast('去找美冴妈妈吧 🍼')">戳这里</a></div>
    </form>

    <!-- 注册 -->
    <form v-else @submit.prevent="doSubmit('reg')">
      <div class="field">
        <label>昵称</label>
        <input v-model="regUser" type="text" placeholder="给自己起个名" required>
      </div>
      <div class="row">
        <div class="field">
          <label>密码</label>
          <input v-model="regPwd" type="password" placeholder="设个密码" required>
        </div>
        <div class="field">
          <label>确认密码</label>
          <input v-model="regPwd2" type="password" placeholder="再输一次" required>
        </div>
      </div>
      <div class="field">
        <label>最喜欢的零食</label>
        <input v-model="regSnack" type="text" placeholder="小新：巧克力饼干！">
      </div>
      <button class="btn blue" type="submit" :disabled="loading">变身·注册！</button>
      <div class="hint">已经有账号了？<a @click="switchTab('login')">去登录</a></div>
    </form>

    <div class="footer">蜡笔小新风格 · Vue 3 版</div>
  </div>

  <div class="toast" :class="{ show: toastMsg }">{{ toastMsg }}</div>
</template>

<style scoped>
.card {
  width: 380px;
  max-width: 94vw;
  padding: 26px 26px 30px;
  position: relative;
}

h1 {
  font-size: 26px;
  text-align: center;
  color: var(--red);
  text-shadow: 2px 2px 0 var(--yellow);
  margin-bottom: 4px;
  letter-spacing: 1px;
}

.subtitle {
  text-align: center;
  font-size: 14px;
  color: var(--ink);
  margin-bottom: 18px;
  opacity: .8;
}

.tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 18px;
}

.tab {
  flex: 1;
  text-align: center;
  padding: 9px 0;
  font-size: 17px;
  cursor: pointer;
  border: 3px solid var(--ink);
  border-radius: 225px 15px 225px 15px / 15px 225px 15px 225px;
  background: #fff;
  transition: transform .1s;
}

.tab:active { transform: translateY(2px); }
.tab.active { background: var(--red); color: #fff; }
.tab.alt.active { background: var(--blue); }

.field { margin-bottom: 14px; }

label {
  display: block;
  font-size: 14px;
  margin-bottom: 5px;
  padding-left: 4px;
}

.field input {
  width: 100%;
  padding: 11px 12px;
  font-size: 15px;
  font-family: inherit;
  border: 3px solid var(--ink);
  border-radius: 15px 225px 15px 225px / 225px 15px 225px 15px;
  background: #fffdf7;
  outline: none;
}

.field input:focus { background: #fff7d6; }

.row { display: flex; gap: 10px; }
.row .field { flex: 1; }

.btn {
  width: 100%;
  margin-top: 8px;
  padding: 13px 0;
  font-size: 19px;
  font-family: inherit;
  color: #fff;
  background: var(--red);
  cursor: pointer;
  border: 3px solid var(--ink);
  border-radius: 225px 15px 225px 15px / 15px 225px 15px 225px;
  box-shadow: 3px 3px 0 rgba(43, 43, 43, .25);
  transition: transform .08s;
}

.btn:active {
  transform: translate(2px, 2px);
  box-shadow: 1px 1px 0 rgba(43, 43, 43, .25);
}

.btn:disabled { opacity: .6; cursor: not-allowed; }

.btn.blue { background: var(--blue); }

.hint {
  text-align: center;
  font-size: 13px;
  margin-top: 14px;
  color: #777;
}

.hint a {
  color: var(--red);
  text-decoration: none;
  cursor: pointer;
}

.footer {
  text-align: center;
  font-size: 12px;
  margin-top: 16px;
  color: #999;
}

.toast {
  position: fixed;
  left: 50%;
  bottom: 40px;
  transform: translateX(-50%) rotate(-2deg);
  background: var(--yellow);
  border: 3px solid var(--ink);
  padding: 12px 22px;
  border-radius: 225px 15px 225px 15px / 15px 225px 15px 225px;
  font-size: 16px;
  opacity: 0;
  pointer-events: none;
  transition: opacity .25s, bottom .25s;
}

.toast.show {
  opacity: 1;
  bottom: 60px;
}
</style>
