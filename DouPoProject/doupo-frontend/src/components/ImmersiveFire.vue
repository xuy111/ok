<template>
  <Teleport to="body">
    <transition name="immfade">
      <div v-if="show" class="imm" :style="fireStyle" @click="close">
        <div class="grain"></div>
        <div class="halo"></div>
        <div class="ground"></div>

        <canvas ref="cv" class="fx"></canvas>

        <div class="core">
          <i class="flame f1"></i>
          <i class="flame f2"></i>
          <i class="flame f3"></i>
          <i class="flame f4"></i>
        </div>

        <button class="sound" @click.stop="toggleSound" :title="muted ? '开启音效' : '静音'">
          <span class="spk" :class="{ off: muted }"></span>
          <span class="sound-txt">{{ muted ? '已静音' : '音效开' }}</span>
        </button>

        <div class="top">
          <span class="rule"></span>
          <span class="top-label">异火图鉴 · 观火</span>
          <span class="rule"></span>
          <div class="rank" v-if="item.rankNo > 0">异火榜 第 {{ item.rankNo }} 位 &nbsp;·&nbsp; {{ item.grade }}</div>
          <div class="rank" v-else>{{ item.grade }} &nbsp;·&nbsp; {{ item.category }}</div>
        </div>

        <div class="bottom">
          <h1 class="name">{{ item.name }}</h1>
          <div class="divider"><i></i><span>✦</span><i></i></div>
          <p class="quote">{{ quote }}</p>
          <p class="tip">轻触任意处 · 或按 ESC 离火</p>
        </div>
      </div>
    </transition>
  </Teleport>
</template>

<script>
import { colorOf } from '../theme'

