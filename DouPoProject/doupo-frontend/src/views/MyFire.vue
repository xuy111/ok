<template>
  <div class="myfire">
    <div class="embers">
      <span v-for="i in 18" :key="i" class="ember"
        :style="{ left: embers[i-1].left, animationDuration: embers[i-1].dur, animationDelay: embers[i-1].delay, opacity: embers[i-1].op }"></span>
    </div>

    <TopNav ref="nav" active="mine" @changed="reload" />

    <!-- 未登录提示：避免出现「已收服 0 / 待收服 27」这种误导性数字 -->
    <div v-if="!loggedIn" class="login-tip">
      <span>当前未登录，收服记录不会保存</span>
      <button @click="$router.push('/login')">去登录</button>
    </div>

    <transition name="fade">
      <div v-if="toast" class="toast" :class="toastType">{{ toast }}</div>
    </transition>

    <section class="head">
      <h1>我的异火</h1>
      <p class="slogan">已收服 {{ collected.length }} / {{ all.length }} 种</p>

      <div class="ring-wrap">
        <svg viewBox="0 0 120 120" class="ring">
          <circle cx="60" cy="60" r="52" class="track" />
          <circle cx="60" cy="60" r="52" class="bar"
                  :stroke-dasharray="circ" :stroke-dashoffset="circ - circ * pct / 100" />
        </svg>
        <div class="ring-txt">
          <b>{{ pct }}%</b>
          <span>图鉴完成度</span>
        </div>
      </div>

      <div class="tiles">
        <div class="tile"><b>{{ collected.length }}</b><span>已收服</span></div>
        <div class="tile"><b>{{ all.length - collected.length }}</b><span>待收服</span></div>
        <div class="tile"><b>{{ realm.name }}</b><span>当前境界</span></div>
        <div class="tile"><b>{{ signDays }}</b><span>签到天数</span></div>
      </div>
    </section>

    <!-- 成就 -->
    <section class="ach-wrap">
      <h2>成就</h2>
      <div class="ach-list">
        <div v-for="a in achievements" :key="a.name" class="ach" :class="{ on: a.unlocked }">
          <div class="ach-badge">{{ a.unlocked ? '★' : '☆' }}</div>
          <div class="ach-main">
            <b>{{ a.name }}</b>
            <span>{{ a.desc }}</span>
          </div>
          <div class="ach-num" v-if="a.need > 0">{{ a.progress }}/{{ a.need }}</div>
          <div class="ach-num" v-else>{{ a.unlocked ? '已达成' : '未达成' }}</div>
        </div>
      </div>
    </section>

    <!-- 已收集 -->
    <section class="content">
      <div class="tab-head">
        <h2>已收服 <em>{{ collected.length }}</em></h2>
      </div>
      <div v-if="!collected.length" class="empty">还没有收服任何异火，去图鉴里点「收服」吧</div>
      <div v-else class="grid">
        <ItemCard v-for="(it, i) in collected" :key="it.id" :item="it" :index="i"
                  :collected="true" @open="openDetail" @toggle="toggle" />
      </div>
    </section>

    <!-- 未收集（剪影） -->
    <section class="content">
      <div class="tab-head">
        <h2>待收服 <em>{{ all.length - collected.length }}</em></h2>
      </div>
      <div class="grid">
        <div v-for="it in pending" :key="it.id" class="silhouette" @click="openDetail(it)">
          <div class="sil-img" v-if="artOf(it)" :style="{ backgroundImage: 'url(' + artOf(it) + ')' }"></div>
          <div class="sil-icon" v-else>{{ it.icon || '🔥' }}</div>
          <div class="sil-name">{{ it.name }}</div>
          <div class="sil-mask">未收服</div>
          <span class="sil-diff">{{ '✦'.repeat(it.difficulty || 0) }}</span>
        </div>
      </div>
    </section>

    <footer class="foot">
      <p>斗破苍穹 · 异火图鉴</p>
    </footer>

    <DetailModal :show="detailShow" :item="current" @close="detailShow = false"
                 @accent="setAccent" @changed="reload" />
  </div>
</template>

<script>
import api from '../api'
import { store, loadProfile, loadUser, applyCollect } from '../store'
import { artOf } from '../art'
import TopNav from '../components/TopNav.vue'
import ItemCard from '../components/ItemCard.vue'
import DetailModal from '../components/DetailModal.vue'

