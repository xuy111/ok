<template>
  <div class="alc-page" :class="{ quake: quaking }">
    <TopNav active="alchemy" />

    <section class="head">
      <h1>炼药模拟器</h1>
      <p class="slogan">药材为骨 · 异火为魂 · 火候即天意</p>
    </section>

    <div class="wrap">
      <!-- ================= 药材 ================= -->
      <section class="panel">
        <div class="p-title">
          <b>① 抓药材</b>
          <span class="p-sub">2 ~ 4 味 · 已选 {{ picked.length }}</span>
        </div>
        <div class="herb-grid">
          <button v-for="h in herbs" :key="h.id" class="herb"
                  :class="{ on: isPicked(h.id), dim: !isPicked(h.id) && picked.length >= 4 }"
                  :title="h.desc" @click="toggleHerb(h)">
            <span class="h-ico">{{ h.icon }}</span>
            <span class="h-name">{{ h.name }}</span>
            <em class="h-tag">{{ h.tag }}</em>
          </button>
        </div>
        <div class="sum">
          <span>完美区 <b :class="zoneMul >= 1 ? 'up' : 'down'">×{{ zoneMul.toFixed(2) }}</b></span>
          <span>品相 <b class="up">+{{ herbQuality }}</b></span>
          <span>风险 <b :class="herbRisk > 0 ? 'down' : 'up'">{{ riskText }}</b></span>
        </div>
      </section>

      <!-- ================= 异火 ================= -->
      <section class="panel">
        <div class="p-title">
          <b>② 引异火</b>
          <span class="p-sub">火性不同，丹成色不同</span>
        </div>
        <div class="fire-grid">
          <button v-for="f in fires" :key="f.id" class="fire"
                  :class="{ on: fire && fire.id === f.id }"
                  :style="{ '--c-hex': colorOf(f.color).hex, '--c-rgb': colorOf(f.color).rgb }"
                  @click="pickFire(f)">
            <span class="f-art" v-if="artOf(f)" :style="{ backgroundImage: 'url(' + artOf(f) + ')' }"></span>
            <span class="f-ico" v-else>{{ f.icon || '🔥' }}</span>
            <span class="f-name">{{ f.name }}</span>
            <span class="f-rank" v-if="f.rankNo > 0">#{{ f.rankNo }}</span>
          </button>
        </div>
        <p class="f-note" v-if="fire">
          <b>{{ fire.name }}</b>：{{ profileOf(fire).note }}
          <span class="f-tags">
            <i>完美区 ×{{ profileOf(fire).zone.toFixed(2) }}</i>
            <i>指针 ×{{ profileOf(fire).speed.toFixed(2) }}</i>
            <i>品相 +{{ profileOf(fire).quality }}</i>
          </span>
        </p>
        <p class="f-note empty" v-else>尚未引火 —— 选一朵异火，才知道这炉丹能走多远。</p>
      </section>
    </div>

    <!-- ================= 丹炉 ================= -->
    <section class="board">
      <div class="stage-wrap">
        <div class="stage" :class="stageClass">
          <div class="halo"></div>
          <div class="fire-ring"></div>
          <div class="flames"><i></i><i></i><i></i><i></i><i></i></div>
          <div class="flame-front"><i></i><i></i><i></i></div>
          <div class="sparks" v-if="phase === 'heating'">
            <i v-for="i in 7" :key="i" :style="sparkStyle(i)"></i>
          </div>

          <div class="pot">
            <span class="handle l"></span>
            <span class="handle r"></span>
            <div class="lid">
              <span class="knob"></span>
              <span class="lid-body"></span>
            </div>
            <div class="rim"></div>
            <div class="body">
              <div class="inner-glow"></div>
              <span class="rune">丹</span>
              <span class="band"></span>
              <div class="crack c1"></div>
              <div class="crack c2"></div>
              <div class="crack c3"></div>
              <div class="crack c4"></div>
            </div>
            <span class="leg a"></span>
            <span class="leg b"></span>
            <span class="leg c"></span>
          </div>

          <div class="blast" v-if="phase === 'boom'"></div>
          <div class="debris" v-if="phase === 'boom'">
            <i v-for="i in 10" :key="i" :style="debrisStyle(i)"></i>
          </div>
          <div class="smoke" v-if="phase === 'boom'">
            <i v-for="i in 14" :key="i" :style="smokeStyle(i)"></i>
          </div>
          <div class="shock" v-if="phase === 'boom'"></div>

          <div class="pill-out" v-if="showingPill" :style="pillStyle">
            <span class="p-core">丹</span>
            <span class="p-ray"></span>
          </div>
        </div>
      </div>

      <!-- 火候控制 -->
      <div class="control">
        <div class="bar-head">
          <span>火 候</span>
          <em v-if="phase === 'heating'">指针进入金色「完美」区间时点击控火</em>
          <em v-else-if="phase === 'boom'">炉壁崩裂，火势反噬中…</em>
          <em v-else-if="phase === 'settling'">丹成之机，只在一瞬…</em>
          <em v-else>配好药与火，点「开炉炼制」</em>
        </div>

        <div class="bar" :class="'st-' + phase">
          <div class="zone good" :style="goodStyle"></div>
          <div class="zone perfect" :style="perfectStyle"></div>
          <div class="ticks"></div>
          <div class="needle" :style="{ left: pointer + '%' }"><i></i></div>
        </div>
        <div class="bar-foot">
          <span>微火</span><span>文火</span><span>武火</span><span>过火</span>
        </div>

        <div class="actions">
          <button v-if="phase !== 'heating'" class="btn big"
                  :disabled="!ready || busy" @click="start">
            {{ busy ? '炉中余温未散…' : '开炉炼制' }}
          </button>
          <button v-else class="btn big strike" @click="strike">控 火 ！</button>

          <button class="btn ghost" :disabled="busy" @click="quickRecipe">推荐配方</button>
          <button class="btn ghost icon" @click="toggleMute" :title="muted ? '开启音效' : '关闭音效'">
            {{ muted ? '🔇' : '🔊' }}
          </button>
        </div>

        <p class="hint">
          <span v-if="!ready">还需 {{ needText }}</span>
          <span v-else>难度 {{ '✦'.repeat(difficulty) }} · 空格键亦可控火 · 偏差越小，丹纹越多</span>
        </p>
      </div>
    </section>

    <!-- ================= 结果 ================= -->
    <transition name="fade">
      <section v-if="result && phase === 'done'" class="result"
               :class="result.success ? 'ok' : 'bad'" :style="resultStyle">
        <template v-if="result.success">
          <div class="r-badges">
            <span class="r-tier">{{ result.tier.name }}</span>
            <span class="r-grade">{{ result.pill.grade }}</span>
          </div>
          <h2>{{ result.pill.name }}</h2>
          <div class="r-rings">
            <i v-for="n in result.tier.rings" :key="n"></i>
          </div>
          <p class="r-desc">{{ result.pill.desc }}</p>
          <div class="r-meta">
            <span>丹纹 {{ result.tier.rings }} 道</span>
            <span>火候偏差 {{ result.deviation }}%</span>
            <span>{{ result.fireName }}</span>
          </div>
          <p class="r-recipe">药方：{{ result.herbNames.join(' · ') }}</p>
          <p class="r-flavor">{{ result.flavor }}</p>
        </template>

        <template v-else>
          <div class="r-boom">炸 炉</div>
          <h2>{{ result.title }}</h2>
          <p class="r-desc">{{ result.msg }}</p>
          <div class="r-meta">
            <span>火候 {{ result.deviation }}% {{ result.side }}</span>
            <span>{{ result.fireName }}</span>
          </div>
          <p class="r-recipe">药方：{{ result.herbNames.join(' · ') }}</p>
        </template>

        <button class="btn again" @click="again">再 炼 一 炉</button>
      </section>
    </transition>

    <!-- ================= 战绩 ================= -->
    <section class="record">
      <div class="rec-line">
        <span>炼制 <b>{{ history.total }}</b> 炉</span>
        <span>成丹 <b class="up">{{ history.success }}</b></span>
        <span>炸炉 <b class="down">{{ history.fail }}</b></span>
        <span>成丹率 <b>{{ rate }}%</b></span>
        <button class="rec-reset" v-if="history.total" @click="clearHistory">清空</button>
      </div>
      <div class="rec-pills" v-if="history.pills.length">
        <span v-for="(p, i) in history.pills" :key="i" class="rec-pill" :class="p.ok ? 'ok' : 'bad'">
          {{ p.name }}<em v-if="p.ok">{{ p.tier }}</em>
        </span>
      </div>
      <p class="rec-tip" v-else>丹炉尚冷，炼出第一枚丹药吧。</p>
    </section>

    <footer class="foot"><p>丹方与火候规则参考原著设定，仅供娱乐</p></footer>

    <AlchemyFx :show="fxShow" :success="fxData.success" :pill-name="fxData.pillName"
               :tier-name="fxData.tierName" :grade="fxData.grade" :rings="fxData.rings"
               :fail-reason="fxData.failReason" :color="fxData.color" :rgb="fxData.rgb"
               :muted="muted" @done="fxShow = false" />
  </div>
