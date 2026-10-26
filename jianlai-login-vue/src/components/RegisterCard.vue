<script setup>
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import SwordField from './SwordField.vue'
import { register, checkUid } from '../api/auth'
import { openSlash } from '../composables/useSlash'
import { burstQi } from '../composables/useSwordFx'
import { saveUid, saveToken } from '../composables/useRemember'

const router = useRouter()

const cardRef = ref(null)
const uidRef = ref(null)

const form = reactive({
  uid: '',
  pwd: '',
  confirm: '',
  invite: '',
  sect: '剑',
  agree: false
})

const errMsg = ref('')
const loading = ref(false)

const sects = [
  { k: '儒', d: '浩然天下' },
  { k: '道', d: '青冥天下' },
  { k: '释', d: '莲花天下' },
  { k: '兵', d: '剑气长城' }
]

/* 剑意强度：长度 + 字符种类 */
const strength = computed(() => {
  const p = form.pwd
  if (!p) return { level: 0, text: '', tip: '' }
  let s = 0
  if (p.length >= 6) s++
  if (p.length >= 10) s++
  if (/[A-Za-z]/.test(p) && /\d/.test(p)) s++
  if (/[^A-Za-z0-9]/.test(p)) s++
  const level = Math.min(s, 3)
  const map = [
    { text: '剑诀未成', tip: '尚需六字以上' },
    { text: '初入境', tip: '再长些，或掺入数字字母' },
    { text: '剑意渐凝', tip: '加个标点，剑意更纯' },
    { text: '剑意圆满', tip: '此诀可护一山' }
  ]
  return { level, ...map[level] }
})

/* 两遍剑诀是否相合 */
const match = computed(() => {
  if (!form.confirm) return { state: '', text: '' }
  return form.confirm === form.pwd
    ? { state: 'ok', text: '两诀相合' }
    : { state: 'bad', text: '两诀不合' }
})

/* 道号实时查重（防抖 500ms，mock 模式下跳过） */
const uidHint = ref('')
let timer = null
watch(
  () => form.uid,
  (v) => {
    uidHint.value = ''
    clearTimeout(timer)
    const name = String(v || '').trim()
    if (!name || import.meta.env.VITE_USE_MOCK === 'true') return
    timer = setTimeout(async () => {
      try {
        const r = await checkUid(name)
        uidHint.value = r.exists ? 'used' : 'free'
      } catch (e) {
        uidHint.value = ''
      }
    }, 500)
  }
)
onBeforeUnmount(() => clearTimeout(timer))

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
    fail('道号不可为空 · 无名何以立派')
    uidRef.value?.focus()
    return
  }
  if (u.length > 12) {
    fail('道号过长 · 山门石碑刻不下')
    uidRef.value?.focus()
    return
  }
  if (form.pwd.length < 6) {
    fail('剑诀不足六字 · 尚难护山')
    return
  }
  if (form.pwd !== form.confirm) {
    fail('两遍剑诀不同 · 心不静则剑不纯')
    return
  }
  if (!form.agree) {
    fail('未允山规 · 不可立派')
    return
  }

  errMsg.value = ''
  loading.value = true
  try {
    const res = await register({
      uid: u,
      pwd: form.pwd,
      confirm: form.confirm,
      invite: form.invite,
      sect: form.sect,
      agree: form.agree
    })
    burstQi(4)
    openSlash('山门已立', `恭喜 ${res.uid} 山主 · ${form.sect} 家一脉`)
    if (res.token) saveToken(res.token)
    saveUid(res.uid)
    setTimeout(() => router.push('/home'), 2600)
  } catch (e) {
    fail(e.message || '天时不利 · 立派未成')
  } finally {
    loading.value = false
  }
}

onMounted(() => uidRef.value?.focus())
</script>

<template>
  <section class="card" ref="cardRef">
    <h2>立 派</h2>
    <p class="sub">开宗立派，自成一山 · Found Your Sect</p>

    <div class="err" :class="{ show: errMsg }">{{ errMsg }}</div>

    <SwordField
      id="r-uid"
      ref="uidRef"
      v-model="form.uid"
      label="道号 / 账号"
      placeholder="请留下你的道号"
      icon="user"
      autocomplete="username"
      :disabled="loading"
      @enter="submit"
    />

    <div class="match" :class="uidHint === 'used' ? 'bad' : 'ok'" v-show="uidHint">
      {{ uidHint === 'used' ? '此道号已有人用 · 换一个吧' : '此道号可用' }}
    </div>

    <SwordField
      id="r-pwd"
      v-model="form.pwd"
      label="剑诀 / 密码"
      placeholder="至少六字，掺入数字字母更佳"
      icon="lock"
      type="toggle"
      autocomplete="new-password"
      :disabled="loading"
      @enter="submit"
    />

    <div class="strength" :class="'lv' + strength.level" v-show="form.pwd">
      <div class="strength-bar"><i></i></div>
      <div class="strength-text">
        <b>{{ strength.text }}</b>
        <span>{{ strength.tip }}</span>
      </div>
    </div>

    <SwordField
      id="r-confirm"
      v-model="form.confirm"
      label="再诵一遍剑诀"
      placeholder="请再输入一次剑诀"
      icon="lock"
      type="toggle"
      autocomplete="new-password"
      :disabled="loading"
      @enter="submit"
    />

    <div class="match" :class="match.state" v-show="form.confirm">{{ match.text }}</div>

    <SwordField
      id="r-invite"
      v-model="form.invite"
      label="山门引荐（可空）"
      placeholder="若有引荐之人，请留其名"
      icon="scroll"
      :disabled="loading"
      @enter="submit"
    />

    <div class="pick">
      <label>择一脉</label>
      <div class="sects">
        <div
          v-for="s in sects"
          :key="s.k"
          class="sect"
          :class="{ on: form.sect === s.k }"
          :title="s.d"
          @click="form.sect = s.k"
        >
          {{ s.k }}
        </div>
      </div>
      <span class="pick-tip">{{ sects.find((x) => x.k === form.sect)?.d }}</span>
    </div>

    <label class="agree" :class="{ checked: form.agree }">
      <input type="checkbox" v-model="form.agree" />
      <span>我已读过并允诺<em>《山规三条》</em></span>
    </label>

    <button class="btn" type="button" :class="{ loading }" :disabled="loading" @click="submit">
      <span v-if="loading" class="spinner"></span>
      {{ loading ? '剑气凝聚中' : '开宗立派' }}
    </button>

    <div class="divider">山 规 三 条</div>
    <ul class="rules">
      <li>剑不可轻出，出则必有所护</li>
      <li>山上无小事，一言一行皆修行</li>
      <li>遇不平事，可讲道理，也可讲剑</li>
    </ul>

    <p class="signup">
      已有山头？
      <router-link to="/login">回山门</router-link>
    </p>
  </section>
</template>
