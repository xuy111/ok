<template>
  <Teleport to="body">
    <transition name="fxfade">
      <div v-if="show" class="fx" :class="'k-' + kind" :style="fxStyle" @click="finish">
        <canvas ref="cv" class="canvas"></canvas>
        <div class="vignette"></div>

        <!-- ============ 成功 / 吞噬：双焰汇聚 → 诞生新焰 ============ -->
        <template v-if="kind !== 'fail'">
          <div class="gather-line gl-a"></div>
          <div class="gather-line gl-b"></div>

          <div class="orb orb-a">
            <i></i><i></i><i></i>
          </div>
          <div class="orb orb-b">
            <i></i><i></i><i></i>
          </div>

          <div class="impact"></div>
          <div class="flash"></div>

          <div class="newflame">
            <i class="fl f1"></i><i class="fl f2"></i><i class="fl f3"></i><i class="fl f4"></i>
          </div>
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
          <div class="beam"></div>
        </template>

        <!-- ============ 失败：斗气暴走 ============ -->
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
          <div class="cap-kicker">{{ kicker }}</div>
          <h1 class="cap-title">{{ kind === 'fail' ? '斗气暴走' : name }}</h1>
          <div class="cap-sub" :class="{ bad: kind === 'fail' }" v-html="subLine"></div>
        </div>

        <div class="skip">点击跳过</div>
      </div>
    </transition>
  </Teleport>
</template>

