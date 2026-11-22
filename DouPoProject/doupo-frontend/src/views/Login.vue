<template>
  <div class="page">
    <div class="embers">
      <span v-for="i in 40" :key="i" class="ember"
        :style="{ left: embers[i-1].left, animationDuration: embers[i-1].dur, animationDelay: embers[i-1].delay, opacity: embers[i-1].op }"></span>
    </div>

    <div class="brand">
      <h1>斗破苍穹</h1>
      <p>三十年河东 · 三十年河西 · 莫欺少年穷</p>
    </div>

    <div class="wrap">
      <div class="card">
        <div class="title">异火图鉴 · 登录</div>
        <div class="subtitle">FIRE ATLAS · WELCOME BACK</div>

        <div class="field">
          <label>用户名</label>
          <input class="input" v-model="form.username" @keyup.enter="doLogin" placeholder="请输入你的用户名">
        </div>
        <div class="field">
          <label>密码</label>
          <input class="input" type="password" v-model="form.password" @keyup.enter="doLogin" placeholder="请输入密码">
        </div>
        <button class="btn" :disabled="loading" @click="doLogin">{{ loading ? '登录中…' : '登 录' }}</button>
        <div class="msg">{{ msg }}</div>

        <!-- 天赋测试入口：登录前先测一把，结果可带去注册 -->
        <div class="talent-entry" @click="$router.push('/talent')">
          <span class="te-icon">测</span>
          <span class="te-body">
            <b>点击测试你的初始天赋</b>
            <i>5 道情境 · 生成你的斗气大陆身份证</i>
          </span>
          <span class="te-arrow">›</span>
        </div>

        <div class="foot">尚无账号？<router-link to="/register">立即注册</router-link></div>
      </div>
    </div>

    <LoginTransition :show="entering" @done="onEnterDone" />
  </div>
</template>

<script>
import api from '../api'
import LoginTransition from '../components/LoginTransition.vue'

export default {
  name: 'Login',
  components: { LoginTransition },
  data() {
    const arr = []
    for (let i = 0; i < 40; i++) {
      arr.push({
        left: (Math.random() * 100) + '%',
        dur: (5 + Math.random() * 8) + 's',
        delay: (Math.random() * 8) + 's',
        op: Math.random() * .7 + .2
      })
    }
    return { form: { username: '', password: '' }, msg: '', loading: false, entering: false, embers: arr }
  },
  created() {
    if (this.$route.query.expired) {
      this.msg = '登录状态已过期，请重新登录后再收服异火'
    }
  },
  methods: {
    async doLogin() {
      this.msg = ''
      if (!this.form.username.trim() || !this.form.password.trim()) {
        this.msg = '请输入用户名和密码'
        return
      }
      this.loading = true
      try {
        const res = await api.login({ username: this.form.username.trim(), password: this.form.password.trim() })
        if (res && res.code === 200) {
          localStorage.setItem('doupo_user', JSON.stringify(res.data))
          this.msg = '登录成功，斗气汇聚中…'
          this.entering = true
          // 真正跳转交给过渡动画播放完成后的回调
        } else {
          this.msg = (res && res.msg) || '登录失败'
        }
      } catch (e) {
        this.msg = e.message
      } finally {
        this.loading = false
      }
    },
    onEnterDone() {
      this.entering = false
      this.$router.push('/home')
    }
  }
}
</script>

<style scoped>
.page{ min-height:100vh; display:flex; align-items:center; justify-content:center; position:relative; overflow:hidden; }
.embers{ position:absolute; inset:0; overflow:hidden; pointer-events:none; }
.ember{ position:absolute; bottom:-20px; width:3px; height:3px; border-radius:50%; background:var(--flame2);
  box-shadow:0 0 8px 2px var(--flame); animation:rise linear infinite; }