export default {
  name: 'ImmersiveFire',
  props: {
    show: { type: Boolean, default: false },
    item: { type: Object, default: () => ({}) }
  },
  emits: ['close'],
  data() {
    return {
      muted: false,
      particles: [],
      raf: 0,
      w: 0,
      h: 0,
      dpr: 1,
      audioCtx: null,
      noiseGain: null,
      crackTimer: null,
      sprites: null,
      last: 0
    }
  },
  computed: {
    color() {
      return colorOf(this.item && this.item.color)
    },
    fireStyle() {
      return {
        '--fire': this.color.hex,
        '--fire-d': this.color.dim,
        '--fire-rgb': this.color.rgb
      }
    },
    quote() {
      return this.item.quote || this.item.formDesc || '天地灵物，焚尽八荒，得之者可将山河化为灰烬。'
    }
  },
  watch: {
    show(v) {
      if (v) this.enter()
      else this.leave()
    }
  },
  beforeUnmount() {
    this.leave()
  },
  methods: {
    enter() {
      this.$nextTick(() => {
        this.initCanvas()
        this.initAudio()
        this.loop(0)
      })
      document.addEventListener('keydown', this.onKey)
      this._prevOverflow = document.body.style.overflow
      document.body.style.overflow = 'hidden'
    },
    leave() {
      cancelAnimationFrame(this.raf)
      this.raf = 0
      document.removeEventListener('keydown', this.onKey)
      if (this._prevOverflow !== undefined) document.body.style.overflow = this._prevOverflow
      this.stopAudio()
      this.particles = []
    },
    onKey(e) {
      if (e.key === 'Escape') this.close()
    },
    close() {
      this.$emit('close')
    },
    toggleSound() {
      this.muted = !this.muted
      if (this.noiseGain && this.audioCtx) {
        const t = this.audioCtx.currentTime
        this.noiseGain.gain.cancelScheduledValues(t)
        this.noiseGain.gain.linearRampToValueAtTime(this.muted ? 0 : 0.16, t + 0.15)
      }
    },

    /* ---------- Canvas 火焰粒子 ---------- */
    initCanvas() {
      const cv = this.$refs.cv
      if (!cv) return
      this.sprites = null
      const resize = () => {
        this.dpr = Math.min(2, window.devicePixelRatio || 1)
        this.w = window.innerWidth
        this.h = window.innerHeight
        cv.width = this.w * this.dpr
        cv.height = this.h * this.dpr
        cv.style.width = this.w + 'px'
        cv.style.height = this.h + 'px'
        this.ctx = cv.getContext('2d')
        this.ctx.setTransform(this.dpr, 0, 0, this.dpr, 0, 0)
        if (!this.sprites) this.sprites = this.makeSprites()
      }
      resize()
      this._resize = resize
      window.addEventListener('resize', resize)
      this.particles = []
      const n = Math.min(210, Math.round(this.w / 6))
      for (let i = 0; i < n; i++) this.particles.push(this.spawn(true))
    },
    makeSprites() {
      const make = (rgb, hot) => {
        const c = document.createElement('canvas')
        c.width = c.height = 64
        const g = c.getContext('2d')
        const grd = g.createRadialGradient(32, 32, 0, 32, 32, 32)
        if (hot) {
          grd.addColorStop(0, 'rgba(255,255,250,1)')
          grd.addColorStop(0.28, 'rgba(255,240,205,0.92)')
          grd.addColorStop(0.6, `rgba(${rgb},0.55)`)
        } else {
          grd.addColorStop(0, `rgba(255,255,235,0.95)`)
          grd.addColorStop(0.25, `rgba(${rgb},0.9)`)
          grd.addColorStop(1, `rgba(${rgb},0)`)
        }
        g.fillStyle = grd
        g.fillRect(0, 0, 64, 64)
        return c
      }
      return { hot: make(this.color.rgb, true), main: make(this.color.rgb, false) }
    },
    spawn(init) {
      const spark = Math.random() < 0.22
      const cx = this.w / 2
      const baseY = this.h * 0.7
      const life = spark ? 70 + Math.random() * 110 : 46 + Math.random() * 66
      return {
        spark,
        x: cx + (Math.random() - 0.5) * (spark ? 140 : Math.max(60, this.w * 0.07)),
        y: init ? baseY - Math.random() * this.h * 0.34 : baseY + Math.random() * 16,
        vx: spark ? (Math.random() - 0.5) * 2.4 : (Math.random() - 0.5) * 0.7,
        vy: spark ? -(1.6 + Math.random() * 3.4) : -(1.1 + Math.random() * 2.4),
        life: init ? Math.random() * life * 0.8 : 0,
        max: life,
        r: spark ? 1.4 + Math.random() * 2.6 : 12 + Math.random() * 26,
        ph: Math.random() * Math.PI * 2,
        ws: 0.02 + Math.random() * 0.05
      }
    },
    loop() {
      if (!this.show || !this.ctx) return
      const ctx = this.ctx
      ctx.clearRect(0, 0, this.w, this.h)
      ctx.globalCompositeOperation = 'lighter'
      const list = this.particles
      for (let i = 0; i < list.length; i++) {
        let p = list[i]
        p.life += 1
        p.ph += p.ws
        p.x += p.vx + Math.sin(p.ph) * (p.spark ? 0.7 : 0.45)
        p.y += p.vy
        p.vy *= 0.992
        if (!p.spark) p.vx *= 0.99
        const t = p.life / p.max
        if (t >= 1 || p.y < -40) {
          list[i] = this.spawn(false)
          continue
        }
        const fade = p.spark ? Math.min(1, (1 - t) * 1.6) : Math.sin(Math.min(1, t * 1.15) * Math.PI) * (1 - t * 0.35)
        const size = p.spark ? p.r * (1 - t * 0.5) : p.r * (0.55 + (1 - t) * 0.75)
        ctx.globalAlpha = Math.max(0, fade) * (p.spark ? 0.95 : 0.8)
        const sprite = t < 0.24 ? this.sprites.hot : this.sprites.main
        ctx.drawImage(sprite, p.x - size, p.y - size, size * 2, size * 2)
      }
      ctx.globalAlpha = 1
      ctx.globalCompositeOperation = 'source-over'
      this.raf = requestAnimationFrame(this.loop)
    },

    /* ---------- Web Audio 实时合成燃烧声 ---------- */
    initAudio() {
      try {
        const AC = window.AudioContext || window.webkitAudioContext
        if (!AC) return
        const ctx = new AC()
        this.audioCtx = ctx
        ctx.resume && ctx.resume()

        const sec = 2
        const buf = ctx.createBuffer(1, ctx.sampleRate * sec, ctx.sampleRate)
        const d = buf.getChannelData(0)
        let last = 0
        for (let i = 0; i < d.length; i++) {
          const white = Math.random() * 2 - 1
          last = (last + 0.02 * white) / 1.02
          d[i] = last * 3.2
        }
        const src = ctx.createBufferSource()
        src.buffer = buf
        src.loop = true
        const lp = ctx.createBiquadFilter()
        lp.type = 'lowpass'
        lp.frequency.value = 560
        const hp = ctx.createBiquadFilter()
        hp.type = 'highpass'
        hp.frequency.value = 60
        const gain = ctx.createGain()
        gain.gain.value = 0
        src.connect(hp).connect(lp).connect(gain).connect(ctx.destination)
        src.start()
        this.noiseGain = gain
        if (!this.muted) gain.gain.linearRampToValueAtTime(0.16, ctx.currentTime + 1.1)

        this.boom()
        this.scheduleCrackle()
      } catch (e) { /* 音频不可用时静默降级 */ }
    },
    boom() {
      const ctx = this.audioCtx
      if (!ctx || this.muted) return
      try {
        const dur = 1.1
        const buf = ctx.createBuffer(1, ctx.sampleRate * dur, ctx.sampleRate)
        const d = buf.getChannelData(0)
        for (let i = 0; i < d.length; i++) d[i] = Math.random() * 2 - 1
        const src = ctx.createBufferSource()
        src.buffer = buf
        const lp = ctx.createBiquadFilter()
        lp.type = 'lowpass'
        lp.frequency.setValueAtTime(1400, ctx.currentTime)
        lp.frequency.exponentialRampToValueAtTime(120, ctx.currentTime + dur)
        const g = ctx.createGain()
        g.gain.setValueAtTime(0.0001, ctx.currentTime)
        g.gain.exponentialRampToValueAtTime(0.5, ctx.currentTime + 0.06)
        g.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + dur)
        src.connect(lp).connect(g).connect(ctx.destination)
        src.start()
      } catch (e) { /* ignore */ }
    },
    scheduleCrackle() {
      const tick = () => {
        if (!this.audioCtx) return
        if (!this.muted) this.crackle()
        this.crackTimer = setTimeout(tick, 90 + Math.random() * 420)
      }
      this.crackTimer = setTimeout(tick, 260)
    },
    crackle() {
      const ctx = this.audioCtx
      try {
        const dur = 0.02 + Math.random() * 0.07
        const buf = ctx.createBuffer(1, Math.ceil(ctx.sampleRate * dur), ctx.sampleRate)
        const d = buf.getChannelData(0)
        for (let i = 0; i < d.length; i++) d[i] = (Math.random() * 2 - 1) * (1 - i / d.length)
        const src = ctx.createBufferSource()
        src.buffer = buf
        const bp = ctx.createBiquadFilter()
        bp.type = 'bandpass'
        bp.frequency.value = 700 + Math.random() * 2600
        bp.Q.value = 0.8
        const g = ctx.createGain()
        g.gain.value = 0.04 + Math.random() * 0.13
        src.connect(bp).connect(g).connect(ctx.destination)
        src.start()
      } catch (e) { /* ignore */ }
    },
    stopAudio() {
      clearTimeout(this.crackTimer)
      this.crackTimer = null
      if (this.noiseGain && this.audioCtx) {
        try {
          const t = this.audioCtx.currentTime
          this.noiseGain.gain.cancelScheduledValues(t)
          this.noiseGain.gain.setValueAtTime(this.noiseGain.gain.value, t)
          this.noiseGain.gain.linearRampToValueAtTime(0, t + 0.25)
        } catch (e) { /* ignore */ }
      }
      const ctx = this.audioCtx
      this.audioCtx = null
      this.noiseGain = null
      if (ctx) setTimeout(() => { try { ctx.close() } catch (e) {} }, 320)
    }
  }
}
</script>

