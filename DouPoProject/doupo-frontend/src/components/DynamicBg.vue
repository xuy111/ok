<template>
  <div class="dyn-bg" :class="{ light, dense, hero, wallpaper }" aria-hidden="true" ref="root">
    <!-- 1. 主层：视频背景（全站共用，路由切换不重载） -->
    <video
      ref="vid"
      class="vid"
      src="/bg-home.mp4"
      poster="/bg-home-poster.jpg"
      autoplay
      muted
      loop
      playsinline
      preload="auto"
      disablepictureinpicture
    ></video>

    <!-- 1b. 桌面壁纸：与视频互斥，由导航栏按钮切换 -->
    <div
      class="wallpaper-img"
      :style="{ backgroundImage: 'url(/bg-wallpaper.jpg)' }"
    ></div>

    <!-- 2. 光晕：粉焰 + 青莲，呼吸 -->
    <div class="aura"></div>

    <!-- 3. 缓慢扫光 -->
    <div class="sweep"></div>

    <!-- 4. 灵火粒子 -->
    <div class="sparks">
      <span v-for="(s, i) in sparks" :key="i" :style="s"></span>
    </div>

    <!-- 5. 颗粒：盖住 4 倍放大的涂抹感，看起来像宣纸墨韵 -->
    <div class="grain"></div>

    <!-- 6. 明暗遮罩：保证前景文字 / 卡片可读 -->
    <div class="veil"></div>
  </div>
</template>

<script>
const SPARK_COUNT = 34

/** 稳定的伪随机，避免每次渲染粒子乱跳 */
function rnd(i, salt) {
  const x = Math.sin(i * 127.1 + salt * 311.7) * 43758.5453
  return x - Math.floor(x)
}

export default {
  name: 'DynamicBg',
  props: {
    /** 内容密集的页面（异火/图谱/融合/后台）：遮罩再压一档，避免透出卡片影响阅读 */
    dense: { type: Boolean, default: false },
    /** 图鉴页：横幅与卡片区更密，用专门的分层遮罩 */
    hero: { type: Boolean, default: false }
  },
  data() {
    return {
      light: document.body.classList.contains('light'),
      wallpaper: document.body.classList.contains('wallpaper'),
      sparks: []
    }
  },
  created() {
    const list = []
    // 与动图配色一致：粉焰、青莲、月白
    const palette = ['#ffd0e4', '#ff9ecb', '#7fe6ff', '#cfe9ff', '#ffffff']
    for (let i = 0; i < SPARK_COUNT; i++) {
      const size = 1.4 + rnd(i, 1) * 3.2
      list.push({
        left: (rnd(i, 2) * 100).toFixed(2) + '%',
        width: size.toFixed(1) + 'px',
        height: size.toFixed(1) + 'px',
        background: palette[i % palette.length],
        boxShadow: `0 0 ${(6 + size * 3.2).toFixed(0)}px ${(size * 0.9).toFixed(1)}px rgba(255,150,200,.5)`,
        animationDuration: (14 + rnd(i, 3) * 15).toFixed(1) + 's',
        animationDelay: '-' + (rnd(i, 4) * 22).toFixed(1) + 's',
        '--dx': ((rnd(i, 5) - 0.5) * 170).toFixed(0) + 'px',
        opacity: (0.32 + rnd(i, 6) * 0.6).toFixed(2)
      })
    }
    this.sparks = list
  },
  mounted() {
    this.mq = window.matchMedia('(prefers-reduced-motion: reduce)')
    this.reduced = this.mq.matches
    // 用户开启「减少动效」时，只保留 poster 静态帧
    if (this.reduced) this.pauseVideo()

    this.observer = new MutationObserver(() => {
      this.light = document.body.classList.contains('light')
      this.wallpaper = document.body.classList.contains('wallpaper')
    })
    this.observer.observe(document.body, { attributes: true, attributeFilter: ['class'] })

    if (!this.reduced) {
      this.target = { x: 0, y: 0 }
      this.onMove = this.handleMove.bind(this)
      window.addEventListener('mousemove', this.onMove, { passive: true })
    }
  },
  beforeUnmount() {
    if (this.observer) this.observer.disconnect()
    if (this.onMove) window.removeEventListener('mousemove', this.onMove)
    if (this.raf) cancelAnimationFrame(this.raf)
  },
  methods: {
    pauseVideo() {
      const v = this.$refs.vid
      if (!v) return
      v.removeAttribute('autoplay')
      try { v.pause() } catch (e) { /* 忽略 */ }
    },
    /** 鼠标视差：目标值 → 逐帧缓动，避免生硬跟随 */
    handleMove(e) {
      if (!this.target) this.target = { x: 0, y: 0 }
      this.target.x = e.clientX / window.innerWidth - 0.5
      this.target.y = e.clientY / window.innerHeight - 0.5
      if (this.raf) return
      const cur = this.cur || (this.cur = { x: 0, y: 0 })
      const tick = () => {
        cur.x += (this.target.x - cur.x) * 0.055
        cur.y += (this.target.y - cur.y) * 0.055
        const el = this.$refs.root
        if (el) {
          el.style.setProperty('--mx', cur.x.toFixed(4))
          el.style.setProperty('--my', cur.y.toFixed(4))
        }
        if (Math.abs(this.target.x - cur.x) > 0.001 || Math.abs(this.target.y - cur.y) > 0.001) {
          this.raf = requestAnimationFrame(tick)
        } else {
          this.raf = null
        }
      }
      this.raf = requestAnimationFrame(tick)
    }
  }
}
</script>

