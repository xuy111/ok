<template>
  <Teleport to="body">
    <transition name="ltfade">
      <div v-if="show" class="lt" :class="{ reduced: reduced }" @click="finish">
        <canvas ref="cv" class="sparks"></canvas>

        <div class="vortex">
          <svg viewBox="0 0 400 400" aria-hidden="true">
            <circle class="vr1" cx="200" cy="200" r="188" />
            <circle class="vr2" cx="200" cy="200" r="168" />
            <circle class="vr3" cx="200" cy="200" r="140" />
            <g class="ticks">
              <line v-for="n in 36" :key="n"
                :x1="200 + 176 * Math.cos(n * Math.PI / 18)"
                :y1="200 + 176 * Math.sin(n * Math.PI / 18)"
                :x2="200 + (n % 3 === 0 ? 160 : 168) * Math.cos(n * Math.PI / 18)"
                :y2="200 + (n % 3 === 0 ? 160 : 168) * Math.sin(n * Math.PI / 18)" />
            </g>
            <text class="glyph g1" x="200" y="60">帝</text>
            <text class="glyph g2" x="348" y="214">炎</text>
            <text class="glyph g3" x="200" y="356">焚</text>
            <text class="glyph g4" x="52" y="214">天</text>
          </svg>
        </div>

        <div class="core">
          <i class="flame f1"></i>
          <i class="flame f2"></i>
          <i class="flame f3"></i>
          <i class="flame f4"></i>
        </div>

        <div class="words">
          <div class="w-line">三十年河东 · 三十年河西</div>
          <h1 class="w-title">斗破苍穹</h1>
          <div class="w-sub">炎 帝 之 路 · 由 此 启 程</div>
        </div>

        <div class="flash"></div>
        <div class="skip">点击跳过</div>
      </div>
    </transition>
  </Teleport>
</template>