<style scoped>
.imm {
  position: fixed; inset: 0; z-index: 9999; background: #000;
  overflow: hidden; cursor: pointer; color: #fff;
  font-family: var(--font-sans, system-ui, sans-serif);
  user-select: none;
}
.grain {
  position: absolute; inset: -50%; pointer-events: none; opacity: .05;
  background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='120' height='120'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='2'/></filter><rect width='100%25' height='100%25' filter='url(%23n)'/></svg>");
  animation: grain 1.2s steps(3) infinite;
}
@keyframes grain { 0%{transform:translate(0,0)} 33%{transform:translate(-3%,2%)} 66%{transform:translate(2%,-3%)} 100%{transform:translate(0,0)} }

.halo {
  position: absolute; left: 50%; top: 50%; width: 90vmin; height: 90vmin;
  transform: translate(-50%, -46%); pointer-events: none;
  background: radial-gradient(circle, rgba(var(--fire-rgb), .22) 0%, rgba(var(--fire-rgb), .07) 32%, transparent 66%);
  filter: blur(14px);
  animation: breathe 3.4s ease-in-out infinite;
}
.ground {
  position: absolute; left: 50%; top: 70%; width: 46vmin; height: 12vmin;
  transform: translateX(-50%); pointer-events: none;
  background: radial-gradient(ellipse, rgba(var(--fire-rgb), .4) 0%, rgba(var(--fire-rgb), .1) 45%, transparent 72%);
  filter: blur(9px);
  animation: breathe 2.6s ease-in-out infinite reverse;
}
@keyframes breathe { 0%,100%{opacity:.75; transform:translate(-50%,-46%) scale(1)} 50%{opacity:1; transform:translate(-50%,-46%) scale(1.08)} }
.ground { animation-name: gbreathe; }
@keyframes gbreathe { 0%,100%{opacity:.7; transform:translateX(-50%) scaleX(1)} 50%{opacity:1; transform:translateX(-50%) scaleX(1.1)} }

