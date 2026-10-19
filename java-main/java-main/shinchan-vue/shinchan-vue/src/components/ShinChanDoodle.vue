<script setup>
// 小新头像涂鸦组件
</script>

<template>
  <svg class="doodle" width="92" height="92" viewBox="0 0 120 120" aria-label="蜡笔小新头像">
    <ellipse cx="60" cy="130" rx="34" ry="14" fill="#000" opacity=".12" />
    <circle cx="60" cy="62" r="44" fill="var(--skin)" stroke="var(--ink)" stroke-width="4" />
    <path d="M40 26 Q60 6 80 26 Q60 16 40 26Z" fill="#3a3a2a" stroke="var(--ink)" stroke-width="3" />
    <line x1="42" y1="24" x2="78" y2="24" stroke="var(--ink)" stroke-width="3" />
    <circle cx="48" cy="58" r="5" fill="var(--ink)" />
    <circle cx="74" cy="58" r="5" fill="var(--ink)" />
    <path d="M50 84 Q60 96 72 84" stroke="var(--ink)" stroke-width="4" fill="none" stroke-linecap="round" />
    <circle cx="38" cy="74" r="6" fill="var(--pink)" opacity=".7" />
    <circle cx="84" cy="74" r="6" fill="var(--pink)" opacity=".7" />
  </svg>
</template>

<style scoped>
.doodle {
  position: absolute;
  top: -58px;
  right: -18px;
  transform: rotate(8deg);
}
</style>
