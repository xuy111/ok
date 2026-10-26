<script setup>
import { onMounted, reactive, ref } from 'vue'
import SwordField from './SwordField.vue'
import { resetPwd } from '../api/auth'
import { openSlash } from '../composables/useSlash'
import { burstQi } from '../composables/useSwordFx'

const cardRef = ref(null)
const uidRef = ref(null)

const form = reactive({ uid: '', pwd: '', confirm: '' })
const errMsg = ref('')
const loading = ref(false)

function shake() {
  const el = cardRef.value
  if (!el) return
  el.classList.remove('shake')
  void el.offsetWidth
  el.classList.add('shake')
}

function fail(msg) {
  errMsg.value = msg
  shake()
}

async function submit() {
  if (loading.value) return
  const u = form.uid.trim()
  if (!u) {
    fail('道号不可为空 · 无主之剑不可重铸')
    uidRef.value?.focus()
    return
  }
  if (form.pwd.length < 6) {
    fail('新剑诀不足六字 · 难承剑意')
    return
  }
  if (form.pwd !== form.confirm) {
    fail('两遍剑诀不同 · 心不静则剑不纯')
    return
  }

  errMsg.value = ''
  loading.value = true
  try {
    const res = await resetPwd({ uid: u, pwd: form.pwd, confirm: form.confirm })
    burstQi(4)
    openSlash('剑诀重铸', `${res.uid} · 新诀已成，可再上剑道`)
    form.pwd = ''
    form.confirm = ''
  } catch (e) {
    fail(e.message || '炉火不济 · 重铸未成')
  } finally {
    loading.value = false
  }
}

onMounted(() => uidRef.value?.focus())
</script>

<template>
  <section class="card" ref="cardRef">
    <h2>重 铸</h2>
    <p class="sub">剑诀重铸，再上剑道 · Reset Your Sword</p>

    <div class="err" :class="{ show: errMsg }">{{ errMsg }}</div>

    <SwordField
      id="f-uid"
      ref="uidRef"
      v-model="form.uid"
      label="道号 / 账号"
      placeholder="请输入原道号"
      icon="user"
      autocomplete="username"
      :disabled="loading"
      @enter="submit"
    />

    <SwordField
      id="f-pwd"
      v-model="form.pwd"
      label="新剑诀"
      placeholder="至少六字"
      icon="key"
      type="toggle"
      autocomplete="new-password"
      :disabled="loading"
      @enter="submit"
    />

    <SwordField
      id="f-confirm"
      v-model="form.confirm"
      label="再诵新剑诀"
      placeholder="请再输入一次新剑诀"
      icon="key"
      type="toggle"
      autocomplete="new-password"
      :disabled="loading"
      @enter="submit"
    />

    <button class="btn" type="button" :class="{ loading }" :disabled="loading" @click="submit">
      <span v-if="loading" class="spinner"></span>
      {{ loading ? '炉火正旺' : '重铸剑诀' }}
    </button>

    <div class="divider">重 铸 须 知</div>
    <ul class="rules">
      <li>新诀不可与旧诀相同</li>
      <li>重铸之后，旧剑自散</li>
      <li>一月之内，只可重铸一次</li>
    </ul>

    <p class="signup">
      想起旧诀？
      <router-link to="/login">回山门</router-link>
    </p>
  </section>
</template>
