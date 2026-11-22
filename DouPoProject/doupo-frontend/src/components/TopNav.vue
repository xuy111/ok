<template>
  <header class="nav">
    <div class="nav-inner">
      <div class="logo" @click="$router.push('/home')">
        <span class="logo-mark">斗</span>
        <div class="logo-text">
          <b>斗破苍穹</b>
          <i>异火图鉴</i>
        </div>
      </div>

      <nav class="menu">
        <router-link to="/home" :class="{ on: active === 'home' }">图鉴</router-link>
        <router-link to="/mine" :class="{ on: active === 'mine' }">我的异火</router-link>
        <router-link to="/graph" :class="{ on: active === 'graph' }">关系图谱</router-link>
        <router-link to="/journey" :class="{ on: active === 'journey' }">人物历程</router-link>
        <router-link to="/gallery" :class="{ on: active === 'gallery' }">照片墙</router-link>
        <router-link to="/cg" :class="{ on: active === 'cg' }">名场面CG</router-link>
        <router-link to="/sim" :class="{ on: active === 'sim' }">异火融合</router-link>
        <router-link to="/alchemy" :class="{ on: active === 'alchemy' }">炼药</router-link>
        <router-link to="/talent" :class="{ on: active === 'talent' }">天赋</router-link>
        <router-link to="/admin/login" class="admin-entry" title="进入后台管理系统（仅管理员可登录）">
          <span class="ae-icon">⚙</span>后台管理
        </router-link>
      </nav>

      <div class="tools">
        <button class="tool" :class="{ done: signedToday }" @click="doSign" :title="signedToday ? '今日已签到' : '点击签到'">
          <span class="ti">✦</span><span class="tl">{{ signedToday ? '已签到' : '签到' }}</span>
        </button>

        <button class="tool draw" @click="openDraw" title="异火降临">
          <span class="ti">🎴</span><span class="tl">异火降临</span>
          <em class="badge">{{ drawLeft }}</em>
        </button>

        <button class="tool icon-only bg-switch" @click="toggleBg"
          :title="wallpaper ? '切回动态背景' : '切换到桌面壁纸'">
          <!-- 壁纸态：影片图标，点我切回动态背景 -->
          <svg v-if="wallpaper" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <rect x="3" y="5" width="18" height="14" rx="2.5" />
            <path d="M3 9.5h18" />
            <path d="M10.5 12.8l4.2 2.2-4.2 2.2z" fill="currentColor" stroke="none" />
          </svg>
          <!-- 动态态：山水图标，点我切到桌面壁纸 -->
          <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor"
               stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <circle cx="17" cy="6.5" r="2" />
            <path d="M3 19.5h18" />
            <path d="M4.5 19.5l5.5-7.5 3.5 4 3-4 4 7.5" />
          </svg>
        </button>

        <div class="user-box" @click="$router.push('/talent')" :title="talentHint">
          <!-- 测过天赋：头像用五行属性字 + 属性色；没测过退回昵称首字 -->
          <div class="avatar" :class="{ 'has-talent': hasTalent }" :style="avatarStyle">
            {{ avatarChar }}
          </div>
          <div class="who">
            <b>{{ user.nickname || user.username }}</b>
            <i v-if="isAdminUser" class="role admin">管理员</i>
            <i v-else-if="hasTalent" class="role talent" :style="{ color: talentTone }">{{ talentShort }}</i>
            <i v-else class="role">{{ realm.name }}</i>
          </div>
          <div class="realm" v-if="realm.name" :title="realmHint">
            <div class="realm-bar"><span :style="{ width: realm.progress + '%' }"></span></div>
          </div>
        </div>

        <!-- 窄屏时菜单被隐藏，这里保留一个紧凑的后台入口 -->
        <button class="btn-admin-m" @click="$router.push('/admin/login')" title="后台管理系统">
          <span class="ae-icon">⚙</span><span class="lbl">后台管理</span>
        </button>
        <button class="btn-quit" @click="logout">退出</button>
      </div>
    </div>

    <DrawModal :show="drawShow" @close="drawShow = false" @drawn="onDrawn" />
  </header>
