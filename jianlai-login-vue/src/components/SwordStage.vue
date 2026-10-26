<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
import { useSwordFx } from '../composables/useSwordFx'

const { canvasRef } = useSwordFx()
const mtsRef = ref(null)
const moonRef = ref(null)

function onMove(e) {
  const x = e.clientX / window.innerWidth - 0.5
  const y = e.clientY / window.innerHeight - 0.5
  if (mtsRef.value) {
    mtsRef.value.style.transform = `translate3d(${x * -18}px,${y * -6}px,0)`
  }
  if (moonRef.value) {
    moonRef.value.style.transform = `translate3d(${x * 26}px,${y * 14}px,0)`
  }
}

onMounted(() => document.addEventListener('mousemove', onMove))
onBeforeUnmount(() => document.removeEventListener('mousemove', onMove))
</script>

<template>
  <div class="stage">
    <div class="sky"></div>
    <div class="moon" ref="moonRef"></div>

    <div class="mountains" ref="mtsRef">
      <svg viewBox="0 0 1440 700" preserveAspectRatio="none" aria-hidden="true">
        <defs>
          <linearGradient id="g1" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stop-color="#1b3243" />
            <stop offset="100%" stop-color="#101c27" />
          </linearGradient>
          <linearGradient id="g2" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stop-color="#122532" />
            <stop offset="100%" stop-color="#0b141d" />
          </linearGradient>
          <linearGradient id="g3" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stop-color="#080f16" />
            <stop offset="100%" stop-color="#05090e" />
          </linearGradient>
        </defs>
        <path
          fill="url(#g1)"
          opacity=".55"
          d="M0,470 C120,420 210,470 320,404 C420,344 520,412 620,372 C740,326 850,404 960,368 C1080,330 1180,392 1290,356 C1350,336 1400,352 1440,338 L1440,700 L0,700 Z"
        />
        <path
          fill="url(#g2)"
          opacity=".85"
          d="M0,556 C130,510 220,548 330,498 C440,448 540,520 660,486 C780,452 880,510 1000,478 C1120,446 1240,492 1340,462 C1390,447 1420,456 1440,448 L1440,700 L0,700 Z"
        />
        <path
          fill="url(#g3)"
          d="M0,616 C140,586 240,614 360,588 C480,562 580,600 700,580 C820,560 940,592 1060,574 C1180,556 1300,586 1440,566 L1440,700 L0,700 Z"
        />
      </svg>
    </div>

    <div class="mist"></div>

    <!-- 长剑 -->
    <svg class="sword" viewBox="0 0 120 620" aria-hidden="true">
      <defs>
        <linearGradient id="blade" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stop-color="#5d7480" />
          <stop offset="42%" stop-color="#e9f4f6" />
          <stop offset="55%" stop-color="#ffffff" />
          <stop offset="100%" stop-color="#435762" />
        </linearGradient>
        <linearGradient id="hilt" x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stop-color="#3a2b1e" />
          <stop offset="50%" stop-color="#7a5c38" />
          <stop offset="100%" stop-color="#2e2217" />
        </linearGradient>
        <linearGradient id="guard" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#e3c177" />
          <stop offset="100%" stop-color="#8d7434" />
        </linearGradient>
      </defs>
      <path d="M60,8 L70,96 L70,438 L50,438 L50,96 Z" fill="url(#blade)" />
      <path d="M60,8 L60,438" stroke="rgba(255,255,255,.55)" stroke-width="1.2" />
      <rect x="18" y="436" width="84" height="15" rx="5" fill="url(#guard)" />
      <rect x="52" y="451" width="16" height="112" rx="7" fill="url(#hilt)" />
      <rect x="52" y="466" width="16" height="4" fill="#e3c177" opacity=".5" />
      <rect x="52" y="486" width="16" height="4" fill="#e3c177" opacity=".5" />
      <rect x="52" y="506" width="16" height="4" fill="#e3c177" opacity=".5" />
      <circle cx="60" cy="572" r="13" fill="url(#guard)" />
      <circle cx="60" cy="572" r="5" fill="#5a4a22" />
    </svg>

    <canvas class="fx" ref="canvasRef"></canvas>
    <div class="mist" style="bottom:8vh;height:18vh;opacity:.6;animation-duration:34s"></div>
    <div class="grain"></div>
    <div class="vignette"></div>
  </div>
</template>
