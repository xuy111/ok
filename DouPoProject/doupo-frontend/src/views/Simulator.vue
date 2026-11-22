<template>
  <div class="sim-page">
    <TopNav active="sim" />

    <section class="head">
      <h1>异火融合</h1>
      <p class="slogan">两火相融，或成新焰，或有一方被吞</p>
    </section>

    <section class="board">
      <div class="mode">
        <button :class="{ on: mode === 'fuse' }" @click="switchMode('fuse')">融 合</button>
        <button :class="{ on: mode === 'devour' }" @click="switchMode('devour')">吞 噬</button>
        <span class="mode-tip">{{ mode === 'fuse' ? '两种异火彼此相容，诞生新的火焰' : '强者吞并弱者，进化自身' }}</span>
      </div>

      <div class="slots" :class="{ merging: phase === 'merging' }">
        <div class="slot" :class="{ filled: a }" @click="pick(0)" :style="slotStyle(a)">
          <template v-if="a">
            <div class="s-art" v-if="artOf(a)" :style="{ backgroundImage: 'url(' + artOf(a) + ')' }"></div>
            <div class="s-icon" v-else>{{ a.icon || '🔥' }}</div>
            <div class="s-foot">
              <div class="s-name">{{ a.name }}</div>
              <div class="s-attr" v-if="a.grade">{{ a.grade }}</div>
            </div>
            <div class="s-rank" v-if="a.rankNo > 0">异火榜 #{{ a.rankNo }}</div>
            <div class="s-swap">换一朵</div>
          </template>
          <template v-else>
            <div class="s-plus">＋</div>
            <div class="s-hint">选择异火</div>
          </template>
        </div>

        <div class="vs">
          <div class="vs-orb" v-if="phase === 'merging'"></div>
          <span>{{ mode === 'fuse' ? '融' : '吞' }}</span>
        </div>

        <div class="slot" :class="{ filled: b }" @click="pick(1)" :style="slotStyle(b)">
          <template v-if="b">
            <div class="s-art" v-if="artOf(b)" :style="{ backgroundImage: 'url(' + artOf(b) + ')' }"></div>
            <div class="s-icon" v-else>{{ b.icon || '🔥' }}</div>
            <div class="s-foot">
              <div class="s-name">{{ b.name }}</div>
              <div class="s-attr" v-if="b.grade">{{ b.grade }}</div>
            </div>
            <div class="s-rank" v-if="b.rankNo > 0">异火榜 #{{ b.rankNo }}</div>
            <div class="s-swap">换一朵</div>
          </template>
          <template v-else>
            <div class="s-plus">＋</div>
            <div class="s-hint">选择异火</div>
          </template>
        </div>
      </div>

      <div class="actions">
        <button class="btn big" :disabled="!a || !b || phase === 'merging'" @click="run">
          {{ phase === 'merging' ? '火焰交锋中…' : mode === 'fuse' ? '开始融合' : '开始吞噬' }}
        </button>
        <button class="btn ghost" @click="reset" v-if="a || b">清空</button>
        <button class="btn snd" @click="muted = !muted" :title="muted ? '开启音效' : '关闭音效'">{{ muted ? '🔇' : '🔊' }}</button>
      </div>

      <transition name="fade">
        <div v-if="result" class="result" :style="resultStyle">
          <div class="r-glow"></div>
          <div class="r-art" v-if="resultArt" :style="{ backgroundImage: 'url(' + resultArt + ')' }"></div>
          <div class="r-icon" v-if="!resultArt">{{ result.icon }}</div>
          <h2>{{ result.name }}</h2>
          <p class="r-desc">{{ result.desc }}</p>
          <div class="r-formula">
            <span>{{ a.name }}</span>
            <i>{{ mode === 'fuse' ? '＋' : '➜' }}</i>
            <span>{{ b.name }}</span>
            <i>＝</i>
            <span class="r-res">{{ result.name }}</span>
          </div>
          <div class="r-tags">
            <span>品阶 {{ result.grade }}</span>
            <span>难度 {{ '✦'.repeat(result.difficulty) }}</span>
          </div>
        </div>
      </transition>
    </section>

    <!-- 选择器 -->
    <transition name="fade">
      <div v-if="pickerShow" class="mask" @click.self="pickerShow = false">
        <div class="picker">
          <div class="p-head">
            <b>选择第 {{ pickIndex + 1 }} 朵异火</b>
            <button @click="pickerShow = false">✕</button>
          </div>
          <div class="p-grid">
            <div v-for="f in fires" :key="f.id" class="p-item"
                 :class="{ used: (a && a.id === f.id) || (b && b.id === f.id) }"
                 :style="{ '--c-hex': colorOf(f.color).hex, '--c-rgb': colorOf(f.color).rgb }"
                 @click="choose(f)">
              <div class="p-art" v-if="artOf(f)" :style="{ backgroundImage: 'url(' + artOf(f) + ')' }"></div>
              <div class="p-icon" v-else>{{ f.icon || '🔥' }}</div>
              <div class="p-name">{{ f.name }}</div>
              <div class="p-grade" v-if="f.grade">{{ f.grade }}</div>
              <div class="p-rank" v-if="f.rankNo > 0">#{{ f.rankNo }}</div>
            </div>
          </div>
        </div>
      </div>
    </transition>

    <footer class="foot"><p>结果依据原著设定整理，仅供娱乐</p></footer>

    <!-- 融合 / 吞噬 / 暴走 全屏特效 -->
    <FuseFx
      :show="!!fx"
      :kind="fx ? fx.kind : 'fuse'"
      :name="fx ? fx.name : ''"
      :grade="fx ? fx.grade : ''"
      :fail-reason="fx ? fx.failReason : ''"
      :color-a="fx ? fx.colorA : '#5fb8ff'"
      :rgb-a="fx ? fx.rgbA : '95,184,255'"
      :color-b="fx ? fx.colorB : '#ff7a45'"
      :rgb-b="fx ? fx.rgbB : '255,122,69'"
      :color-r="fx ? fx.colorR : '#f5d76e'"
      :rgb-r="fx ? fx.rgbR : '245,215,110'"
      :muted="muted"
      @done="fx = null"
    />
  </div>
