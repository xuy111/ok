<script setup>
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import SwordField from './SwordField.vue'
import { login } from '../api/auth'
import { openSlash } from '../composables/useSlash'
import { burstQi } from '../composables/useSwordFx'
import { saveUid, loadUid, clearUid, saveToken, saveRefreshToken } from '../composables/useRemember'

const router = useRouter()

const cardRef = ref(null)
const uidRef = ref(null)
const pwdRef = ref(null)

const form = reactive({ uid: '', pwd: '', remember: true })
const errMsg = ref('')
const loading = ref(false)

const sects = ['儒', '道', '释', '兵']

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

async function handleLogin() {
  if (loading.value) return
  const u = form.uid.trim()
  if (!u) {
    fail('道号不可为空 · 请留下姓名')
    uidRef.value?.focus()
    return
  }
  if (form.pwd.length < 6) {
    fail('剑诀不足六字 · 尚难登门')
    pwdRef.value?.focus()
    return
  }

  errMsg.value = ''
  loading.value = true
  try {
    const res = await login({ uid: u, pwd: form.pwd, remember: form.remember })
    burstQi(4)
    openSlash('山门已开', `恭迎 ${res.uid} 山主 · 片刻后自行散去`)
    if (res.token) saveToken(res.token)
    form.remember ? saveUid(res.uid) : clearUid()
    form.pwd = ''
    setTimeout(() => router.push('/home'), 2600)
  } catch (e) {
    fail(e.message || '山门未应 · 请稍后再试')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  const saved = loadUid()
  if (saved) form.uid = saved
  uidRef.value?.focus()
})
</script>

<template>
  <section class="card" ref="cardRef">
    <h2>山 门</h2>
    <p class="sub">验明正身，方可入山 · Enter the Sword Path</p>

    <div class="err" :class="{ show: errMsg }">{{ errMsg }}</div>

    <SwordField
      id="uid"
      ref="uidRef"
      v-model="form.uid"
      label="道号 / 账号"
      placeholder="请输入道号"
      icon="user"
      autocomplete="username"
      :disabled="loading"
      @enter="handleLogin"
    />

    <SwordField
      id="pwd"
      ref="pwdRef"
      v-model="form.pwd"
      label="剑诀 / 密码"
      placeholder="请输入剑诀"
      icon="lock"
      type="toggle"
      autocomplete="current-password"
      :disabled="loading"
      @enter="handleLogin"
    />

    <div class="row">
      <label class="remember">
        <input type="checkbox" v-model="form.remember" />
        记住此山
      </label>
      <router-link class="forgot" to="/reset">忘却剑诀？</router-link>
    </div>

    <button class="btn" type="button" :class="{ loading }" :disabled="loading" @click="handleLogin">
      <span v-if="loading" class="spinner"></span>
      {{ loading ? '剑气凝聚中' : '仗剑入山' }}
    </button>

    <div class="divider">三 教 通 行</div>
    <div class="sects">
      <div
        v-for="s in sects"
        :key="s"
        class="sect"
        :title="s + '家'"
        @click="fail('此处山路未通 · 仅为演示')"
      >
        {{ s }}
      </div>
    </div>

    <p class="signup">
      尚无山头？
      <router-link to="/register">在此开宗立派</router-link>
    </p>
  </section>
</template>
