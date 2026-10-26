<script setup>
defineProps({
  active: { type: Boolean, default: false },
  word: { type: String, default: '山门已开' },
  tip: { type: String, default: '恭迎山主 · 片刻后自行散去' }
})
</script>

<template>
  <div class="slash" :class="{ on: active }">
    <div class="beam"></div>
    <div class="word">{{ word }}</div>
    <div class="tip">{{ tip }}</div>
  </div>
</template>