</template>

<script>
import api from '../api'
import { store, loadProfile, loadUser, isAdmin } from '../store'
import { applyBg, applyAccent, FIRE_COLORS } from '../theme'
import DrawModal from './DrawModal.vue'

export default {
  name: 'TopNav',
  components: { DrawModal },
  props: {
    active: { type: String, default: 'home' }
  },
  data() {
    return {
      drawShow: false,
      wallpaper: document.body.classList.contains('wallpaper'),
      signedToday: false,
      drawLeft: 3
    }
  },
  computed: {
    user() {
      return store.user || {}
    },
    profile() {
      return store.profile
    },
    isAdminUser() {
      return isAdmin()
    },
    realm() {
      return (store.profile && store.profile.realm) || { name: '', progress: 0 }
    },
    realmHint() {
      const r = this.realm
      if (!r || !r.name) return ''
      if (r.nextName === '已至巅峰') return `${r.name} · 已至巅峰`
      return `${r.name} · 修为 ${r.score} · 距 ${r.nextName} 还差 ${r.remain}`
    },
    /** 天赋称号，如「木属性·天生炼药师」 */
    talent() {
      const p = store.profile
      const t = (p && p.talent) || (store.user && store.user.talent) || ''
      return t
    },
    hasTalent() {
      return !!this.talent
    },
    /** 头像取属性字（木/火/金/水/土），没天赋时取昵称首字 */
    avatarChar() {
      if (this.hasTalent) {
        const m = this.talent.match(/^([木火金水土])/)
        if (m) return m[1]
      }
      return (this.user.nickname || this.user.username || '?').slice(0, 1)
    },
    /** 属性主色 */
    talentTone() {
      const map = { 火: '#ff6a3d', 木: '#5fbf7a', 金: '#d8d2c4', 水: '#4aa8d8', 土: '#b98a52' }
      const m = this.talent.match(/^([木火金水土])/)
      return m ? map[m[1]] : '#d4af37'
    },
    talentShort() {
      // 只显示「属性·职业」里的职业部分，窄栏放得下
      const parts = this.talent.split('·')
      return parts.length > 1 ? parts[1] : this.talent
    },
    avatarStyle() {
      if (!this.hasTalent) return {}
      const tone = this.talentTone
      return {
        '--tone': tone,
        background: `radial-gradient(circle at 35% 25%, color-mix(in srgb, ${tone} 42%, #1a1510), #241c14)`,
        borderColor: `color-mix(in srgb, ${tone} 62%, transparent)`,
        color: '#fff'
      }
    },
    talentHint() {
      const p = store.profile
      if (!this.hasTalent) return '还没测天赋？点击测出你的斗气大陆身份证'
      const score = p && p.talentScore ? p.talentScore : ''
      const rank = p && p.talentRank ? p.talentRank : ''
      return `${this.talent}${rank ? ' · ' + rank : ''}${score ? ' · 魂力 ' + score : ''}\n点击查看 / 重测`
    }
  },
  watch: {
    profile: {
      immediate: true,
      handler(p) {
        if (!p) return
        this.signedToday = !!p.signedToday
        this.drawLeft = p.drawLeft
      }
    }
  },
  async created() {
    loadUser()
    await loadProfile()
    this.sync()
  },
  mounted() {
    // 背景状态由 App 在 created 时恢复，本组件初始化可能早于那时，
    // 故监听 body class 保持按钮图标与实际背景同步。
    this.bgObserver = new MutationObserver(() => {
      this.wallpaper = document.body.classList.contains('wallpaper')
    })
    this.bgObserver.observe(document.body, { attributes: true, attributeFilter: ['class'] })
  },
  beforeUnmount() {
    if (this.bgObserver) this.bgObserver.disconnect()
  },
  methods: {
    sync() {
      const p = store.profile
      if (!p) return
      this.signedToday = !!p.signedToday
      this.drawLeft = p.drawLeft
    },
    async doSign() {
      if (this.signedToday) return
      try {
        const res = await api.sign()
        if (res && res.code === 200) {
          this.signedToday = true
          await loadProfile()
          this.sync()
        }
      } catch (e) {
        alert(e.message)
      }
    },
    openDraw() {
      this.drawShow = true
    },
    async onDrawn() {
      await loadProfile()
      this.sync()
      this.$emit('changed')
    },
    toggleBg() {
      this.wallpaper = !this.wallpaper
      applyBg(this.wallpaper ? 'wallpaper' : 'default')
    },
    /** 由详情弹窗调用：按异火主色切换整站强调色 */
    setAccent(key) {
      if (FIRE_COLORS[key]) applyAccent(key)
    },
    async logout() {
      try {
        await api.logout()
      } catch (e) { /* 忽略 */ }
      localStorage.removeItem('doupo_user')
      localStorage.removeItem('doupo_admin')
      store.user = {}
      store.profile = null
      this.$router.push('/login')
    }
  }
}
</script>