.fx { position: absolute; inset: 0; pointer-events: none; }

.core {
  position: absolute; left: 50%; top: 50%; width: 34vmin; height: 44vmin;
  transform: translate(-50%, -40%); pointer-events: none;
  mix-blend-mode: screen;
  animation: ignite .9s cubic-bezier(.16,.8,.3,1) both;
}
.flame {
  position: absolute; left: 50%; bottom: 0; border-radius: 50% 50% 48% 48% / 64% 64% 36% 36%;
  transform-origin: 50% 88%;
  filter: blur(6px);
}
.f1 { width: 100%; height: 100%; left: 0; bottom: 0;
  background: radial-gradient(ellipse at 50% 78%, rgba(255,252,240,.95) 0%, rgba(var(--fire-rgb),.8) 26%, rgba(var(--fire-rgb),.2) 58%, transparent 72%);
  animation: sway1 1.9s ease-in-out infinite; }
.f2 { width: 76%; height: 82%; left: 12%; bottom: 2%;
  background: radial-gradient(ellipse at 50% 74%, rgba(255,255,240,.9) 0%, rgba(var(--fire-rgb),.92) 30%, rgba(var(--fire-d),.35) 62%, transparent 76%);
  filter: blur(4px); animation: sway2 1.35s ease-in-out infinite; }