</template>

<script>
import api from '../api'
import { colorOf } from '../theme'
import { artOf } from '../art'
import TopNav from '../components/TopNav.vue'
import FuseFx from '../components/FuseFx.vue'

/** 原著向的融合规则（无序对） */
const FUSE_RULES = [
  {
    pair: ['青莲地心火', '陨落心炎'],
    name: '琉璃莲心火',
    icon: '🌸',
    color: 'pink',
    grade: '天阶',
    difficulty: 5,
    desc: '青莲为骨，心炎为心，莲台之上燃起琉璃色的新焰。这是萧炎最经典的一次异火融合，威能远超两火之和。'
  },
  {
    pair: ['净莲妖火', '骨灵冷火'],
    name: '净莲寒焰',
    icon: '❄️',
    color: 'ice',
    grade: '天阶',
    difficulty: 5,
    desc: '净世之力裹挟极寒，焰生莲台却触之成霜。可净化污秽，亦可冻结灵魂。'
  },
  {
    pair: ['三千焱炎火', '海心焰'],
    name: '星海焚天炎',
    icon: '🌌',
    color: 'blue',
    grade: '天阶',
    difficulty: 5,
    desc: '星辰之火坠入深海之心，焰色如星河倒悬，一燃便是半片天穹。'
  },
  {
    pair: ['金帝焚天炎', '八荒破灭炎'],
    name: '焚天灭世炎',
    icon: '☀️',
    color: 'red',
    grade: '天阶',
    difficulty: 5,
    desc: '古族圣焰与八荒赤焰相叠，热浪所至，山河皆成焦土。'
  },
  {
    pair: ['生灵之焱', '九幽风炎'],
    name: '风生炎起',
    icon: '🌪️',
    color: 'green',
    grade: '地阶',
    difficulty: 4,
    desc: '风助生机，火借风势。此焰不焚草木，反令枯木回春，却能烧尽一切阴邪。'
  }
]