<style scoped>
.nav { position: sticky; top: 0; z-index: 40; background: var(--nav-bg);
  backdrop-filter: blur(12px); border-bottom: 1px solid var(--line); }
.nav-inner { max-width: 1260px; margin: 0 auto; height: 66px; padding: 0 20px;
  display: flex; align-items: center; gap: 20px; }
.logo { display: flex; align-items: center; gap: 10px; cursor: pointer; flex-shrink: 0; }
.logo-mark { width: 34px; height: 34px; border-radius: 8px; display: grid; place-items: center;
  background: linear-gradient(145deg, #c99a2e, #f5d76e); color: #1a1206;
  font-weight: 800; font-size: 18px; box-shadow: 0 0 16px rgba(212,175,55,.35); }
.logo-text b { display: block; font-size: 15px; letter-spacing: 3px; color: var(--gold2); }
.logo-text i { display: block; font-size: 10px; letter-spacing: 3px; color: var(--muted); font-style: normal; }

.menu { display: flex; gap: 2px; flex: 1; min-width: 0; overflow-x: auto; }
.menu a { padding: 7px 11px; border-radius: 7px; font-size: 13.5px; color: var(--muted);
  white-space: nowrap; transition: .2s; border: 1px solid transparent; }
.menu a:hover { color: var(--gold2); background: rgba(212,175,55,.07); }
.menu a.on { color: var(--gold2); background: rgba(212,175,55,.12); border-color: var(--line); }

/* 后台管理系统入口：金色描边按钮，一眼能认出来 */
.menu a.admin-entry { margin-left: 8px; display: inline-flex; align-items: center; gap: 5px;
  color: var(--gold2); font-weight: 600; letter-spacing: .5px;
  border: 1px solid rgba(212,175,55,.45); background: rgba(212,175,55,.08); }
.menu a.admin-entry:hover { color: #1a1206; background: linear-gradient(90deg, #c99a2e, #f5d76e);
  border-color: transparent; box-shadow: 0 0 16px rgba(212,175,55,.3); }
.menu a.admin-entry .ae-icon { font-size: 12.5px; line-height: 1; }

.tools { display: flex; align-items: center; gap: 8px; flex-shrink: 0; margin-left: auto; }
.tool { position: relative; height: 32px; padding: 0 10px; border-radius: 7px; cursor: pointer;
  display: inline-flex; align-items: center; gap: 5px; font-size: 12.5px;
  color: var(--muted); background: transparent; border: 1px solid rgba(212,175,55,.24); }
.tool:hover { color: var(--gold2); border-color: var(--gold); }
.tool.done { color: #7fd6a0; border-color: rgba(127,214,160,.35); cursor: default; }
.tool.draw { color: #ffcf7a; border-color: rgba(var(--flame-rgb),.42);
  background: rgba(var(--flame-rgb),.10); }
.tool .ti { font-size: 12px; }
.badge { position: absolute; top: -6px; right: -6px; min-width: 15px; height: 15px; padding: 0 3px;
  border-radius: 8px; font-size: 10px; font-style: normal; line-height: 15px; text-align: center;
  color: #1a1206; background: linear-gradient(90deg, #c99a2e, #f5d76e); font-weight: 700; }
.icon-only { width: 32px; padding: 0; justify-content: center; font-size: 13px; }
.bg-switch { color: var(--gold2); border-color: rgba(212,175,55,.4);
  background: rgba(212,175,55,.08); }
.bg-switch svg { width: 17px; height: 17px; display: block; transition: transform .25s; }
.bg-switch:hover { color: var(--gold2); border-color: var(--gold);
  background: rgba(212,175,55,.18); box-shadow: 0 0 12px rgba(212,175,55,.3); }
.bg-switch:hover svg { transform: scale(1.12); }

.user-box { display: flex; align-items: center; gap: 8px; cursor: pointer; padding: 3px 4px;
  border-radius: 8px; transition: .2s; }
.user-box:hover { background: rgba(212,175,55,.07); }
.avatar { width: 30px; height: 30px; border-radius: 50%; display: grid; place-items: center;
  background: linear-gradient(145deg, #2a2018, #3a2c1c); border: 1px solid var(--line);
  color: var(--gold2); font-size: 13px; transition: .25s; }
.avatar.has-talent { font-size: 14px; font-weight: 800;
  box-shadow: 0 0 0 2px rgba(0,0,0,.3), 0 0 14px color-mix(in srgb, var(--tone) 45%, transparent); }
.user-box:hover .avatar { transform: scale(1.06); }
.who b { display: block; font-size: 12.5px; color: var(--text); font-weight: 600; }
.role { font-size: 10px; color: var(--muted); font-style: normal; letter-spacing: 1px; }
.role.admin { color: #ff9d5c; }
.role.talent { font-weight: 600; }
.realm { width: 62px; }
.realm-bar { height: 3px; border-radius: 2px; background: rgba(212,175,55,.18); overflow: hidden; }
.realm-bar span { display: block; height: 100%; border-radius: 2px;
  background: linear-gradient(90deg, var(--flame2), var(--gold2)); transition: width .5s; }

.btn-admin-m { display: none; align-items: center; gap: 4px; height: 32px; padding: 0 12px;
  border-radius: 7px; cursor: pointer; font-size: 12.5px; font-weight: 700; letter-spacing: .5px;
  color: var(--gold2); background: rgba(212,175,55,.08); border: 1px solid rgba(212,175,55,.45); }
.btn-admin-m:hover { color: #1a1206; background: linear-gradient(90deg, #c99a2e, #f5d76e); border-color: transparent; }
.btn-quit { height: 32px; padding: 0 10px; border-radius: 7px; cursor: pointer; font-size: 12.5px;
  background: transparent; border: 1px solid rgba(212,175,55,.28); color: var(--muted); }
.btn-quit:hover { color: var(--gold2); border-color: var(--gold); }

@media (max-width: 1180px) {
  .menu { display: none; }
  .tool .tl { display: none; }
  .tool { padding: 0 8px; }
  .btn-admin-m { display: inline-flex; }
}
@media (max-width: 720px) {
  .user-box .who, .realm { display: none; }
  .btn-admin-m .lbl { display: none; }
  .btn-admin-m { padding: 0 9px; }
}
@media (prefers-reduced-motion: reduce) {
  .bg-switch svg { transition: none !important; }
  .bg-switch:hover svg { transform: none !important; }
}
</style>