.f3 { width: 48%; height: 62%; left: 26%; bottom: 5%;
  background: radial-gradient(ellipse at 50% 70%, #fff 0%, rgba(255,248,220,.95) 24%, rgba(var(--fire-rgb),.8) 52%, transparent 74%);
  filter: blur(2px); animation: sway3 .95s ease-in-out infinite; }
.f4 { width: 24%; height: 40%; left: 38%; bottom: 8%;
  background: radial-gradient(ellipse at 50% 66%, #fff 0%, rgba(255,255,240,.9) 38%, rgba(var(--fire-rgb),.6) 66%, transparent 80%);
  filter: blur(1px); animation: sway4 .7s ease-in-out infinite; }
@keyframes sway1 { 0%,100%{transform:rotate(-4deg) scale(1,1)} 50%{transform:rotate(5deg) scale(1.05,.96)} }
@keyframes sway2 { 0%,100%{transform:rotate(6deg) scale(.98,1.04)} 50%{transform:rotate(-6deg) scale(1.04,.95)} }
@keyframes sway3 { 0%,100%{transform:rotate(-8deg) scale(1.03,.96)} 50%{transform:rotate(7deg) scale(.96,1.06)} }
@keyframes sway4 { 0%,100%{transform:rotate(10deg) scale(.95,1.05)} 50%{transform:rotate(-9deg) scale(1.06,.94)} }
@keyframes ignite { 0%{opacity:0; transform:translate(-50%,-40%) scale(.35); filter:blur(20px)} 60%{opacity:1; filter:blur(0)} 100%{opacity:1; transform:translate(-50%,-40%) scale(1)} }

.sound {
  position: absolute; top: 22px; right: 24px; z-index: 3; cursor: pointer;
  display: flex; align-items: center; gap: 8px; height: 34px; padding: 0 13px;
  border-radius: 20px; color: rgba(255,255,255,.7); font-size: 12px; letter-spacing: 1px;
  background: rgba(255,255,255,.06); border: 1px solid rgba(var(--fire-rgb),.32);
  transition: .2s;
}
.sound:hover { color: #fff; border-color: rgba(var(--fire-rgb),.7); background: rgba(var(--fire-rgb),.12); }
.sound-txt { opacity: .8; }
.spk { width: 12px; height: 12px; position: relative; display: inline-block; }
.spk::before { content:""; position:absolute; left:0; top:4px; width:0; height:0;
  border-top:4px solid transparent; border-bottom:4px solid transparent; border-right:6px solid currentColor; }
.spk::after { content:""; position:absolute; left:6px; top:2px; width:6px; height:8px;
  border-right:2px solid currentColor; border-radius:0 50% 50% 0; opacity:.9; }
.spk.off::after { opacity:.25; }

.top {
  position: absolute; top: 12vh; left: 0; right: 0; text-align: center; z-index: 2;
  animation: fadeDown 1.1s .45s ease both;
}
.rule { display: inline-block; width: 46px; height: 1px; vertical-align: middle; margin: 0 14px;
  background: linear-gradient(90deg, transparent, rgba(var(--fire-rgb),.8)); }
.rule:last-of-type { background: linear-gradient(90deg, rgba(var(--fire-rgb),.8), transparent); }
.top-label { font-size: 12px; letter-spacing: 6px; color: rgba(var(--fire-rgb),.9); }
.rank { margin-top: 14px; font-size: 13px; letter-spacing: 3px; color: rgba(255,255,255,.5); }

.bottom {
  position: absolute; left: 0; right: 0; bottom: 9vh; text-align: center; z-index: 2; padding: 0 24px;
  animation: fadeUp 1.2s .6s ease both;
}
.name {
  margin: 0; font-size: clamp(38px, 7vw, 92px); font-weight: 500; letter-spacing: 16px;
  font-family: "STKaiti", "KaiTi", "Songti SC", serif;
  color: #fff; text-shadow: 0 0 30px rgba(var(--fire-rgb),.85), 0 0 80px rgba(var(--fire-rgb),.5);
}
.divider { margin: 18px auto 14px; display: flex; align-items: center; justify-content: center; gap: 12px;
  color: rgba(var(--fire-rgb),.8); }
.divider i { display: block; width: 70px; height: 1px; background: linear-gradient(90deg, transparent, rgba(var(--fire-rgb),.6)); }
.divider i:last-child { background: linear-gradient(90deg, rgba(var(--fire-rgb),.6), transparent); }
.divider span { font-size: 12px; }
.quote { margin: 0 auto; max-width: 620px; font-size: clamp(12px, 1.5vw, 15px); line-height: 2;
  letter-spacing: 2px; color: rgba(255,255,255,.66); }
.tip { margin-top: 30px; font-size: 11px; letter-spacing: 3px; color: rgba(255,255,255,.32); }

@keyframes fadeDown { from{opacity:0; transform:translateY(-14px)} to{opacity:1; transform:none} }
@keyframes fadeUp { from{opacity:0; transform:translateY(18px)} to{opacity:1; transform:none} }
.immfade-enter-active, .immfade-leave-active { transition: opacity .55s ease; }
.immfade-enter-from, .immfade-leave-to { opacity: 0; }

@media (max-width: 640px) {
  .name { letter-spacing: 8px; }
  .core { width: 52vmin; height: 60vmin; }
  .top { top: 9vh; }
  .bottom { bottom: 7vh; }
}
@media (prefers-reduced-motion: reduce) {
  .flame, .halo, .ground, .grain, .core { animation: none !important; }
}
</style>
