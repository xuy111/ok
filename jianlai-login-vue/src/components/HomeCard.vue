<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { me, logout, logs, stats } from '../api/auth'
import { openSlash } from '../composables/useSlash'
import { burstQi } from '../composables/useSwordFx'
import { clearToken, clearUid, loadUid } from '../composables/useRemember'

const router = useRouter()

const info = ref(null)
const errMsg = ref('')
const loading = ref(false)
const record = ref([])
const stat = ref({ disciples: 0 })

const initial = computed(() => (info.value?.uid || loadUid() || '剑').slice(0, 1))

const rows = computed(() => {
  const u = info.value
  if (!u) return []
  return [
    { k: '道号', v: u.uid },
    { k: '门派', v: (u.sect || '剑') + ' 家' },
    { k: '引荐', v: u.invite || '无' },
    { k: '入门', v: fmt(u.createTime) },
    { k: '最近入山', v: fmt(u.lastLoginTime) },
    { k: '入山次数', v: (u.loginCount ?? 0) + ' 次' },
    { k: '山门弟子', v: stat.value.disciples + ' 位' }
  ]
})

function fmt(v) {
  if (!v) return '—'
  const s = String(v).replace('T', ' ').slice(0, 16)
  return s
}

async function load() {
  loading.value = true
  try {
    info.value = await me()
    const [l, s] = await Promise.all([logs(5), stats()])
    record.value = l
    stat.value = s
  } catch (e) {
    errMsg.value = e.message
    clearToken()
    setTimeout(() => router.push('/login'), 800)
  } finally {
    loading.value = false
  }
}

async function onLogout() {
  try {
    await logout()
  } catch (e) {
    /* 令牌失效也照样出山 */
  }
  burstQi(4)
  openSlash('已出山门', '山门在你身后合上 · 后会有期')
  clearToken()
  clearUid()
  setTimeout(() => router.push('/login'), 2400)
}

onMounted(load)
</script>

<template>
  <section class="card">
    <h2>山 主</h2>
    <p class="sub">此处是你的道碑 · Your Sword Record</p>

    <div class="err" :class="{ show: errMsg }">{{ errMsg }}</div>

    <div class="pf-head">
      <div class="avatar">{{ initial }}</div>
      <div class="pf-name">
        <b>{{ info?.uid || '——' }}</b>
        <span>{{ (info?.sect || '剑') + ' 家一脉' }}</span>
      </div>
    </div>

    <ul class="profile">
      <li v-for="r in rows" :key="r.k" class="pf-row">
        <span>{{ r.k }}</span>
        <b>{{ r.v }}</b>
      </li>
      <li v-if="loading && !rows.length" class="pf-row">
        <span>道碑读取中…</span>
      </li>
    </ul>

    <div class="divider">近 五 次 入 山</div>
    <ul class="logs">
      <li v-for="(l, i) in record" :key="i" class="log-item">
        <i :class="l.success ? 'ok' : 'bad'"></i>
        <span class="log-time">{{ fmt(l.time) }}</span>
        <span class="log-msg">{{ l.msg }}</span>
      </li>
      <li v-if="!record.length" class="log-item">
        <i class="ok"></i>
        <span class="log-msg">尚无记录</span>
      </li>
    </ul>

    <button class="btn ghost" type="button" @click="router.push('/hall')">山门名录</button>
    <button class="btn ghost" type="button" style="margin-top: 12px" @click="router.push('/reset')">
      重铸剑诀
    </button>
    <button class="btn ghost danger" type="button" style="margin-top: 12px" @click="onLogout">
      出 山
    </button>

    <div class="divider">剑 来 一 句</div>
    <ul class="rules">
      <li>天底下没有什么事情是一剑解决不了的</li>
      <li>如果有，那就两剑</li>
    </ul>
  </section>
</template>
