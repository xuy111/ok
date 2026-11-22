<template>
  <div class="wall-page">
    <TopNav active="gallery" />

    <!-- ================= 头部 ================= -->
    <section class="hero">
      <div class="film"></div>
      <div class="hero-in">
        <p class="kicker">群像 · 高光时刻</p>
        <h1>六人十二幕</h1>
        <p class="sub">
          从乌坦城那根指天的手指，到异火广场落下的一尺。<br />
          六个人，十二个瞬间，一条烧穿了整个斗气大陆的线。
        </p>
        <div class="stats">
          <div><b>12</b><i>名场面</i></div>
          <span class="dot"></span>
          <div><b>6</b><i>核心角色</i></div>
          <span class="dot"></span>
          <div><b>22</b><i>种异火</i></div>
          <span class="dot"></span>
          <div><b>1</b><i>个炎帝</i></div>
        </div>
      </div>
    </section>

    <!-- ================= 控制条 ================= -->
    <div class="ctrl">
      <div class="seg">
        <button :class="{ on: mode === 'char' }" @click="mode = 'char'">按角色</button>
        <button :class="{ on: mode === 'time' }" @click="mode = 'time'">按时间线</button>
      </div>

      <div class="chips">
        <button class="chip" :class="{ on: pick === 'all' }" @click="pick = 'all'">
          全部<em>12</em>
        </button>
        <button
          v-for="c in CHARS"
          :key="c.id"
          class="chip"
          :class="{ on: pick === c.id }"
          :style="{ '--c': c.color }"
          @click="pick = c.id"
        >
          <i></i>{{ c.name }}<em>2</em>
        </button>
      </div>
    </div>

    <!-- ================= 视图一：按角色 ================= -->
    <div class="wall" v-show="mode === 'char'">
      <section
        v-for="(c, ci) in shownChars"
        :key="c.id"
        class="group"
        :style="{ '--c': c.color, '--tone': c.tone }"
      >
        <aside class="gInfo">
          <span class="gIdx">{{ String(ci + 1).padStart(2, '0') }}</span>
          <div class="gAva">
            <img :src="'/characters/' + c.id + '_avatar.jpg'" :alt="c.name" @error="avaFail($event, c)" />
          </div>
          <h2 class="gName">{{ c.name }}</h2>
          <p class="gAlias">{{ c.alias }}</p>
          <p class="gLine">{{ c.line }}</p>
          <div class="gBar"><i></i></div>
        </aside>

        <div class="gShots">
          <!-- 官方形象照：横构图，占满整行，钉在这组的最上面 -->
          <PhotoCard
            v-for="o in officialsOf(c.id)"
            :key="o.id"
            class="wide"
            :scene="o"
            :tone="c.tone"
            ratio="16 / 9"
            @open="open(o)"
          />
          <PhotoCard
            v-for="s in byChar(c.id)"
            :key="s.id"
            :scene="s"
            :tone="c.tone"
            @open="open(s)"
          />
        </div>
      </section>
    </div>

    <!-- ================= 视图二：按时间线 ================= -->
    <div class="wall time-wall" v-show="mode === 'time'">
      <div class="titem" v-for="s in timeline" :key="s.id">
        <div class="tarc" :style="{ '--tone': CHAR_MAP[s.char].tone }">
          <i></i>{{ stageOf(s) }}<b>{{ CHAR_MAP[s.char].name }}</b>
        </div>
        <PhotoCard :scene="s" :tone="CHAR_MAP[s.char].tone" @open="open(s)" />
      </div>
    </div>

    <footer class="foot">
      内容依据天蚕土豆原著《斗破苍穹》整理，动画对应画面为参考；台词为原著大意转述，非逐字引文。<br />
      图片为 AI 依据角色设定生成的同人插画，仅用于个人学习与展示。
    </footer>

    <!-- ================= 考据弹层 ================= -->
    <Teleport to="body">
      <transition name="lb">
        <div v-if="cur" class="lb" @click.self="close">
          <button class="lbX" @click="close" title="关闭（Esc）">✕</button>
          <button class="lbNav prev" @click.stop="step(-1)" title="上一张（←）">‹</button>
          <button class="lbNav next" @click.stop="step(1)" title="下一张（→）">›</button>

          <div class="lbBox" :style="{ '--tone': CHAR_MAP[cur.char].tone }">
            <div class="lbShot">
              <img class="lbBg" :src="cur.img" alt="" aria-hidden="true" />
              <img class="lbMain" :src="cur.img" :alt="cur.title" />
              <div class="lbShotFoot">
                <span class="lbNo">{{ cur.official ? '官方形象' : 'NO.' + cur.no }}</span>
                <span class="lbPos">{{ pos + 1 }} / {{ list.length }}</span>
              </div>
            </div>

            <div class="lbInfo">
              <div class="lbWho">
                <div class="lbAva" :style="{ '--c': CHAR_MAP[cur.char].color }">
                  <img :src="'/characters/' + cur.char + '_avatar.jpg'" :alt="CHAR_MAP[cur.char].name"
                       @error="avaFail($event, CHAR_MAP[cur.char])" />
                </div>
                <div>
                  <b>{{ CHAR_MAP[cur.char].name }}</b>
                  <i>{{ CHAR_MAP[cur.char].alias }}</i>
                </div>
              </div>

              <h3 class="lbTitle">{{ cur.title }}</h3>
              <p class="lbTag">{{ cur.tag }}</p>

              <div class="lbMeta">
                <span>场景 <b>{{ stageOf(cur) }}</b></span>
                <span>阶段 <b>{{ arcOf(cur) }}</b></span>
                <span>境界 <b>{{ cur.realm }}</b></span>
              </div>

              <div class="lbNotes">
                <div class="note" v-for="(n, i) in cur.detail" :key="i">
                  <div class="noteH"><em>{{ String(i + 1).padStart(2, '0') }}</em>{{ n.h }}</div>
                  <p class="noteP">{{ n.p }}</p>
                </div>
              </div>

              <blockquote class="lbQuote" v-if="cur.quote">{{ cur.quote }}</blockquote>
            </div>
          </div>
        </div>
      </transition>
    </Teleport>
  </div>
