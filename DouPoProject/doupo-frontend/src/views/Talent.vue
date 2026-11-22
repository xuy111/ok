<template>
  <div class="talent-page light-scope">
    <div class="embers">
      <span v-for="i in 30" :key="i" class="ember"
        :style="{ left: embers[i-1].left, animationDuration: embers[i-1].dur, animationDelay: embers[i-1].delay, opacity: embers[i-1].op }"></span>
    </div>

    <div class="topbar">
      <button class="back" @click="goBack">{{ backText }}</button>
      <div class="brand-mini"><i>斗</i>斗气大陆 · 天赋鉴定所</div>
    </div>

    <!-- ============ 1. 封面 ============ -->
    <section v-if="stage === 'intro'" class="stage wrap-intro">
      <div class="intro-seal"><span>鉴</span></div>
      <h1>灵魂力天赋测试</h1>
      <p class="slogan">五道情境 · 定你的属性与道途</p>

      <div class="intro-card">
        <p>斗气大陆上，每个人生来魂力不同。</p>
        <p>有人魂力温润，天生能辨药性；有人斗气暴烈，一动手就收不住。</p>
        <p class="dim">回答下面 5 个情境问题，测出你的<em>初始天赋</em>，并生成一张专属的<em>斗气大陆身份证</em>。</p>
        <div class="meta-row">
          <span>❖ 约 1 分钟</span>
          <span>❖ 5 道情境题</span>
          <span>❖ 无对错</span>
        </div>
      </div>

      <button class="btn-gold" @click="start">点击测试你的初始天赋</button>
      <p class="tip-line">测完可作为账号头像，注册时会一并保存</p>
    </section>

    <!-- ============ 2. 答题 ============ -->
    <section v-else-if="stage === 'quiz'" class="stage wrap-quiz">
      <div class="progress">
        <div class="pg-dots">
          <i v-for="(q, i) in questions" :key="q.id"
             :class="{ on: i < answers.length, cur: i === answers.length }"></i>
        </div>
        <span class="pg-text">{{ answers.length + 1 }} / {{ questions.length }}</span>
      </div>

      <transition name="q-slide" mode="out-in">
        <div class="q-box" :key="current.id">
          <div class="q-scene">{{ current.scene }}</div>
          <p class="q-hint">{{ current.hint }}</p>

          <div class="opts">
            <button v-for="o in current.options" :key="o.key" class="opt" @click="choose(o)">
              <span class="opt-key">{{ o.key }}</span>
              <span class="opt-body">
                <b>{{ o.label }}</b>
                <i>{{ o.desc }}</i>
              </span>
            </button>
          </div>
        </div>
      </transition>

      <div class="quiz-foot">
        <button class="btn-ghost" :disabled="answers.length === 0" @click="prev">上一题</button>
        <span class="quiz-tip">凭第一感觉选，别想太多</span>
      </div>
    </section>

    <!-- ============ 3. 结果 + 身份证 ============ -->
    <section v-else class="stage wrap-result">
      <div class="result-head">
        <p class="rh-sub">魂力鉴定完毕</p>
        <h1 :style="{ color: result.tone }">{{ result.title }}</h1>
        <p class="rh-role">{{ result.role }} · {{ result.rank }}</p>
      </div>

      <!-- 身份证 -->
      <div class="cert" :class="{ flip: flipping }" :style="{ '--tone': result.tone }" ref="certEl">
        <div class="cert-inner">
          <div class="cert-front">
            <div class="cert-top">
              <div class="cert-emblem">斗</div>
              <div class="cert-title">
                <b>斗气大陆身份证</b>
                <i>DOU QI CONTINENT · SOUL ID</i>
              </div>
              <div class="cert-no">{{ certNo }}</div>
            </div>

            <div class="cert-body">
              <div class="cert-seal" :style="{ borderColor: result.tone }">
                <span class="seal-char">{{ axisChar }}</span>
                <em class="seal-sub">{{ result.rank }}</em>
              </div>

              <div class="cert-fields">
                <div class="cf"><label>天赋</label><b :style="{ color: result.tone }">{{ result.title }}</b></div>
                <div class="cf"><label>身份</label><span>{{ result.role }}</span></div>
                <div class="cf"><label>魂力</label><b class="num">{{ result.score }}</b><em class="stars">{{ '★'.repeat(result.stars) }}{{ '☆'.repeat(5 - result.stars) }}</em></div>
                <div class="cf"><label>副属性</label><span>{{ result.subAxisName }} · 亲和</span></div>
                <div class="cf"><label>适用异火</label><span>{{ result.fire }}</span></div>
              </div>
            </div>

            <div class="cert-stats">
              <div v-for="(v, k) in result.stats" :key="k" class="stat">
                <span>{{ k }}</span>
                <div class="bar"><i :style="{ width: (v * 10) + '%', background: result.tone }"></i></div>
                <em>{{ v }}</em>
              </div>
            </div>

            <div class="cert-verdict">「{{ result.verdict }}」</div>

            <div class="cert-bottom">
              <span>发放：斗气大陆天赋鉴定所</span>
              <span>{{ todayText }}</span>
            </div>
          </div>
        </div>
      </div>

      <p class="result-desc">{{ result.desc }}</p>

      <div class="axis-chart">
        <div v-for="a in result.axisLabels" :key="a.key" class="ax">
          <span class="ax-name" :style="{ color: a.tone }">{{ a.name }}</span>
          <div class="ax-bar"><i :style="{ width: a.percent + '%', background: a.tone }"></i></div>
        </div>
      </div>

      <div class="acts">
        <button class="btn-gold" @click="saveOrRegister">{{ saveLabel }}</button>
        <button class="btn-ghost" @click="restart">再测一次</button>
        <button class="btn-ghost" @click="downloadCert">保存身份证</button>
      </div>
      <p class="saved-msg" v-if="savedMsg">{{ savedMsg }}</p>
    </section>
  </div>
