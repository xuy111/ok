<template>
  <transition name="fade">
    <div v-if="show" class="mask" @click.self="close">
      <div class="box" :style="accentStyle">
        <button class="close" @click="close">✕</button>
        <h3>异火降临</h3>
        <p class="sub">
          每日 {{ info.limit }} 次机缘　·　今日剩余
          <b>{{ info.left }}</b> 次
        </p>

        <div class="stage">
          <!-- 未抽：火种 -->
          <div v-if="!result" class="seed" :class="{ rolling }">
            <div class="seed-core">火</div>
            <span class="ring r1"></span>
            <span class="ring r2"></span>
          </div>

          <!-- 已抽：翻牌 -->
          <div v-else class="got" :class="{ show: revealed }">
            <div class="got-glow"></div>
            <div class="got-icon">{{ result.item.icon || '🔥' }}</div>
            <div class="got-name">{{ result.item.name }}</div>
            <div class="got-tags">
              <span class="tag" v-if="result.item.rankNo > 0">异火榜 #{{ result.item.rankNo }}</span>
              <span class="tag">{{ result.item.grade }}</span>
            </div>
            <div class="got-quote" v-if="result.item.quote">{{ result.item.quote }}</div>
            <div class="got-new" v-if="result.isNew">首次收服 · 已入图鉴</div>
            <div class="got-new dup" v-else>已拥有 · 修为 +1</div>
          </div>
        </div>

        <div class="actions">
          <button class="btn ghost" v-if="result" @click="reset">再抽一次</button>
          <button class="btn" :disabled="rolling || info.left <= 0" @click="doDraw">
            {{ rolling ? '异火汇聚中…' : info.left > 0 ? (result ? '继续抽取' : '开始降临') : '今日已达上限' }}
          </button>
          <button class="btn ghost" v-if="result" @click="close">收入囊中</button>
        </div>

        <p class="tip" v-if="msg">{{ msg }}</p>
      </div>
    </div>
  </transition>
</template>

<script>
import api from '../api'
import { colorOf } from '../theme'
import { artOf } from '../art'

export default {
  name: 'DrawModal',
  props: { show: { type: Boolean, default: false } },
  emits: ['close', 'drawn'],
  data() {
    return {
      info: { limit: 3, used: 0, left: 3 },
      result: null,
      rolling: false,
      revealed: false,
      msg: ''
    }
  },
  computed: {
    accentStyle() {
      const c = colorOf(this.result ? this.result.item.color : 'red')
      return { '--c-hex': c.hex, '--c-dim': c.dim, '--c-rgb': c.rgb }
    }
  },
  watch: {
    show(v) {
      if (v) {
        this.result = null
        this.revealed = false
        this.msg = ''
        this.loadInfo()
      }
    }
  },
  methods: {
    artOf,
    async loadInfo() {
      try {
        const res = await api.drawInfo()
        if (res && res.code === 200) this.info = res.data
      } catch (e) { /* 忽略 */ }
    },
    reset() {
      this.result = null
      this.revealed = false
      this.msg = ''
    },
    async doDraw() {
      if (this.rolling || this.info.left <= 0) return
      this.rolling = true
      this.result = null
      this.revealed = false
      this.playFire()
      try {
        // 让「火种汇聚」动画先走一会儿
        const p = api.draw()
        await new Promise(r => setTimeout(r, 900))
        const res = await p
        if (res && res.code === 200) {
          this.result = res.data
          this.info = { limit: res.data.limit, used: res.data.used, left: res.data.left }
          this.$nextTick(() => { this.revealed = true })
          this.crackle()
          this.$emit('drawn', res.data)
        }
      } catch (e) {
        this.msg = e.message
      } finally {
        this.rolling = false
      }
    },
    /* ---------- Web Audio：不依赖音频文件，纯合成火焰声 ---------- */
    ctx() {
      if (!this._ac) {
        const AC = window.AudioContext || window.webkitAudioContext
        if (!AC) return null
        this._ac = new AC()
      }
      if (this._ac.state === 'suspended') this._ac.resume()
      return this._ac
    },
    playFire() {
      const ac = this.ctx()
      if (!ac) return
      const dur = 1.1
      const buf = ac.createBuffer(1, ac.sampleRate * dur, ac.sampleRate)
      const d = buf.getChannelData(0)
      for (let i = 0; i < d.length; i++) {
        d[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / d.length, 2)
      }
      const src = ac.createBufferSource()
      src.buffer = buf
      const lp = ac.createBiquadFilter()
      lp.type = 'lowpass'
      lp.frequency.setValueAtTime(280, ac.currentTime)
      lp.frequency.exponentialRampToValueAtTime(2600, ac.currentTime + dur * 0.7)
      const g = ac.createGain()
      g.gain.setValueAtTime(0.001, ac.currentTime)
      g.gain.exponentialRampToValueAtTime(0.22, ac.currentTime + 0.18)
      g.gain.exponentialRampToValueAtTime(0.001, ac.currentTime + dur)
      src.connect(lp); lp.connect(g); g.connect(ac.destination)
      src.start()
    },
    crackle() {
      const ac = this.ctx()
      if (!ac) return
      // 高频「噼啪」+ 一个上扬的叮
      const osc = ac.createOscillator()
      const g = ac.createGain()
      osc.type = 'triangle'
      osc.frequency.setValueAtTime(880, ac.currentTime)
      osc.frequency.exponentialRampToValueAtTime(1760, ac.currentTime + 0.28)
      g.gain.setValueAtTime(0.0001, ac.currentTime)
      g.gain.exponentialRampToValueAtTime(0.14, ac.currentTime + 0.04)
      g.gain.exponentialRampToValueAtTime(0.0001, ac.currentTime + 0.5)
      osc.connect(g); g.connect(ac.destination)
      osc.start(); osc.stop(ac.currentTime + 0.55)
    },
    close() {
      this.$emit('close')
    }
  }
}
</script>

