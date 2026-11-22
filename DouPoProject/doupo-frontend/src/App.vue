<template>
  <DynamicBg :dense="dense" :hero="isHeroPage" />
  <div class="app-shell">
    <router-view />
  </div>
</template>

<script>
import DynamicBg from './components/DynamicBg.vue'
import { loadAccent, loadTheme, loadBg } from './theme'
import { loadUser, store } from './store'

export default {
  name: 'App',
  components: { DynamicBg },
  created() {
    loadUser()
    loadTheme()
    loadBg()
    loadAccent()
    window.addEventListener('doupo:auth-expired', this.onUserExpired)
    window.addEventListener('doupo:admin-expired', this.onAdminExpired)
  },
  beforeUnmount() {
    window.removeEventListener('doupo:auth-expired', this.onUserExpired)
    window.removeEventListener('doupo:admin-expired', this.onAdminExpired)
  },
  computed: {
    /** 登录/注册这类空页面保持立绘清晰；内容页自动压暗一档 */
    dense() {
      const p = this.$route.path
      return !(p === '/login' || p === '/register' || p === '/admin/login')
    },
    /** 图鉴页：横幅要露出人物，卡片区要压住字，用专门的分层遮罩 */
    isHeroPage() {
      return this.$route.path === '/home'
    }
  },
  methods: {
    /** 前台令牌失效：清状态并回登录页（避免停在页面上看到假数据） */
    onUserExpired() {
      store.user = {}
      store.profile = null
      const path = this.$route.path
      if (path === '/login' || path === '/register' || path.startsWith('/admin')) return
      this.$router.replace({ path: '/login', query: { expired: '1' } })
    },
    onAdminExpired() {
      if (!this.$route.path.startsWith('/admin') || this.$route.path === '/admin/login') return
      this.$router.replace({ path: '/admin/login', query: { expired: '1' } })
    }
  }
}
</script>

<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
/* 前景层：压住动态背景，各页面保持原有 z-index 关系 */
.app-shell { position: relative; z-index: 1; min-height: 100vh; }
:root{
  --gold:#d4af37; --gold2:#f5d76e; --flame:#ff8c42; --flame2:#e2542a;
  --flame-rgb:255,140,66;
  --ink:#0c0a09; --ink2:#171310; --line:rgba(212,175,55,.35);
  --text:#e8dcc0; --muted:#a8926b;
  /* 语义色：切白昼模式时只需要改这几个 */
  --nav-bg:rgba(12,10,9,.86);
  --card:linear-gradient(150deg, rgba(30,24,19,.92), rgba(16,13,11,.94));
  --card-line:rgba(212,175,55,.22);
  --panel:rgba(0,0,0,.36);
  --panel-solid:#12100e;
  --txt:#f0e4c8;
  --sub:#9c8a68;
  --label:#8c7a5c;
  --shadow:0 14px 34px rgba(0,0,0,.5);
}
body.light{
  --ink:#f7f2e8; --ink2:#efe6d6; --line:rgba(160,124,40,.35);
  --text:#33291d; --muted:#7d6a4f;
  --nav-bg:rgba(252,248,240,.9);
  --card:linear-gradient(150deg,#fffdf8,#f6eede);
  --card-line:rgba(170,132,44,.28);
  --panel:rgba(255,255,255,.72);
  --panel-solid:#fffdf8;
  --txt:#33291d;
  --sub:#6f5d45;
  --label:#8a7355;
  --shadow:0 12px 28px rgba(120,95,50,.16);
}
html,body,#app{ height:100%; }
body{
  font-family:"Microsoft YaHei","PingFang SC",serif;
  color:var(--text);
  background:
    radial-gradient(circle at 50% 0%, rgba(var(--flame-rgb),.18), transparent 45%),
    linear-gradient(160deg,#0c0a09 0%,#171310 50%,#0c0a09 100%);
  min-height:100vh;
  transition:background .5s ease;
}
body.light{
  background:
    radial-gradient(circle at 50% 0%, rgba(var(--flame-rgb),.16), transparent 45%),
    linear-gradient(160deg,#fbf7ef 0%,#f1e9da 60%,#fbf7ef 100%);
}
a{ color:var(--gold2); text-decoration:none; }
input,button,textarea,select{ font-family:inherit; }
::-webkit-scrollbar{ width:8px; height:8px; }
::-webkit-scrollbar-thumb{ background:rgba(212,175,55,.35); border-radius:4px; }
::-webkit-scrollbar-track{ background:rgba(0,0,0,.2); }

/* ---------- 全局动画：卡片火焰浮现 ---------- */
@keyframes cardIn{
  0%{ opacity:0; transform:translateY(26px) scale(.96); filter:blur(6px) }
  60%{ opacity:1; filter:blur(0) }
  100%{ opacity:1; transform:translateY(0) scale(1) }
}
@keyframes flamePulse{
  0%,100%{ box-shadow:0 0 0 0 rgba(var(--flame-rgb),.0) }
  50%{ box-shadow:0 0 22px 2px rgba(var(--flame-rgb),.28) }
}
@keyframes glowSweep{
  0%{ transform:translateX(-120%) }
  100%{ transform:translateX(220%) }
}
.fade-enter-active,.fade-leave-active{ transition:opacity .22s ease }
.fade-enter-from,.fade-leave-to{ opacity:0 }

/* ---------- 白昼模式：把鎏金标题压深，避免金底金字看不清 ---------- */
body.light .page .brand h1 { color: #8a6a12; text-shadow: 0 0 18px rgba(180, 140, 40, .25); }
body.light .page .brand p { color: #8a7355; }
body.light .logo-text b,
body.light .hero h1,
body.light .head h1,
body.light .stat b,
body.light .content-head h2,
body.light .ach-wrap h2,
body.light .tab-head h2,
body.light .p-head b,
body.light .ach-main b,
body.light .menu a.on,
body.light .vs,
body.light .r-formula i{ color:#7a5f14; }
body.light .hero h1,
body.light .head h1{ text-shadow:0 0 20px rgba(180,140,40,.18); }
body.light .slogan,
body.light .realm-strip .rs-next{ color:#7d6a4f; }
body.light .g-tian{ color:#b4520f; background:rgba(226,84,42,.10); border-color:rgba(226,84,42,.3) }
body.light .g-di{ color:#5b3fa8; background:rgba(140,110,220,.10); border-color:rgba(140,110,220,.3) }
body.light .g-xuan{ color:#1e5fa8; background:rgba(80,140,220,.10); border-color:rgba(80,140,220,.3) }
body.light .g-huang{ color:#5c5344; background:rgba(120,110,90,.10); border-color:rgba(120,110,90,.25) }
body.light .cat{ color:#8a7355; border-color:rgba(160,124,40,.28) }
body.light .card h3,
body.light .got-name,
body.light .m-name{ color:#33291d }
body.light .card p{ color:#6f5d45 }

</style>
