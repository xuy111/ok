<script setup>
import SwordStage from './components/SwordStage.vue'
import BrandPanel from './components/BrandPanel.vue'
import SlashOverlay from './components/SlashOverlay.vue'
import { slash } from './composables/useSlash'
</script>

<template>
  <SwordStage />

  <main class="wrap">
    <div class="panel">
      <BrandPanel />
      <router-view v-slot="{ Component }">
        <transition name="page" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </div>
  </main>

  <SlashOverlay :active="slash.active" :word="slash.word" :tip="slash.tip" />
</template>
