/**
 * 剑气 / 灵光 粒子引擎
 * 用法：组件内 const { canvasRef } = useSwordFx()，onMounted 后自动开始渲染；
 *      其他组件通过 burstQi(n) 主动催发剑气。
 */
import { onMounted, onBeforeUnmount, ref } from 'vue'

let controller = null

function createController(canvas) {
  const ctx = canvas.getContext('2d')
  let W = 0
  let H = 0
  let dpr = 1
  let raf = 0
  let tick = 0

  const motes = []
  const qi = []

  function resize() {
    dpr = Math.min(window.devicePixelRatio || 1, 2)
    W = canvas.clientWidth
    H = canvas.clientHeight
    canvas.width = Math.floor(W * dpr)
    canvas.height = Math.floor(H * dpr)
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
  }

  function seedMotes() {
    motes.length = 0
    const n = Math.max(40, Math.min(120, Math.round((W * H) / 14000)))
    for (let i = 0; i < n; i++) {
      motes.push({
        x: Math.random() * W,
        y: Math.random() * H,
        r: Math.random() * 1.6 + 0.5,
        vy: -(Math.random() * 0.28 + 0.08),
        vx: (Math.random() - 0.5) * 0.22,
        a: Math.random() * 0.5 + 0.15,
        ph: Math.random() * Math.PI * 2,
        gold: Math.random() < 0.35
      })
    }
  }

  function spawnQi(force) {
    if (!force && Math.random() > 0.45) return
    const fromLeft = Math.random() < 0.5
    qi.push({
      x: fromLeft ? -120 : W + 120,
      y: H * (0.12 + Math.random() * 0.72),
      a: (Math.random() * 0.5 + 0.08) * (Math.random() < 0.5 ? 1 : -1),
      len: 160 + Math.random() * 320,
      w: 1 + Math.random() * 2.2,
      sp: 5 + Math.random() * 6,
      dir: fromLeft ? 1 : -1,
      life: 0,
      max: 70 + Math.random() * 50
    })
  }

  function drawMotes() {
    for (const m of motes) {
      m.x += m.vx
      m.y += m.vy
      if (m.y < -10) {
        m.y = H + 10
        m.x = Math.random() * W
      }
      if (m.x < -10) m.x = W + 10
      if (m.x > W + 10) m.x = -10

      const tw = 0.55 + 0.45 * Math.sin(tick * 0.03 + m.ph)
      ctx.beginPath()
      ctx.arc(m.x, m.y, m.r, 0, Math.PI * 2)
      ctx.fillStyle = m.gold
        ? `rgba(227,193,119,${m.a * tw})`
        : `rgba(190,235,225,${m.a * tw})`
      ctx.shadowBlur = 6
      ctx.shadowColor = m.gold ? 'rgba(227,193,119,.6)' : 'rgba(127,211,196,.6)'
      ctx.fill()
    }
    ctx.shadowBlur = 0
  }

  function drawQi() {
    for (let i = qi.length - 1; i >= 0; i--) {
      const q = qi[i]
      q.life++
      if (q.life > q.max) {
        qi.splice(i, 1)
        continue
      }
      q.x += Math.cos(q.a) * q.sp * q.dir
      q.y += Math.sin(q.a) * q.sp * 0.25

      const p = Math.max(1 - q.life / q.max, 0)
      const al = Math.sin(p * Math.PI)

      ctx.save()
      ctx.translate(q.x, q.y)
      ctx.rotate(q.a)
      const g = ctx.createLinearGradient(0, 0, q.len, 0)
      g.addColorStop(0, 'rgba(127,211,196,0)')
      g.addColorStop(0.45, `rgba(200,246,238,${0.85 * al})`)
      g.addColorStop(0.75, `rgba(227,193,119,${0.35 * al})`)
      g.addColorStop(1, 'rgba(255,255,255,0)')
      ctx.strokeStyle = g
      ctx.lineWidth = q.w
      ctx.lineCap = 'round'
      ctx.shadowBlur = 16
      ctx.shadowColor = 'rgba(127,211,196,.75)'
      ctx.beginPath()
      ctx.moveTo(0, 0)
      ctx.lineTo(q.len, 0)
      ctx.stroke()
      ctx.restore()
      ctx.shadowBlur = 0
    }
  }

  function frame() {
    tick++
    ctx.clearRect(0, 0, W, H)
    drawMotes()
    if (tick % 46 === 0) spawnQi(false)
    drawQi()
    raf = requestAnimationFrame(frame)
  }

  const onResize = () => {
    resize()
    seedMotes()
  }

  return {
    start() {
      onResize()
      window.addEventListener('resize', onResize)
      raf = requestAnimationFrame(frame)
    },
    stop() {
      cancelAnimationFrame(raf)
      window.removeEventListener('resize', onResize)
    },
    burst(n = 1) {
      for (let i = 0; i < n; i++) spawnQi(true)
    }
  }
}

export function useSwordFx() {
  const canvasRef = ref(null)

  onMounted(() => {
    if (!canvasRef.value) return
    controller = createController(canvasRef.value)
    controller.start()
  })

  onBeforeUnmount(() => {
    if (controller) {
      controller.stop()
      controller = null
    }
  })

  return { canvasRef }
}

/** 主动催发剑气（供任意组件调用） */
export function burstQi(n = 4) {
  if (controller) controller.burst(n)
}