<script>
export default {
  name: 'LoginTransition',
  props: {
    show: { type: Boolean, default: false }
  },
  emits: ['done'],
  data() {
    return {
      reduced: false,
      parts: [],
      raf: 0,
      ctx: null,
      w: 0,
      h: 0,
      cx: 0,
      cy: 0,
      t0: 0,
      duration: 2600,
      audioCtx: null,
      _done: false
    }
  },
  watch: {
    show(v) {
      if (v) this.start()
      else this.stop()
    }
  },
  beforeUnmount() {
    this.stop()
  },
  methods: {
    start() {
      this._done = false
      try {
        this.reduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches
      } catch (e) { this.reduced = false }
      this.duration = this.reduced ? 700 : 2600
      this.$nextTick(() => {
        try { this.initCanvas(); this.loop() } catch (e) { /* 粒子降级 */ }
        try { this.playSound() } catch (e) { /* 音频降级 */ }
      })
      this._timer = setTimeout(() => this.finish(), this.duration)
    },
    stop() {
      clearTimeout(this._timer)
      cancelAnimationFrame(this.raf)
      this.raf = 0
      this.closeAudio()
    },
    finish() {
      if (this._done) return
      this._done = true
      clearTimeout(this._timer)
      this.$emit('done')
    },

    /* ---------- 异火粒子向中心汇聚 ---------- */
    initCanvas() {
      const cv = this.$refs.cv
      if (!cv) return
      const dpr = Math.min(2, window.devicePixelRatio || 1)
      this.w = window.innerWidth
      this.h = window.innerHeight
      cv.width = this.w * dpr
      cv.height = this.h * dpr
      cv.style.width = this.w + 'px'
      cv.style.height = this.h + 'px'
      this.ctx = cv.getContext('2d')
      this.ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
      this.cx = this.w / 2
      this.cy = this.h * 0.44
      if (this.reduced) return
      this.parts = []
      const n = Math.min(180, Math.round(this.w / 7))
      for (let i = 0; i < n; i++) this.parts.push(this.spawn())
    },
    spawn() {
      const a = Math.random() * Math.PI * 2
      const r = Math.max(this.w, this.h) * (0.32 + Math.random() * 0.45)
      const x = this.cx + Math.cos(a) * r
      const y = this.cy + Math.sin(a) * r
      return { x, y, px: x, py: y, r: 0.8 + Math.random() * 2.2, sp: 0.5 + Math.random() * 1.1 }
    },
    loop(ts) {
      if (!this.show || !this.ctx) return
      if (!this.t0) this.t0 = ts || 0
      const el = (ts || 0) - this.t0
      const k = Math.min(1, el / (this.duration * 0.78))
      const ctx = this.ctx
      ctx.clearRect(0, 0, this.w, this.h)
      ctx.globalCompositeOperation = 'lighter'
      const pull = 0.012 + k * 0.06
      for (const p of this.parts) {
        p.px = p.x
        p.py = p.y
        const dx = this.cx - p.x
        const dy = this.cy - p.y
        p.x += dx * pull * p.sp * 0.12
        p.y += dy * pull * p.sp * 0.12
        const dist = Math.hypot(dx, dy)
        if (dist < 6) Object.assign(p, this.spawn())
        const near = 1 - Math.min(1, dist / (this.w * 0.32))
        const alpha = 0.12 + near * 0.75
        ctx.strokeStyle = `rgba(245,215,110,${alpha * 0.55})`
        ctx.lineWidth = p.r * (0.6 + near)
        ctx.beginPath()
        ctx.moveTo(p.px, p.py)
        ctx.lineTo(p.x, p.y)
        ctx.stroke()
        ctx.fillStyle = `rgba(255,240,200,${alpha})`
        ctx.beginPath()
        ctx.arc(p.x, p.y, p.r * (0.5 + near * 0.8), 0, Math.PI * 2)
        ctx.fill()
      }
      ctx.globalAlpha = 1
      ctx.globalCompositeOperation = 'source-over'
      this.raf = requestAnimationFrame(this.loop)
    },

    /* ---------- Web Audio：汇聚上升 + 爆发 ---------- */
    playSound() {
      const AC = window.AudioContext || window.webkitAudioContext
      if (!AC) return
      const ctx = new AC()
      this.audioCtx = ctx
      ctx.resume && ctx.resume()
      const now = ctx.currentTime
      const dur = (this.duration - 300) / 1000

      const buf = ctx.createBuffer(1, Math.ceil(ctx.sampleRate * dur), ctx.sampleRate)
      const d = buf.getChannelData(0)
      for (let i = 0; i < d.length; i++) d[i] = Math.random() * 2 - 1
      const src = ctx.createBufferSource()
      src.buffer = buf
      const bp = ctx.createBiquadFilter()
      bp.type = 'bandpass'
      bp.Q.value = 1.1
      bp.frequency.setValueAtTime(180, now)
      bp.frequency.exponentialRampToValueAtTime(2600, now + dur)
      const g = ctx.createGain()
      g.gain.setValueAtTime(0.0001, now)
      g.gain.exponentialRampToValueAtTime(0.2, now + dur * 0.75)
      g.gain.exponentialRampToValueAtTime(0.0001, now + dur)
      src.connect(bp).connect(g).connect(ctx.destination)
      src.start(now)
      src.stop(now + dur)

      const bt = now + dur - 0.05
      const bbuf = ctx.createBuffer(1, Math.ceil(ctx.sampleRate * 0.9), ctx.sampleRate)
      const bd = bbuf.getChannelData(0)
      for (let i = 0; i < bd.length; i++) bd[i] = Math.random() * 2 - 1
      const bsrc = ctx.createBufferSource()
      bsrc.buffer = bbuf
      const lp = ctx.createBiquadFilter()
      lp.type = 'lowpass'
      lp.frequency.setValueAtTime(1600, bt)
      lp.frequency.exponentialRampToValueAtTime(90, bt + 0.85)
      const bg = ctx.createGain()
      bg.gain.setValueAtTime(0.0001, bt)
      bg.gain.exponentialRampToValueAtTime(0.55, bt + 0.04)
      bg.gain.exponentialRampToValueAtTime(0.0001, bt + 0.85)
      bsrc.connect(lp).connect(bg).connect(ctx.destination)
      bsrc.start(bt)
    },
    closeAudio() {
      const ctx = this.audioCtx
      this.audioCtx = null
      if (ctx) setTimeout(() => { try { ctx.close() } catch (e) {} }, 400)
    }
  }
}
</script>