</template>

<script>
import { QUESTIONS, evaluate, makeCertNo, AXES } from '../talent'
import api from '../api'
import { store, loadProfile } from '../store'

export default {
  name: 'Talent',
  data() {
    const arr = []
    for (let i = 0; i < 30; i++) {
      arr.push({
        left: (Math.random() * 100) + '%',
        dur: (5 + Math.random() * 8) + 's',
        delay: (Math.random() * 8) + 's',
        op: Math.random() * .6 + .2
      })
    }
    return {
      stage: 'intro',
      questions: QUESTIONS,
      answers: [],
      result: null,
      certNo: '',
      flipping: false,
      savedMsg: '',
      embers: arr
    }
  },
  computed: {
    current() {
      return this.questions[Math.min(this.answers.length, this.questions.length - 1)]
    },
    loggedIn() {
      return !!(store.user && store.user.token)
    },
    axisChar() {
      if (!this.result) return '斗'
      const found = Object.keys(AXES).find(k => this.result.title.indexOf(AXES[k].full) === 0)
      return found ? AXES[found].name : '斗'
    },
    backText() {
      return this.loggedIn ? '返回图鉴' : '返回登录'
    },
    saveLabel() {
      if (this.loggedIn) return '用作我的头像 / 天赋'
      return '带着天赋去注册'
    },
    todayText() {
      const d = new Date()
      const p = n => String(n).padStart(2, '0')
      return `${d.getFullYear()}.${p(d.getMonth() + 1)}.${p(d.getDate())}`
    }
  },
  created() {
    // 已测过且登录了：直接显示上次结果，方便回看身份证
    const cached = this.readCache()
    if (cached) {
      this.result = cached
      this.certNo = cached.certNo || makeCertNo()
      this.stage = 'result'
    }
  },
  methods: {
    readCache() {
      try {
        return JSON.parse(localStorage.getItem('doupo_talent') || 'null')
      } catch (e) {
        return null
      }
    },
    start() {
      this.answers = []
      this.stage = 'quiz'
    },
    choose(opt) {
      this.answers.push(opt)
      if (this.answers.length >= this.questions.length) {
        this.finish()
      }
    },
    prev() {
      if (this.answers.length > 0) this.answers.pop()
    },
    finish() {
      this.result = evaluate(this.answers)
      this.certNo = makeCertNo()
      this.result.certNo = this.certNo
      this.result.at = Date.now()
      localStorage.setItem('doupo_talent', JSON.stringify(this.result))
      this.stage = 'result'
      // 揭晓时给身份证一个翻牌动效
      this.flipping = true
      window.setTimeout(() => { this.flipping = false }, 900)
    },
    restart() {
      this.savedMsg = ''
      this.answers = []
      this.stage = 'quiz'
    },
    goBack() {
      this.$router.push(this.loggedIn ? '/home' : '/login')
    },
    async saveOrRegister() {
      // 未登录：把结果缓存后带去注册页，注册时一并提交
      if (!this.loggedIn) {
        this.$router.push({ path: '/register', query: { talent: '1' } })
        return
      }
      try {
        await api.saveTalent({
          talent: this.result.title,
          talentRank: this.result.rank,
          talentScore: String(this.result.score)
        })
        await loadProfile()
        this.savedMsg = '已把天赋设为你的账号头像'
      } catch (e) {
        this.savedMsg = e.message
      }
    },
    async downloadCert() {
      const el = this.certEl || this.$refs.certEl
      if (!el) return
      try {
        // 固定宽度重绘再用 SVG foreignObject 不行（外部样式会丢），
        // 这里退化为浏览器打印对话框，用户可直接「另存为 PDF」或截图
        this.flipping = false
        window.print()
      } catch (e) {
        this.savedMsg = '请直接截图保存'
      }
    }
  }
}
</script>

