<template>
  <div class="page">
    <div class="embers">
      <span v-for="i in 26" :key="i" class="ember"
        :style="{ left: embers[i-1].left, animationDuration: embers[i-1].dur, animationDelay: embers[i-1].delay, opacity: embers[i-1].op }"></span>
    </div>

    <div class="brand">
      <h1>斗破苍穹</h1>
      <p>后台管理系统 · 仅管理员可入</p>
    </div>

    <div class="wrap">
      <div class="card">
        <div class="seal">管理</div>
        <div class="title">后台管理登录</div>
        <div class="subtitle">ADMIN CONSOLE · AUTHORIZED ONLY</div>

        <div class="field">
          <label>管理员账号</label>
          <input class="input" v-model="form.username" @keyup.enter="doLogin" placeholder="请输入管理员账号">
        </div>
        <div class="field">
          <label>密码</label>
          <input class="input" type="password" v-model="form.password" @keyup.enter="doLogin" placeholder="请输入密码">
        </div>
        <button class="btn" :disabled="loading" @click="doLogin">{{ loading ? '验证中…' : '进入后台' }}</button>
        <div class="msg" :class="{ ok: okMsg }">{{ msg }}</div>
        <div class="foot">
          <router-link to="/login">返回前台登录</router-link>
          <span>·</span>
          <router-link to="/home">返回首页</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from '../api'

export default {
  name: 'AdminLogin',
  data() {
    const arr = []
    for (let i = 0; i < 26; i++) {
      arr.push({
        left: (Math.random() * 100) + '%',
        dur: (6 + Math.random() * 8) + 's',
        delay: (Math.random() * 8) + 's',
        op: Math.random() * 0.6 + 0.2
      })
    }
    return { form: { username: '', password: '' }, msg: '', okMsg: false, loading: false, embers: arr }
  },
  methods: {
    async doLogin() {
      this.msg = ''
      this.okMsg = false
      if (!this.form.username.trim() || !this.form.password.trim()) {
        this.msg = '请输入账号和密码'
        return
      }
      this.loading = true
      try {
        const res = await api.adminLogin({
          username: this.form.username.trim(),
          password: this.form.password.trim()
        })
        if (res && res.code === 200) {
          localStorage.setItem('doupo_admin', JSON.stringify(res.data))
          this.okMsg = true
          this.msg = '验证通过，正在进入后台…'
          setTimeout(() => this.$router.push('/admin'), 500)
        } else {
          this.msg = (res && res.msg) || '登录失败'
        }
      } catch (e) {
        this.msg = e.message
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style scoped>
.page { min-height: 100vh; display: flex; align-items: center; justify-content: center; position: relative; overflow: hidden; }
.embers { position: absolute; inset: 0; overflow: hidden; pointer-events: none; }
.ember { position: absolute; bottom: -20px; width: 3px; height: 3px; border-radius: 50%; background: var(--flame2);
  box-shadow: 0 0 8px 2px var(--flame); animation: rise linear infinite; }
@keyframes rise { 0% { transform: translateY(0) scale(1); opacity: .8 } 100% { transform: translateY(-110vh) scale(.2); opacity: 0 } }
.brand { position: absolute; top: 34px; text-align: center; width: 100%; }
.brand h1 { font-size: 30px; letter-spacing: 12px; color: var(--gold2); text-shadow: 0 0 18px rgba(212,175,55,.55); }
.brand p { margin-top: 8px; font-size: 12px; letter-spacing: 5px; color: #a8926b; }
.wrap { position: relative; z-index: 2; width: 420px; max-width: 92vw; }
.card { background: linear-gradient(145deg, rgba(28,22,18,.95), rgba(16,13,11,.97));
  border: 1px solid var(--line); border-radius: 14px; padding: 40px 36px 30px; position: relative;
  box-shadow: 0 0 0 1px rgba(0,0,0,.6), 0 18px 60px rgba(0,0,0,.7), inset 0 0 40px rgba(226,84,42,.05); }
.card::before, .card::after { content: ""; position: absolute; width: 26px; height: 26px; border: 2px solid var(--gold); }
.card::before { top: -1px; left: -1px; border-right: none; border-bottom: none; border-radius: 14px 0 0 0; }
.card::after { bottom: -1px; right: -1px; border-left: none; border-top: none; border-radius: 0 0 14px 0; }
.seal { position: absolute; top: 18px; right: 20px; width: 40px; height: 40px; border-radius: 6px;
  display: grid; place-items: center; font-size: 12px; letter-spacing: 1px; color: #ff8c6b;
  border: 1.5px solid rgba(226,84,42,.55); transform: rotate(8deg); opacity: .85; }
.title { text-align: center; font-size: 21px; letter-spacing: 4px; color: var(--gold2); }
.subtitle { text-align: center; font-size: 11px; color: #8c7a5c; margin: 8px 0 26px; letter-spacing: 3px; }
.field { margin-bottom: 16px; }
.field label { display: block; font-size: 13px; color: #b9a67e; margin-bottom: 8px; letter-spacing: 1px; }
.input { width: 100%; height: 46px; background: rgba(0,0,0,.35); border: 1px solid rgba(212,175,55,.25);
  border-radius: 8px; padding: 0 14px; color: #f0e4c8; font-size: 14px; outline: none; transition: .25s; }
.input:focus { border-color: var(--gold); box-shadow: 0 0 12px rgba(212,175,55,.25); }
.input::placeholder { color: #6b5c44; }
.btn { width: 100%; height: 48px; margin-top: 8px; border: none; border-radius: 8px; cursor: pointer;
  font-size: 16px; letter-spacing: 5px; font-weight: 700; color: #1a1206;
  background: linear-gradient(90deg, #c99a2e, #f5d76e, #c99a2e);
  box-shadow: 0 6px 20px rgba(212,175,55,.3); transition: .25s; }
.btn:hover:not(:disabled) { filter: brightness(1.12); }
.btn:disabled { opacity: .6; cursor: not-allowed; }
.msg { min-height: 18px; text-align: center; color: #ff7a5c; font-size: 13px; margin-top: 12px; }
.msg.ok { color: #8fd48a; }
.foot { margin-top: 16px; text-align: center; font-size: 12.5px; color: #8c7a5c;
  display: flex; gap: 10px; justify-content: center; }
.foot a:hover { text-decoration: underline; }
</style>