<style scoped>
.lt {
  position: fixed; inset: 0; z-index: 10000; overflow: hidden; cursor: pointer;
  background: radial-gradient(circle at 50% 44%, #1a1108 0%, #050403 55%, #000 100%);
  user-select: none;
}
.lt::before {
  content: ""; position: absolute; inset: 0; pointer-events: none;
  background: radial-gradient(circle at 50% 44%, rgba(var(--flame-rgb),.14), transparent 46%);
  animation: ltBg 2.6s ease-in-out both;
}
@keyframes ltBg { 0%{opacity:0} 55%{opacity:1} 100%{opacity:.8} }

.sparks { position: absolute; inset: 0; pointer-events: none; }

.vortex {
  position: absolute; left: 50%; top: 44%; width: min(78vmin, 460px); height: min(78vmin, 460px);
  transform: translate(-50%,-50%); pointer-events: none;
  animation: ltVortex 2.4s cubic-bezier(.2,.8,.3,1) both;
}
.vortex svg { width: 100%; height: 100%; overflow: visible; }
.vr1,.vr2,.vr3 { fill: none; stroke: rgba(212,175,55,.4); stroke-width: 1; }
.vr2 { stroke: rgba(212,175,55,.2); stroke-dasharray: 4 9; }
.vr3 { stroke: rgba(var(--flame-rgb),.25); }
.ticks line { stroke: rgba(212,175,55,.3); stroke-width: 1; }
.ticks line:nth-child(3n+1) { stroke: rgba(245,215,110,.6); }
.glyph { fill: rgba(245,215,110,.55); font-size: 17px; font-family: "STKaiti","KaiTi",serif; text-anchor: middle; }
.g2 { dominant-baseline: middle; }
@keyframes ltVortex {
  0%{ opacity:0; transform:translate(-50%,-50%) scale(.7) rotate(-40deg) }
  30%{ opacity:1 }
  100%{ opacity:.9; transform:translate(-50%,-50%) scale(1) rotate(70deg) }
}

.core {
  position: absolute; left: 50%; top: 44%; width: 26vmin; height: 34vmin;
  transform: translate(-50%,-50%); pointer-events: none; mix-blend-mode: screen;
  animation: ltIgnite 1.5s .35s cubic-bezier(.16,.8,.3,1) both;
}
.flame {
  position: absolute; left: 50%; bottom: 0; border-radius: 50% 50% 48% 48% / 64% 64% 36% 36%;
  transform-origin: 50% 88%; filter: blur(5px);
}
.f1 { width:100%; height:100%; left:0; bottom:0;
  background: radial-gradient(ellipse at 50% 78%, rgba(255,252,240,.95), rgba(245,215,110,.7) 28%, rgba(var(--flame-rgb),.2) 58%, transparent 72%);
  animation: s1 1.8s ease-in-out infinite; }
.f2 { width:76%; height:82%; left:12%; bottom:2%;
  background: radial-gradient(ellipse at 50% 74%, rgba(255,255,240,.9), rgba(245,215,110,.9) 30%, rgba(226,84,42,.35) 62%, transparent 76%);
  filter: blur(4px); animation: s2 1.3s ease-in-out infinite; }
.f3 { width:48%; height:62%; left:26%; bottom:5%;
  background: radial-gradient(ellipse at 50% 70%, #fff, rgba(255,245,210,.95) 24%, rgba(245,215,110,.8) 52%, transparent 74%);
  filter: blur(2px); animation: s3 .95s ease-in-out infinite; }
.f4 { width:24%; height:40%; left:38%; bottom:8%;
  background: radial-gradient(ellipse at 50% 66%, #fff, rgba(255,255,235,.9) 38%, rgba(245,215,110,.6) 66%, transparent 80%);
  filter: blur(1px); animation: s4 .7s ease-in-out infinite; }
@keyframes s1{0%,100%{transform:rotate(-4deg) scale(1,1)}50%{transform:rotate(5deg) scale(1.05,.96)}}
@keyframes s2{0%,100%{transform:rotate(6deg) scale(.98,1.04)}50%{transform:rotate(-6deg) scale(1.04,.95)}}
@keyframes s3{0%,100%{transform:rotate(-8deg) scale(1.03,.96)}50%{transform:rotate(7deg) scale(.96,1.06)}}
@keyframes s4{0%,100%{transform:rotate(10deg) scale(.95,1.05)}50%{transform:rotate(-9deg) scale(1.06,.94)}}
@keyframes ltIgnite{0%{opacity:0;transform:translate(-50%,-50%) scale(.3);filter:blur(18px)}60%{opacity:1;filter:blur(0)}100%{opacity:1;transform:translate(-50%,-50%) scale(1)}}

.words {
  position: absolute; left: 0; right: 0; bottom: 13%; text-align: center; padding: 0 18px;
}
.w-line { font-size: 12px; letter-spacing: 7px; color: rgba(245,215,110,.72);
  animation: ltUp .7s 1.0s ease both; }
.w-title {
  margin: 14px 0 12px; font-size: clamp(40px, 8vw, 88px); font-weight: 500; letter-spacing: 18px;
  font-family: "STKaiti","KaiTi","Songti SC",serif; color: #fff6df;
  text-shadow: 0 0 26px rgba(245,215,110,.85), 0 0 70px rgba(var(--flame-rgb),.6);
  animation: ltTitle .9s 1.2s cubic-bezier(.16,.8,.3,1) both;
}
.w-sub { font-size: 12px; letter-spacing: 8px; color: rgba(255,255,255,.5);
  animation: ltUp .8s 1.55s ease both; }
@keyframes ltUp{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:none}}
@keyframes ltTitle{0%{opacity:0;letter-spacing:42px;filter:blur(12px)}100%{opacity:1;letter-spacing:18px;filter:blur(0)}}

.flash {
  position: absolute; inset: 0; pointer-events: none; background: #fff6e6; opacity: 0;
  animation: ltFlash .55s 2.05s ease-in both;
}
@keyframes ltFlash{0%{opacity:0}18%{opacity:.92}100%{opacity:0}}

.skip { position: absolute; right: 24px; bottom: 20px; font-size: 11px; letter-spacing: 2px;
  color: rgba(255,255,255,.3); animation: ltUp .6s 1.8s ease both; }

.ltfade-enter-active { transition: opacity .35s ease; }
.ltfade-leave-active { transition: opacity .5s ease; }
.ltfade-enter-from, .ltfade-leave-to { opacity: 0; }

.lt.reduced .sparks, .lt.reduced .vortex, .lt.reduced .core,
.lt.reduced .flame, .lt.reduced .words > *, .lt.reduced .flash { animation-duration: .5s !important; animation-delay: 0s !important; }
@media (max-width: 640px) {
  .w-title { letter-spacing: 9px; }
  .w-line, .w-sub { letter-spacing: 4px; }
}
</style>