<script>
export default {
  name: 'FuseFx',
  props: {
    show: { type: Boolean, default: false },
    kind: { type: String, default: 'fuse' }, // fuse | devour | fail
    name: { type: String, default: '新焰' },
    grade: { type: String, default: '天阶' },
    failReason: { type: String, default: '同源之力相斥' },
    colorA: { type: String, default: '#5fb8ff' },
    rgbA: { type: String, default: '95,184,255' },
    colorB: { type: String, default: '#ff7a45' },
    rgbB: { type: String, default: '255,122,69' },
    colorR: { type: String, default: '#f5d76e' },
    rgbR: { type: String, default: '245,215,110' },
    muted: { type: Boolean, default: false }
  },
  emits: ['done'],
  data() {
    return { parts: [], raf: 0, ctx: null, w: 0, h: 0, cx: 0, cy: 0, t0: 0, duration: 2600, _done: false }
  },
  computed: {
    fxStyle() {
      return {
        '--fx': this.colorR, '--fx-rgb': this.rgbR,
        '--fxa': this.colorA, '--fxa-rgb': this.rgbA,
        '--fxb': this.colorB, '--fxb-rgb': this.rgbB
      }
    },
    kicker() {
      return this.kind === 'fail' ? '融 合 失 败' : (this.kind === 'devour' ? '吞 噬 成 功' : '融 合 成 功')
    },
    subLine() {
      if (this.kind === 'fail') return '<span>' + this.failReason + '</span>'
      const tail = this.kind === 'devour' ? '焰体进化 · 威能暴涨' : '双火归一 · 威能远超之和'
      return '<span>' + this.grade + '</span><i>·</i><span>' + tail + '</span>'
    }
  },
  watch: {
    show(v) { if (v) this.start(); else this.stop() }
  },
  beforeUnmount() { this.stop() },
  methods: {
    start() {
      this._done = false
      this.duration = this.kind === 'fail' ? 2100 : (this.kind === 'devour' ? 2400 : 2700)
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
      const n = Math.min(220, Math.round(this.w / 6))
      for (let i = 0; i < n; i++) this.parts.push(this.spawn(i))
    },
    spawn(i) {
      if (this.kind === 'fail') {
        const a = Math.random() * Math.PI * 2
        const sp = 3 + Math.random() * 12
        const x = this.cx + (Math.random() - 0.5) * 30
        const y = this.cy + (Math.random() - 0.5) * 30
        return { x, y, px: x, py: y, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp - 1.2,
          r: 1.2 + Math.random() * 3.4, life: 0, max: 40 + Math.random() * 55, smoke: Math.random() < 0.4 }
      }
      const g = i % 2 // 0 = A 组（左），1 = B 组（右）
      const x = g === 0 ? Math.random() * this.w * 0.36 : this.w * 0.64 + Math.random() * this.w * 0.36
      const y = this.cy + (Math.random() - 0.5) * this.h * 0.72
      return { x, y, px: x, py: y, g, r: 0.8 + Math.random() * 2.4,
        sp: 0.5 + Math.random() * 1.1, delay: Math.random() * 0.3, out: false }
    },
    loop(ts) {
      if (!this.show || !this.ctx) return
      if (!this.t0) this.t0 = ts || 0
      const el = (ts || 0) - this.t0
      const ctx = this.ctx
      ctx.clearRect(0, 0, this.w, this.h)
      ctx.globalCompositeOperation = 'lighter'
      if (this.kind === 'fail') this.drawFail(ctx, el)
      else this.drawFuse(ctx, el)
      ctx.globalCompositeOperation = 'source-over'
      ctx.globalAlpha = 1
      this.raf = requestAnimationFrame(this.loop)
    },
    drawFuse(ctx, el) {
      const gather = Math.min(1, el / 980)
      const fade = el > 2000 ? Math.max(0, 1 - (el - 2000) / 600) : 1
      for (const p of this.parts) {
        if (gather < p.delay) continue
        p.px = p.x; p.py = p.y
        if (el < 1180) {
          const k = Math.min(1, (gather - p.delay) / (1 - p.delay))
          const pull = 0.045 + 0.05 * k * k
          p.x += (this.cx - p.x) * pull * p.sp
          p.y += (this.cy - p.y) * pull * p.sp
        } else {
          // 融合完成，余烬向外扩散（结果色）
          if (!p.out) { const a = Math.random() * Math.PI * 2; p.vx = Math.cos(a) * (1 + Math.random() * 3.5); p.vy = Math.sin(a) * (1 + Math.random() * 3.5) - 0.6; p.out = true }
          p.x += p.vx; p.y += p.vy; p.vx *= 0.98; p.vy = p.vy * 0.98 + 0.05
        }
        const rgb = el < 1180 ? (p.g === 0 ? this.rgbA : this.rgbB) : this.rgbR
        const near = 1 - Math.min(1, Math.hypot(p.x - this.cx, p.y - this.cy) / (this.w * 0.3))
        ctx.strokeStyle = `rgba(${rgb},${(0.16 + near * 0.6) * fade})`
        ctx.lineWidth = p.r * (0.6 + near)
        ctx.beginPath(); ctx.moveTo(p.px, p.py); ctx.lineTo(p.x, p.y); ctx.stroke()
        ctx.fillStyle = `rgba(255,248,220,${(0.28 + near * 0.6) * fade})`
        ctx.beginPath(); ctx.arc(p.x, p.y, p.r * (0.5 + near * 0.7), 0, Math.PI * 2); ctx.fill()
      }
    },
    drawFail(ctx, el) {
      const fade = el > 1600 ? Math.max(0, 1 - (el - 1600) / 500) : 1
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
      if (this.kind === 'fail') {
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
        o.frequency.setValueAtTime(170, now)
        o.frequency.exponentialRampToValueAtTime(38, now + 0.7)
        og.gain.setValueAtTime(0.14, now)
        og.gain.exponentialRampToValueAtTime(0.0001, now + 0.75)
        o.connect(og).connect(ctx.destination)
        o.start(now); o.stop(now + 0.8)
        return
      }
      // 汇聚上升扫频（两焰接近）
      const sw = ctx.createOscillator(); const sg = ctx.createGain()
      sw.type = 'sawtooth'
      sw.frequency.setValueAtTime(120, now)
      sw.frequency.exponentialRampToValueAtTime(620, now + 0.95)
      const bp = ctx.createBiquadFilter(); bp.type = 'bandpass'; bp.Q.value = 1.2
      bp.frequency.setValueAtTime(300, now)
      bp.frequency.exponentialRampToValueAtTime(1400, now + 0.95)
      sg.gain.setValueAtTime(0.0001, now)
      sg.gain.exponentialRampToValueAtTime(0.10, now + 0.5)
      sg.gain.exponentialRampToValueAtTime(0.0001, now + 1.05)
      sw.connect(bp).connect(sg).connect(ctx.destination)
      sw.start(now); sw.stop(now + 1.1)
      // 碰撞轰鸣
      const len = Math.floor(ctx.sampleRate * 0.7)
      const buf = ctx.createBuffer(1, len, ctx.sampleRate)
      const d = buf.getChannelData(0)
      for (let i = 0; i < len; i++) d[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / len, 2.4)
      const src = ctx.createBufferSource(); src.buffer = buf
      const lp = ctx.createBiquadFilter(); lp.type = 'lowpass'
      lp.frequency.setValueAtTime(1600, now + 0.95)
      lp.frequency.exponentialRampToValueAtTime(120, now + 1.6)
      const ng = ctx.createGain()
      ng.gain.setValueAtTime(0.22, now + 0.95)
      ng.gain.exponentialRampToValueAtTime(0.0001, now + 1.65)
      src.connect(lp).connect(ng).connect(ctx.destination)
      src.start(now + 0.95)
      // 新焰诞生的五音编钟
      const scale = this.kind === 'devour'
        ? [392, 523.25, 659.25, 783.99]
        : [523.25, 659.25, 783.99, 1046.5, 1318.5]
      scale.forEach((f, i) => {
        const o = ctx.createOscillator(); const g = ctx.createGain()
        o.type = 'triangle'; o.frequency.value = f
        const t0 = now + 1.15 + i * 0.13
        g.gain.setValueAtTime(0.0001, t0)
        g.gain.exponentialRampToValueAtTime(0.085, t0 + 0.02)
        g.gain.exponentialRampToValueAtTime(0.0001, t0 + 1.1)
        o.connect(g).connect(ctx.destination)
        o.start(t0); o.stop(t0 + 1.15)
      })
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
  background: radial-gradient(circle at 50% 42%, rgba(var(--fx-rgb),.13), #050403 58%, #000 100%); }
.k-fail { background: radial-gradient(circle at 50% 42%, rgba(120,36,16,.3), #0a0503 56%, #000 100%); }
.canvas { position: absolute; inset: 0; }
.vignette { position: absolute; inset: 0; pointer-events: none;
  background: radial-gradient(circle at 50% 42%, transparent 30%, rgba(0,0,0,.72) 100%); }

/* ---------- 汇聚轨迹 ---------- */
.gather-line { position: absolute; top: 42%; height: 2px; width: 34vw; transform: translateY(-50%);
  pointer-events: none; opacity: 0; filter: blur(1px); }
.gl-a { left: 4vw; background: linear-gradient(to right, transparent, var(--fxa));
  box-shadow: 0 0 14px var(--fxa); animation: lineIn .5s .05s ease both; }
.gl-b { right: 4vw; background: linear-gradient(to left, transparent, var(--fxb));
  box-shadow: 0 0 14px var(--fxb); animation: lineIn .5s .05s ease both; }
@keyframes lineIn { 0%{opacity:0;transform:translateY(-50%) scaleX(.2)} 40%{opacity:.8} 100%{opacity:0;transform:translateY(-50%) scaleX(1)} }

/* ---------- 两团源焰 ---------- */
.orb { position: absolute; top: 42%; width: 96px; height: 120px; pointer-events: none; }
.orb-a { left: 50%; animation: orbA 1.05s cubic-bezier(.5,0,.3,1) both; }
.orb-b { left: 50%; animation: orbB 1.05s cubic-bezier(.5,0,.3,1) both; }
@keyframes orbA { 0%{opacity:0;transform:translate(-46vw,-50%) scale(.7)} 20%{opacity:1} 86%{opacity:1} 100%{opacity:0;transform:translate(-10px,-50%) scale(1.05)} }
@keyframes orbB { 0%{opacity:0;transform:translate(calc(-100% + 46vw),-50%) scale(.7)} 20%{opacity:1} 86%{opacity:1} 100%{opacity:0;transform:translate(calc(-100% + 10px),-50%) scale(1.05)} }
.orb i { position: absolute; left: 50%; bottom: 0; width: 100%; height: 100%; transform-origin: 50% 100%;
  border-radius: 50% 50% 44% 44% / 66% 66% 34% 34%; filter: blur(9px); mix-blend-mode: screen; }
.orb-a i:nth-child(1) { background: radial-gradient(circle at 50% 78%, var(--fxa), transparent 70%); opacity:.85; animation: flick 1.05s infinite alternate; }
.orb-a i:nth-child(2) { width:64%; height:74%; left:18%; background: radial-gradient(circle at 50% 80%, #fff, var(--fxa) 60%, transparent 78%); animation: flick .82s .1s infinite alternate; }
.orb-a i:nth-child(3) { width:34%; height:48%; left:33%; background: radial-gradient(circle at 50% 82%, #fff, transparent 72%); animation: flick .62s .2s infinite alternate; }
.orb-b i:nth-child(1) { background: radial-gradient(circle at 50% 78%, var(--fxb), transparent 70%); opacity:.85; animation: flick .95s .05s infinite alternate-reverse; }
.orb-b i:nth-child(2) { width:64%; height:74%; left:18%; background: radial-gradient(circle at 50% 80%, #fff, var(--fxb) 60%, transparent 78%); animation: flick .76s .12s infinite alternate-reverse; }
.orb-b i:nth-child(3) { width:34%; height:48%; left:33%; background: radial-gradient(circle at 50% 82%, #fff, transparent 72%); animation: flick .58s .22s infinite alternate-reverse; }
@keyframes flick { 0%{transform:scaleY(1) scaleX(1)} 100%{transform:scaleY(1.14) scaleX(.94)} }

/* ---------- 碰撞 / 闪光 ---------- */
.impact { position: absolute; left: 50%; top: 42%; width: 30px; height: 30px; border-radius: 50%;
  transform: translate(-50%,-50%); pointer-events: none; mix-blend-mode: screen;
  background: radial-gradient(circle, #fff, var(--fx) 50%, transparent 72%);
  animation: impact .55s .92s ease-out both; }
@keyframes impact { 0%{opacity:0;transform:translate(-50%,-50%) scale(.3)} 30%{opacity:1;transform:translate(-50%,-50%) scale(2.2)} 100%{opacity:0;transform:translate(-50%,-50%) scale(5)} }
.flash { position: absolute; inset: 0; pointer-events: none; background: #fff; opacity: 0;
  animation: flash .4s 1.0s ease-out both; }
@keyframes flash { 0%{opacity:0} 22%{opacity:.85} 100%{opacity:0} }

/* ---------- 新焰 ---------- */
.newflame { position: absolute; left: 50%; top: 42%; width: 130px; height: 150px;
  transform: translate(-50%,-50%); pointer-events: none;
  animation: nfIn .9s 1.12s cubic-bezier(.16,.9,.3,1.2) both; }
@keyframes nfIn { 0%{opacity:0;transform:translate(-50%,-50%) scale(.25) rotate(-40deg)} 100%{opacity:1;transform:translate(-50%,-50%) scale(1) rotate(0)} }
.newflame .fl { position: absolute; left: 50%; bottom: 0; transform-origin: 50% 100%;
  border-radius: 50% 50% 44% 44% / 66% 66% 34% 34%; filter: blur(7px); }
.f1 { width:120px; height:150px; margin-left:-60px; background: radial-gradient(circle at 50% 76%, var(--fx), rgba(var(--fx-rgb),.35) 55%, transparent 74%); animation: flick 1.15s .1s infinite alternate; }
.f2 { width:88px; height:116px; margin-left:-44px; bottom:8px; background: radial-gradient(circle at 50% 80%, #fff8e2, var(--fx) 58%, transparent 78%); animation: flick .9s .2s infinite alternate-reverse; }
.f3 { width:54px; height:82px; margin-left:-27px; bottom:16px; background: radial-gradient(circle at 50% 82%, #fff, rgba(var(--fx-rgb),.9) 60%, transparent 80%); animation: flick .7s .35s infinite alternate; }
.f4 { width:28px; height:48px; margin-left:-14px; bottom:24px; background: radial-gradient(circle at 50% 84%, #fff, transparent 76%); animation: flick .55s .1s infinite alternate-reverse; }
.newflame::after { content:""; position:absolute; left:50%; bottom:-26px; width:130px; height:40px; transform:translateX(-50%);
  background:radial-gradient(ellipse, rgba(var(--fx-rgb),.6), transparent 70%); filter:blur(8px); }

/* ---------- 光环 / 符文 / 光柱 ---------- */
.halo { position: absolute; left: 50%; top: 42%; width: 74vmin; height: 74vmin; transform: translate(-50%,-50%);
  border-radius: 50%; pointer-events: none;
  background: radial-gradient(circle, rgba(var(--fx-rgb),.32), rgba(var(--fx-rgb),.05) 42%, transparent 66%);
  filter: blur(12px); animation: haloIn 1s 1.15s ease both; }
@keyframes haloIn { 0%{opacity:0;transform:translate(-50%,-50%) scale(.5)} 100%{opacity:1;transform:translate(-50%,-50%) scale(1)} }
.rings { position: absolute; left: 50%; top: 42%; width: 1px; height: 1px; pointer-events: none; }
.ring { position: absolute; left: 0; top: 0; border-radius: 50%; transform: translate(-50%,-50%);
  border: 1px solid rgba(var(--fx-rgb),.6); opacity: 0; }
.r1 { animation: ringOut 1.6s 1.2s ease-out forwards; }
.r2 { animation: ringOut 1.6s 1.42s ease-out forwards; }
.r3 { animation: ringOut 1.6s 1.64s ease-out forwards; }
@keyframes ringOut { 0%{opacity:.85;width:40px;height:40px;border-width:2px} 100%{opacity:0;width:min(92vmin,740px);height:min(92vmin,740px);border-width:1px} }
.sigil { position: absolute; left: 50%; top: 42%; width: min(64vmin,400px); height: min(64vmin,400px);
  transform: translate(-50%,-50%); pointer-events: none; animation: sigilSpin 6s 1.15s linear both; opacity: 0; }
@keyframes sigilSpin { 0%{opacity:0;transform:translate(-50%,-50%) rotate(-30deg) scale(.7)} 30%{opacity:.9} 100%{opacity:.75;transform:translate(-50%,-50%) rotate(80deg) scale(1)} }
.sigil svg { width:100%; height:100%; }
.sc1,.sc2 { fill:none; stroke:var(--fx); }
.sc1 { stroke-width:1; opacity:.5 } .sc2 { stroke-width:.6; opacity:.3; stroke-dasharray:3 7 }
.ticks line { stroke:var(--fx); stroke-width:1; opacity:.45 }
.ticks line:nth-child(4n+1) { opacity:.9 }
.beam { position:absolute; left:50%; top:42%; width:2px; height:0; transform:translate(-50%,-100%);
  background:linear-gradient(to top, rgba(var(--fx-rgb),.85), transparent); filter:blur(1px);
  animation: beamUp 1.1s 1.3s ease-out forwards; }
@keyframes beamUp { 0%{height:0;opacity:.9} 100%{height:62vh;opacity:0} }

/* ---------- 失败 ---------- */
.fireball { position:absolute; left:50%; top:42%; width:40vmin; height:40vmin; transform:translate(-50%,-50%);
  border-radius:50%; pointer-events:none; mix-blend-mode:screen;
  background:radial-gradient(circle, #fff3d0 0%, #ffb347 22%, #ff5a1e 46%, rgba(180,30,10,.4) 66%, transparent 76%);
  filter:blur(8px); animation: fireball 1s .08s ease-out forwards; }
@keyframes fireball { 0%{opacity:0;transform:translate(-50%,-50%) scale(.2)} 22%{opacity:1;transform:translate(-50%,-50%) scale(1.15)} 100%{opacity:0;transform:translate(-50%,-50%) scale(1.9)} }
.shock { position:absolute; left:50%; top:42%; width:60px; height:60px; border-radius:50%;
  transform:translate(-50%,-50%); pointer-events:none; border:3px solid rgba(255,140,70,.85); opacity:0; }
.s1 { animation: shockOut .95s .1s ease-out forwards; }
.s2 { animation: shockOut 1.15s .28s ease-out forwards; }
@keyframes shockOut { 0%{opacity:1;width:40px;height:40px;border-width:4px} 100%{opacity:0;width:min(120vmin,900px);height:min(120vmin,900px);border-width:1px} }
.cracks { position:absolute; left:50%; top:42%; width:min(80vmin,520px); height:min(80vmin,520px);
  transform:translate(-50%,-50%); pointer-events:none; }
.cracks svg { width:100%; height:100%; overflow:visible; }
.crack { fill:none; stroke:rgba(255,120,50,.9); stroke-width:2.2; filter:drop-shadow(0 0 5px rgba(255,90,30,.9));
  stroke-dasharray:320; stroke-dashoffset:320; animation: crackDraw .7s .18s ease-out forwards; }
@keyframes crackDraw { 0%{stroke-dashoffset:320;opacity:1} 100%{stroke-dashoffset:0;opacity:.75} }
.scorch { position:absolute; left:50%; top:42%; width:44vmin; height:44vmin; transform:translate(-50%,-50%);
  border-radius:50%; pointer-events:none;
  background:radial-gradient(circle, rgba(10,6,4,.8), rgba(40,18,8,.4) 55%, transparent 72%);
  opacity:0; animation: scorchIn .8s .35s ease forwards; }
@keyframes scorchIn { 0%{opacity:0} 100%{opacity:.85} }

/* ---------- 文案 ---------- */
.caption { position:absolute; left:0; right:0; bottom:12%; text-align:center; z-index:3; padding:0 20px; }
.cap-kicker { font-size:12px; letter-spacing:8px; color:rgba(var(--fx-rgb),.9);
  animation: capUp .7s 1.15s ease both; }
.k-fail .cap-kicker { color:rgba(255,150,110,.9); animation-delay:.5s }
.cap-title { margin:10px 0 12px; font-size:clamp(34px,6.5vw,72px); font-weight:500; letter-spacing:12px;
  font-family:"STKaiti","KaiTi","Songti SC",serif; color:#fff6e6;
  text-shadow:0 0 28px rgba(var(--fx-rgb),.9), 0 0 70px rgba(var(--fx-rgb),.55);
  animation: capTitle .8s 1.3s cubic-bezier(.16,.8,.3,1) both; }
.k-fail .cap-title { color:#ffd9c4; text-shadow:0 0 26px rgba(255,90,40,.9), 0 0 64px rgba(200,40,10,.6);
  animation: capTitle .7s .62s cubic-bezier(.16,.8,.3,1) both, shakeBad .5s 1.1s ease-in-out; }
@keyframes capTitle { 0%{opacity:0;letter-spacing:34px;filter:blur(12px)} 100%{opacity:1;letter-spacing:12px;filter:blur(0)} }
@keyframes shakeBad { 0%,100%{transform:translateX(0)} 25%{transform:translateX(-5px)} 75%{transform:translateX(5px)} }
.cap-sub { display:flex; gap:12px; justify-content:center; align-items:center; font-size:12px;
  letter-spacing:2px; color:rgba(255,255,255,.65); animation: capUp .7s 1.55s ease both; }
.cap-sub.bad { color:rgba(255,190,160,.75); animation-delay:1s }
.cap-sub i { font-style:normal; opacity:.5 }
@keyframes capUp { from{opacity:0;transform:translateY(14px)} to{opacity:1;transform:none} }
.skip { position:absolute; right:24px; bottom:20px; font-size:11px; letter-spacing:2px;
  color:rgba(255,255,255,.3); animation:capUp .6s 1.6s ease both; }

.fxfade-enter-active { transition:opacity .3s ease }
.fxfade-leave-active { transition:opacity .5s ease }
.fxfade-enter-from, .fxfade-leave-to { opacity:0 }
@media (max-width:640px) { .cap-title { letter-spacing:6px } .caption { bottom:11% } .newflame { transform:translate(-50%,-50%) scale(.82) } }
</style>
