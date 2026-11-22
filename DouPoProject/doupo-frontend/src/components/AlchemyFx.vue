<template>
  <Teleport to="body">
    <transition name="fxfade">
      <div v-if="show" class="fx" :class="success ? 's-ok' : 's-bad'" :style="fxStyle" @click="finish">
        <canvas ref="cv" class="canvas"></canvas>
        <div class="vignette"></div>

        <!-- ============ 成功：丹纹光轮 ============ -->
        <template v-if="success">
          <div class="halo"></div>
          <div class="rings">
            <i class="ring r1"></i><i class="ring r2"></i><i class="ring r3"></i>
          </div>
          <div class="sigil">
            <svg viewBox="0 0 320 320" aria-hidden="true">
              <circle cx="160" cy="160" r="150" class="sc1" />
              <circle cx="160" cy="160" r="132" class="sc2" />
              <g class="ticks">
                <line v-for="n in 48" :key="n"
                  :x1="160 + 142 * Math.cos(n*Math.PI/24)" :y1="160 + 142 * Math.sin(n*Math.PI/24)"
                  :x2="160 + (n%4===0 ? 126 : 134) * Math.cos(n*Math.PI/24)"
                  :y2="160 + (n%4===0 ? 126 : 134) * Math.sin(n*Math.PI/24)" />
              </g>
            </svg>
          </div>
          <div class="pill">
            <span class="pill-glow"></span>
            <span class="pill-body"><em>丹</em></span>
            <i class="pill-ring" v-for="n in rings" :key="n" :style="{ '--n': n }"></i>
          </div>
          <div class="beam"></div>
        </template>

        <!-- ============ 失败：炸炉 ============ -->
        <template v-else>
          <div class="fireball"></div>
          <div class="shock s1"></div>
          <div class="shock s2"></div>
          <div class="cracks">
            <svg viewBox="0 0 400 400" aria-hidden="true">
              <g v-for="n in 9" :key="n" :transform="'rotate(' + (n*40) + ' 200 200)'">
                <path class="crack" :d="crackPath(n)" />
              </g>
            </svg>
          </div>
          <div class="scorch"></div>
        </template>

        <div class="caption">
          <div class="cap-kicker">{{ success ? '炼 化 成 功' : '炼 化 失 败' }}</div>
          <h1 class="cap-title">{{ success ? pillName : '炸 炉' }}</h1>
          <div class="cap-sub" v-if="success">
            <span>{{ tierName }}</span><i>·</i><span>{{ grade }}</span><i>·</i><span>丹纹 {{ rings }} 道</span>
          </div>
          <div class="cap-sub bad" v-else>
            <span>{{ failReason }}</span>
          </div>
        </div>

        <div class="skip">点击跳过</div>
      </div>
    </transition>
  </Teleport>
</template>