export default {
  name: 'MyFire',
  components: { TopNav, ItemCard, DetailModal },
  data() {
    const arr = []
    for (let i = 0; i < 18; i++) {
      arr.push({
        left: (Math.random() * 100) + '%',
        dur: (7 + Math.random() * 8) + 's',
        delay: (Math.random() * 8) + 's',
        op: Math.random() * 0.4 + 0.12
      })
    }
    return {
      all: [],
      detailShow: false,
      current: {},
      embers: arr,
      circ: 2 * Math.PI * 52,
      toast: '',
      toastType: 'ok'
    }
  },
  computed: {
    loggedIn() {
      return !!(store.user && store.user.token)
    },
    profile() {
      return store.profile
    },
    ids() {
      return (store.profile && store.profile.ids) || []
    },
    collected() {
      return this.all.filter(it => this.ids.indexOf(it.id) >= 0)
    },
    pending() {
      return this.all.filter(it => this.ids.indexOf(it.id) < 0)
    },
    pct() {
      if (!this.all.length) return 0
      return Math.round(this.collected.length * 100 / this.all.length)
    },
    realm() {
      return (store.profile && store.profile.realm) || { name: '斗者', progress: 0 }
    },
    signDays() {
      return (store.profile && store.profile.signDays) || 0
    },
    achievements() {
      return (store.profile && store.profile.achievements) || []
    }
  },
  async created() {
    loadUser()
    await loadProfile()
    await this.loadAll()
  },
  methods: {
    artOf,
    async loadAll() {
      try {
        const res = await api.itemList({ page: 1, size: 100, sort: 'rank' })
        if (res && res.code === 200) this.all = res.data.list || []
      } catch (e) { /* 忽略 */ }
    },
    async reload() {
      await loadProfile()
      await this.loadAll()
    },
    openDetail(item) {
      this.current = item
      this.detailShow = true
    },
    async toggle(item) {
      try {
        const res = this.ids.indexOf(item.id) >= 0
          ? await api.release(item.id)
          : await api.collect(item.id, '')
        const data = (res && res.data) || {}
        applyCollect(data)
        await loadProfile()
        this.flash(data.collected
          ? '收服成功 ·「' + item.name + '」已收入图鉴'
          : '已放生 ·「' + item.name + '」', 'ok')
      } catch (e) {
        this.flash(e.message || '操作失败，请重试', 'warn')
      }
    },
    flash(text, type) {
      this.toast = text
      this.toastType = type || 'ok'
      clearTimeout(this._toastTimer)
      this._toastTimer = setTimeout(() => { this.toast = '' }, 2600)
    },
    setAccent(key) {
      if (this.$refs.nav && this.$refs.nav.setAccent) this.$refs.nav.setAccent(key)
    }
  }
}
</script>

<style scoped>
.myfire { position: relative; min-height: 100vh; padding-bottom: 30px; }

.login-tip { position: relative; z-index: 2; max-width: 1180px; margin: 14px auto 0; padding: 10px 16px;
  display: flex; align-items: center; justify-content: space-between; gap: 12px;
  border-radius: 10px; font-size: 12.5px; color: #ffcf9e;
  background: rgba(226,84,42,.12); border: 1px solid rgba(226,84,42,.35); }