<style scoped>
.mask { position: fixed; inset: 0; z-index: 95; display: grid; place-items: center;
  padding: 20px; background: rgba(0,0,0,.72); backdrop-filter: blur(5px); }
.box { position: relative; width: min(430px, 100%); padding: 26px 24px 20px; border-radius: 16px;
  text-align: center; border: 1px solid rgba(var(--c-rgb),.35); background: var(--panel-solid);
  box-shadow: 0 30px 80px rgba(0,0,0,.65), 0 0 50px rgba(var(--c-rgb),.16);
  animation: cardIn .3s ease both; }
.close { position: absolute; top: 12px; right: 12px; width: 26px; height: 26px; border-radius: 50%;
  cursor: pointer; font-size: 11px; color: var(--muted); background: rgba(0,0,0,.25);
  border: 1px solid rgba(212,175,55,.25); }
h3 { font-size: 19px; letter-spacing: 5px; color: var(--c-hex); font-weight: 700; }
.sub { margin-top: 8px; font-size: 12px; color: var(--label); letter-spacing: 1px; }
.sub b { color: var(--c-hex); font-size: 14px; }

.stage { height: auto; min-height: 230px; display: grid; place-items: center; position: relative; margin: 8px 0; }

/* 火种 */
.seed { position: relative; width: 130px; height: 130px; display: grid; place-items: center; }
.seed-core { width: 74px; height: 74px; border-radius: 50%; display: grid; place-items: center;
  font-size: 26px; color: #1a1206; font-weight: 800;
  background: radial-gradient(circle at 38% 32%, var(--c-hex), var(--c-dim));
  box-shadow: 0 0 40px rgba(var(--c-rgb),.55); animation: flamePulse 1.6s ease-in-out infinite; }
.seed.rolling .seed-core { animation: spinFlame .45s linear infinite; }
@keyframes spinFlame {
  0%{ transform:scale(1) rotate(0); filter:brightness(1) }
  50%{ transform:scale(1.14) rotate(180deg); filter:brightness(1.5) }
  100%{ transform:scale(1) rotate(360deg); filter:brightness(1) }
}
.ring { position: absolute; inset: 0; border-radius: 50%; border: 1px solid rgba(var(--c-rgb),.5);
  animation: ripple 2s ease-out infinite; }
.ring.r2 { animation-delay: 1s; }
@keyframes ripple { 0%{ transform:scale(.7); opacity:1 } 100%{ transform:scale(1.5); opacity:0 } }

/* 抽到的卡 */
.got { position: relative; width: 100%; padding: 18px 16px; border-radius: 14px;
  border: 1px solid rgba(var(--c-rgb),.45); background: var(--card);
  opacity: 0; transform: rotateY(-90deg) scale(.9); transition: .55s cubic-bezier(.2,.8,.3,1); }
.got.show { opacity: 1; transform: rotateY(0) scale(1); }
.got-glow { position: absolute; inset: -30% -10% auto; height: 160px;
  background: radial-gradient(circle, rgba(var(--c-rgb),.3), transparent 70%); pointer-events: none; }
.got-art { height: 132px; border-radius: 10px; background-size: cover; background-position: center 34%;
  border: 1px solid rgba(var(--c-rgb),.35); box-shadow: 0 0 26px rgba(var(--c-rgb),.22); }
.got-icon { font-size: 44px; line-height: 1; }
.got-name { margin-top: 10px; font-size: 21px; letter-spacing: 3px; color: var(--txt); font-weight: 700; }
.got-tags { margin-top: 9px; display: flex; gap: 7px; justify-content: center; flex-wrap: wrap; }
.tag { font-size: 11px; padding: 3px 9px; border-radius: 20px; color: var(--c-hex);
  background: rgba(var(--c-rgb),.12); border: 1px solid rgba(var(--c-rgb),.35); }
.got-quote { margin-top: 12px; font-size: 12.5px; color: var(--sub); letter-spacing: 1px; }
.got-new { margin-top: 10px; font-size: 11.5px; color: #7fd6a0; letter-spacing: 1px; }
.got-new.dup { color: var(--label); }

.actions { display: flex; gap: 10px; justify-content: center; flex-wrap: wrap; margin-top: 6px; }
.btn { height: 38px; padding: 0 22px; border-radius: 8px; cursor: pointer; font-size: 13.5px;
  border: none; font-weight: 700; letter-spacing: 2px; color: #1a1206;
  background: linear-gradient(90deg, var(--c-dim), var(--c-hex)); }
.btn.ghost { background: transparent; color: var(--c-hex); border: 1px solid rgba(var(--c-rgb),.42); }
.btn:hover { filter: brightness(1.08); }
.btn:disabled { opacity: .55; cursor: default; }
.tip { margin-top: 12px; font-size: 12px; color: #ff9d7a; }
</style>
