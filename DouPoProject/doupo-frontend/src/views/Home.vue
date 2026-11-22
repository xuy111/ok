<template>
  <div class="home">
    <!-- 视频背景已提升到全局 DynamicBg，见 App.vue -->

    <!-- 动态背景：火星 + 流光 -->
    <div class="embers">
      <span v-for="i in 26" :key="i" class="ember"
        :style="{ left: embers[i-1].left, animationDuration: embers[i-1].dur, animationDelay: embers[i-1].delay, opacity: embers[i-1].op }"></span>
    </div>
    <div class="aurora"></div>

    <TopNav ref="nav" active="home" @changed="refreshAll" />

    <transition name="fade">
      <div v-if="toast" class="toast" :class="toastType">{{ toast }}</div>
    </transition>

    <!-- ==================== 头部横幅 ==================== -->
    <section class="hero">
      <div class="hero-glow"></div>
      <h1>异火图鉴</h1>
      <p class="slogan">三十年河东 · 三十年河西 · 莫欺少年穷</p>

      <div class="stats">
        <div class="stat"><b>{{ overview.total }}</b><span>收录条目</span></div>
        <div class="divider"></div>
        <div class="stat"><b>{{ countOf(overview.categories, '异火') }}</b><span>异火</span></div>
        <div class="divider"></div>
        <div class="stat"><b>{{ countOf(overview.grades, '天阶') }}</b><span>天阶</span></div>
        <div class="divider"></div>
        <div class="stat"><b>{{ collectedCount }}</b><span>我已收服</span></div>
        <div class="divider"></div>
        <div class="stat realm-stat" v-if="realm.name">
          <b>{{ realm.name }}</b><span>当前境界</span>
        </div>
      </div>

      <div class="realm-strip" v-if="realm.name">
        <span class="rs-label">{{ realm.name }}</span>
        <div class="rs-bar"><i :style="{ width: realm.progress + '%' }"></i></div>
        <span class="rs-next" v-if="realm.nextName !== '已至巅峰'">距 {{ realm.nextName }} 还差 {{ realm.remain }}</span>
        <span class="rs-next" v-else>已至巅峰</span>
      </div>

      <!-- 玩法快捷入口 -->
      <div class="play-links">
        <button @click="$router.push('/talent')">
          <i>🧿</i>
          <div class="pl-txt"><span>天赋测试</span><em>5 道情境 · 领你的身份证</em></div>
        </button>
        <button @click="$router.push('/alchemy')">
          <i>⚗️</i>
          <div class="pl-txt"><span>炼药模拟器</span><em>选药材 · 控火候 · 小心炸炉</em></div>
        </button>
        <button @click="$router.push('/sim')">
          <i>🔥</i>
          <div class="pl-txt"><span>异火融合</span><em>两火相融，或成新焰</em></div>
        </button>
        <button @click="$router.push('/journey')">
          <i>📜</i>
          <div class="pl-txt"><span>人物历程</span><em>关系图谱 · 成长轨迹</em></div>
        </button>
      </div>
    </section>

    <!-- ==================== 搜索栏 ==================== -->
    <section class="search-wrap">
      <div class="search">
        <span class="ico">🔍</span>
        <input v-model="query.keyword" @keyup.enter="doSearch"
               placeholder="搜索异火、功法、持有者（如：药尘）…" />
        <button class="btn-search" @click="doSearch">搜 索</button>
      </div>
      <div class="hot">
        <span>热门：</span>
        <a v-for="(k, i) in overview.hotKeywords" :key="i" @click="searchHot(k)">{{ k }}</a>
      </div>
    </section>

    <!-- ==================== 高级筛选 ==================== -->
    <section class="filters">
      <div class="filter-row">
        <label>分类</label>
        <a :class="{ on: query.category === '' }" @click="pick('category', '')">全部</a>
        <a v-for="c in categoryEntries" :key="c.name"
           :class="{ on: query.category === c.name }" @click="pick('category', c.name)">
          {{ c.name }}<em>{{ c.count }}</em>
        </a>
      </div>
      <div class="filter-row">
        <label>品阶</label>
        <a :class="{ on: query.grade === '' }" @click="pick('grade', '')">全部</a>
        <a v-for="g in gradeEntries" :key="g.name"
           :class="{ on: query.grade === g.name }" @click="pick('grade', g.name)">
          {{ g.name }}<em>{{ g.count }}</em>
        </a>
      </div>
      <div class="filter-row">
        <label>火色</label>
        <a :class="{ on: query.color === '' }" @click="pick('color', '')">全部</a>
        <a v-for="(c, k) in colorEntries" :key="k" class="swatch-a"
           :class="{ on: query.color === k }" @click="pick('color', k)" :title="c.label + ' ' + c.count">
          <i :style="{ background: c.hex, boxShadow: '0 0 8px ' + c.hex }"></i>{{ c.label }}
        </a>
      </div>
      <div class="filter-row">
        <label>排序</label>
        <a v-for="s in sortOptions" :key="s.key"
           :class="{ on: query.sort === s.key }" @click="pickSort(s.key)">{{ s.label }}</a>
        <label class="ml">难度 ≥</label>
        <a v-for="d in [0, 3, 4, 5]" :key="d" :class="{ on: query.minDiff === d }" @click="pickDiff(d)">
          {{ d === 0 ? '不限' : d + ' 星' }}
        </a>
        <button class="reset" @click="resetAll">重置</button>
      </div>
    </section>

    <!-- ==================== 列表 ==================== -->
    <section class="content">
      <div class="content-head">
        <h2>
          {{ query.category || '全部' }}{{ query.grade ? ' · ' + query.grade : '' }}
          <span v-if="query.color">· {{ colorLabel(query.color) }}</span>
          <span v-if="query.keyword">· “{{ query.keyword }}”</span>
        </h2>
        <span class="count">共 {{ total }} 条</span>
      </div>

      <div v-if="loading" class="empty">斗气化马，正在加载…</div>
      <div v-else-if="!list.length" class="empty">此处尚无收录，换个关键词试试</div>

      <div v-else class="grid">
        <ItemCard v-for="(it, i) in list" :key="it.id + '-' + query.sort"
                  :item="it" :index="i" :collected="isCollected(it.id)"
                  @open="openDetail" @toggle="toggleCollect" />
      </div>

      <div v-if="pages > 1" class="pager">
        <button :disabled="page <= 1" @click="goPage(page - 1)">上一页</button>
        <span>{{ page }} / {{ pages }}</span>
        <button :disabled="page >= pages" @click="goPage(page + 1)">下一页</button>
      </div>
    </section>

    <footer class="foot">
      <p>斗破苍穹 · 异火图鉴　|　Vue 3 + Vite + Spring Boot + MyBatis-Plus + MySQL</p>
      <p class="sub">数据由后台管理系统维护　·　{{ msg }}</p>
    </footer>

    <DetailModal :show="detailShow" :item="current" @close="detailShow = false"
                 @accent="setAccent" @changed="refreshAll" />
  </div>