</template>

<script>
import TopNav from '../components/TopNav.vue'
import PhotoCard from '../components/PhotoCard.vue'
import { CHARS, CHAR_MAP, SCENES, OFFICIALS, ARCS } from '../gallery'

export default {
  name: 'PhotoWall',
  components: { TopNav, PhotoCard },
  data() {
    return {
      CHARS, CHAR_MAP, SCENES, OFFICIALS,
      mode: 'char',
      pick: 'all',
      cur: null,
      pos: 0
    }
  },
  computed: {
    shownChars() {
      return this.pick === 'all' ? CHARS : CHARS.filter(c => c.id === this.pick)
    },
    /** 时间线视图：只排十二幕剧情，官方形象照不参与时间轴 */
    timeline() {
      const list = this.pick === 'all' ? SCENES : SCENES.filter(s => s.char === this.pick)
      return [...list].sort((a, b) => a.arcIndex - b.arcIndex || a.no.localeCompare(b.no))
    },
    /** 弹层左右翻页用的序列，与当前视图的渲染顺序一致（官方照排在每组最前） */
    list() {
      if (this.mode === 'time') return this.timeline
      const out = []
      this.shownChars.forEach(c => {
        out.push(...OFFICIALS.filter(o => o.char === c.id), ...SCENES.filter(s => s.char === c.id))
      })
      return out
    }
  },
  watch: {
    pick() {
      this.cur = null
    }
  },
  mounted() {
    window.addEventListener('keydown', this.onKey)
  },
  beforeUnmount() {
    window.removeEventListener('keydown', this.onKey)
    document.body.style.overflow = ''
  },
  methods: {
    byChar(id) {
      return SCENES.filter(s => s.char === id)
    },
    officialsOf(id) {
      return OFFICIALS.filter(o => o.char === id)
    },
    arcOf(s) {
      return ARCS[s.arcIndex] || ''
    },
    /** 场景标注优先用每幕自己的精确地点，缺省回落到剧情阶段 */
    stageOf(s) {
      return s.stage || this.arcOf(s)
    },
    open(s) {
      const i = this.list.findIndex(x => x.id === s.id)
      this.pos = i < 0 ? 0 : i
      this.cur = s
      document.body.style.overflow = 'hidden'
    },
    close() {
      this.cur = null
      document.body.style.overflow = ''
    },
    step(d) {
      if (!this.list.length) return
      this.pos = (this.pos + d + this.list.length) % this.list.length
      this.cur = this.list[this.pos]
    },
    onKey(e) {
      if (!this.cur) return
      if (e.key === 'Escape') this.close()
      if (e.key === 'ArrowLeft') this.step(-1)
      if (e.key === 'ArrowRight') this.step(1)
    },
    /** 头像缺失时退回角色名首字，避免出现破图 */
    avaFail(e, c) {
      const el = e.target
      el.style.display = 'none'
      const box = el.parentElement
      box.textContent = c.name.slice(-1)
      box.style.background = c.color
      box.style.color = '#0c0a09'
      box.style.fontWeight = '800'
    }
  }
}
</script>