</template>

<script>
import api from '../api'
import { colorOf } from '../theme'
import { artOf } from '../art'
import TopNav from '../components/TopNav.vue'
import AlchemyFx from '../components/AlchemyFx.vue'

/* ------------------------------ 药材 ------------------------------ */
const HERBS = [
  { id: 'ziye', name: '紫叶兰草', icon: '🌿', tag: '中和', zone: 0.07, quality: 0, risk: -0.02,
    desc: '最寻常的调和之药，能让暴躁的药力安静下来。' },
  { id: 'bingling', name: '冰灵叶', icon: '❄️', tag: '寒性', zone: 0.10, quality: 0, risk: -0.05,
    desc: '极寒药叶，压得住火，火候更容易掌控。' },
  { id: 'longxian', name: '龙涎草', icon: '💧', tag: '润养', zone: 0.08, quality: 1, risk: 0,
    desc: '龙族涎水滋养而生，出丹温润，品相与成丹率俱佳。' },
  { id: 'shetui', name: '蛇蜕花', icon: '🌾', tag: '稳性', zone: 0.06, quality: 0, risk: -0.06,
    desc: '药性极稳，最宜新手拿来练手。' },
  { id: 'huolian', name: '火莲果', icon: '🔥', tag: '烈性', zone: -0.06, quality: 2, risk: 0.10,
    desc: '天生火性，能拔高丹药品阶，也让火候更难压。' },
  { id: 'xuelian', name: '血莲精', icon: '🌸', tag: '血性', zone: -0.02, quality: 1, risk: 0.06,
    desc: '血气充盈，丹药成色更浓，代价是火候窗口变窄。' },
  { id: 'ziling', name: '紫灵石髓', icon: '💠', tag: '灵性', zone: -0.08, quality: 2, risk: 0.08,
    desc: '传说中养出过丹灵的石髓，极其挑火候。' },
  { id: 'hansui', name: '寒髓晶', icon: '⭐', tag: '寒性', zone: 0.05, quality: 1, risk: -0.03,
    desc: '万年寒髓凝成的晶体，与冷火最合。' },
  { id: 'jiuyou', name: '九幽藤', icon: '🌱', tag: '幽性', zone: -0.04, quality: 1, risk: 0.04,
    desc: '生于九幽之地的藤蔓，药力阴柔，火候需精细。' }
]

/* --------------------------- 异火特性表 --------------------------- */
/* speed：指针速度倍率（越大越难）；zone：完美区宽度倍率；quality：品相加成 */
const FIRE_PROFILE = {
  '帝炎':       { speed: 0.88, zone: 1.50, quality: 3, wobble: 0,    note: '万火之帝，火候随心而动，几乎不会失手。' },
  '虚无吞炎':   { speed: 1.35, zone: 0.62, quality: 4, wobble: 0.10, note: '无形黑焰最难驾驭，可一旦成丹，必是绝品。' },
  '净莲妖火':   { speed: 0.95, zone: 1.28, quality: 2, wobble: 0,    note: '净世莲火，能洗去药中杂质，丹色格外纯净。' },
  '金帝焚天炎': { speed: 1.18, zone: 0.92, quality: 2, wobble: 0,    note: '炽金圣焰，火力凶猛，过火只在一线之间。' },
  '生灵之焱':   { speed: 1.00, zone: 1.16, quality: 2, wobble: 0,    note: '蕴含磅礴生机，炼出的丹药药力更足。' },
  '八荒破灭炎': { speed: 1.25, zone: 0.85, quality: 2, wobble: 0.06, note: '赤焰焚尽八荒，火势极难收束。' },
  '九幽风炎':   { speed: 1.05, zone: 1.02, quality: 1, wobble: 0.30, note: '风助火势，指针会被风推得忽快忽慢。' },
  '骨灵冷火':   { speed: 0.70, zone: 1.38, quality: 1, wobble: 0,    note: '极寒之火，火候最稳，成丹率最高——药老的本命火。' },
  '三千焱炎火': { speed: 1.12, zone: 0.96, quality: 2, wobble: 0.16, note: '星辰碎焰，火候飘忽如星河流转。' },
  '青莲地心火': { speed: 0.86, zone: 1.22, quality: 1, wobble: 0,    note: '青莲温养斗气，也温养丹药，最好上手的一朵。' },
  '陨落心炎':   { speed: 1.05, zone: 1.10, quality: 1, wobble: 0,    note: '淬炼之力极强，丹纹更容易成形。' },
  '海心焰':     { speed: 0.90, zone: 1.15, quality: 1, wobble: 0,    note: '深海水焰，温和绵长，最不伤药性。' }
}
const FIRE_FALLBACK = { speed: 1.0, zone: 1.0, quality: 1, wobble: 0, note: '未录入的火焰，火性中平。' }

/* --------------------------- 丹药品相 --------------------------- */
const TIERS = [
  { name: '下品', rings: 1, grade: '黄阶', hex: '#b6a689', rgb: '182,166,137' },
  { name: '中品', rings: 2, grade: '黄阶', hex: '#5fe0a0', rgb: '95,224,160' },
  { name: '上品', rings: 3, grade: '玄阶', hex: '#5fb8ff', rgb: '95,184,255' },
  { name: '极品', rings: 4, grade: '地阶', hex: '#c39bff', rgb: '195,155,255' },
  { name: '绝品', rings: 5, grade: '天阶', hex: '#f5d76e', rgb: '245,215,110' }
]

const PILL_FALLBACK = {
  '黄阶': ['聚气散', '养气丹', '凝元散'],
  '玄阶': ['三纹青灵丹', '护脉丹', '醒神丹'],
  '地阶': ['破厄丹', '玄龙丹', '复骨丹'],
  '天阶': ['九转斗尊强体丹', '菩提丹', '天魂丹']
}

const FLAVORS = {
  '下品': '丹成而纹浅，勉强能入药，聊胜于无。',
  '中品': '丹香初凝，纹路两道，已算可用的寻常丹药。',
  '上品': '三纹环生，丹体圆润，市坊之中已是抢手货。',
  '极品': '四纹如龙，丹光透壳，丹塔老怪也会多看一眼。',
  '绝品': '五纹天成，丹成之时炉中隐有清鸣——此丹已生灵性。'
}

const RECORD_KEY = 'doupo_alchemy_v1'