<script>
export default {
  name: 'AlchemyFx',
  props: {
    show: { type: Boolean, default: false },
    success: { type: Boolean, default: true },
    pillName: { type: String, default: '丹药' },
    tierName: { type: String, default: '下品' },
    grade: { type: String, default: '黄阶' },
    rings: { type: Number, default: 1 },
    failReason: { type: String, default: '火候失守' },
    color: { type: String, default: '#f5d76e' },
    rgb: { type: String, default: '245,215,110' },
    muted: { type: Boolean, default: false }
  },
  emits: ['done'],
  data() {
    return { parts: [], raf: 0, ctx: null, w: 0, h: 0, cx: 0, cy: 0, t0: 0, duration: 2300, _done: false }
  },
  computed: {
    fxStyle() {
      return { '--fx': this.color, '--fx-rgb': this.rgb }
    }
  },
  watch: {
    show(v) {
      if (v) this.start()
      else this.stop()
    }
  },
  beforeUnmount() { this.stop() },
  methods: {
    start() {
      this._done = false
      this.duration = this.success ? 2400 : 2000
      this.$nextTick(() => {
        try { this.initCanvas(); this.loop() } catch (e) { /* 粒子降级 */ }
        try { this.playSfx() } catch (e) { /* 音频降级 */ }
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
    crackPath(n) {
      const seed = n * 37
      const x = 200 + ((seed % 60) - 30)
      const y = 200 + (((seed * 3) % 60) - 30)
      return `M200 200 L${x + 20} ${y - 30} L${x - 12} ${y - 66} L${x + 34} ${y - 104} L${x + 6} ${y - 150}`
    },

    /* ---------------- Canvas 粒子 ---------------- */
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
      this.cy = this.h * 0.42
      this.parts = []
      const n = Math.min(200, Math.round(this.w / 7))
      for (let i = 0; i < n; i++) this.parts.push(this.spawn(true))
    },
    spawn(init) {
      if (this.success) {
        const a = Math.random() * Math.PI * 2
        const r = Math.max(this.w, this.h) * (0.28 + Math.random() * 0.45)
        const x = this.cx + Math.cos(a) * r
        const y = this.cy + Math.sin(a) * r
        return { x, y, px: x, py: y, tx: this.cx, ty: this.cy, r: 0.8 + Math.random() * 2.3,
          sp: 0.5 + Math.random() * 1.2, delay: Math.random() * 0.32, dr: 0 }
      }
      const a = Math.random() * Math.PI * 2
      const sp = 3 + Math.random() * 11
      const x = this.cx + (Math.random() - 0.5) * 30
      const y = this.cy + (Math.random() - 0.5) * 30
      return { x, y, px: x, py: y, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp - 1.5,
        r: 1.2 + Math.random() * 3.4, life: 0, max: 40 + Math.random() * 55, smoke: Math.random() < 0.4 }
    },
    loop(ts) {
      if (!this.show || !this.ctx) return
      if (!this.t0) this.t0 = ts || 0
      const el = (ts || 0) - this.t0
      const ctx = this.ctx
      ctx.clearRect(0, 0, this.w, this.h)
      ctx.globalCompositeOperation = 'lighter'
      if (this.success) this.drawSuccess(ctx, el)
      else this.drawFail(ctx, el)
      ctx.globalCompositeOperation = 'source-over'
      ctx.globalAlpha = 1
      this.raf = requestAnimationFrame(this.loop)
    },
    drawSuccess(ctx, el) {
      const gather = Math.min(1, el / 900)
      const fade = el > 1900 ? Math.max(0, 1 - (el - 1900) / 500) : 1
      for (const p of this.parts) {
        if (gather < p.delay) continue
        p.px = p.x; p.py = p.y
        const k = Math.min(1, (gather - p.delay) / (1 - p.delay))
        const ease = k * k
        p.x += (p.tx - p.x) * 0.06 * p.sp + (p.tx - p.x) * 0.02 * ease
        p.y += (p.ty - p.y) * 0.06 * p.sp + (p.ty - p.y) * 0.02 * ease
        if (el > 1400) {
          p.px = p.x; p.py = p.y
          p.x += (p.x - p.tx) * 0.02
          p.y += (p.y - p.ty) * 0.02 - 0.3
        }
        const near = 1 - Math.min(1, Math.hypot(p.x - p.tx, p.y - p.ty) / (this.w * 0.3))
        ctx.strokeStyle = `rgba(${this.rgb},${(0.18 + near * 0.6) * fade})`
        ctx.lineWidth = p.r * (0.6 + near)
        ctx.beginPath(); ctx.moveTo(p.px, p.py); ctx.lineTo(p.x, p.y); ctx.stroke()
        ctx.fillStyle = `rgba(255,248,220,${(0.3 + near * 0.6) * fade})`
        ctx.beginPath(); ctx.arc(p.x, p.y, p.r * (0.5 + near * 0.7), 0, Math.PI * 2); ctx.fill()
      }
    },
    drawFail(ctx, el) {
      const fade = el > 1500 ? Math.max(0, 1 - (el - 1500) / 500) : 1
      for (const p of this.parts) {
        p.life++
        p.px = p.x; p.py = p.y
        if (p.smoke) {
          p.x += p.vx * 0.35 + Math.sin(p.life * 0.06) * 0.6
          p.y += p.vy * 0.5 - 0.4
          p.vx *= 0.98
          ctx.fillStyle = `rgba(70,58,50,${Math.max(0, (1 - p.life / p.max)) * 0.5 * fade})`
          ctx.beginPath(); ctx.arc(p.x, p.y, p.r * (1 + p.life / p.max * 2.5), 0, Math.PI * 2); ctx.fill()
        } else {
          p.x += p.vx; p.y += p.vy
          p.vx *= 0.985; p.vy = p.vy * 0.985 + 0.12
          ctx.strokeStyle = `rgba(255,${140 + Math.floor(Math.random() * 60)},70,${(1 - p.life / p.max) * fade})`
          ctx.lineWidth = p.r
          ctx.beginPath(); ctx.moveTo(p.px, p.py); ctx.lineTo(p.x, p.y); ctx.stroke()
        }
      }
    },

    /* ---------------- Web Audio ---------------- */
    playSfx() {
      const AC = window.AudioContext || window.webkitAudioContext
      if (!AC || this.muted) return
      const ctx = new AC()
      this.audioCtx = ctx
      ctx.resume && ctx.resume()
      const now = ctx.currentTime
      if (this.success) {
        [523.25, 659.25, 783.99, 1046.5, 1318.5].forEach((f, i) => {
          const o = ctx.createOscillator(); const g = ctx.createGain()
          o.type = 'triangle'; o.frequency.value = f
          const t0 = now + 0.35 + i * 0.13
          g.gain.setValueAtTime(0.0001, t0)
          g.gain.exponentialRampToValueAtTime(0.09, t0 + 0.02)
          g.gain.exponentialRampToValueAtTime(0.0001, t0 + 1.1)
          o.connect(g).connect(ctx.destination)
          o.start(t0); o.stop(t0 + 1.15)
        })
      } else {
        const len = Math.floor(ctx.sampleRate * 1.1)
        const buf = ctx.createBuffer(1, len, ctx.sampleRate)
        const d = buf.getChannelData(0)
        for (let i = 0; i < len; i++) d[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / len, 2.2)
        const src = ctx.createBufferSource(); src.buffer = buf
        const lp = ctx.createBiquadFilter(); lp.type = 'lowpass'
        lp.frequency.setValueAtTime(1200, now)
        lp.frequency.exponentialRampToValueAtTime(90, now + 1)
        const g = ctx.createGain()
        g.gain.setValueAtTime(0.32, now)
        g.gain.exponentialRampToValueAtTime(0.0001, now + 1.1)
        src.connect(lp).connect(g).connect(ctx.destination)
        src.start(now)
        const o = ctx.createOscillator(); const og = ctx.createGain()
        o.type = 'sawtooth'
        o.frequency.setValueAtTime(160, now)
        o.frequency.exponentialRampToValueAtTime(38, now + 0.7)
        og.gain.setValueAtTime(0.14, now)
        og.gain.exponentialRampToValueAtTime(0.0001, now + 0.75)
        o.connect(og).connect(ctx.destination)
        o.start(now); o.stop(now + 0.8)
      }
    },
    closeAudio() {
      const ctx = this.audioCtx
      this.audioCtx = null
      if (ctx) setTimeout(() => { try { ctx.close() } catch (e) {} }, 300)
    }
  }
}
</script>

<style scoped>
.fx { position: fixed; inset: 0; z-index: 9998; overflow: hidden; cursor: pointer; user-select: none;
  background: radial-gradient(circle at 50% 42%, rgba(var(--fx-rgb),.12), #050403 58%, #000 100%); }
.s-bad { background: radial-gradient(circle at 50% 42%, rgba(120,36,16,.28), #0a0503 56%, #000 100%); }
.canvas { position: absolute; inset: 0; }
.vignette { position: absolute; inset: 0; pointer-events: none;
  background: radial-gradient(circle at 50% 42%, transparent 30%, rgba(0,0,0,.72) 100%); }

/* ---------- 成功 ---------- */
.halo { position: absolute; left: 50%; top: 42%; width: 70vmin; height: 70vmin; transform: translate(-50%,-50%);
  border-radius: 50%; pointer-events: none;
  background: radial-gradient(circle, rgba(var(--fx-rgb),.3), rgba(var(--fx-rgb),.05) 42%, transparent 66%);
  filter: blur(12px); animation: haloIn 1s .3s ease both; }
@keyframes haloIn { 0%{opacity:0;transform:translate(-50%,-50%) scale(.5)} 100%{opacity:1;transform:translate(-50%,-50%) scale(1)} }

.rings { position: absolute; left: 50%; top: 42%; width: 1px; height: 1px; pointer-events: none; }
.ring { position: absolute; left: 0; top: 0; border-radius: 50%; transform: translate(-50%,-50%);
  border: 1px solid rgba(var(--fx-rgb),.6); opacity: 0; }
.r1 { animation: ringOut 1.5s .55s ease-out forwards; }
.r2 { animation: ringOut 1.5s .78s ease-out forwards; }
.r3 { animation: ringOut 1.5s 1.0s ease-out forwards; }
@keyframes ringOut {
  0%{opacity:.85; width:40px; height:40px; border-width:2px}
  100%{opacity:0; width:min(90vmin,720px); height:min(90vmin,720px); border-width:1px}
}
.sigil { position: absolute; left: 50%; top: 42%; width: min(64vmin,400px); height: min(64vmin,400px);
  transform: translate(-50%,-50%); pointer-events: none; animation: sigilSpin 6s .5s linear both; opacity: 0; }
@keyframes sigilSpin { 0%{opacity:0; transform:translate(-50%,-50%) rotate(-30deg) scale(.7)} 30%{opacity:.9} 100%{opacity:.75; transform:translate(-50%,-50%) rotate(80deg) scale(1)} }
.sigil svg { width:100%; height:100%; }
.sc1,.sc2 { fill:none; stroke:var(--fx); }
.sc1 { stroke-width:1; opacity:.5 } .sc2 { stroke-width:.6; opacity:.3; stroke-dasharray:3 7 }
.ticks line { stroke:var(--fx); stroke-width:1; opacity:.45 }
.ticks line:nth-child(4n+1) { opacity:.9 }

.pill { position: absolute; left: 50%; top: 42%; width: 96px; height: 96px; transform: translate(-50%,-50%);
  pointer-events: none; animation: pillIn .9s .45s cubic-bezier(.16,.9,.3,1.2) both; }
@keyframes pillIn { 0%{opacity:0; transform:translate(-50%,-50%) scale(.2) rotate(-90deg)} 100%{opacity:1; transform:translate(-50%,-50%) scale(1) rotate(0)} }
.pill-glow { position:absolute; inset:-60px; border-radius:50%;
  background:radial-gradient(circle, rgba(var(--fx-rgb),.5), transparent 60%); filter:blur(8px);
  animation: glowBreath 1.6s 1.1s ease-in-out infinite; }
@keyframes glowBreath { 0%,100%{opacity:.7; transform:scale(1)} 50%{opacity:1; transform:scale(1.12)} }
.pill-body { position:absolute; inset:0; border-radius:50%; display:grid; place-items:center;
  background:radial-gradient(circle at 34% 28%, #fffdf2, var(--fx) 52%, rgba(0,0,0,.5) 100%);
  box-shadow:0 0 34px rgba(var(--fx-rgb),.9), 0 0 80px rgba(var(--fx-rgb),.5), inset 0 -8px 18px rgba(0,0,0,.35); }
.pill-body em { font-style:normal; font-family:"STKaiti","KaiTi",serif; font-size:40px; font-weight:700;
  color:rgba(30,20,4,.55); text-shadow:0 1px 0 rgba(255,255,255,.4); animation: pillSpin 1.4s .5s ease-out both; }
@keyframes pillSpin { 0%{transform:rotate(0)} 100%{transform:rotate(360deg)} }
.pill-ring { position:absolute; inset:calc(-6px - var(--n) * 4px); border-radius:50%;
  border:1px solid rgba(var(--fx-rgb),.75); box-shadow:0 0 10px rgba(var(--fx-rgb),.6);
  opacity:0; animation: ringAppear .5s calc(1.0s + var(--n) * .13s) ease forwards; }
@keyframes ringAppear { 0%{opacity:0; transform:scale(.8) rotate(0)} 100%{opacity:.85; transform:scale(1) rotate(calc(var(--n) * 30deg))} }
.beam { position:absolute; left:50%; top:42%; width:2px; height:0; transform:translate(-50%,-100%);
  background:linear-gradient(to top, rgba(var(--fx-rgb),.85), transparent); filter:blur(1px);
  animation: beamUp 1s .6s ease-out forwards; }
@keyframes beamUp { 0%{height:0;opacity:.9} 100%{height:60vh;opacity:0} }

/* ---------- 失败 ---------- */
.fireball { position:absolute; left:50%; top:42%; width:40vmin; height:40vmin; transform:translate(-50%,-50%);
  border-radius:50%; pointer-events:none; mix-blend-mode:screen;
  background:radial-gradient(circle, #fff3d0 0%, #ffb347 22%, #ff5a1e 46%, rgba(180,30,10,.4) 66%, transparent 76%);
  filter:blur(8px); animation: fireball 1s ease-out forwards; }
@keyframes fireball { 0%{opacity:0;transform:translate(-50%,-50%) scale(.2)} 22%{opacity:1;transform:translate(-50%,-50%) scale(1.15)} 100%{opacity:0;transform:translate(-50%,-50%) scale(1.9)} }
.shock { position:absolute; left:50%; top:42%; width:60px; height:60px; border-radius:50%;
  transform:translate(-50%,-50%); pointer-events:none; border:3px solid rgba(255,140,70,.85); opacity:0; }
.s1 { animation: shockOut .95s .05s ease-out forwards; }
.s2 { animation: shockOut 1.15s .22s ease-out forwards; }
@keyframes shockOut { 0%{opacity:1;width:40px;height:40px;border-width:4px} 100%{opacity:0;width:min(120vmin,900px);height:min(120vmin,900px);border-width:1px} }
.cracks { position:absolute; left:50%; top:42%; width:min(80vmin,520px); height:min(80vmin,520px);
  transform:translate(-50%,-50%); pointer-events:none; }
.cracks svg { width:100%; height:100%; overflow:visible; }
.crack { fill:none; stroke:rgba(255,120,50,.9); stroke-width:2.2; filter:drop-shadow(0 0 5px rgba(255,90,30,.9));
  stroke-dasharray:320; stroke-dashoffset:320; animation: crackDraw .7s .12s ease-out forwards; }
@keyframes crackDraw { 0%{stroke-dashoffset:320;opacity:1} 100%{stroke-dashoffset:0;opacity:.75} }
.scorch { position:absolute; left:50%; top:42%; width:44vmin; height:44vmin; transform:translate(-50%,-50%);
  border-radius:50%; pointer-events:none;
  background:radial-gradient(circle, rgba(10,6,4,.8), rgba(40,18,8,.4) 55%, transparent 72%);
  opacity:0; animation: scorchIn .8s .3s ease forwards; }
@keyframes scorchIn { 0%{opacity:0} 100%{opacity:.85} }

/* ---------- 文案 ---------- */
.caption { position:absolute; left:0; right:0; bottom:14%; text-align:center; z-index:3; padding:0 20px; }
.cap-kicker { font-size:12px; letter-spacing:8px; color:rgba(var(--fx-rgb),.85);
  animation: capUp .7s .5s ease both; }
.cap-title { margin:10px 0 12px; font-size:clamp(34px,6.5vw,72px); font-weight:500; letter-spacing:12px;
  font-family:"STKaiti","KaiTi","Songti SC",serif; color:#fff6e6;
  text-shadow:0 0 28px rgba(var(--fx-rgb),.9), 0 0 70px rgba(var(--fx-rgb),.55);
  animation: capTitle .8s .62s cubic-bezier(.16,.8,.3,1) both; }
.s-bad .cap-title { color:#ffd9c4; text-shadow:0 0 26px rgba(255,90,40,.9), 0 0 64px rgba(200,40,10,.6);
  animation: capTitleBad .7s .3s cubic-bezier(.16,.8,.3,1) both, shakeBad .5s 1.0s ease-in-out; }
@keyframes capTitle { 0%{opacity:0;letter-spacing:34px;filter:blur(12px)} 100%{opacity:1;letter-spacing:12px;filter:blur(0)} }
@keyframes capTitleBad { 0%{opacity:0;letter-spacing:34px;filter:blur(12px)} 100%{opacity:1;letter-spacing:12px;filter:blur(0)} }
@keyframes shakeBad { 0%,100%{transform:translateX(0)} 25%{transform:translateX(-5px)} 75%{transform:translateX(5px)} }
.cap-sub { display:flex; gap:12px; justify-content:center; align-items:center; font-size:12px;
  letter-spacing:2px; color:rgba(255,255,255,.6); animation: capUp .7s .85s ease both; }
.cap-sub.bad { color:rgba(255,190,160,.7); animation-delay:.6s }
.cap-sub i { font-style:normal; opacity:.5 }
@keyframes capUp { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:none} }
.skip { position:absolute; right:24px; bottom:20px; font-size:11px; letter-spacing:2px;
  color:rgba(255,255,255,.3); animation:capUp .6s 1.2s ease both; }

.fxfade-enter-active { transition:opacity .3s ease }
.fxfade-leave-active { transition:opacity .5s ease }
.fxfade-enter-from, .fxfade-leave-to { opacity:0 }
@media (max-width:640px) { .cap-title { letter-spacing:6px } .caption { bottom:11% } }
</style>