<style scoped>
.wall-page { min-height: 100vh; padding-bottom: 20px; }

/* ---------------- 头部 ---------------- */
.hero { position: relative; padding: 54px 20px 30px; overflow: hidden; }
.film {
  position: absolute; inset: 0; pointer-events: none; opacity: .5;
  background-image:
    radial-gradient(circle at 50% 0%, rgba(var(--flame-rgb), .22), transparent 58%),
    repeating-linear-gradient(90deg, rgba(212, 175, 55, .10) 0 1px, transparent 1px 46px);
  mask-image: linear-gradient(to bottom, #000 0%, transparent 88%);
  -webkit-mask-image: linear-gradient(to bottom, #000 0%, transparent 88%);
}
.hero-in { position: relative; max-width: 940px; margin: 0 auto; text-align: center; }
.kicker {
  font-size: 11px; letter-spacing: 8px; color: var(--gold); margin-bottom: 16px;
  text-transform: uppercase;
}
.hero h1 {
  font-size: 46px; letter-spacing: 16px; font-weight: 800; color: var(--gold2);
  text-shadow: 0 0 34px rgba(212, 175, 55, .45); line-height: 1.2;
  padding-left: 16px; /* 抵消末尾字距 */
}
.sub {
  margin-top: 18px; font-size: 13px; line-height: 2.05; color: var(--muted); letter-spacing: 1.2px;
}
.stats {
  margin-top: 26px; display: inline-flex; align-items: center; gap: 18px;
  padding: 12px 26px; border-radius: 40px;
  border: 1px solid var(--line); background: rgba(0, 0, 0, .22);
  backdrop-filter: blur(6px);
}
.stats div { text-align: center; }
.stats b { display: block; font-size: 21px; color: var(--gold2); letter-spacing: 1px; line-height: 1.2; }
.stats i { display: block; font-size: 10px; font-style: normal; color: var(--label); letter-spacing: 2px; margin-top: 3px; }
.stats .dot { width: 1px; height: 26px; background: var(--line); }

/* ---------------- 控制条 ---------------- */
.ctrl {
  max-width: 1180px; margin: 8px auto 30px; padding: 0 20px;
  display: flex; align-items: center; gap: 16px; flex-wrap: wrap;
}
.seg {
  display: inline-flex; padding: 3px; border-radius: 24px;
  border: 1px solid var(--line); background: rgba(0, 0, 0, .25);
}
.seg button {
  padding: 7px 18px; border: 0; border-radius: 20px; cursor: pointer;
  font-size: 12.5px; letter-spacing: 1.5px; color: var(--muted); background: transparent; transition: .22s;
}
.seg button:hover { color: var(--gold2); }
.seg button.on {
  color: #1a1206; font-weight: 700;
  background: linear-gradient(90deg, #c99a2e, #f5d76e);
  box-shadow: 0 0 16px rgba(212, 175, 55, .33);
}

.chips { display: flex; gap: 8px; flex-wrap: wrap; margin-left: auto; }
.chip {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 6px 13px; border-radius: 16px; cursor: pointer;
  font-size: 12px; color: var(--muted); letter-spacing: .5px;
  border: 1px solid rgba(212, 175, 55, .22); background: rgba(0, 0, 0, .22);
  transition: .22s;
}
.chip i { width: 6px; height: 6px; border-radius: 50%; background: var(--c, var(--gold2)); box-shadow: 0 0 8px var(--c, var(--gold2)); }
.chip em { font-style: normal; font-size: 9.5px; opacity: .55; }
.chip:hover { color: var(--gold2); border-color: var(--gold); }
.chip.on {
  color: #1a1206; font-weight: 700;
  background: linear-gradient(90deg, #c99a2e, #f5d76e); border-color: transparent;
}
.chip.on i { background: #1a1206; box-shadow: none; }

/* ---------------- 照片墙 ---------------- */
.wall { max-width: 1180px; margin: 0 auto; padding: 0 20px 40px; }

.group {
  display: grid; grid-template-columns: 196px minmax(0, 1fr); gap: 40px;
  padding: 34px 0; border-top: 1px solid rgba(212, 175, 55, .13);
  animation: cardIn .55s ease-out;
}
.group:first-child { border-top: 0; padding-top: 6px; }

.gInfo { position: sticky; top: 92px; align-self: start; }
.gIdx {
  font-size: 11px; letter-spacing: 3px; color: var(--c);
  font-weight: 800; opacity: .8;
}
.gAva {
  width: 58px; height: 58px; margin: 12px 0 14px; border-radius: 50%; overflow: hidden;
  border: 2px solid var(--c); display: grid; place-items: center;
  font-size: 22px; color: #0c0a09;
  box-shadow: 0 0 0 4px color-mix(in srgb, var(--c) 12%, transparent), 0 0 20px color-mix(in srgb, var(--c) 42%, transparent);
}
.gAva img { width: 100%; height: 100%; object-fit: cover; display: block; }
.gName { font-size: 26px; letter-spacing: 5px; color: var(--tone); font-weight: 800; line-height: 1.2; }
.gAlias { margin-top: 8px; font-size: 10.5px; letter-spacing: .8px; color: var(--label); line-height: 1.6; }
.gLine {
  margin-top: 14px; font-size: 11.5px; line-height: 1.85; color: var(--muted);
  padding-left: 11px; border-left: 2px solid color-mix(in srgb, var(--c) 55%, transparent);
}
.gBar { margin-top: 18px; height: 2px; width: 62px; background: rgba(212, 175, 55, .18); border-radius: 2px; overflow: hidden; }
.gBar i { display: block; height: 100%; width: 100%; background: linear-gradient(90deg, var(--c), transparent); }

.gShots {
  display: grid; grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 34px 30px; max-width: 730px;
}
/* 官方形象照：横跨两列，横构图不倾斜，像一张贴在整组正中的剧照 */
.gShots .wide { grid-column: 1 / -1; }
.gShots .wide :deep(.cap b) { font-size: 15px; letter-spacing: 2px; }

/* 时间线视图 */
.time-wall {
  display: grid; grid-template-columns: repeat(auto-fill, minmax(232px, 1fr));
  gap: 40px 30px; padding-top: 6px;
}
.titem { animation: cardIn .5s ease-out; }
.tarc {
  display: flex; align-items: center; gap: 7px;
  font-size: 10px; letter-spacing: 1px; color: var(--label);
  margin-bottom: 16px; padding-bottom: 7px;
  border-bottom: 1px dashed rgba(212, 175, 55, .22);
}
.tarc i { width: 5px; height: 5px; border-radius: 50%; background: var(--tone); box-shadow: 0 0 7px var(--tone); }
.tarc b { margin-left: auto; color: var(--tone); font-weight: 600; letter-spacing: .5px; }

.foot {
  max-width: 940px; margin: 10px auto 40px; padding: 0 20px;
  text-align: center; font-size: 11px; line-height: 1.95; color: var(--label);
}

/* ---------------- 弹层 ---------------- */
.lb {
  position: fixed; inset: 0; z-index: 90;
  display: grid; place-items: center; padding: 34px 20px;
  background: rgba(6, 4, 3, .86); backdrop-filter: blur(10px);
}
.lbBox {
  position: relative; width: min(1120px, 100%); height: min(86vh, 780px); max-height: 100%;
  display: grid; grid-template-columns: minmax(0, 1fr) 440px;
  border-radius: 10px; overflow: hidden;
  border: 1px solid color-mix(in srgb, var(--tone) 38%, transparent);
  background: var(--panel-solid);
  box-shadow: 0 40px 90px -30px #000, 0 0 60px -20px color-mix(in srgb, var(--tone) 30%, transparent);
}

.lbShot { position: relative; background: #0a0806; display: flex; flex-direction: column; min-height: 0; overflow: hidden; }
/* 虚化底图：填掉竖图在宽容器里的左右留白 */
.lbBg {
  position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover;
  filter: blur(26px) saturate(1.3) brightness(.62); transform: scale(1.18); opacity: .8;
}
.lbMain {
  position: relative; z-index: 1; width: 100%; height: 100%; object-fit: contain;
  display: block; flex: 1; min-height: 0;
}
.lbShotFoot {
  position: absolute; inset: auto 0 0 0; display: flex; justify-content: space-between;
  padding: 20px 18px 12px; font-size: 10.5px; letter-spacing: 2px; color: #e8dcc0;
  background: linear-gradient(to top, rgba(0, 0, 0, .8), transparent);
}
.lbNo { color: var(--tone); font-weight: 800; }
.lbPos { opacity: .7; }

.lbInfo { padding: 30px 28px 34px; overflow-y: auto; min-height: 0;
  background: linear-gradient(165deg, var(--panel-solid), var(--panel-solid)); }
.lbWho { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; }
.lbAva {
  width: 42px; height: 42px; border-radius: 50%; overflow: hidden; flex: none;
  display: grid; place-items: center; font-size: 16px; color: #0c0a09;
  border: 1.5px solid var(--c);
  box-shadow: 0 0 16px color-mix(in srgb, var(--c) 45%, transparent);
}
.lbAva img { width: 100%; height: 100%; object-fit: cover; display: block; }
.lbWho b { display: block; font-size: 14px; color: var(--text); letter-spacing: 2px; }
.lbWho i { display: block; margin-top: 4px; font-size: 10px; font-style: normal; color: var(--label); letter-spacing: .5px; }

.lbTitle { font-size: 27px; letter-spacing: 4px; color: var(--tone); font-weight: 800; line-height: 1.3; }
.lbTag { margin-top: 10px; font-size: 12px; color: var(--muted); line-height: 1.8; letter-spacing: .6px; }

.lbMeta { display: flex; gap: 8px; flex-wrap: wrap; margin: 18px 0 8px; }
.lbMeta span {
  font-size: 10.5px; padding: 4px 10px; border-radius: 12px;
  border: 1px solid var(--line); color: var(--label);
}
.lbMeta b { color: var(--gold2); font-weight: 600; }

.lbNotes { margin-top: 18px; }
.note { padding: 14px 0; border-top: 1px dashed rgba(212, 175, 55, .16); }
.noteH {
  display: flex; align-items: center; gap: 9px;
  font-size: 12px; letter-spacing: 2px; color: var(--gold); font-weight: 600; margin-bottom: 8px;
}
.noteH em { font-style: normal; font-size: 10px; color: var(--tone); opacity: .65; letter-spacing: 1px; }
.noteP { font-size: 12px; line-height: 1.95; color: var(--label); letter-spacing: .3px; }

.lbQuote {
  margin-top: 20px; padding: 14px 16px; border-radius: 6px;
  font-size: 12.5px; line-height: 1.85; color: var(--tone); letter-spacing: .8px;
  border-left: 2px solid var(--tone);
  background: color-mix(in srgb, var(--tone) 7%, transparent);
}

.lbX, .lbNav {
  position: absolute; z-index: 3; cursor: pointer;
  display: grid; place-items: center; color: var(--text);
  border: 1px solid rgba(212, 175, 55, .25); background: rgba(0, 0, 0, .45);
  backdrop-filter: blur(6px); border-radius: 50%; transition: .2s;
}
.lbX { top: 22px; right: 24px; width: 38px; height: 38px; font-size: 15px; }
.lbNav { top: 50%; width: 44px; height: 44px; margin-top: -22px; font-size: 26px; line-height: 1; padding-bottom: 4px; }
.lbNav.prev { left: 22px; }
.lbNav.next { right: 22px; }
.lbX:hover, .lbNav:hover { color: #1a1206; background: linear-gradient(135deg, #c99a2e, #f5d76e); border-color: transparent; }

.lb-enter-active, .lb-leave-active { transition: opacity .24s ease; }
.lb-enter-from, .lb-leave-to { opacity: 0; }
.lb-enter-active .lbBox { animation: lbIn .34s cubic-bezier(.2, .8, .25, 1); }
@keyframes lbIn {
  from { transform: translateY(18px) scale(.97); opacity: 0; }
  to { transform: none; opacity: 1; }
}

/* ---------------- 无障碍：偏好减少动效时直接显示 ---------------- */
@media (prefers-reduced-motion: reduce) {
  .group, .titem { animation: none !important; }
  .lb-enter-active .lbBox { animation: none !important; }
}

/* ---------------- 响应式 ---------------- */
@media (max-width: 900px) {
  .group { grid-template-columns: 1fr; gap: 24px; }
  .gInfo { position: static; display: grid; grid-template-columns: auto auto 1fr; align-items: center; gap: 0 14px; }
  .gIdx { display: none; }
  .gAva { width: 44px; height: 44px; margin: 0; font-size: 17px; grid-row: span 2; }
  .gName { font-size: 20px; letter-spacing: 3px; }
  .gAlias { margin: 0; }
  .gLine { grid-column: 1 / -1; margin-top: 12px; }
  .gBar { display: none; }
  .lbBox { grid-template-columns: 1fr; height: auto; max-height: 100%; }
  .lbShot { height: 40vh; }
  .lbInfo { max-height: 46vh; }
  .lbNav { top: auto; bottom: 18px; margin-top: 0; }
}
@media (max-width: 620px) {
  .hero { padding-top: 38px; }
  .hero h1 { font-size: 30px; letter-spacing: 8px; }
  .stats { gap: 12px; padding: 10px 16px; }
  .stats b { font-size: 17px; }
  .chips { margin-left: 0; width: 100%; }
  .gShots { grid-template-columns: 1fr; gap: 30px; }
  .time-wall { grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 30px 16px; }
  .lb { padding: 12px; }
  .lbInfo { padding: 20px 18px 24px; }
  .lbTitle { font-size: 21px; letter-spacing: 2px; }
}
</style>