export default {
  name: 'Alchemy',
  components: { TopNav, AlchemyFx },
  data() {
    return {
      fxShow: false,
      fxData: { success: true, pillName: '丹药', tierName: '下品', grade: '黄阶', rings: 1,
        failReason: '火候失守', color: '#f5d76e', rgb: '245,215,110' },
      herbs: HERBS,
      picked: [],
      fires: [],
      danList: [],
      fire: null,

      phase: 'idle',          // idle | heating | settling | boom | done
      pointer: 0,
      dir: 1,
      zoneCenter: 50,
      zoneWidth: 12,
      lastTs: 0,
      passes: 0,
      raf: null,
      ctx: null,
      result: null,
      quaking: false,

      muted: false,
      history: { total: 0, success: 0, fail: 0, pills: [] }
    }
  },
  computed: {
    zoneMul() {
      let m = 1
      this.picked.forEach(id => {
        const h = HERBS.find(x => x.id === id)
        if (h) m += h.zone
      })
      return Math.max(0.55, m)
    },
    herbQuality() {
      return this.picked.reduce((s, id) => {
        const h = HERBS.find(x => x.id === id)
        return s + (h ? h.quality : 0)
      }, 0)
    },
    herbRisk() {
      return this.picked.reduce((s, id) => {
        const h = HERBS.find(x => x.id === id)
        return s + (h ? h.risk : 0)
      }, 0)
    },
    riskText() {
      const r = this.herbRisk
      if (r <= -0.05) return '低'
      if (r < 0.05) return '中'
      return '高'
    },
    speed() {
      const p = this.profileOf(this.fire)
      return 46 * p.speed * (1 + this.herbRisk * 0.6)
    },
    difficulty() {
      const w = Math.max(6, Math.min(34, 9.5 * this.profileOf(this.fire).zone * this.zoneMul))
      const raw = this.speed / w * 1.35
      return Math.max(1, Math.min(5, Math.round(raw)))
    },
    ready() {
      return !!this.fire && this.picked.length >= 2
    },
    needText() {
      if (!this.fire && this.picked.length < 2) return '一朵异火 + 至少两味药材'
      if (!this.fire) return '再引一朵异火'
      return 2 - this.picked.length + ' 味药材'
    },
    busy() {
      return this.phase === 'heating' || this.phase === 'settling' || this.phase === 'boom'
    },
    stageClass() {
      return {
        heating: this.phase === 'heating',
        boom: this.phase === 'boom' || (!!this.result && !this.result.success),
        success: (this.phase === 'settling' || this.phase === 'done') && !!this.result && this.result.success,
        hot: this.phase === 'heating' && this.pointer > 46
      }
    },
    showingPill() {
      return this.phase === 'settling' && !!this.result && this.result.success
    },
    pillStyle() {
      const t = this.result ? this.result.tier : TIERS[0]
      return { '--c-hex': t.hex, '--c-rgb': t.rgb }
    },
    perfectStyle() {
      return { left: (this.zoneCenter - this.zoneWidth / 2) + '%', width: this.zoneWidth + '%' }
    },
    goodStyle() {
      const w = Math.min(96, this.zoneWidth * 1.9)
      return { left: (this.zoneCenter - w / 2) + '%', width: w + '%' }
    },
    resultStyle() {
      // 失败时不要把「下品」的灰色套到炸炉卡上，单独给一组焦色
      if (this.result && !this.result.success) {
        return { '--c-hex': '#e8905f', '--c-rgb': '232,144,95' }
      }
      const t = this.result && this.result.tier ? this.result.tier : TIERS[0]
      return { '--c-hex': t.hex, '--c-rgb': t.rgb }
    },
    rate() {
      if (!this.history.total) return 0
      return Math.round(this.history.success / this.history.total * 100)
    }
  },
  async created() {
    this.loadHistory()
    try {
      const res = await api.itemList({ category: '异火', size: 100 })
      if (res && res.code === 200) {
        this.fires = (res.data.list || []).slice()
        // 默认选中骨灵冷火：火候最稳，第一次炼丹不至于直接炸炉
        this.fire = this.fires.find(f => f.name === '骨灵冷火') || this.fires[0] || null
      }
    } catch (e) { /* 忽略，页面仍可用（只是没有火可选） */ }
    try {
      const res = await api.itemList({ category: '丹药', size: 100 })
      if (res && res.code === 200) this.danList = res.data.list || []
    } catch (e) { /* 忽略 */ }
  },
  mounted() {
    window.addEventListener('keydown', this.onKey)
  },
  beforeUnmount() {
    window.removeEventListener('keydown', this.onKey)
    this.stopLoop()
  },
  methods: {
    colorOf,
    artOf,

    /* ---------------- 选择 ---------------- */
    isPicked(id) {
      return this.picked.indexOf(id) >= 0
    },
    toggleHerb(h) {
      if (this.busy) return
      const i = this.picked.indexOf(h.id)
      if (i >= 0) {
        this.picked.splice(i, 1)
      } else {
        if (this.picked.length >= 4) return
        this.picked.push(h.id)
      }
      this.resetResult()
    },
    pickFire(f) {
      if (this.busy) return
      this.fire = f
      this.resetResult()
    },
    profileOf(f) {
      if (!f) return FIRE_FALLBACK
      return FIRE_PROFILE[f.name] || FIRE_FALLBACK
    },
    quickRecipe() {
      if (this.busy) return
      this.picked = ['longxian', 'bingling', 'ziye']
      const best = this.fires.find(f => f.name === '骨灵冷火')
      if (best) this.fire = best
      this.resetResult()
    },

    /* ---------------- 炼制 ---------------- */
    start() {
      if (!this.ready || this.busy) return
      this.result = null
      this.passes = 0
      this.pointer = 0
      this.dir = 1
      // 完美区宽度与位置：每炉都不同，宽度由异火与药材共同决定
      const w = Math.max(6, Math.min(34, 9.5 * this.profileOf(this.fire).zone * this.zoneMul))
      this.zoneWidth = w
      const lo = 14 + w / 2
      const hi = 86 - w / 2
      this.zoneCenter = lo + Math.random() * Math.max(1, hi - lo)
      this.phase = 'heating'
      this.lastTs = 0
      if (!this.muted) this.sound('start')
      this.raf = requestAnimationFrame(this.tick)
    },
    tick(ts) {
      if (this.phase !== 'heating') return
      if (!this.lastTs) this.lastTs = ts
      const dt = Math.min(0.05, (ts - this.lastTs) / 1000)
      this.lastTs = ts

      const p = this.profileOf(this.fire)
      const wob = p.wobble ? 1 + p.wobble * Math.sin(ts / 260) : 1
      let np = this.pointer + this.dir * this.speed * wob * dt
      if (np > 100) {
        np = 200 - np
        this.dir = -1
        this.passes++
      } else if (np < 0) {
        np = -np
        this.dir = 1
        this.passes++
      }
      this.pointer = Math.max(0, Math.min(100, np))

      // 三个来回仍不控火，火势彻底失控
      if (this.passes >= 3) {
        this.resolve(999)
        return
      }
      this.raf = requestAnimationFrame(this.tick)
    },
    stopLoop() {
      if (this.raf) cancelAnimationFrame(this.raf)
      this.raf = null
    },
    strike() {
      if (this.phase !== 'heating') return
      this.stopLoop()
      const dist = Math.abs(this.pointer - this.zoneCenter)
      this.resolve(dist)
    },
    onKey(e) {
      if (e.code !== 'Space' && e.key !== ' ') return
      const t = e.target && e.target.tagName
      if (t === 'INPUT' || t === 'TEXTAREA' || t === 'SELECT') return
      e.preventDefault()
      if (this.phase === 'heating') this.strike()
      else if (!this.busy && this.ready) this.start()
    },

    /**
     * dist：指针到完美区中心的距离（百分点，999 = 走火超时）
     * 判定：完美区内 → 成丹，按精度给品相；良好区 → 成丹但丹纹浅；其余 → 炸炉
     */
    resolve(dist) {
      this.stopLoop()
      const half = this.zoneWidth / 2
      const timedOut = dist === 999
      const side = timedOut ? '走火' : (this.pointer < this.zoneCenter ? '火候不足' : '火候过盛')
      const herbNames = this.picked.map(id => {
        const h = HERBS.find(x => x.id === id)
        return h ? h.name : ''
      }).filter(Boolean)

      const base = {
        fireName: this.fire ? this.fire.name : '凡火',
        herbNames,
        tier: TIERS[0],
        deviation: Math.abs(Math.round((this.pointer - this.zoneCenter) * 10) / 10)
      }

      /* ---------- 失败：炸炉 ---------- */
      if (timedOut || dist > half * 1.9) {
        let title = '丹未成，炉先裂'
        let msg = ''
        if (timedOut) {
          title = '心神失守，火势暴走'
          msg = '指尖迟迟未落，炉中火候三度往复，药力先焦后爆——一声闷响，丹炉四壁尽裂，只余焦黑。'
        } else if (this.pointer < this.zoneCenter) {
          title = '火候不足，药力未化'
          msg = '火候尚未走足便强行收丹，药汁仍是半凝的浊液，陡然遇冷，鼎内炸开一团黑烟。'
        } else {
          title = '火候过盛，药已成灰'
          msg = '指针越过完美之境，药力在高温中迅速焦化，炉壁承受不住那股膨胀的火气，轰然炸裂。'
        }
        this.failWith(Object.assign({}, base, { success: false, title, msg, side }))
        return
      }

      /* ---------- 成功：成丹 ---------- */
      const inPerfect = dist <= half
      // 完美区内越靠中心越好：贴边仍有 0.6 的精度，不至于「明明进圈却只得下品」
      const precision = inPerfect ? 1 - 0.4 * (dist / Math.max(0.001, half)) : 0.28
      const p = this.profileOf(this.fire)
      let score = precision * 2.8 + p.quality * 0.75 + this.herbQuality * 0.55 + Math.random() * 0.4
      // 勉强进圈（良好区）最多只能到中品
      if (!inPerfect) score = Math.min(score, 2.7)

      let idx = 0
      if (score >= 5.0) idx = 4
      else if (score >= 4.0) idx = 3
      else if (score >= 3.0) idx = 2
      else if (score >= 2.0) idx = 1
      const tier = TIERS[idx]
      const pill = this.pickPill(tier.grade)

      const data = Object.assign({}, base, {
        success: true,
        tier,
        pill,
        deviation: Math.abs(Math.round((this.pointer - this.zoneCenter) * 10) / 10),
        flavor: FLAVORS[tier.name] || ''
      })
      data.deviation = Math.round(data.deviation * 10) / 10
      this.succeedWith(data)
    },
    pickPill(grade) {
      const pool = this.danList.filter(d => d.grade === grade)
      if (pool.length) {
        const it = pool[Math.floor(Math.random() * pool.length)]
        return {
          name: it.name,
          grade: it.grade,
          icon: it.icon || '💊',
          desc: it.description || '丹成而无声，药力内敛。'
        }
      }
      const names = PILL_FALLBACK[grade] || ['无名丹']
      return {
        name: names[Math.floor(Math.random() * names.length)],
        grade,
        icon: '💊',
        desc: '丹成于火候恰好的那一瞬，药香尚在炉中未散。'
      }
    },
    succeedWith(data) {
      this.result = data
      this.phase = 'settling'
      this.pointer = this.zoneCenter
      // 音效交给全屏特效，避免两段音叠在一起
      this.fxData = {
        success: true,
        pillName: data.pill.name,
        tierName: data.tier.name,
        grade: data.pill.grade,
        rings: data.tier.rings,
        failReason: '',
        color: data.tier.hex,
        rgb: data.tier.rgb
      }
      this.fxShow = true
      window.setTimeout(() => {
        if (this.phase === 'settling') {
          this.phase = 'done'
          this.scrollToResult()
        }
      }, 1000)
      this.logAttempt(data)
    },
    failWith(data) {
      this.result = data
      this.phase = 'boom'
      // 音效交给全屏特效
      this.fxData = {
        success: false,
        pillName: '炸炉',
        tierName: '',
        grade: '',
        rings: 0,
        failReason: data.title || '火候失守',
        color: '#e8905f',
        rgb: '232,144,95'
      }
      this.fxShow = true
      this.quaking = true
      window.setTimeout(() => { this.quaking = false }, 620)
      window.setTimeout(() => {
        if (this.phase === 'boom') {
          this.phase = 'done'
          this.scrollToResult()
        }
      }, 1550)
      this.logAttempt(data)
    },
    /** 结果卡若在视口之外，轻轻推上来一点，省得用户自己滚 */
    scrollToResult() {
      this.$nextTick(() => {
        const el = this.$el.querySelector('.result')
        if (!el) return
        const r = el.getBoundingClientRect()
        if (r.bottom > window.innerHeight - 16) {
          window.scrollBy({ top: r.bottom - window.innerHeight + 88, behavior: 'smooth' })
        }
      })
    },
    again() {
      this.resetResult()
      const board = this.$el.querySelector('.board')
      if (board) board.scrollIntoView({ behavior: 'smooth', block: 'start' })
    },
    resetResult() {
      if (this.busy) return
      this.result = null
      this.phase = 'idle'
      this.pointer = 0
    },

    /* ---------------- 战绩 ---------------- */
    logAttempt(data) {
      const h = this.history
      h.total++
      if (data.success) {
        h.success++
        h.pills.unshift({ ok: true, name: data.pill.name, tier: data.tier.name })
      } else {
        h.fail++
        h.pills.unshift({ ok: false, name: '炸炉', tier: '' })
      }
      h.pills = h.pills.slice(0, 6)
      this.saveHistory()
    },
    saveHistory() {
      try {
        localStorage.setItem(RECORD_KEY, JSON.stringify(this.history))
      } catch (e) { /* 忽略 */ }
    },
    loadHistory() {
      try {
        const raw = localStorage.getItem(RECORD_KEY)
        if (raw) {
          const h = JSON.parse(raw)
          this.history = {
            total: h.total || 0,
            success: h.success || 0,
            fail: h.fail || 0,
            pills: Array.isArray(h.pills) ? h.pills.slice(0, 6) : []
          }
        }
        this.muted = localStorage.getItem('doupo_alchemy_muted') === '1'
      } catch (e) { /* 忽略 */ }
    },
    clearHistory() {
      this.history = { total: 0, success: 0, fail: 0, pills: [] }
      this.saveHistory()
    },

    /* ---------------- 音效（WebAudio 合成，无需素材） ---------------- */
    toggleMute() {
      this.muted = !this.muted
      try { localStorage.setItem('doupo_alchemy_muted', this.muted ? '1' : '0') } catch (e) { /* 忽略 */ }
    },
    sound(type) {
      if (this.muted) return
      this.playSfx(type)
    },
    playSfx(type) {
      if (this.muted) return
      try {
        const AC = window.AudioContext || window.webkitAudioContext
        if (!AC) return
        if (!this.ctx) this.ctx = new AC()
        const ctx = this.ctx
        if (ctx.state === 'suspended') ctx.resume()
        const now = ctx.currentTime

        if (type === 'start') {
          const o = ctx.createOscillator()
          const g = ctx.createGain()
          o.type = 'sine'
          o.frequency.setValueAtTime(180, now)
          o.frequency.exponentialRampToValueAtTime(420, now + 0.35)
          g.gain.setValueAtTime(0.0001, now)
          g.gain.exponentialRampToValueAtTime(0.06, now + 0.08)
          g.gain.exponentialRampToValueAtTime(0.0001, now + 0.45)
          o.connect(g).connect(ctx.destination)
          o.start(now); o.stop(now + 0.5)
          return
        }

        if (type === 'success') {
          [523.25, 659.25, 783.99, 1046.5].forEach((f, i) => {
            const o = ctx.createOscillator()
            const g = ctx.createGain()
            o.type = 'triangle'
            o.frequency.value = f
            const t0 = now + i * 0.085
            g.gain.setValueAtTime(0.0001, t0)
            g.gain.exponentialRampToValueAtTime(0.075, t0 + 0.02)
            g.gain.exponentialRampToValueAtTime(0.0001, t0 + 0.5)
            o.connect(g).connect(ctx.destination)
            o.start(t0); o.stop(t0 + 0.55)
          })
          return
        }

        if (type === 'boom') {
          const len = Math.floor(ctx.sampleRate * 0.9)
          const buf = ctx.createBuffer(1, len, ctx.sampleRate)
          const ch = buf.getChannelData(0)
          for (let i = 0; i < len; i++) {
            ch[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / len, 2.6)
          }
          const src = ctx.createBufferSource()
          src.buffer = buf
          const lp = ctx.createBiquadFilter()
          lp.type = 'lowpass'
          lp.frequency.setValueAtTime(900, now)
          lp.frequency.exponentialRampToValueAtTime(120, now + 0.7)
          const g = ctx.createGain()
          g.gain.setValueAtTime(0.22, now)
          g.gain.exponentialRampToValueAtTime(0.0001, now + 0.9)
          src.connect(lp).connect(g).connect(ctx.destination)
          src.start(now)
        }
      } catch (e) { /* 音频不可用就算了 */ }
    },

    /* ---------------- 视觉辅助 ---------------- */
    smokeStyle(i) {
      const left = 14 + ((i * 23) % 72)
      return {
        left: left + '%',
        animationDelay: (i * 0.05).toFixed(2) + 's',
        '--dx': ((i % 2 ? 1 : -1) * (16 + i * 5)) + 'px',
        '--sc': (0.8 + (i % 4) * 0.22).toFixed(2)
      }
    },
    sparkStyle(i) {
      return {
        left: (14 + i * 11) + '%',
        '--dx': (i % 2 ? 1 : -1) * (5 + i * 2),
        animationDelay: (i * 0.17).toFixed(2) + 's',
        animationDuration: (1.2 + (i % 3) * 0.3).toFixed(2) + 's'
      }
    },
    debrisStyle(i) {
      const ang = (-158 + i * 15) * Math.PI / 180
      return {
        '--dx': Math.round(Math.cos(ang) * (80 + i * 7)),
        '--dy': Math.round(Math.sin(ang) * (60 + i * 6)) - 12,
        '--rot': (i * 53) + 'deg',
        animationDelay: (i * 0.02).toFixed(2) + 's'
      }
    }
  }
}
</script>