<style scoped>
.dyn-bg {
  --mx: 0;
  --my: 0;
  position: fixed;
  inset: 0;
  z-index: 0;
  overflow: hidden;
  pointer-events: none;
  background: #05070d;
}

/* ---------- 1. 视频主层 ----------
   挂在 App 层，路由切换不会重建 video，视频不会重头播；
   轻微放大是为了给鼠标视差留出边缘余量。 */
.vid {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center 42%;
  background: #05070d;
  transform: translate3d(calc(var(--mx) * -14px), calc(var(--my) * -10px), 0) scale(1.045);
  will-change: transform;
}

/* ---------- 1b. 桌面壁纸：默认隐藏，切到壁纸模式时盖住视频 ---------- */
.wallpaper-img {
  position: absolute;
  inset: 0;
  background-size: cover;
  background-position: center 55%;
  background-repeat: no-repeat;
  opacity: 0;
  transition: opacity .6s ease;
  transform: translate3d(calc(var(--mx) * -12px), calc(var(--my) * -8px), 0) scale(1.04);
  will-change: transform, opacity;
}
.dyn-bg.wallpaper .wallpaper-img { opacity: 1; }
.dyn-bg.wallpaper .vid { opacity: 0; }

/* ---------- 2. 光晕（粉焰 + 青莲） ---------- */
.aura {
  position: absolute;
  inset: -12%;
  background:
    radial-gradient(40% 36% at 62% 38%, rgba(255, 120, 190, .3), transparent 70%),
    radial-gradient(34% 30% at 40% 30%, rgba(110, 220, 255, .22), transparent 70%),
    radial-gradient(48% 44% at 30% 78%, rgba(190, 90, 240, .2), transparent 74%);
  mix-blend-mode: screen;
  filter: blur(12px);
  animation: auraPulse 16s ease-in-out infinite alternate;
}
@keyframes auraPulse {
  0%   { opacity: .5; transform: scale(1) translate3d(0, 0, 0) }
  100% { opacity: .95; transform: scale(1.12) translate3d(-1.5%, -2%, 0) }
}

/* ---------- 3. 扫光 ---------- */
.sweep {
  position: absolute;
  top: -40%;
  left: -60%;
  width: 46%;
  height: 190%;
  background: linear-gradient(90deg, transparent, rgba(255, 200, 230, .05), rgba(255, 235, 245, .1), rgba(255, 200, 230, .05), transparent);
  transform: rotate(16deg);
  animation: sweepMove 14s ease-in-out infinite;
}
@keyframes sweepMove {
  0%, 62%  { left: -70%; opacity: 0 }
  70%       { opacity: 1 }
  100%      { left: 120%; opacity: 0 }
}

/* ---------- 4. 灵火粒子 ---------- */
.sparks {
  position: absolute;
  inset: 0;
  overflow: hidden;
}
.sparks span {
  position: absolute;
  bottom: -8vh;
  border-radius: 50%;
  animation-name: sparkRise;
  animation-timing-function: linear;
  animation-iteration-count: infinite;
  will-change: transform, opacity;
}
@keyframes sparkRise {
  0%   { transform: translate3d(0, 0, 0) scale(.7); opacity: 0 }
  10%  { opacity: 1 }
  72%  { opacity: .75 }
  100% { transform: translate3d(var(--dx), -104vh, 0) scale(.25); opacity: 0 }
}

/* ---------- 5. 颗粒 ---------- */
.grain {
  position: absolute;
  inset: 0;
  opacity: .07;
  mix-blend-mode: overlay;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='160' height='160'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='160' height='160' filter='url(%23n)'/%3E%3C/svg%3E");
  background-size: 160px 160px;
}

/* ---------- 6. 遮罩：默认给登录/注册这类空页面，薄一点，能看清视频 ---------- */
.veil {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(180deg, rgba(6, 8, 14, .58) 0%, rgba(6, 8, 14, .2) 26%, rgba(6, 8, 14, .42) 68%, rgba(6, 8, 14, .8) 100%),
    radial-gradient(ellipse at 50% 44%, transparent 26%, rgba(5, 7, 12, .46) 74%, rgba(4, 6, 10, .78) 100%);
}

