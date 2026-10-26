<script setup>
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { disciples } from '../api/auth'

const router = useRouter()

const kw = ref('')
const page = reactive({ current: 1, size: 5, pages: 1, total: 0 })
const list = ref([])
const loading = ref(false)
const errMsg = ref('')

function fmt(v) {
  return v ? String(v).replace('T', ' ').slice(0, 10) : '—'
}

async function load() {
  loading.value = true
  errMsg.value = ''
  try {
    const r = await disciples({ page: page.current, size: page.size, kw: kw.value })
    list.value = r.records || []
    page.total = r.total || 0
    page.pages = r.pages || 1
    page.current = r.current || 1
  } catch (e) {
    errMsg.value = e.message
  } finally {
    loading.value = false
  }
}

function search() {
  page.current = 1
  load()
}

function go(p) {
  if (p < 1 || p > page.pages) return
  page.current = p
  load()
}

onMounted(load)
</script>

<template>
  <section class="card">
    <h2>名 录</h2>
    <p class="sub">山门在籍弟子 · Disciples of the Sword</p>

    <div class="err" :class="{ show: errMsg }">{{ errMsg }}</div>

    <div class="hall-search">
      <input v-model="kw" placeholder="搜道号或门派" @keydown.enter="search" />
      <button type="button" @click="search">寻</button>
    </div>

    <ul class="hall">
      <li v-for="d in list" :key="d.uid" class="hall-item">
        <div class="who">
          {{ d.uid }}
          <i>{{ (d.sect || '剑') + ' 家' }}</i>
        </div>
        <div class="meta">
          <div>{{ d.invite || '无引荐' }}</div>
          <div>入门 {{ fmt(d.createTime) }}</div>
        </div>
      </li>
      <li v-if="!loading && !list.length" class="hall-item">
        <div class="who">查无此人</div>
      </li>
    </ul>

    <div class="pager">
      <button type="button" :disabled="page.current <= 1" @click="go(page.current - 1)">
        上一页
      </button>
      <span>{{ page.current }} / {{ page.pages }} · 共 {{ page.total }} 位</span>
      <button type="button" :disabled="page.current >= page.pages" @click="go(page.current + 1)">
        下一页
      </button>
    </div>

    <button class="btn ghost" type="button" style="margin-top: 18px" @click="router.push('/home')">
      回道碑
    </button>
  </section>
</template>