<style scoped>
.alc-page { min-height: 100vh; padding-bottom: 34px; }
.alc-page.quake { animation: quake .5s linear; }
@keyframes quake {
  0%, 100% { transform: translate(0, 0) }
  15% { transform: translate(-7px, 3px) }
  30% { transform: translate(6px, -4px) }
  45% { transform: translate(-5px, -2px) }
  60% { transform: translate(4px, 3px) }
  78% { transform: translate(-2px, 1px) }
}

.head { text-align: center; padding: 38px 20px 6px; }
.head h1 { font-size: 30px; letter-spacing: 12px; color: var(--gold2); font-weight: 800;
  text-shadow: 0 0 24px rgba(212, 175, 55, .4); }
.slogan { margin-top: 9px; font-size: 12.5px; letter-spacing: 3px; color: var(--muted); }

.wrap { max-width: 1000px; margin: 20px auto 0; padding: 0 20px; display: grid;
  grid-template-columns: 1fr 1fr; gap: 14px; }
.panel { padding: 14px 16px 16px; border-radius: 14px; border: 1px solid var(--line);
  background: var(--panel); backdrop-filter: blur(6px); }
.p-title { display: flex; align-items: baseline; gap: 10px; margin-bottom: 12px; }
.p-title b { font-size: 14px; letter-spacing: 2px; color: var(--gold2); }
.p-sub { font-size: 11px; color: var(--label); }