@keyframes rise{ 0%{ transform:translateY(0) scale(1); opacity:.8 } 100%{ transform:translateY(-110vh) scale(.2); opacity:0 } }
.brand{ position:absolute; top:34px; text-align:center; width:100%; }
.brand h1{ font-size:30px; letter-spacing:12px; color:var(--gold2); text-shadow:0 0 18px rgba(212,175,55,.55); }
.brand p{ margin-top:8px; font-size:12px; letter-spacing:6px; color:#a8926b; }
.wrap{ position:relative; z-index:2; width:400px; max-width:92vw; }
.card{ background:linear-gradient(145deg, rgba(28,22,18,.94), rgba(16,13,11,.96)); border:1px solid var(--line);
  border-radius:14px; padding:40px 36px 34px; position:relative;
  box-shadow:0 0 0 1px rgba(0,0,0,.6), 0 18px 60px rgba(0,0,0,.7), inset 0 0 40px rgba(226,84,42,.05); }
.card::before,.card::after{ content:""; position:absolute; width:26px; height:26px; border:2px solid var(--gold); }
.card::before{ top:-1px; left:-1px; border-right:none; border-bottom:none; border-radius:14px 0 0 0; }
.card::after{ bottom:-1px; right:-1px; border-left:none; border-top:none; border-radius:0 0 14px 0; }
.title{ text-align:center; font-size:22px; letter-spacing:4px; color:var(--gold2); }
.subtitle{ text-align:center; font-size:12px; color:#8c7a5c; margin:6px 0 28px; letter-spacing:2px; }
.field{ margin-bottom:18px; }
.field label{ display:block; font-size:13px; color:#b9a67e; margin-bottom:8px; letter-spacing:1px; }
.input{ width:100%; height:46px; background:rgba(0,0,0,.35); border:1px solid rgba(212,175,55,.25);
  border-radius:8px; padding:0 14px; color:#f0e4c8; font-size:14px; outline:none; transition:.25s; }
.input:focus{ border-color:var(--gold); box-shadow:0 0 12px rgba(212,175,55,.25); }
.input::placeholder{ color:#6b5c44; }
.btn{ width:100%; height:48px; margin-top:10px; border:none; border-radius:8px; cursor:pointer; font-size:16px;
  letter-spacing:6px; font-weight:700; color:#1a1206; background:linear-gradient(90deg,#c99a2e,#f5d76e,#c99a2e);
  box-shadow:0 6px 20px rgba(212,175,55,.3); transition:.25s; }
.btn:hover:not(:disabled){ filter:brightness(1.12); box-shadow:0 8px 28px rgba(245,215,110,.45); }
.btn:disabled{ opacity:.6; cursor:not-allowed; }
.msg{ min-height:18px; text-align:center; color:#ff7a5c; font-size:13px; margin-top:12px; }

/* 天赋测试入口 */
.talent-entry{ display:flex; align-items:center; gap:11px; margin-top:14px; padding:11px 13px;
  border-radius:9px; cursor:pointer; transition:.24s;
  border:1px dashed rgba(212,175,55,.34); background:rgba(212,175,55,.05); }
.talent-entry:hover{ border-style:solid; border-color:var(--gold);
  background:rgba(212,175,55,.11); box-shadow:0 0 20px rgba(212,175,55,.16);
  transform:translateY(-1px); }
.te-icon{ flex-shrink:0; width:30px; height:30px; border-radius:7px; display:grid; place-items:center;
  font-size:13px; font-weight:800; color:#1a1206;
  background:linear-gradient(145deg,#c99a2e,#f5d76e);
  box-shadow:0 0 14px rgba(212,175,55,.35); }
.te-body{ flex:1; text-align:left; }
.te-body b{ display:block; font-size:12.5px; color:var(--gold2); letter-spacing:.8px; font-weight:600; }
.te-body i{ display:block; margin-top:3px; font-size:10.5px; font-style:normal;
  color:#8c7a5c; letter-spacing:.5px; }
.te-arrow{ font-size:17px; color:#8c7a5c; line-height:1; }
.talent-entry:hover .te-arrow{ color:var(--gold2); }

.foot{ margin-top:14px; text-align:center; font-size:13px; color:#9c8a68; }
.foot a:hover{ text-decoration:underline; }
</style>
