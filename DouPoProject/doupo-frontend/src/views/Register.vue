<template>
  <div class="page">
    <div class="embers">
      <span v-for="i in 30" :key="i" class="ember"
        :style="{ left: embers[i-1].left, animationDuration: embers[i-1].dur, animationDelay: embers[i-1].delay, opacity: embers[i-1].op }"></span>
    </div>
    <div class="brand">
      <h1>斗破苍穹</h1>
      <p>异火图鉴 · 开启你的修炼之路</p>
    </div>
    <div class="wrap">
      <div class="card">
        <div class="title">创建账号</div>
        <div class="subtitle">REGISTER · 注册即为默认权限</div>

        <!-- 从天赋测试带过来的结果 -->
        <div class="talent-chip" v-if="talent" :style="{ '--tone': talent.tone || '#d4af37' }">
          <span class="tc-seal">{{ talent.title.slice(0, 1) }}</span>
          <span class="tc-body">
            <b :style="{ color: talent.tone }">{{ talent.title }}</b>
            <i>魂力 {{ talent.score }} · {{ talent.rank }}</i>
          </span>
          <button class="tc-x" @click="clearTalent" title="不带天赋注册">✕</button>
        </div>
        <div class="talent-empty" v-else @click="$router.push('/talent')">
          还没测天赋？<b>先去测一下</b> ›
        </div>

        <div class="field">
          <label>用户名</label>
          <input class="input" v-model="form.username" placeholder="请输入用户名（2-20位）">
        </div>
        <div class="field">
          <label>密码</label>
          <input class="input" type="password" v-model="form.password" placeholder="请输入密码">
        </div>
        <div class="field">
          <label>确认密码</label>
          <input class="input" type="password" v-model="form.confirm" @keyup.enter="doRegister" placeholder="请再次输入密码">
        </div>
        <button class="btn" :disabled="loading" @click="doRegister">{{ loading ? '注册中…' : '注 册' }}</button>
        <div class="msg">{{ msg }}</div>
        <div class="foot">已有账号？<router-link to="/login">返回登录</router-link></div>
      </div>
    </div>
  </div>
</template>

<script>
import api from '../api'
export default {
  name: 'Register',
  data() {
    const arr = []
    for (let i = 0; i < 30; i++) arr.push({ left:(Math.random()*100)+'%', dur:(5+Math.random()*8)+'s', delay:(Math.random()*8)+'s', op:Math.random()*.7+.2 })
    return { form:{ username:'', password:'', confirm:'' }, msg:'', loading:false, embers:arr, talent:null }
  },
  created() {
    // 天赋测试页会把结果写进 localStorage 再跳过来
    try {
      const t = JSON.parse(localStorage.getItem('doupo_talent') || 'null')
      if (t && t.title) this.talent = t
    } catch (e) { /* 忽略 */ }
  },
  methods: {
    clearTalent() {
      localStorage.removeItem('doupo_talent')
      this.talent = null
    },
    async doRegister() {
      this.msg = ''
      const u = this.form.username.trim()
      if (u.length < 2 || u.length > 20) return this.msg = '用户名需为 2-20 位'
      if (!this.form.password) return this.msg = '请输入密码'
      if (this.form.password !== this.form.confirm) return this.msg = '两次密码不一致'
      this.loading = true
      try {
        const payload = { username:u, password:this.form.password }
        if (this.talent) {
          payload.talent = this.talent.title
          payload.talentRank = this.talent.rank
          payload.talentScore = String(this.talent.score)
        }
        const res = await api.register(payload)
        if (res && res.code === 200) {
          this.msg = '注册成功，正在跳转登录…'
          setTimeout(() => this.$router.push('/login'), 800)
        } else {
          this.msg = (res && res.msg) || '注册失败'
        }
      } catch (e) { this.msg = e.message }
      finally { this.loading = false }
    }
  }
}
</script>