.herb-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 7px; }
.herb { position: relative; padding: 9px 6px 8px; border-radius: 9px; cursor: pointer;
  display: grid; justify-items: center; gap: 2px; transition: .2s;
  border: 1px solid rgba(212, 175, 55, .16); background: rgba(0, 0, 0, .18); }
.herb:hover { border-color: rgba(212, 175, 55, .45); transform: translateY(-1px); }
.herb.dim { opacity: .34; }
.herb.on { border-color: var(--gold); background: rgba(212, 175, 55, .14);
  box-shadow: 0 0 16px rgba(212, 175, 55, .18), inset 0 0 18px rgba(212, 175, 55, .08); }
.h-ico { font-size: 17px; line-height: 1.2; filter: saturate(1.1); }
.h-name { font-size: 11.5px; color: var(--txt); letter-spacing: .5px; }
.h-tag { font-size: 9.5px; font-style: normal; letter-spacing: 1px; color: var(--label); }
.herb.on .h-tag { color: var(--gold2); }
.herb.on::after { content: "✓"; position: absolute; top: 4px; right: 6px; font-size: 10px;
  color: var(--gold2); }

.sum { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 12px; padding-top: 10px;
  border-top: 1px dashed rgba(212, 175, 55, .18); font-size: 11.5px; color: var(--muted); }