/* ---------- 内容页：再压一档，保证卡片与文字可读 ---------- */
.dyn-bg.dense .vid { filter: saturate(1.02) brightness(.88); }
.dyn-bg.dense .aura { opacity: .45 }
.dyn-bg.dense .veil {
  background:
    linear-gradient(180deg, rgba(6, 8, 14, .8) 0%, rgba(6, 8, 14, .58) 28%, rgba(6, 8, 14, .62) 64%, rgba(6, 8, 14, .9) 100%),
    radial-gradient(ellipse at 46% 44%, rgba(5, 7, 12, .4) 20%, rgba(5, 7, 12, .7) 70%, rgba(4, 6, 10, .9) 100%);
}

/* ---------- 图鉴页：横幅要露人，卡片区要压字（放在 dense 之后覆盖） ---------- */
.dyn-bg.hero .vid { filter: none; }
.dyn-bg.hero .veil {
  background:
    linear-gradient(180deg, rgba(6, 8, 14, .66) 0%, rgba(6, 8, 14, .26) 22%, rgba(6, 8, 14, .5) 45%, rgba(6, 8, 14, .64) 64%, rgba(6, 8, 14, .88) 100%),
    radial-gradient(ellipse at 50% 40%, transparent 38%, rgba(5, 7, 12, .36) 78%, rgba(4, 6, 10, .72) 100%);
}

/* ---------- 白昼模式：视频提亮成淡彩，配奶油色遮罩 ---------- */
.dyn-bg.light { background: #f7f1e6; }
.dyn-bg.light .vid { filter: brightness(1.5) saturate(.62) contrast(.72); }
.dyn-bg.light .aura {
  mix-blend-mode: multiply;
  opacity: .28;
}
.dyn-bg.light .sweep { display: none; }
.dyn-bg.light .grain { opacity: .045 }
.dyn-bg.light .sparks { opacity: .22; }
.dyn-bg.light .veil {
  background:
    linear-gradient(180deg, rgba(250, 246, 238, .88) 0%, rgba(250, 246, 238, .72) 38%, rgba(248, 242, 232, .94) 100%);
}
.dyn-bg.light.dense .veil {
  background:
    linear-gradient(180deg, rgba(250, 246, 238, .92) 0%, rgba(250, 246, 238, .82) 40%, rgba(248, 242, 232, .96) 100%);
}
.dyn-bg.light.hero .veil {
  background:
    linear-gradient(180deg, rgba(250, 246, 238, .86) 0%, rgba(250, 246, 238, .74) 38%, rgba(248, 242, 232, .94) 100%);
}

/* ---------- 桌面壁纸模式：压掉焰系特效，换成适配场景图的遮罩 ----------
   蜡笔小新雪景本身偏亮，遮罩只做轻量压暗，保证内容页文字仍可读。 */
.dyn-bg.wallpaper .aura,
.dyn-bg.wallpaper .sweep,
.dyn-bg.wallpaper .sparks { display: none; }
.dyn-bg.wallpaper .grain { opacity: .05; }
.dyn-bg.wallpaper .veil {
  background: linear-gradient(180deg, rgba(8, 12, 22, .34) 0%, rgba(8, 12, 22, .12) 30%, rgba(8, 12, 22, .28) 64%, rgba(8, 12, 22, .62) 100%);
}
.dyn-bg.wallpaper.dense .veil {
  background: linear-gradient(180deg, rgba(8, 12, 22, .62) 0%, rgba(8, 12, 22, .46) 30%, rgba(8, 12, 22, .5) 64%, rgba(8, 12, 22, .78) 100%);
}
.dyn-bg.wallpaper.hero .veil {
  background: linear-gradient(180deg, rgba(8, 12, 22, .42) 0%, rgba(8, 12, 22, .14) 26%, rgba(8, 12, 22, .34) 58%, rgba(8, 12, 22, .7) 100%);
}
/* 白昼 + 壁纸同时开启时，用浅色遮罩，避免深罩把场景图压成灰 */
.dyn-bg.wallpaper.light .veil {
  background: linear-gradient(180deg, rgba(250, 246, 238, .5) 0%, rgba(250, 246, 238, .24) 34%, rgba(248, 242, 232, .62) 100%);
}
.dyn-bg.wallpaper.light.dense .veil {
  background: linear-gradient(180deg, rgba(250, 246, 238, .74) 0%, rgba(250, 246, 238, .6) 40%, rgba(248, 242, 232, .86) 100%);
}

/* ---------- 无障碍：偏好减少动效时静止 ---------- */
@media (prefers-reduced-motion: reduce) {
  .vid { transform: none; animation: none !important; }
  .aura, .sweep, .sparks span { animation: none !important; }
  .sparks { display: none; }
}

/* ---------- 窄屏：竖构图时把人物往上挪，避免只看到胸口以下 ---------- */
@media (max-width: 860px) {
  .vid {
    object-position: center 38%;
    transform: translate3d(0, calc(var(--my) * -8px), 0) scale(1.08);
  }
}
</style>