<style scoped>
.page{ min-height:100vh; display:flex; align-items:center; justify-content:center; position:relative; overflow:hidden; }
.embers{ position:absolute; inset:0; overflow:hidden; pointer-events:none; }
.ember{ position:absolute; bottom:-20px; width:3px; height:3px; border-radius:50%; background:var(--flame2); box-shadow:0 0 8px 2px var(--flame); animation:rise linear infinite; }
@keyframes rise{ 0%{ transform:translateY(0) scale(1); opacity:.8 } 100%{ transform:translateY(-110vh) scale(.2); opacity:0 } }
.brand{ position:absolute; top:30px; text-align:center; width:100%; }
.brand h1{ font-size:28px; letter-spacing:12px; color:var(--gold2); text-shadow:0 0 18px rgba(212,175,55,.55); }
.brand p{ margin-top:8px; font-size:12px; letter-spacing:4px; color:#a8926b; }
.wrap{ position:relative; z-index:2; width:400px; max-width:92vw; }
.card{ background:linear-gradient(145deg, rgba(28,22,18,.94), rgba(16,13,11,.96)); border:1px solid var(--line); border-radius:14px; padding:34px 36px 30px; position:relative; box-shadow:0 0 0 1px rgba(0,0,0,.6), 0 18px 60px rgba(0,0,0,.7); }
.card::before,.card::after{ content:""; position:absolute; width:26px; height:26px; border:2px solid var(--gold); }
.card::before{ top:-1px; left:-1px; border-right:none; border-bottom:none; border-radius:14px 0 0 0; }
.card::after{ bottom:-1px; right:-1px; border-left:none; border-top:none; border-radius:0 0 14px 0; }
.title{ text-align:center; font-size:22px; letter-spacing:4px; color:var(--gold2); }
.subtitle{ text-align:center; font-size:12px; color:#8c7a5c; margin:6px 0 22px; letter-spacing:2px; }

/* 天赋徽章：从测试页带过来的结果 */
.talent-chip{ display:flex; align-items:center; gap:10px; margin-bottom:16px; padding:10px 12px;
  border-radius:9px; border:1px dashed color-mix(in srgb, var(--tone) 55%, transparent);
  background:color-mix(in srgb, var(--tone) 9%, transparent); }
.tc-seal{ flex-shrink:0; width:30px; height:30px; border-radius:7px; display:grid; place-items:center;
  font-size:15px; font-weight:800; color:#fff;
  background:color-mix(in srgb, var(--tone) 68%, #1a1510);
  border:1px solid color-mix(in srgb, var(--tone) 85%, transparent);
  text-shadow:0 0 10px color-mix(in srgb, var(--tone) 80%, transparent); }
.tc-body{ flex:1; text-align:left; }
.tc-body b{ display:block; font-size:12.5px; letter-spacing:1px; }
.tc-body i{ display:block; margin-top:2px; font-size:10.5px; font-style:normal; color:#9c8a68; }
.tc-x{ width:20px; height:20px; border-radius:50%; cursor:pointer; font-size:10px; line-height:1;
  color:#8c7a5c; background:transparent; border:1px solid rgba(212,175,55,.24); }
.tc-x:hover{ color:#ff7a5c; border-color:rgba(255,122,92,.5); }
.talent-empty{ margin-bottom:16px; padding:9px 12px; border-radius:8px; cursor:pointer; text-align:center;
  font-size:11.5px; color:#8c7a5c; border:1px dashed rgba(212,175,55,.22); background:rgba(212,175,55,.03); }
.talent-empty b{ color:var(--gold2); font-weight:600; }
.talent-empty:hover{ border-color:rgba(212,175,55,.5); background:rgba(212,175,55,.08); }
.field{ margin-bottom:16px; }
.field label{ display:block; font-size:13px; color:#b9a67e; margin-bottom:8px; letter-spacing:1px; }
.input{ width:100%; height:44px; background:rgba(0,0,0,.35); border:1px solid rgba(212,175,55,.25); border-radius:8px; padding:0 14px; color:#f0e4c8; font-size:14px; outline:none; transition:.25s; }
.input:focus{ border-color:var(--gold); box-shadow:0 0 12px rgba(212,175,55,.25); }
.input::placeholder{ color:#6b5c44; }
.btn{ width:100%; height:48px; margin-top:10px; border:none; border-radius:8px; cursor:pointer; font-size:16px; letter-spacing:6px; font-weight:700; color:#1a1206; background:linear-gradient(90deg,#c99a2e,#f5d76e,#c99a2e); box-shadow:0 6px 20px rgba(212,175,55,.3); transition:.25s; }
.btn:hover:not(:disabled){ filter:brightness(1.12); }
.btn:disabled{ opacity:.6; cursor:not-allowed; }
.msg{ min-height:18px; text-align:center; color:#ff7a5c; font-size:13px; margin-top:12px; }
.foot{ margin-top:12px; text-align:center; font-size:13px; color:#9c8a68; }
.foot a:hover{ text-decoration:underline; }
</style>