export default {
  name: 'Simulator',
  components: { TopNav, FuseFx },
  data() {
    return {
      mode: 'fuse',
      fires: [],
      a: null,
      b: null,
      phase: 'idle',
      result: null,
      pickerShow: false,
      pickIndex: 0,
      fx: null,
      muted: false
    }
  },
  computed: {
    resultStyle() {
      const c = colorOf(this.result ? this.result.color : 'gold')
      return { '--c-hex': c.hex, '--c-dim': c.dim, '--c-rgb': c.rgb }
    },
    /**
     * 结果插图：
     * - 吞噬 → 胜者原图（由 devour() 写入 artFrom）
     * - 融合 → 结果名里包含哪朵原火（如「虚无·吞」→ 虚无吞炎），就用那一朵
     * - 都对不上（同源相斥、万火归一、无名双色焰）→ 回退 emoji
     */
    resultArt() {
      if (!this.result) return ''
      const both = [this.a, this.b].filter(Boolean)
      const want = this.result.artFrom
      if (want) {
        const f = both.find(x => x.name === want)
        return f ? artOf(f) : ''
      }
      const hit = both.find(x => this.result.name.indexOf(x.name) >= 0)
      return hit ? artOf(hit) : ''
    }
  },
  async created() {
    try {
      const res = await api.itemList({ category: '异火', size: 100 })
      if (res && res.code === 200) this.fires = res.data.list || []
    } catch (e) { /* 忽略 */ }
  },
  methods: {
    colorOf,
    artOf,
    slotStyle(f) {
      if (!f) return {}
      const c = colorOf(f.color)
      return { '--c-hex': c.hex, '--c-dim': c.dim, '--c-rgb': c.rgb }
    },
    switchMode(m) {
      this.mode = m
      this.reset()
    },
    pick(i) {
      // 模板里 @click="pick(0)" / "pick(1)"，拿到的是槽位下标
      this.pickIndex = i
      this.pickerShow = true
    },
    /** 已占用的火不能再选（包括同一槽位重新挑） */
    usedBy(f) {
      return (this.a && this.a.id === f.id) || (this.b && this.b.id === f.id)
    },
    choose(f) {
      if (!f) return
      if (this.usedBy(f)) return
      if (this.pickIndex === 0) this.a = f
      else this.b = f
      this.pickerShow = false
      this.result = null
      this.phase = 'idle'
      this.fx = null
    },
    reset() {
      this.a = null
      this.b = null
      this.result = null
      this.phase = 'idle'
      this.fx = null
    },
    run() {
      if (!this.a || !this.b) return
      this.phase = 'merging'
      this.result = null
      this.fx = null
      clearTimeout(this._runTimer)
      this._runTimer = setTimeout(() => {
        const r = this.mode === 'fuse' ? this.fuse() : this.devour()
        this.result = r
        this.phase = 'idle'
        // 结果判定：同源相斥 / 自噬为暴走失败，其余按模式播放融合或吞噬特效
        const failed = r.name === '同源相斥' || r.name === '无意义的自噬'
        const ca = colorOf(this.a.color)
        const cb = colorOf(this.b.color)
        const cr = colorOf(r.color)
        this.fx = {
          kind: failed ? 'fail' : this.mode,
          name: r.name,
          grade: r.grade,
          failReason: r.name === '同源相斥' ? '同源之力相斥 · 斗气暴走' : '自我吞噬 · 焰体溃散',
          colorA: ca.hex, rgbA: ca.rgb,
          colorB: cb.hex, rgbB: cb.rgb,
          colorR: cr.hex, rgbR: cr.rgb
        }
      }, 1200)
    },
    fuse() {
      const x = this.a
      const y = this.b
      if (x.id === y.id) {
        return {
          name: '同源相斥',
          icon: '💥',
          color: 'red',
          grade: '—',
          difficulty: 1,
          desc: '同一朵异火无法自我融合，强行施为只会引发斗气暴走，人火俱伤。'
        }
      }
      // 帝炎统御万火
      const god = [x, y].find(f => f.name === '帝炎')
      if (god) {
        return {
          name: '万火归一',
          icon: '👑',
          color: 'gold',
          grade: '天阶',
          difficulty: 5,
          desc: '帝炎为万火之帝，任何异火靠近皆俯首听令。融合的结果不是新焰，而是帝炎又多了一位臣属。'
        }
      }
      const devour = [x, y].find(f => f.name === '虚无吞炎')
      if (devour) {
        return {
          name: '虚无·吞',
          icon: '🌫️',
          color: 'black',
          grade: '天阶',
          difficulty: 5,
          artFrom: '虚无吞炎',
          desc: '虚无吞炎无形无质，另一朵异火尚未成形便被吞入虚无，只余一缕更凝实的黑焰。'
        }
      }
      const names = [x.name, y.name]
      const hit = FUSE_RULES.find(r => r.pair.every(p => names.indexOf(p) >= 0))
      if (hit) {
        return {
          name: hit.name,
          icon: hit.icon,
          color: hit.color,
          grade: hit.grade,
          difficulty: hit.difficulty,
          desc: hit.desc
        }
      }
      // 兜底：按两火主色混出一朵无名异火
      const lib = ['无名·双色焰', '异火·共生体', '混杂之炎', '短暂的奇迹']
      const pick = lib[Math.floor(Math.random() * lib.length)]
      return {
        name: pick,
        icon: '🔥',
        color: (x.rankNo || 99) < (y.rankNo || 99) ? x.color : y.color,
        grade: '地阶',
        difficulty: 4,
        desc: '两股性质迥异的异火勉强相融，焰色驳杂、气息不稳，虽能短时爆发，却难以长久维持。'
      }
    },
    devour() {
      const x = this.a
      const y = this.b
      const rank = f => (f.rankNo && f.rankNo > 0 ? f.rankNo : 99)
      if (x.id === y.id) {
        return {
          name: '无意义的自噬',
          icon: '🌀',
          color: 'black',
          grade: '—',
          difficulty: 1,
          desc: '吞噬自己只会让斗气陷入死循环，最终连火焰本身都开始溃散。'
        }
      }
      const win = rank(x) <= rank(y) ? x : y
      const lose = win === x ? y : x
      return {
        name: win.name + '·进化',
        icon: win.icon || '🔥',
        color: win.color,
        grade: win.grade,
        difficulty: Math.min(5, (win.difficulty || 3) + 1),
        artFrom: win.name,
        desc: `${win.name}（异火榜第 ${rank(win) === 99 ? '—' : rank(win)}）吞下了${lose.name}，焰体更加凝实，威能暴涨，但那股驳杂气息需要时间炼化。`
      }
    }
  }
}
</script>