.sum b { font-weight: 700; }
.up { color: #5fe0a0; }
.down { color: #ff7a6b; }

.fire-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 7px; }
.fire { position: relative; padding: 0; border-radius: 9px; cursor: pointer; overflow: hidden;
  border: 1px solid rgba(var(--c-rgb), .22); background: rgba(0, 0, 0, .2); transition: .2s;
  aspect-ratio: 1 / 1; }
.fire:hover { border-color: rgba(var(--c-rgb), .6); }
.fire.on { border-color: var(--c-hex);
  box-shadow: 0 0 0 1px rgba(var(--c-rgb), .5), 0 0 18px rgba(var(--c-rgb), .32); }
.f-art { position: absolute; inset: 0; background-size: cover; background-position: center 28%;
  opacity: .62; transition: .25s; }
.fire:hover .f-art, .fire.on .f-art { opacity: .92; transform: scale(1.05); }
.f-ico { position: absolute; inset: 0; display: grid; place-items: center; font-size: 20px; }
.f-name { position: absolute; left: 0; right: 0; bottom: 0; padding: 12px 3px 3px;
  font-size: 10px; letter-spacing: .3px; color: #f4ead4; text-align: center;
  background: linear-gradient(to top, rgba(0, 0, 0, .88), transparent); }
.f-rank { position: absolute; top: 4px; right: 5px; font-size: 9px; color: var(--c-hex);
  text-shadow: 0 1px 3px #000; }
.f-note { margin-top: 11px; font-size: 11.5px; line-height: 1.75; color: var(--sub); }
.f-note b { color: var(--c-hex, var(--gold2)); }
.f-note.empty { color: var(--label); }
.f-tags { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; }
.f-tags i { font-style: normal; font-size: 10px; padding: 1px 6px; border-radius: 5px;
  color: var(--muted); border: 1px solid rgba(212, 175, 55, .2); }

/* ------------------------- 丹炉 ------------------------- */
.board { max-width: 1000px; margin: 18px auto 0; padding: 0 20px; }
.stage-wrap { display: grid; place-items: center; padding: 6px 0 0; }
.stage { position: relative; width: 100%; height: 250px; display: grid; place-items: end center; }
.halo { position: absolute; left: 50%; bottom: 8px; width: 380px; height: 200px;
  transform: translateX(-50%); border-radius: 50%; opacity: .5;
  background: radial-gradient(circle, rgba(var(--flame-rgb), .55), transparent 68%);
  filter: blur(6px); transition: opacity .5s; }
.stage.heating .halo { opacity: .95; animation: haloPulse 1.1s ease-in-out infinite; }
.stage.hot .halo { background: radial-gradient(circle, rgba(255, 90, 40, .7), transparent 66%); }
@keyframes haloPulse { 0%, 100% { transform: translateX(-50%) scale(1) } 50% { transform: translateX(-50%) scale(1.08) } }

.fire-ring { position: absolute; left: 50%; bottom: 26px; width: 260px; height: 30px;
  transform: translateX(-50%); border-radius: 50%; opacity: .5; transition: opacity .4s;
  background: radial-gradient(ellipse at center, rgba(255, 190, 90, .85), rgba(255, 90, 30, .35) 55%, transparent 72%);
  filter: blur(10px); }
.stage.heating .fire-ring { opacity: 1; animation: ringFlick .8s ease-in-out infinite; }
@keyframes ringFlick { 0%, 100% { transform: translateX(-50%) scaleX(1) } 50% { transform: translateX(-50%) scaleX(1.08) } }

.flames { position: absolute; left: 50%; bottom: 12px; width: 330px; height: 120px;
  transform: translateX(-50%); z-index: 1; }
.flames i { position: absolute; bottom: 0; left: 50%; border-radius: 50% 50% 44% 44%;
  background: linear-gradient(to top, #ffd08a, #ff8a2a 46%, rgba(255, 70, 20, .08));
  filter: blur(10px); opacity: .6; transform-origin: 50% 100%;
  animation: flick 1.5s ease-in-out infinite; }
.flames i:nth-child(1) { width: 190px; height: 104px; margin-left: -95px; opacity: .45 }
.flames i:nth-child(2) { width: 120px; height: 78px; margin-left: -60px; animation-delay: .28s; opacity: .5 }
.flames i:nth-child(3) { width: 74px; height: 54px; margin-left: -37px; animation-delay: .55s; opacity: .62 }
.flames i:nth-child(4) { width: 260px; height: 46px; margin-left: -130px; animation-delay: .12s; opacity: .3 }
.flames i:nth-child(5) { width: 46px; height: 84px; margin-left: -23px; animation-delay: .42s;
  background: linear-gradient(to top, #fff2c8, #ffb347 50%, rgba(255, 120, 40, .1));
  filter: blur(7px); opacity: .55 }
@keyframes flick {
  0%, 100% { transform: scaleY(1) scaleX(1) }
  35% { transform: scaleY(1.16) scaleX(.93) }
  65% { transform: scaleY(.9) scaleX(1.07) }
}
.stage:not(.heating):not(.success) .flames i { animation-duration: 2.8s; opacity: .3; }
.stage.boom .flames i { opacity: .1; animation-play-state: paused; }

/* 炉底火舌（在炉身之前，才看得见） */
.flame-front { position: absolute; left: 50%; bottom: 28px; width: 220px; height: 76px;
  transform: translateX(-50%); z-index: 3; pointer-events: none; }
.flame-front i { position: absolute; bottom: 0; left: 50%; border-radius: 50% 50% 40% 40%;
  background: radial-gradient(ellipse at 50% 92%, #fff3cc, #ffb347 42%, rgba(255, 90, 30, .22) 76%, transparent);
  filter: blur(6px); opacity: .5; transform-origin: 50% 100%;
  animation: flick 1.2s ease-in-out infinite; transition: opacity .4s; }
.flame-front i:nth-child(1) { width: 74px; height: 52px; margin-left: -100px; animation-delay: .22s }
.flame-front i:nth-child(2) { width: 92px; height: 64px; margin-left: -46px }
.flame-front i:nth-child(3) { width: 68px; height: 48px; margin-left: 34px; animation-delay: .46s }
.stage.heating .flame-front i { opacity: .85; }
.stage.hot .flame-front i { background: radial-gradient(ellipse at 50% 92%, #fff0b0, #ff7a2a 40%, rgba(255, 50, 10, .3) 78%, transparent); }
.stage.boom .flame-front i { opacity: .06; animation-play-state: paused; }
.stage:not(.heating):not(.boom) .flame-front i { opacity: .28; }

.sparks { position: absolute; left: 50%; bottom: 40px; width: 180px; height: 10px;
  transform: translateX(-50%); z-index: 1; pointer-events: none; }
.sparks i { position: absolute; bottom: 0; width: 3px; height: 3px; border-radius: 50%;
  background: #ffd98a; box-shadow: 0 0 8px rgba(255, 180, 80, .95);
  animation: sparkUp 1.4s linear infinite; }
@keyframes sparkUp {
  0% { opacity: 0; transform: translateY(0) scale(.6) }
  25% { opacity: 1 }
  100% { opacity: 0; transform: translate(calc(var(--dx) * 1px), -110px) scale(.3) }
}

.pot { position: relative; width: 176px; height: 140px; margin-bottom: 34px; z-index: 2; }
.lid { position: absolute; top: -18px; left: -11px; right: -11px; height: 26px; z-index: 4;
  transform-origin: 50% 100%; }
.lid-body { position: absolute; inset: 0; border-radius: 54% 54% 9px 9px / 100% 100% 9px 9px;
  background: linear-gradient(180deg, #c19a5a, #6d4c23 56%, #3d2a10);
  border: 1px solid rgba(255, 224, 158, .38);
  box-shadow: inset 0 -7px 14px rgba(0, 0, 0, .55), 0 4px 12px rgba(0, 0, 0, .55); }
.knob { position: absolute; top: -9px; left: 50%; transform: translateX(-50%);
  width: 16px; height: 13px; border-radius: 50% 50% 32% 32%; z-index: 2;
  background: linear-gradient(180deg, #f0d69b, #a97f3c);
  box-shadow: 0 2px 6px rgba(0, 0, 0, .55), inset 0 1px 0 rgba(255, 244, 210, .75); }
.stage.heating .lid { animation: lidRattle .16s linear infinite; }
@keyframes lidRattle {
  0%, 100% { transform: translateY(0) rotate(0) }
  25% { transform: translateY(-1.5px) rotate(-.7deg) }
  75% { transform: translateY(1px) rotate(.7deg) }
}
.stage.success .lid { animation: lidOff .95s cubic-bezier(.2, .7, .3, 1) forwards; }
@keyframes lidOff {
  0% { transform: translateY(0) rotate(0); opacity: 1 }
  100% { transform: translateY(-118px) rotate(-26deg); opacity: 0 }
}
.stage.boom .lid { animation: lidBlast .95s cubic-bezier(.2, .8, .3, 1) forwards; }
@keyframes lidBlast {
  0% { transform: translateY(0) rotate(0); opacity: 1 }
  32% { transform: translateY(-76px) rotate(18deg); opacity: 1 }
  100% { transform: translateY(-168px) rotate(64deg); opacity: 0 }
}
.rim { position: absolute; top: 0; left: -13px; right: -13px; height: 15px; border-radius: 8px;
  background: linear-gradient(180deg, #a5824a, #553b1c 70%, #3a2710);
  box-shadow: 0 2px 0 rgba(0, 0, 0, .6), inset 0 1px 0 rgba(255, 226, 160, .5); }
.body { position: absolute; top: 9px; left: 0; right: 0; bottom: 15px; overflow: hidden;
  border-radius: 11px 11px 44% 44% / 11px 11px 68% 68%;
  background: radial-gradient(circle at 32% 20%, #75603a, #3d2c18 56%, #221809 100%);
  border: 1px solid rgba(212, 175, 55, .34);
  box-shadow: inset 0 -20px 26px rgba(0, 0, 0, .62), inset 0 14px 20px rgba(var(--flame-rgb), .16),
    0 12px 24px rgba(0, 0, 0, .5); transition: filter .5s, box-shadow .4s; }
.inner-glow { position: absolute; inset: -30% -10% auto; height: 90px;
  background: radial-gradient(circle at 50% 40%, rgba(255, 190, 110, .55), transparent 70%);
  opacity: .55; transition: opacity .3s; }
.stage.heating .inner-glow { opacity: 1; animation: innerPulse 1.2s ease-in-out infinite; }
@keyframes innerPulse { 0%, 100% { opacity: .55 } 50% { opacity: 1 } }
.rune { position: absolute; left: 50%; top: 52%; transform: translate(-50%, -50%);
  font-size: 40px; color: rgba(212, 175, 55, .14); letter-spacing: 4px; font-weight: 700; }
.band { position: absolute; left: 0; right: 0; top: 46%; height: 4px; opacity: .5;
  background: linear-gradient(90deg, transparent, rgba(212, 175, 55, .55) 18%,
    rgba(255, 236, 180, .8) 50%, rgba(212, 175, 55, .55) 82%, transparent); }
.handle { position: absolute; top: 22px; width: 20px; height: 9px; border-radius: 5px;
  border: 2px solid #6a4f28; border-left: none; border-right: none; }
.handle.l { left: -18px }
.handle.r { right: -18px }
.leg { position: absolute; bottom: 0; width: 12px; height: 22px;
  background: linear-gradient(180deg, #4c361b, #2a1c0c); border-radius: 0 0 5px 5px; }
.leg.a { left: 24px } .leg.b { left: 82px } .leg.c { right: 24px }

/* 炸炉：裂纹 + 焦黑 */
.crack { position: absolute; width: 8px; opacity: 0; transition: opacity .3s;
  background: linear-gradient(180deg, #150b02, #3a1c04 60%, #ff9a4a);
  filter: drop-shadow(0 0 4px rgba(255, 130, 50, .8));
  clip-path: polygon(50% 0, 100% 14%, 52% 31%, 96% 47%, 46% 63%, 92% 80%, 44% 100%,
    4% 84%, 42% 66%, 0 49%, 40% 33%, 0 15%); }
.crack.c1 { left: 32%; top: 2px; height: 78px; transform: rotate(7deg); }
.crack.c2 { left: 56%; top: 24px; height: 62px; transform: rotate(-12deg); }
.crack.c3 { left: 44%; bottom: 10px; height: 44px; transform: rotate(3deg); }
.crack.c4 { left: 68%; top: 38px; height: 48px; transform: rotate(20deg); }
.stage.boom .crack { opacity: .95; }
/* 焦黑：改炉身底色，不用 filter（filter 会把裂纹的橙光一起压灰） */
.stage.boom .body {
  background:
    radial-gradient(circle at 26% 24%, rgba(90, 82, 74, .55), transparent 46%),
    radial-gradient(circle at 70% 60%, rgba(40, 34, 28, .7), transparent 55%),
    linear-gradient(165deg, #221d18, #14100c 58%, #080605);
  border-color: rgba(120, 96, 60, .3);
  box-shadow: inset 0 -20px 26px #000, inset 0 12px 18px rgba(0, 0, 0, .6),
    0 12px 24px rgba(0, 0, 0, .6); }
.stage.boom .rune { opacity: .08; }
.stage.boom .inner-glow { opacity: 0; }
.stage.boom .rim { background: linear-gradient(180deg, #5a4a30, #2e2418 70%, #1a1410); }
.stage.boom .pot { animation: potCrack .6s ease-out; }
@keyframes potCrack {
  0% { transform: translate(0) }
  20% { transform: translate(-6px, 2px) rotate(-1.6deg) }
  45% { transform: translate(5px, -3px) rotate(1.4deg) }
  70% { transform: translate(-3px, 1px) rotate(-.8deg) }
  100% { transform: translate(0) }
}

/* 炸炉：红光冲击 + 碎片 */
.blast { position: absolute; inset: 0; z-index: 6; pointer-events: none;
  background: radial-gradient(circle at 50% 58%, rgba(255, 170, 80, .85), rgba(255, 70, 30, .45) 30%, transparent 62%);
  animation: blastOut .85s ease-out forwards; }
@keyframes blastOut {
  0% { opacity: 1; transform: scale(.35) }
  55% { opacity: .55 }
  100% { opacity: 0; transform: scale(1.5) }
}
.debris { position: absolute; left: 50%; bottom: 70px; width: 10px; height: 10px; z-index: 6;
  pointer-events: none; }
.debris i { position: absolute; top: 0; left: 0; width: 7px; height: 5px; border-radius: 2px;
  background: linear-gradient(135deg, #5a4526, #1d1409);
  box-shadow: 0 0 6px rgba(255, 140, 60, .55);
  animation: debrisFly .95s cubic-bezier(.2, .7, .4, 1) forwards; }
@keyframes debrisFly {
  0% { opacity: 1; transform: translate(0, 0) rotate(0) }
  100% { opacity: 0;
    transform: translate(calc(var(--dx) * 1px), calc(var(--dy) * 1px)) rotate(var(--rot)) }
}

.smoke { position: absolute; left: 50%; bottom: 92px; width: 260px; height: 180px;
  transform: translateX(-50%); pointer-events: none; z-index: 5; }
.smoke i { position: absolute; bottom: 0; width: 60px; height: 60px; border-radius: 50%;
  background: radial-gradient(circle, rgba(58, 50, 44, .9), rgba(28, 24, 20, .12) 70%);
  filter: blur(9px); opacity: 0; animation: puff 1.9s ease-out forwards; }
@keyframes puff {
  0% { opacity: .9; transform: translate(0, 0) scale(.45) }
  100% { opacity: 0; transform: translate(var(--dx), -132px) scale(var(--sc)) }
}
.shock { position: absolute; left: 50%; bottom: 74px; width: 60px; height: 60px;
  border-radius: 50%; transform: translate(-50%, 50%); z-index: 4;
  border: 3px solid rgba(255, 180, 90, .85); animation: shock .75s ease-out forwards; }
@keyframes shock {
  0% { opacity: 1; width: 40px; height: 40px }
  100% { opacity: 0; width: 520px; height: 520px; border-width: 1px }
}

/* 成丹：丹丸升起 */
.pill-out { position: absolute; left: 50%; bottom: 120px; z-index: 5; width: 54px; height: 54px;
  margin-left: -27px; display: grid; place-items: center;
  animation: pillRise 1.05s cubic-bezier(.2, .7, .3, 1) forwards; }
.p-core { width: 40px; height: 40px; border-radius: 50%; display: grid; place-items: center;
  font-size: 15px; font-weight: 800; color: #3a2a08;
  background: radial-gradient(circle at 34% 30%, #fffbe8, var(--c-hex) 55%, #8a6a1e 100%);
  box-shadow: 0 0 22px rgba(var(--c-rgb), .95), 0 0 52px rgba(var(--c-rgb), .5);
  animation: pillSpin 1.05s ease-out forwards; }
.p-ray { position: absolute; inset: -34px; border-radius: 50%;
  background: radial-gradient(circle, rgba(var(--c-rgb), .45), transparent 62%); }
@keyframes pillRise {
  0% { transform: translateY(14px) scale(.2); opacity: 0 }
  25% { opacity: 1 }
  60% { transform: translateY(-58px) scale(1.12) }
  100% { transform: translateY(-104px) scale(1); opacity: .96 }
}
@keyframes pillSpin { 0% { transform: rotate(0) } 100% { transform: rotate(540deg) } }

/* ------------------------- 火候条 ------------------------- */
.control { margin-top: 4px; padding: 16px; border-radius: 14px; border: 1px solid var(--line);
  background: var(--panel); backdrop-filter: blur(6px); }
.bar-head { display: flex; align-items: baseline; gap: 12px; margin-bottom: 10px; }
.bar-head span { font-size: 12px; letter-spacing: 4px; color: var(--gold2); }
.bar-head em { font-style: normal; font-size: 11px; color: var(--label); }

.bar { position: relative; height: 30px; border-radius: 9px; overflow: hidden;
  background: linear-gradient(90deg, #2b1a10, #4a2a16 45%, #6b2f14 78%, #8d2a10);
  border: 1px solid rgba(212, 175, 55, .28);
  box-shadow: inset 0 2px 10px rgba(0, 0, 0, .6); }
.ticks { position: absolute; inset: 0; pointer-events: none; opacity: .5;
  background-image: repeating-linear-gradient(90deg, rgba(255, 220, 160, .16) 0 1px, transparent 1px 5%); }
.zone { position: absolute; top: 0; bottom: 0; }
.zone.perfect { z-index: 2;
  background: linear-gradient(180deg, rgba(245, 215, 110, .75), rgba(212, 175, 55, .5));
  box-shadow: 0 0 18px rgba(245, 215, 110, .8), inset 0 0 12px rgba(255, 255, 220, .7);
  transition: opacity .2s; }
.zone.perfect::after { content: "完美"; position: absolute; inset: 0; display: grid; place-items: center;
  font-size: 10px; letter-spacing: 2px; color: #4a3406; font-weight: 700; }
.zone.good { z-index: 1; background: rgba(95, 224, 160, .22);
  border-left: 1px solid rgba(95, 224, 160, .4); border-right: 1px solid rgba(95, 224, 160, .4); }
.bar.st-idle .zone { opacity: .3 }
.bar.st-idle .zone.perfect::after { color: rgba(74, 52, 6, .5); }
.needle { position: absolute; top: -6px; bottom: -6px; width: 3px; z-index: 4;
  transform: translateX(-50%); border-radius: 2px;
  background: linear-gradient(180deg, #fff8e0, #ffd166 60%, #ff8a3d);
  box-shadow: 0 0 12px rgba(255, 200, 100, .95), 0 0 26px rgba(255, 120, 40, .6); }
.needle i { position: absolute; top: -6px; left: 50%; transform: translateX(-50%);
  border-left: 5px solid transparent; border-right: 5px solid transparent;
  border-top: 7px solid #ffd166; }
.bar.st-heating { box-shadow: inset 0 2px 10px rgba(0, 0, 0, .6), 0 0 22px rgba(var(--flame-rgb), .32); }

.bar-foot { display: flex; justify-content: space-between; margin-top: 5px;
  font-size: 10px; color: var(--label); letter-spacing: 2px; }

.actions { display: flex; gap: 10px; justify-content: center; align-items: center; margin-top: 16px; }
.btn { height: 38px; padding: 0 20px; border-radius: 9px; cursor: pointer; font-size: 13px;
  font-weight: 700; letter-spacing: 2px; color: #1a1206; border: none;
  background: linear-gradient(90deg, #c99a2e, #f5d76e); transition: .2s; }
.btn.big { height: 44px; padding: 0 34px; letter-spacing: 4px; }
.btn:hover:not(:disabled) { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(212, 175, 55, .3); }
.btn:disabled { opacity: .42; cursor: default; }
.btn.ghost { background: transparent; color: var(--muted); border: 1px solid rgba(212, 175, 55, .28);
  letter-spacing: 1px; font-weight: 400; }
.btn.ghost:hover:not(:disabled) { color: var(--gold2); border-color: var(--gold); }
.btn.ghost.icon { padding: 0 12px; }
.btn.strike { background: linear-gradient(90deg, #ff6a2a, #ffd166);
  animation: strikePulse .9s ease-in-out infinite; }
@keyframes strikePulse {
  0%, 100% { box-shadow: 0 0 0 0 rgba(255, 140, 60, .55) }
  50% { box-shadow: 0 0 0 10px rgba(255, 140, 60, 0) }
}
.hint { margin-top: 10px; text-align: center; font-size: 11px; color: var(--label); letter-spacing: 1px; }
.btn.again { margin-top: 20px; height: 34px; padding: 0 22px; letter-spacing: 3px;
  background: transparent; color: var(--c-hex); border: 1px solid rgba(var(--c-rgb), .55);
  font-weight: 400; }
.btn.again:hover { background: rgba(var(--c-rgb), .14); box-shadow: none; }

/* ------------------------- 结果 ------------------------- */
.result { position: relative; max-width: 960px; margin: 18px auto 0; padding: 24px 22px;
  border-radius: 16px; text-align: center; overflow: hidden;
  border: 1px solid rgba(var(--c-rgb), .42); background: var(--card);
  box-shadow: 0 18px 46px rgba(0, 0, 0, .42), 0 0 46px rgba(var(--c-rgb), .14);
  animation: cardIn .45s ease both; }
.result.bad { --c-hex: #d98a5a; --c-rgb: 217, 138, 90; }
.r-badges { display: flex; gap: 8px; justify-content: center; }
.r-tier { font-size: 11px; padding: 2px 10px; border-radius: 20px; font-weight: 700;
  color: #221806; background: var(--c-hex); }
.r-grade { font-size: 11px; padding: 2px 10px; border-radius: 20px; color: var(--c-hex);
  border: 1px solid rgba(var(--c-rgb), .5); }
.result h2 { margin-top: 10px; font-size: 26px; letter-spacing: 6px; color: var(--c-hex);
  font-weight: 800; text-shadow: 0 0 22px rgba(var(--c-rgb), .45); }
.r-rings { display: flex; gap: 7px; justify-content: center; margin-top: 12px; }
.r-rings i { width: 9px; height: 9px; border-radius: 50%; background: var(--c-hex);
  box-shadow: 0 0 10px rgba(var(--c-rgb), .9); animation: dotIn .4s ease both; }
.r-rings i:nth-child(2) { animation-delay: .08s }
.r-rings i:nth-child(3) { animation-delay: .16s }
.r-rings i:nth-child(4) { animation-delay: .24s }
.r-rings i:nth-child(5) { animation-delay: .32s }
@keyframes dotIn { from { opacity: 0; transform: scale(.2) } to { opacity: 1; transform: scale(1) } }
.r-desc { margin: 12px auto 0; max-width: 620px; font-size: 13px; line-height: 1.95; color: var(--sub); }
.r-meta { margin-top: 12px; display: flex; gap: 16px; justify-content: center; flex-wrap: wrap;
  font-size: 11.5px; color: var(--label); letter-spacing: 1px; }
.r-recipe { margin-top: 8px; font-size: 11.5px; color: var(--label); }
.r-flavor { margin-top: 12px; font-size: 12px; color: var(--muted); font-style: italic; }
.r-boom { font-size: 13px; letter-spacing: 10px; color: #ff9d6b; font-weight: 700; }

/* ------------------------- 战绩 ------------------------- */
.record { max-width: 960px; margin: 16px auto 0; padding: 14px 16px; border-radius: 14px;
  border: 1px dashed rgba(212, 175, 55, .26); background: rgba(0, 0, 0, .16); }
.rec-line { display: flex; align-items: center; gap: 18px; flex-wrap: wrap;
  font-size: 12px; color: var(--muted); }
.rec-line b { font-weight: 700; color: var(--txt); }
.rec-line b.up { color: #5fe0a0 }
.rec-line b.down { color: #ff7a6b }
.rec-reset { margin-left: auto; height: 26px; padding: 0 10px; border-radius: 6px; cursor: pointer;
  font-size: 11px; color: var(--label); background: transparent;
  border: 1px solid rgba(212, 175, 55, .2); }
.rec-reset:hover { color: var(--gold2); border-color: var(--gold); }
.rec-pills { display: flex; gap: 7px; flex-wrap: wrap; margin-top: 10px; }
.rec-pill { font-size: 11px; padding: 3px 9px; border-radius: 6px;
  border: 1px solid rgba(212, 175, 55, .2); color: var(--sub); }
.rec-pill.ok { border-color: rgba(95, 224, 160, .32); color: #9fe6c0; }
.rec-pill.bad { border-color: rgba(255, 122, 107, .3); color: #ff9d90; }
.rec-pill em { font-style: normal; margin-left: 4px; opacity: .8; font-size: 10px; }
.rec-tip { margin-top: 8px; font-size: 11px; color: var(--label); }
.foot { text-align: center; margin-top: 26px; font-size: 11.5px; color: var(--label); }

/* ------------------------- 白昼兜底 ------------------------- */
:global(body.light) .p-title b,
:global(body.light) .bar-head span,
:global(body.light) .result h2 { color: #7a5f14; }
:global(body.light) .f-note b { color: #7a5f14; }
:global(body.light) .btn.again { color: #7a5f14; border-color: rgba(122, 95, 20, .5); }
:global(body.light) .r-flavor { color: #6f5d45; }
:global(body.light) .result.bad h2,
:global(body.light) .r-boom { color: #b4520f; }
:global(body.light) .herb,
:global(body.light) .fire { background: rgba(255, 255, 255, .6); }
:global(body.light) .herb.on { background: rgba(212, 175, 55, .18); }
:global(body.light) .record { background: rgba(255, 255, 255, .45); }
:global(body.light) .r-tier { color: #fffdf6; }
:global(body.light) .rec-pill.ok { color: #1c8a56; }
:global(body.light) .rec-pill.bad { color: #b8392a; }
:global(body.light) .rec-pill { background: rgba(255, 255, 255, .72); }
:global(body.light) .up { color: #1c8a56 }
:global(body.light) .down { color: #b8392a }

@media (max-width: 760px) {
  .wrap { grid-template-columns: 1fr; }
  .herb-grid { grid-template-columns: repeat(3, 1fr); }
  .fire-grid { grid-template-columns: repeat(4, 1fr); }
  .stage { height: 220px; }
  .pot { transform: scale(.9); margin-bottom: 26px; }
  .actions { flex-wrap: wrap; }
  .head h1 { font-size: 24px; letter-spacing: 8px; }
}
</style>
