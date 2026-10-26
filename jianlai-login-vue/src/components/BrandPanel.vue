<script setup>
defineProps({
  kicker: { type: String, default: '骊珠洞天 · 浩然天下' },
  seal: { type: String, default: '陈平安' },
  routes: {
    type: Array,
    default: () => ['剑气长城', '落魄山', '青冥天下', '莲花洞天']
  }
})
</script>

<template>
  <section class="brand">
    <div class="kicker">{{ kicker }}</div>
    <div class="title"><span>剑</span><span>来</span></div>
    <span class="seal">{{ seal }}</span>
    <p class="verse">
      天道崩塌，<em>我陈平安</em>，唯有一剑。<br />
      可搬山、断江、倒海、摧城、摘星——<br />
      亦可，一剑开天。
    </p>
    <div class="route">
      <span v-for="r in routes" :key="r" class="chip">{{ r }}</span>
    </div>
  </section>
</template>