.login-tip button { height: 28px; padding: 0 14px; border-radius: 6px; cursor: pointer; font-size: 12px;
  color: #1a1206; font-weight: 700; border: none;
  background: linear-gradient(90deg, #e2542a, #ffb347); }
body.light .login-tip { color: #8a3b12; background: rgba(226,84,42,.08); }

.toast { position: fixed; left: 50%; top: 84px; transform: translateX(-50%); z-index: 120;
  padding: 10px 20px; border-radius: 10px; font-size: 13px; letter-spacing: .5px;
  background: var(--panel-solid); border: 1px solid var(--line); color: var(--txt);
  box-shadow: 0 12px 34px rgba(0,0,0,.45); animation: toastIn .28s cubic-bezier(.2,.8,.3,1) both; }
.toast.ok { color: var(--gold2); border-color: rgba(var(--flame-rgb),.55);
  box-shadow: 0 12px 34px rgba(0,0,0,.45), 0 0 22px rgba(var(--flame-rgb),.22); }
.toast.warn { color: #ff9a76; border-color: rgba(226,84,42,.55); }
@keyframes toastIn { from { opacity: 0; transform: translate(-50%, -10px) } to { opacity: 1; transform: translate(-50%, 0) } }
.embers { position: fixed; inset: 0; overflow: hidden; pointer-events: none; z-index: 0; }
.ember { position: absolute; bottom: -20px; width: 2px; height: 2px; border-radius: 50%;
  background: var(--flame); box-shadow: 0 0 8px 2px var(--flame2); animation: rise linear infinite; }
@keyframes rise { 0% { transform: translateY(0); opacity: .7 } 100% { transform: translateY(-105vh) scale(.2); opacity: 0 } }

.head { position: relative; z-index: 1; text-align: center; padding: 44px 20px 10px; }
.head h1 { font-size: 32px; letter-spacing: 12px; color: var(--gold2); font-weight: 800;
  text-shadow: 0 0 24px rgba(212,175,55,.4); }
.slogan { margin-top: 10px; font-size: 12.5px; letter-spacing: 3px; color: var(--muted); }

.ring-wrap { position: relative; width: 130px; height: 130px; margin: 22px auto 0; }
.ring { width: 130px; height: 130px; transform: rotate(-90deg); }
.ring .track { fill: none; stroke: rgba(212,175,55,.14); stroke-width: 7; }
.ring .bar { fill: none; stroke: url(#g); stroke: var(--flame); stroke-width: 7;
  stroke-linecap: round; transition: stroke-dashoffset 1s ease;
  filter: drop-shadow(0 0 6px rgba(var(--flame-rgb),.6)); }
.ring-txt { position: absolute; inset: 0; display: grid; place-content: center; text-align: center; }
.ring-txt b { font-size: 25px; color: var(--gold2); }
.ring-txt span { font-size: 10.5px; color: var(--muted); letter-spacing: 1px; }

.tiles { position: relative; margin: 24px auto 0; display: inline-flex; gap: 12px; flex-wrap: wrap;
  justify-content: center; }
.tile { min-width: 96px; padding: 12px 16px; border-radius: 10px; border: 1px solid var(--line);
  background: var(--panel); }
.tile b { display: block; font-size: 19px; color: var(--gold2); }
.tile span { font-size: 11px; color: var(--muted); letter-spacing: 1px; }

.ach-wrap { position: relative; z-index: 1; max-width: 1180px; margin: 32px auto 0; padding: 0 20px; }
.ach-wrap h2, .tab-head h2 { font-size: 16px; color: var(--gold2); letter-spacing: 3px;
  font-weight: 600; margin-bottom: 14px; }
.tab-head h2 em { font-style: normal; font-size: 12px; color: var(--muted); margin-left: 6px; }
.ach-list { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 10px; }
.ach { display: flex; align-items: center; gap: 10px; padding: 12px 14px; border-radius: 10px;
  border: 1px solid rgba(212,175,55,.14); background: var(--panel); opacity: .55; }
.ach.on { opacity: 1; border-color: rgba(var(--flame-rgb),.4);
  box-shadow: 0 0 18px rgba(var(--flame-rgb),.1); }
.ach-badge { width: 30px; height: 30px; border-radius: 50%; display: grid; place-items: center;
  font-size: 15px; color: var(--flame); border: 1px solid rgba(var(--flame-rgb),.35);
  background: rgba(var(--flame-rgb),.08); flex-shrink: 0; }
.ach-main { flex: 1; min-width: 0; }
.ach-main b { display: block; font-size: 13px; color: var(--txt); }
.ach-main span { font-size: 11px; color: var(--muted); line-height: 1.6; }
.ach-num { font-size: 11px; color: var(--muted); flex-shrink: 0; }

.content { position: relative; z-index: 1; max-width: 1180px; margin: 28px auto 0; padding: 0 20px; }
.grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }

.silhouette { position: relative; height: 176px; border-radius: 12px; cursor: pointer;
  border: 1px dashed rgba(212,175,55,.18); background: rgba(0,0,0,.28);
  display: grid; place-content: center; text-align: center; gap: 6px; overflow: hidden;
  transition: .25s; }
body.light .silhouette { background: rgba(120,100,70,.08); }
.silhouette:hover { border-color: rgba(var(--flame-rgb),.45); }
.sil-img { position: absolute; inset: 0; background-size: cover; background-position: center;
  filter: grayscale(1) brightness(.34) contrast(1.15); opacity: .55; transition: .35s; }
.silhouette:hover .sil-img { filter: grayscale(.65) brightness(.5) contrast(1.1); opacity: .8; }
.sil-icon { font-size: 30px; filter: grayscale(1) brightness(.35); }
.sil-name { font-size: 13px; color: var(--label); filter: blur(.3px); letter-spacing: 2px; }
.sil-mask { position: absolute; bottom: 12px; left: 50%; transform: translateX(-50%);
  font-size: 10.5px; letter-spacing: 2px; color: var(--muted); opacity: .8; }
.sil-diff { position: absolute; top: 10px; right: 12px; font-size: 10px; color: rgba(212,175,55,.3); }

.empty { padding: 40px 0; text-align: center; color: var(--muted); font-size: 13px; }
.foot { position: relative; z-index: 1; margin-top: 44px; text-align: center; font-size: 12px;
  color: var(--label); }

@media (max-width: 980px) { .grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 640px) { .grid { grid-template-columns: 1fr; } }
</style>