</template>

<script>
import api from '../api'
import { store, loadProfile, applyCollect } from '../store'
import { FIRE_COLORS, colorOf } from '../theme'
import TopNav from '../components/TopNav.vue'
import ItemCard from '../components/ItemCard.vue'
import DetailModal from '../components/DetailModal.vue'

export default {
  name: 'Home',
  components: { TopNav, ItemCard, DetailModal },
  data() {
    const arr = []
    for (let i = 0; i < 26; i++) {
      arr.push({
        left: (Math.random() * 100) + '%',
        dur: (6 + Math.random() * 9) + 's',
        delay: (Math.random() * 9) + 's',
        op: Math.random() * 0.55 + 0.15
      })
    }
    return {
      overview: { total: 0, categories: {}, grades: {}, colors: {}, hotKeywords: [] },
      query: { keyword: '', category: '', grade: '', color: '', minDiff: 0, sort: 'grade' },
      list: [],
      total: 0,
      page: 1,
      size: 9,
      pages: 1,
      loading: true,
      msg: '',
      embers: arr,
      detailShow: false,
      current: {},
      toast: '',
      toastType: 'ok',
      sortOptions: [
        { key: 'grade', label: '按品阶' },
        { key: 'rank', label: '按异火榜' },
        { key: 'difficulty', label: '按难度' },
        { key: 'newest', label: '最新收录' }
      ]
    }
  },
  computed: {
    profile() {
      return store.profile
    },
    realm() {
      return (store.profile && store.profile.realm) || { name: '', progress: 0 }
    },
    collectedCount() {
      return (store.profile && store.profile.collectCount) || 0
    },
    categoryEntries() {
      const obj = this.overview.categories || {}
      return Object.keys(obj).map(k => ({ name: k, count: obj[k] }))
    },
    gradeEntries() {
      const obj = this.overview.grades || {}
      return Object.keys(obj).map(k => ({ name: k, count: obj[k] }))
    },
    colorEntries() {
      const obj = this.overview.colors || {}
      const out = {}
      Object.keys(obj).forEach(k => {
        const c = FIRE_COLORS[k]
        if (c) out[k] = { label: c.label, hex: c.hex, count: obj[k] }
      })
      return out
    }
  },
  created() {
    this.loadOverview()
    this.fetchList()
  },
  methods: {
    countOf(obj, key) {
      if (!obj || !obj[key]) return 0
      return obj[key]
    },
    colorLabel(k) {
      return colorOf(k).label
    },
    isCollected(id) {
      const p = store.profile
      return !!(p && p.ids && p.ids.indexOf(id) >= 0)
    },
    async loadOverview() {
      try {
        const res = await api.overview()
        if (res && res.code === 200) {
          this.overview = res.data
        }
      } catch (e) {
        this.msg = e.message
      }
    },
    async fetchList() {
      this.loading = true
      try {
        const res = await api.itemList({
          keyword: this.query.keyword || undefined,
          category: this.query.category || undefined,
          grade: this.query.grade || undefined,
          color: this.query.color || undefined,
          minDiff: this.query.minDiff || undefined,
          sort: this.query.sort,
          page: this.page,
          size: this.size
        })
        if (res && res.code === 200) {
          this.list = res.data.list || []
          this.total = res.data.total || 0
          this.pages = res.data.pages || 1
        } else {
          this.msg = (res && res.msg) || '加载失败'
        }
      } catch (e) {
        this.msg = e.message
      } finally {
        this.loading = false
      }
    },
    refreshAll() {
      this.loadOverview()
      loadProfile()
    },
    doSearch() {
      this.page = 1
      this.fetchList()
    },
    searchHot(k) {
      this.query.keyword = k
      this.page = 1
      this.fetchList()
    },
    pick(field, value) {
      this.query[field] = value
      this.page = 1
      this.fetchList()
    },
    pickSort(k) {
      this.query.sort = k
      this.page = 1
      this.fetchList()
    },
    pickDiff(d) {
      this.query.minDiff = d
      this.page = 1
      this.fetchList()
    },
    resetAll() {
      this.query = { keyword: '', category: '', grade: '', color: '', minDiff: 0, sort: 'grade' }
      this.page = 1
      this.fetchList()
    },
    goPage(p) {
      if (p < 1 || p > this.pages) return
      this.page = p
      this.fetchList()
      window.scrollTo({ top: 320, behavior: 'smooth' })
    },
    openDetail(item) {
      this.current = item
      this.detailShow = true
    },
    async toggleCollect(item) {
      try {
        const res = this.isCollected(item.id)
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
      if (this.$refs.nav && this.$refs.nav.setAccent) {
        this.$refs.nav.setAccent(key)
      }
    }
  }
}
</script>

<style scoped>
.home { position: relative; min-height: 100vh; padding-bottom: 20px; }

/* ---------- 视频背景已移到全局 DynamicBg（App.vue） ---------- */

.toast { position: fixed; left: 50%; top: 84px; transform: translateX(-50%); z-index: 120;
  padding: 10px 20px; border-radius: 10px; font-size: 13px; letter-spacing: .5px;
  background: var(--panel-solid); border: 1px solid var(--line); color: var(--txt);
  box-shadow: 0 12px 34px rgba(0,0,0,.45); animation: toastIn .28s cubic-bezier(.2,.8,.3,1) both; }
.toast.ok { color: var(--gold2); border-color: rgba(var(--flame-rgb),.55);
  box-shadow: 0 12px 34px rgba(0,0,0,.45), 0 0 22px rgba(var(--flame-rgb),.22); }
.toast.warn { color: #ff9a76; border-color: rgba(226,84,42,.55); }
@keyframes toastIn { from { opacity: 0; transform: translate(-50%, -10px) } to { opacity: 1; transform: translate(-50%, 0) } }
.embers { position: fixed; inset: 0; overflow: hidden; pointer-events: none; z-index: 0; }
.ember { position: absolute; bottom: -20px; width: 3px; height: 3px; border-radius: 50%;
  background: var(--flame); box-shadow: 0 0 8px 2px var(--flame2); animation: rise linear infinite; }
@keyframes rise { 0% { transform: translateY(0) scale(1); opacity: .75 } 100% { transform: translateY(-105vh) scale(.2); opacity: 0 } }
.aurora { position: fixed; top: 0; left: 0; right: 0; height: 320px; pointer-events: none; z-index: 0;
  background: linear-gradient(100deg, transparent 30%, rgba(var(--flame-rgb),.07) 50%, transparent 70%);
  animation: drift 14s ease-in-out infinite alternate; }
@keyframes drift { 0% { transform: translateX(-12%) } 100% { transform: translateX(12%) } }

.hero { position: relative; z-index: 1; text-align: center; padding: 50px 20px 26px; }
.hero-glow { position: absolute; left: 50%; top: 6px; width: 520px; height: 220px; transform: translateX(-50%);
  background: radial-gradient(circle, rgba(var(--flame-rgb),.22), transparent 68%); filter: blur(6px); }
.hero h1 { position: relative; font-size: 44px; letter-spacing: 16px; color: var(--gold2);
  text-shadow: 0 0 26px rgba(212,175,55,.45); font-weight: 800; }
.slogan { position: relative; margin-top: 12px; font-size: 12.5px; letter-spacing: 6px; color: var(--muted); }
.stats { position: relative; margin-top: 24px; display: inline-flex; align-items: center; gap: 16px;
  padding: 13px 26px; border-radius: 12px; border: 1px solid var(--line);
  background: var(--panel); }
.stat { text-align: center; min-width: 62px; }
.stat b { display: block; font-size: 21px; color: var(--gold2); font-weight: 700; }
.stat span { font-size: 11px; color: var(--muted); letter-spacing: 1px; }
.realm-stat b { font-size: 18px; color: var(--flame); }
.divider { width: 1px; height: 26px; background: rgba(212,175,55,.2); }

.realm-strip { position: relative; margin: 14px auto 0; width: min(420px, 86%); display: flex;
  align-items: center; gap: 10px; }
.rs-label { font-size: 12px; color: var(--flame); letter-spacing: 2px; }
.rs-bar { flex: 1; height: 5px; border-radius: 3px; background: rgba(212,175,55,.16); overflow: hidden; }
.rs-bar i { display: block; height: 100%; border-radius: 3px;
  background: linear-gradient(90deg, var(--flame2), var(--gold2)); transition: width .6s; }
.rs-next { font-size: 11px; color: var(--muted); }

.play-links { position: relative; margin: 20px auto 0; display: flex; gap: 12px;
  justify-content: center; flex-wrap: wrap; padding: 0 16px; }
.play-links button { display: flex; align-items: center; gap: 10px; padding: 9px 18px 9px 15px;
  border-radius: 10px; cursor: pointer; text-align: left; transition: .22s;
  border: 1px solid rgba(212,175,55,.28); background: var(--panel); }
.play-links button:hover { border-color: var(--gold); transform: translateY(-2px);
  box-shadow: 0 8px 22px rgba(0,0,0,.35), 0 0 18px rgba(212,175,55,.18); }
.play-links i { font-style: normal; font-size: 20px; line-height: 1;
  filter: drop-shadow(0 0 9px rgba(var(--flame-rgb),.55)); }
.pl-txt span { display: block; font-size: 13px; letter-spacing: 1px; color: var(--txt); font-weight: 600; }
.pl-txt em { display: block; font-style: normal; font-size: 10px; color: var(--muted); margin-top: 2px; }

.search-wrap { position: relative; z-index: 1; max-width: 760px; margin: 0 auto; padding: 0 20px; }
.search { display: flex; align-items: center; gap: 8px; padding: 6px 6px 6px 16px;
  border-radius: 12px; border: 1px solid var(--line); background: var(--panel);
  box-shadow: inset 0 0 26px rgba(var(--flame-rgb),.06); }
.search:focus-within { border-color: var(--gold); box-shadow: 0 0 16px rgba(212,175,55,.22); }
.search .ico { font-size: 14px; opacity: .8; }
.search input { flex: 1; height: 40px; background: transparent; border: none; outline: none;
  color: var(--txt); font-size: 14px; }
.search input::placeholder { color: var(--label); }
.btn-search { height: 40px; padding: 0 26px; border: none; border-radius: 8px; cursor: pointer;
  font-size: 14px; letter-spacing: 4px; font-weight: 700; color: #1a1206;
  background: linear-gradient(90deg, #c99a2e, #f5d76e, #c99a2e); }
.btn-search:hover { filter: brightness(1.1); }
.hot { margin-top: 12px; font-size: 12px; color: var(--muted); display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
.hot a { padding: 3px 10px; border-radius: 20px; border: 1px solid rgba(212,175,55,.18);
  color: var(--muted); cursor: pointer; transition: .2s; }
.hot a:hover { color: var(--gold2); border-color: var(--gold); background: rgba(212,175,55,.08); }

.filters { position: relative; z-index: 1; max-width: 1180px; margin: 22px auto 0; padding: 0 20px; }
.filter-row { display: flex; align-items: center; flex-wrap: wrap; gap: 8px; padding: 9px 0;
  border-bottom: 1px dashed rgba(212,175,55,.14); }
.filter-row label { width: 42px; font-size: 12.5px; color: var(--label); letter-spacing: 2px; }
.filter-row label.ml { width: auto; margin-left: 14px; }
.filter-row a { padding: 5px 12px; border-radius: 7px; font-size: 13px; color: var(--muted);
  cursor: pointer; border: 1px solid transparent; transition: .2s; }
.filter-row a:hover { color: var(--gold2); background: rgba(212,175,55,.07); }
.filter-row a.on { color: #1a1206; background: linear-gradient(90deg, #c99a2e, #f5d76e);
  border-color: transparent; font-weight: 700; }
.filter-row a em { margin-left: 4px; font-style: normal; font-size: 11px; opacity: .75; }
.filter-row a.swatch-a { display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px; }
.swatch-a i { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }
.reset { margin-left: auto; height: 28px; padding: 0 14px; border-radius: 7px; cursor: pointer;
  font-size: 12px; color: var(--muted); background: transparent; border: 1px solid rgba(212,175,55,.25); }
.reset:hover { color: var(--gold2); border-color: var(--gold); }

.content { position: relative; z-index: 1; max-width: 1180px; margin: 0 auto; padding: 20px 20px 0; }
.content-head { display: flex; align-items: baseline; justify-content: space-between; margin-bottom: 16px; }
.content-head h2 { font-size: 17px; color: var(--gold2); letter-spacing: 2px; font-weight: 600; }
.content-head .count { font-size: 12px; color: var(--label); }
.grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }

.empty { padding: 60px 0; text-align: center; color: var(--muted); font-size: 13.5px; letter-spacing: 2px; }
.pager { display: flex; justify-content: center; align-items: center; gap: 14px; margin: 26px 0 10px; }
.pager button { height: 34px; padding: 0 16px; border-radius: 7px; cursor: pointer; font-size: 13px;
  color: var(--muted); background: var(--panel); border: 1px solid rgba(212,175,55,.25); }
.pager button:hover:not(:disabled) { color: var(--gold2); border-color: var(--gold); }
.pager button:disabled { opacity: .4; cursor: not-allowed; }
.pager span { font-size: 12.5px; color: var(--label); }

.foot { position: relative; z-index: 1; margin-top: 40px; padding: 22px 20px; text-align: center;
  border-top: 1px solid rgba(212,175,55,.12); }
.foot p { font-size: 12px; color: var(--label); letter-spacing: 1px; line-height: 1.9; }
.foot .sub { color: var(--muted); opacity: .8; }

@media (max-width: 980px) {
  .grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 640px) {
  .grid { grid-template-columns: 1fr; }
  .hero h1 { font-size: 30px; letter-spacing: 10px; }
  .stats { gap: 8px; padding: 10px 14px; flex-wrap: wrap; justify-content: center; }
  .divider { display: none; }
}
</style>