<style scoped>
.talent-page{ min-height:100vh; position:relative; overflow:hidden; padding-bottom:60px; }
.embers{ position:absolute; inset:0; overflow:hidden; pointer-events:none; }
.ember{ position:absolute; bottom:-20px; width:3px; height:3px; border-radius:50%; background:var(--flame2);
  box-shadow:0 0 8px 2px var(--flame); animation:rise linear infinite; }
@keyframes rise{ 0%{ transform:translateY(0) scale(1); opacity:.8 } 100%{ transform:translateY(-110vh) scale(.2); opacity:0 } }

.topbar{ position:relative; z-index:3; max-width:900px; margin:0 auto; padding:20px;
  display:flex; align-items:center; justify-content:space-between; }
.back{ height:32px; padding:0 14px; border-radius:7px; cursor:pointer; font-size:12.5px;
  color:var(--muted); background:transparent; border:1px solid rgba(212,175,55,.26); }
.back:hover{ color:var(--gold2); border-color:var(--gold); }
.brand-mini{ display:flex; align-items:center; gap:8px; font-size:12px; letter-spacing:2px; color:#a8926b; }
.brand-mini i{ width:22px; height:22px; border-radius:5px; display:grid; place-items:center;
  font-style:normal; font-size:12px; font-weight:800; color:#1a1206;
  background:linear-gradient(145deg,#c99a2e,#f5d76e); }

.stage{ position:relative; z-index:2; max-width:900px; margin:0 auto; padding:0 20px; }

/* ---------------- 封面 ---------------- */
.wrap-intro{ text-align:center; padding-top:26px; }
.intro-seal{ width:84px; height:84px; margin:0 auto 22px; border-radius:50%;
  display:grid; place-items:center; border:1.5px solid rgba(212,175,55,.45);
  background:radial-gradient(circle, rgba(212,175,55,.16), transparent 70%);
  box-shadow:0 0 40px rgba(212,175,55,.2); animation:sealPulse 3.4s ease-in-out infinite; }
.intro-seal span{ font-size:34px; font-weight:800; color:var(--gold2); letter-spacing:2px; }
@keyframes sealPulse{ 0%,100%{ transform:scale(1) } 50%{ transform:scale(1.05) } }
.wrap-intro h1{ font-size:30px; letter-spacing:10px; color:var(--gold2); font-weight:800;
  text-shadow:0 0 26px rgba(212,175,55,.45); }
.slogan{ margin-top:10px; font-size:12.5px; letter-spacing:4px; color:var(--muted); }

.intro-card{ max-width:560px; margin:28px auto 0; padding:24px 26px; border-radius:14px;
  border:1px solid var(--line); background:var(--panel); text-align:left;
  box-shadow:0 14px 40px rgba(0,0,0,.35); }
.intro-card p{ font-size:13.5px; line-height:2; color:var(--sub); }
.intro-card .dim{ margin-top:12px; color:var(--muted); }
.intro-card em{ font-style:normal; color:var(--gold2); }
.meta-row{ margin-top:16px; padding-top:14px; border-top:1px dashed rgba(212,175,55,.2);
  display:flex; gap:18px; flex-wrap:wrap; font-size:11.5px; color:var(--label); }

.btn-gold{ margin-top:26px; height:48px; padding:0 40px; border:none; border-radius:9px; cursor:pointer;
  font-size:15px; letter-spacing:4px; font-weight:700; color:#1a1206;
  background:linear-gradient(90deg,#c99a2e,#f5d76e,#c99a2e);
  box-shadow:0 8px 26px rgba(212,175,55,.32); transition:.25s; }
.btn-gold:hover{ filter:brightness(1.1); transform:translateY(-1px); }
.btn-ghost{ height:40px; padding:0 22px; border-radius:8px; cursor:pointer; font-size:13px;
  color:var(--muted); background:transparent; border:1px solid rgba(212,175,55,.26); transition:.2s; }
.btn-ghost:hover:not(:disabled){ color:var(--gold2); border-color:var(--gold); }
.btn-ghost:disabled{ opacity:.4; cursor:not-allowed; }
.tip-line{ margin-top:14px; font-size:11.5px; color:var(--label); letter-spacing:1px; }

/* ---------------- 答题 ---------------- */
.wrap-quiz{ max-width:700px; }
.progress{ display:flex; align-items:center; gap:14px; margin:6px 0 24px; }
.pg-dots{ display:flex; gap:7px; }
.pg-dots i{ width:26px; height:4px; border-radius:2px; background:rgba(212,175,55,.18); transition:.3s; }
.pg-dots i.on{ background:var(--gold); box-shadow:0 0 10px rgba(212,175,55,.5); }
.pg-dots i.cur{ background:rgba(212,175,55,.5); }
.pg-text{ margin-left:auto; font-size:12px; color:var(--label); letter-spacing:1px; }

.q-box{ }
.q-scene{ font-size:19px; line-height:1.85; color:var(--text); font-weight:600; letter-spacing:.5px; }
.q-hint{ margin-top:8px; font-size:12.5px; color:var(--muted); letter-spacing:1px; }
.opts{ margin-top:24px; display:grid; gap:12px; }
.opt{ display:flex; gap:14px; align-items:flex-start; width:100%; padding:16px 18px;
  border-radius:11px; cursor:pointer; text-align:left;
  border:1px solid rgba(212,175,55,.2); background:var(--panel); transition:.22s; }
.opt:hover{ border-color:var(--gold); background:rgba(212,175,55,.06); transform:translateX(3px); }
.opt-key{ flex-shrink:0; width:26px; height:26px; border-radius:50%; display:grid; place-items:center;
  font-size:12px; font-weight:800; color:var(--gold2);
  border:1px solid rgba(212,175,55,.4); background:rgba(212,175,55,.08); }
.opt:hover .opt-key{ color:#1a1206; background:linear-gradient(145deg,#c99a2e,#f5d76e); border-color:transparent; }
.opt-body{ display:flex; flex-direction:column; gap:4px; }
.opt-body b{ font-size:14.5px; color:var(--text); font-weight:600; letter-spacing:.5px; }
.opt-body i{ font-size:12px; color:var(--muted); font-style:normal; line-height:1.7; }

.quiz-foot{ margin-top:26px; display:flex; align-items:center; gap:16px; }
.quiz-tip{ font-size:11.5px; color:var(--label); }

.q-slide-enter-active,.q-slide-leave-active{ transition:all .28s ease; }
.q-slide-enter-from{ opacity:0; transform:translateX(24px); }
.q-slide-leave-to{ opacity:0; transform:translateX(-24px); }

/* ---------------- 结果 ---------------- */
.wrap-result{ text-align:center; }
.result-head{ margin-top:10px; }
.rh-sub{ font-size:11.5px; letter-spacing:5px; color:var(--label); }
.result-head h1{ margin-top:12px; font-size:29px; letter-spacing:5px; font-weight:800;
  text-shadow:0 0 30px currentColor; }
.rh-role{ margin-top:9px; font-size:12.5px; letter-spacing:3px; color:var(--muted); }

/* 身份证 */
.cert{ max-width:560px; margin:26px auto 0; perspective:1200px; }
.cert-inner{ transform-style:preserve-3d; transition:transform .9s cubic-bezier(.2,.8,.3,1); }
.cert.flip .cert-inner{ animation:cardIn .9s cubic-bezier(.2,.8,.3,1); }
@keyframes cardIn{
  0%{ transform:rotateY(-90deg) scale(.92); opacity:0 }
  100%{ transform:rotateY(0) scale(1); opacity:1 }
}
.cert-front{ position:relative; padding:20px 22px 16px; border-radius:14px; text-align:left;
  background:linear-gradient(150deg, rgba(34,27,20,.98), rgba(15,12,10,.99));
  border:1px solid rgba(212,175,55,.38);
  box-shadow:0 20px 60px rgba(0,0,0,.6), inset 0 0 60px rgba(212,175,55,.05),
             0 0 44px color-mix(in srgb, var(--tone) 18%, transparent); }
.cert-front::before,.cert-front::after{ content:""; position:absolute; width:22px; height:22px;
  border:2px solid color-mix(in srgb, var(--tone) 65%, transparent); }
.cert-front::before{ top:-1px; left:-1px; border-right:none; border-bottom:none; border-radius:14px 0 0 0; }
.cert-front::after{ bottom:-1px; right:-1px; border-left:none; border-top:none; border-radius:0 0 14px 0; }

.cert-top{ display:flex; align-items:center; gap:12px; padding-bottom:14px;
  border-bottom:1px solid rgba(212,175,55,.16); }
.cert-emblem{ width:34px; height:34px; flex-shrink:0; border-radius:7px; display:grid; place-items:center;
  font-size:17px; font-weight:800; color:#1a1206;
  background:linear-gradient(145deg,#c99a2e,#f5d76e); }
.cert-title b{ display:block; font-size:14px; letter-spacing:3px; color:var(--gold2); }
.cert-title i{ display:block; margin-top:3px; font-size:9px; letter-spacing:1.6px; color:#7d6c50; font-style:normal; }
.cert-no{ margin-left:auto; font-size:10px; letter-spacing:1px; color:#8c7a5c; font-family:Consolas,monospace; }

.cert-body{ display:flex; gap:18px; padding:18px 0 12px; }
.cert-seal{ width:96px; height:96px; flex-shrink:0; border-radius:10px; display:flex;
  flex-direction:column; align-items:center; justify-content:center; gap:2px;
  border:2px solid; background:radial-gradient(circle at 50% 40%,
    color-mix(in srgb, var(--tone) 24%, transparent), transparent 72%);
  box-shadow:inset 0 0 26px color-mix(in srgb, var(--tone) 16%, transparent); }
.seal-char{ font-size:40px; font-weight:800; color:var(--tone); line-height:1;
  text-shadow:0 0 18px color-mix(in srgb, var(--tone) 60%, transparent); }
.seal-sub{ font-size:10px; font-style:normal; letter-spacing:2px; color:#b9a67e; }

.cert-fields{ flex:1; display:grid; gap:9px; }
.cf{ display:flex; align-items:center; gap:10px; font-size:12.5px; flex-wrap:wrap; }
.cf label{ width:56px; flex-shrink:0; font-size:10.5px; letter-spacing:1px; color:#8c7a5c; }
.cf b{ font-size:14px; letter-spacing:1px; }
.cf span{ color:#e6d9bd; }
.cf .num{ font-size:15px; font-weight:700; color:var(--gold2); margin-right:-2px; }
.cf .stars{ font-style:normal; font-size:10px; letter-spacing:1px; color:var(--gold2);
  opacity:.85; white-space:nowrap; }

.cert-stats{ display:grid; gap:7px; padding:12px 0; border-top:1px dashed rgba(212,175,55,.16); }
.stat{ display:flex; align-items:center; gap:10px; font-size:11px; color:#9c8a68; }
.stat span{ width:32px; flex-shrink:0; letter-spacing:1px; }
.stat .bar{ flex:1; height:4px; border-radius:2px; background:rgba(255,255,255,.07); overflow:hidden; }
.stat .bar i{ display:block; height:100%; border-radius:2px; transition:width .8s ease; }
.stat em{ width:16px; text-align:right; font-style:normal; color:#c8b894; }

.cert-verdict{ padding:10px 0 0; font-size:12.5px; letter-spacing:2px; color:#b9a67e; text-align:center;
  border-top:1px dashed rgba(212,175,55,.16); }
.cert-bottom{ margin-top:12px; padding-top:10px; display:flex; justify-content:space-between;
  font-size:9.5px; letter-spacing:1px; color:#6b5c44;
  border-top:1px solid rgba(212,175,55,.12); }

.result-desc{ max-width:560px; margin:22px auto 0; font-size:13px; line-height:2;
  color:var(--sub); text-align:left; }

.axis-chart{ max-width:560px; margin:20px auto 0; display:grid; gap:8px; }
.ax{ display:flex; align-items:center; gap:10px; }
.ax-name{ width:52px; flex-shrink:0; font-size:11.5px; letter-spacing:1px; text-align:left; }
.ax-bar{ flex:1; height:6px; border-radius:3px; background:rgba(255,255,255,.06); overflow:hidden; }
.ax-bar i{ display:block; height:100%; border-radius:3px; transition:width .9s ease; opacity:.85; }

.acts{ margin-top:28px; display:flex; gap:12px; justify-content:center; flex-wrap:wrap; }
.acts .btn-gold{ margin-top:0; height:44px; }
.saved-msg{ margin-top:14px; font-size:12px; color:#7fd6a0; }

@media (max-width: 640px){
  .wrap-intro h1{ font-size:23px; letter-spacing:6px; }
  .result-head h1{ font-size:22px; letter-spacing:2px; }
  .cert-body{ flex-direction:column; align-items:center; }
  .cert-fields{ width:100%; }
  .q-scene{ font-size:16.5px; }
  .meta-row{ gap:10px; }
}
@media print{
  .topbar,.embers,.acts,.axis-chart,.result-desc,.saved-msg{ display:none !important; }
  .cert{ box-shadow:none; }
}
</style>

<style>
/* 身份证白昼皮肤：米白证件纸。
   之前这段放在 scoped 块里，用 :global(body.light) :global(.light-scope) .xxx 连写，
   实测编译后两个 :global 被并成复合选择器、匹配不上，整段规则静默失效
   （症状：白昼模式下身份证仍是黑底金字）。
   改为独立的非 scoped 块，用 .light-scope 前缀把作用域限定在本组件内；
   选择器 body.light .light-scope .xxx 优先级 0,3,1，高于 scoped 的 .xxx[data-v] 0,2,0，
   因此不必依赖 :deep / !important 也能稳定覆盖。 */
body.light .light-scope .cert-front { background:linear-gradient(150deg,#fffdf6,#f2e9d6);
  border-color:rgba(140,110,30,.42);
  box-shadow:0 18px 44px rgba(80,60,20,.16), inset 0 0 50px rgba(212,175,55,.07); }
body.light .light-scope .cert-top { border-bottom-color:rgba(140,110,30,.18); }
body.light .light-scope .cert-title b { color:#8a6a12; }
body.light .light-scope .cert-title i,
body.light .light-scope .cert-no,
body.light .light-scope .seal-sub,
body.light .light-scope .cf label,
body.light .light-scope .cert-bottom { color:#8a7c66; }
body.light .light-scope .cf span { color:#403525; }
/* 天赋名是模板内联 :style="{color:result.tone}"，只有 !important 压得过内联亮色，
   否则亮绿 / 亮橙在米白纸上几乎看不清 */
body.light .light-scope .cf b { color:#5a4310 !important; }
body.light .light-scope .cf .num { color:#8a6a12; }
body.light .light-scope .cert-stats,
body.light .light-scope .cert-verdict { border-top-color:rgba(140,110,30,.2); }
body.light .light-scope .stat { color:#7a6c56; }
body.light .light-scope .stat .bar { background:rgba(120,95,40,.12); }
body.light .light-scope .stat em { color:#5a4a30; }
body.light .light-scope .cert-verdict { color:#6b5638; }
body.light .light-scope .rh-sub { color:#8a7c66; }
body.light .light-scope .result-desc { color:#4a3f2e; }
body.light .light-scope .ax-bar { background:rgba(120,95,40,.12); }
body.light .light-scope .intro-card,
body.light .light-scope .opt { background:#fffdf7; }
body.light .light-scope .q-scene { color:#2c2418; }
/* 印章大字沿用属性色但压深，避免米白纸上发飘 */
body.light .light-scope .seal-char { color:color-mix(in srgb, var(--tone, #b98a52) 55%, #2e2410);
  text-shadow:none; }
/* 主标题 / 五行轴标签用的是内联主题亮色，白昼在米白背景上偏淡：
   不改色相，只压亮度并去掉发光阴影，既提对比度又保留五行属性色的区分 */
body.light .light-scope .result-head h1 { filter:brightness(.6) saturate(1.05); text-shadow:none; }
body.light .light-scope .ax-name { filter:brightness(.58) saturate(1.05); }
</style>