<style scoped>
.sim-page { min-height: 100vh; padding-bottom: 30px; }
.head { text-align: center; padding: 38px 20px 6px; }
.head h1 { font-size: 30px; letter-spacing: 12px; color: var(--gold2); font-weight: 800;
  text-shadow: 0 0 24px rgba(212,175,55,.4); }
.slogan { margin-top: 9px; font-size: 12.5px; letter-spacing: 3px; color: var(--muted); }

.board { max-width: 860px; margin: 18px auto 0; padding: 0 20px; }
.mode { display: flex; align-items: center; gap: 8px; padding: 8px; border-radius: 10px;
  border: 1px solid var(--line); background: var(--panel); }
.mode button { height: 32px; padding: 0 20px; border-radius: 7px; cursor: pointer; font-size: 13px;
  letter-spacing: 3px; color: var(--muted); background: transparent; border: 1px solid transparent; }
.mode button.on { color: #1a1206; font-weight: 700;
  background: linear-gradient(90deg, #c99a2e, #f5d76e); }
.mode-tip { margin-left: auto; font-size: 11.5px; color: var(--label); padding-right: 6px; }

.slots { display: grid; grid-template-columns: 1fr 92px 1fr; gap: 12px; align-items: center;
  margin: 22px 0 6px; }
.slot { position: relative; height: 170px; border-radius: 14px; cursor: pointer;
  border: 1px dashed rgba(212,175,55,.3); background: var(--panel);
  display: grid; place-content: center; text-align: center; gap: 6px; transition: .25s; }
.slot:hover { border-color: var(--gold); }
.slot.filled { border-style: solid; border-color: rgba(var(--c-rgb),.5);
  background: radial-gradient(circle at 50% 0%, rgba(var(--c-rgb),.14), transparent 65%), var(--panel);
  box-shadow: inset 0 0 40px rgba(var(--c-rgb),.08); }
.s-plus { font-size: 26px; color: rgba(212,175,55,.45); }
.s-hint { font-size: 12px; color: var(--muted); letter-spacing: 2px; }
.s-icon { position: relative; z-index: 1; font-size: 40px; line-height: 1; margin: 0 auto;
  filter: drop-shadow(0 0 14px rgba(var(--c-rgb),.6)); }
.s-art { position: absolute; inset: 0; z-index: 0; border-radius: 13px; background-size: cover;
  background-position: center 26%; transition: transform .45s ease, opacity .3s;
  filter: saturate(1.06); }
.s-art::after { content: ""; position: absolute; inset: 0; border-radius: 13px;
  background:
    linear-gradient(to bottom, rgba(0,0,0,.3) 0%, rgba(0,0,0,0) 26%, rgba(0,0,0,.12) 62%, rgba(0,0,0,.55) 100%),
    radial-gradient(120% 80% at 50% 0%, rgba(var(--c-rgb),.26), transparent 62%);
  box-shadow: inset 0 0 60px rgba(0,0,0,.3); }
.slot.filled { display: block; overflow: hidden; border-color: rgba(var(--c-rgb),.55); }
.slot.filled:hover .s-art { transform: scale(1.06); filter: saturate(1.16) brightness(1.05); }
.slot .s-foot { position: absolute; z-index: 2; left: 0; right: 0; bottom: 0; padding: 26px 14px 13px;
  text-align: left;
  background: linear-gradient(to top, rgba(0,0,0,.9) 12%, rgba(0,0,0,.62) 55%, rgba(0,0,0,0) 100%); }
.s-name { font-size: 16px; font-weight: 700; color: #fff; letter-spacing: 2px;
  text-shadow: 0 2px 10px rgba(0,0,0,.95), 0 0 18px rgba(var(--c-rgb),.55); }
.s-attr { margin-top: 3px; font-size: 10.5px; letter-spacing: 2px; color: rgba(255,255,255,.66); }
.s-rank { position: absolute; top: 10px; left: 12px; z-index: 2; padding: 3px 9px; border-radius: 999px;
  font-size: 10px; letter-spacing: .5px; color: #fff; font-weight: 700;
  background: rgba(12,10,8,.72); border: 1px solid rgba(var(--c-rgb),.85);
  box-shadow: 0 2px 10px rgba(0,0,0,.45), 0 0 12px rgba(var(--c-rgb),.35);
  backdrop-filter: blur(4px); }
.s-rank::before { content: ""; display: inline-block; width: 5px; height: 5px; border-radius: 50%;
  margin-right: 5px; vertical-align: 1px; background: var(--c-hex);
  box-shadow: 0 0 6px var(--c-hex); }
.s-swap { position: absolute; top: 9px; right: 11px; z-index: 2; padding: 2px 9px; border-radius: 999px;
  font-size: 10px; letter-spacing: 1px; color: #fff; opacity: 0; transform: translateY(-3px);
  background: rgba(0,0,0,.55); border: 1px solid rgba(255,255,255,.28);
  backdrop-filter: blur(4px); transition: .22s; }
.slot.filled:hover .s-swap { opacity: 1; transform: translateY(0); }

/* 白昼：卡片本身是深色图，徽章保持深底白字即可，无需反色 */

.vs { position: relative; text-align: center; font-size: 15px; letter-spacing: 2px;
  color: var(--gold2); }
.vs-orb { position: absolute; left: 50%; top: 50%; width: 10px; height: 10px; border-radius: 50%;
  transform: translate(-50%,-50%); background: #fff;
  box-shadow: 0 0 30px 12px rgba(var(--flame-rgb),.9), 0 0 60px 30px rgba(var(--flame-rgb),.5);
  animation: burst 1.2s ease-out; }
@keyframes burst {
  0% { opacity: 0; width: 6px; height: 6px }
  40% { opacity: 1; width: 16px; height: 16px }
  100% { opacity: 0; width: 90px; height: 90px }
}
.slots.merging .slot.filled { animation: shake .3s ease-in-out infinite; }
@keyframes shake {
  0%,100% { transform: translateX(0) }
  50% { transform: translateX(4px) }
}

.actions { display: flex; gap: 10px; justify-content: center; margin-top: 18px; }
.btn { height: 36px; padding: 0 18px; border-radius: 8px; cursor: pointer; font-size: 13px;
  color: #1a1206; border: none; font-weight: 700; letter-spacing: 2px;
  background: linear-gradient(90deg, #c99a2e, #f5d76e); }
.btn.ghost { background: transparent; color: var(--muted); border: 1px solid rgba(212,175,55,.28); }
.btn.snd { background: transparent; color: var(--muted); border: 1px solid rgba(212,175,55,.28);
  padding: 0 12px; letter-spacing: 0; font-size: 15px; }
.btn.snd:hover { border-color: var(--gold); }
.btn.big { height: 40px; padding: 0 30px; letter-spacing: 4px; }
.btn:disabled { opacity: .5; cursor: default; }

.result { position: relative; margin-top: 26px; padding: 26px 22px; border-radius: 16px;
  text-align: center; border: 1px solid rgba(var(--c-rgb),.45); background: var(--card);
  box-shadow: 0 18px 50px rgba(0,0,0,.45), 0 0 50px rgba(var(--c-rgb),.15);
  animation: cardIn .45s ease both; overflow: hidden; }
.r-glow { position: absolute; inset: -50% -10% auto; height: 200px;
  background: radial-gradient(circle, rgba(var(--c-rgb),.3), transparent 70%); }
.r-art { position: relative; width: 96px; height: 96px; margin: 0 auto; border-radius: 50%;
  background-size: cover; background-position: center 32%;
  border: 2px solid rgba(var(--c-rgb),.6);
  box-shadow: 0 0 34px rgba(var(--c-rgb),.55), inset 0 0 20px rgba(0,0,0,.4);
  animation: rPulse 2.6s ease-in-out infinite; }
@keyframes rPulse {
  0%, 100% { box-shadow: 0 0 26px rgba(var(--c-rgb),.45), inset 0 0 20px rgba(0,0,0,.4) }
  50% { box-shadow: 0 0 46px rgba(var(--c-rgb),.75), inset 0 0 20px rgba(0,0,0,.4) }
}
.r-icon { position: relative; font-size: 46px; filter: drop-shadow(0 0 18px rgba(var(--c-rgb),.7)); }
.result h2 { position: relative; margin-top: 10px; font-size: 24px; letter-spacing: 5px;
  color: var(--c-hex); font-weight: 800; }
.r-desc { position: relative; margin: 12px auto 0; max-width: 560px; font-size: 13px;
  line-height: 1.95; color: var(--sub); }
.r-formula { position: relative; margin-top: 16px; display: flex; align-items: center;
  justify-content: center; gap: 8px; flex-wrap: wrap; font-size: 12.5px; color: var(--muted); }
.r-formula i { font-style: normal; color: var(--gold2); }
.r-res { color: var(--c-hex); font-weight: 700; }
.r-tags { position: relative; margin-top: 14px; display: flex; gap: 16px; justify-content: center;
  font-size: 11.5px; color: var(--label); letter-spacing: 1px; }

.mask { position: fixed; inset: 0; z-index: 92; display: grid; place-items: center; padding: 20px;
  background: rgba(0,0,0,.66); backdrop-filter: blur(4px); }
.picker { width: min(620px, 100%); max-height: 80vh; overflow-y: auto; padding: 18px;
  border-radius: 14px; background: var(--panel-solid); border: 1px solid var(--line); }
.p-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.p-head b { font-size: 14px; color: var(--gold2); letter-spacing: 2px; }
.p-head button { width: 26px; height: 26px; border-radius: 50%; cursor: pointer; font-size: 11px;
  color: var(--muted); background: transparent; border: 1px solid rgba(212,175,55,.25); }
.p-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)); gap: 10px; }
.p-item { position: relative; padding: 10px 10px 11px; border-radius: 10px; cursor: pointer;
  text-align: center; border: 1px solid rgba(212,175,55,.18); background: var(--panel); transition: .2s; }
.p-item:hover { border-color: var(--c-hex); box-shadow: 0 0 16px rgba(var(--c-rgb),.22); transform: translateY(-2px); }
.p-item.used { opacity: .35; pointer-events: none; }
.p-icon { font-size: 22px; }
.p-art { position: relative; height: 72px; border-radius: 7px; background-size: cover;
  background-position: center 32%; border: 1px solid rgba(var(--c-rgb),.3); overflow: hidden; }
.p-art::after { content: ""; position: absolute; inset: 0;
  background: linear-gradient(to top, rgba(0,0,0,.42), transparent 55%),
              radial-gradient(120% 90% at 50% 0%, rgba(var(--c-rgb),.22), transparent 65%); }
.p-name { margin-top: 7px; font-size: 12px; color: var(--txt); }
.p-grade { margin-top: 2px; font-size: 10px; letter-spacing: 1px; color: var(--label); }
.p-rank { position: absolute; top: 6px; right: 8px; font-size: 10px; color: var(--c-hex); }
.foot { text-align: center; margin-top: 30px; font-size: 11.5px; color: var(--label); }

@media (max-width: 640px) {
  .slots { grid-template-columns: 1fr; }
  .vs { padding: 6px 0; }
}
</style>
