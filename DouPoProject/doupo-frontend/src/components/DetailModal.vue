<template>
  <transition name="fade">
    <div v-if="show" class="mask" @click.self="$emit('close')">
      <div class="modal" :style="accentStyle">
        <button class="close" @click="$emit('close')">✕</button>

        <!-- 异火插图（按原著形态） -->
        <div v-if="showArt" class="m-hero">
          <img :src="art" :alt="item.name" @error="artBroken = true" />
          <span class="hero-veil"></span>
          <span v-if="item.rankNo > 0" class="hero-rank">异火榜 #{{ item.rankNo }}</span>
          <span class="hero-cat" v-if="item.category !== '异火'">{{ item.category }}</span>
          <button class="immersive-btn" @click="openImmersive">
            <span class="ib-ico">◎</span> 沉浸观赏
          </button>
        </div>

        <div class="m-head" :class="{ 'no-icon': showArt }">
          <div class="m-icon" v-if="!showArt">{{ item.icon || '🔥' }}</div>
          <div class="m-title">
            <div class="m-name">
              {{ item.name }}
              <span v-if="item.rankNo > 0 && !showArt" class="rank">异火榜 #{{ item.rankNo }}</span>
            </div>
            <div class="m-tags">
              <span class="grade" :class="gradeClass">{{ item.grade }}</span>
              <span class="cat">{{ item.category }}</span>
              <span class="src">出处 · {{ item.source || '不详' }}</span>
            </div>
          </div>
        </div>

        <div class="m-body">
          <!-- 形态 + 难度 -->
          <div class="row2">
            <div class="block">
              <label>异火形态</label>
              <p class="form">{{ item.formDesc || '形态不详，只知灼热难当。' }}</p>
            </div>
            <div class="block">
              <label>收服难度</label>
              <div class="diff">
                <span class="stars">
                  <i v-for="n in 5" :key="n" :class="{ on: n <= (item.difficulty || 0) }">✦</i>
                </span>
                <em class="diff-txt">{{ diffText }}</em>
              </div>
              <div class="swatches" v-if="hasColor">
                <span v-for="k in colorKeys" :key="k" class="sw" :class="{ on: k === item.color }"
                      :style="{ background: colorHex(k) }" :title="'以' + colorLabel(k) + '之力渲染页面'"
                      @click="$emit('accent', k)"></span>
              </div>
            </div>
          </div>

          <!-- 持有者 / 功法 -->
          <div class="row2">
            <div class="block">
              <label>历代持有者</label>
              <div class="chips">
                <span v-for="h in holders" :key="h" class="chip">{{ h }}</span>
                <span v-if="!holders.length" class="none">无记载</span>
              </div>
            </div>
            <div class="block">
              <label>收服功法</label>
              <p class="method">{{ item.method || '无' }}</p>
            </div>
          </div>

          <!-- 台词 -->
          <div class="quote" v-if="item.quote">
            <span class="q-mark">“</span>{{ item.quote }}<span class="q-mark">”</span>
          </div>

          <!-- 简介 -->
          <div class="block">
            <label>简介</label>
            <p class="desc">{{ item.description || '暂无简介' }}</p>
          </div>

          <!-- 我的笔记 -->
          <div class="block note-block" v-if="collected">
            <label>我的笔记 <em>仅自己可见，存在数据库</em></label>
            <div class="note-row">
              <textarea v-model="note" rows="2" placeholder="例如：需去塔戈尔大沙漠寻找…"></textarea>
              <button class="btn ghost" @click="saveNote">保存</button>
            </div>
          </div>

          <!-- 评论 -->
          <div class="block comment-block">
            <label>斗破迷讨论 <em>{{ comments.length }} 条</em></label>
            <div class="comment-input">
              <input v-model="content" maxlength="300" placeholder="说点什么…" @keyup.enter="send" />
              <button class="btn" :disabled="sending" @click="send">{{ sending ? '发送中' : '发表' }}</button>
            </div>
            <div class="comment-list" v-if="comments.length">
              <div v-for="c in comments" :key="c.id" class="cm">
                <span class="cm-av">{{ (c.nickname || '?').slice(0, 1) }}</span>
                <div class="cm-main">
                  <div class="cm-top"><b>{{ c.nickname }}</b><i>{{ fmt(c.createTime) }}</i></div>
                  <p>{{ c.content }}</p>
                </div>
              </div>
            </div>
            <div class="empty-cm" v-else>还没有人说话，来抢个沙发</div>
          </div>
        </div>

        <div class="m-foot">
          <span class="foot-hint" :class="{ ok: okMsg, warn: needLogin }" v-if="msg">{{ msg }}</span>
          <span class="foot-hint" v-else>收服后可写入私人笔记，并计入境界修为</span>
          <div class="foot-actions">
            <button class="btn imm" @click="openImmersive"><span class="ib-ico">◎</span> 沉浸观赏</button>
            <button v-if="needLogin" class="btn big warn-btn" @click="goLogin">去 登 录</button>
            <button v-else class="btn big" :class="{ on: collected, busy: busy }" :disabled="busy" @click="toggleCollect">
              {{ busy ? '结 印 中…' : (collected ? '已收服 · 点击放生' : '收 服 此 火') }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </transition>

  <ImmersiveFire :show="immersive" :item="item" @close="immersive = false" />
</template>

<script>
import api from '../api'
import { store, loadProfile, applyCollect } from '../store'
import { FIRE_COLORS, COLOR_KEYS, colorOf } from '../theme'
import { artOf } from '../art'
import ImmersiveFire from './ImmersiveFire.vue'

export default {
  name: 'DetailModal',
  components: { ImmersiveFire },
  props: {
    show: { type: Boolean, default: false },
    item: { type: Object, default: () => ({}) }
  },
  emits: ['close', 'accent', 'changed'],
  data() {
    return {
      immersive: false,
      comments: [],
      content: '',
      note: '',
      sending: false,
      collected: false,
      busy: false,
      okMsg: false,
      needLogin: false,
      msg: '',
      colorKeys: COLOR_KEYS,
      artBroken: false
    }
  },
  computed: {
    art() {
      return artOf(this.item)
    },
    showArt() {
      return !!this.art && !this.artBroken
    },
    gradeClass() {
      return {
        '天阶': 'g-tian',
        '地阶': 'g-di',
        '玄阶': 'g-xuan',
        '黄阶': 'g-huang'
      }[this.item.grade] || 'g-huang'
    },
    holders() {
      return (this.item.holders || '').split(',').filter(Boolean)
    },
    diffText() {
      return ['', '随手可收', '略费手脚', '凶险异常', '九死一生', '万中无一'][this.item.difficulty || 0] || '未知'
    },
    accentStyle() {
      const c = colorOf(this.item.color)
      return { '--c-hex': c.hex, '--c-dim': c.dim, '--c-rgb': c.rgb }
    },
    hasColor() {
      return this.item && this.item.id
    }
  },
  watch: {
    show(v) {
      if (v) this.onOpen()
      else this.immersive = false
    }
  },
  methods: {
    openImmersive() {
      this.immersive = true
    },
    colorHex(k) {
      return colorOf(k).hex
    },
    colorLabel(k) {
      return colorOf(k).label
    },
    async onOpen() {
      this.msg = ''
      this.content = ''
      this.okMsg = false
      this.needLogin = false
      this.busy = false
      const p = store.profile
      this.collected = !!(p && p.ids && p.ids.indexOf(this.item.id) >= 0)
      this.note = (p && p.notes && p.notes[this.item.id]) || ''
      await this.loadComments()
    },
    async loadComments() {
      try {
        const res = await api.comments(this.item.id)
        if (res && res.code === 200) this.comments = res.data.list || []
      } catch (e) {
        this.comments = []
      }
    },
    /** 收服 / 放生：以后端返回的 collected + ids 为准，绝不本地假装成功 */
    async toggleCollect() {
      if (this.busy) return
      this.busy = true
      this.okMsg = false
      this.needLogin = false
      try {
        const res = this.collected
          ? await api.release(this.item.id)
          : await api.collect(this.item.id, this.note)
        const data = (res && res.data) || {}
        this.collected = !!data.collected
        applyCollect(data)
        this.msg = this.collected ? '收服成功 · 修为 +4，已收入图鉴' : '已放生，随时可以再收服'
        this.okMsg = true
        // 再拉一次完整档案（境界/成就），失败也不影响上面的即时状态
        await loadProfile()
        if (store.profile && Array.isArray(store.profile.ids)) {
          this.collected = store.profile.ids.indexOf(this.item.id) >= 0
        }
        this.$emit('changed')
        setTimeout(() => { this.okMsg = false }, 2600)
      } catch (e) {
        this.msg = e && e.code === 401
          ? '登录状态已失效，请重新登录后再收服'
          : (e.message || '收服失败，请重试')
        this.needLogin = !!(e && e.code === 401)
      } finally {
        this.busy = false
      }
    },
    goLogin() {
      this.$emit('close')
      this.$router.push({ path: '/login', query: { expired: '1' } })
    },
    async saveNote() {
      try {
        await api.saveNote(this.item.id, this.note)
        await loadProfile()
        this.msg = '笔记已保存'
      } catch (e) {
        this.msg = e.message
      }
    },
    async send() {
      if (!this.content.trim()) return
      this.sending = true
      try {
        await api.addComment(this.item.id, this.content.trim())
        this.content = ''
        await this.loadComments()
      } catch (e) {
        this.msg = e.message
      } finally {
        this.sending = false
      }
    },
    fmt(t) {
      if (!t) return ''
      return String(t).replace('T', ' ').slice(0, 16)
    }
  }
}
</script>

<style scoped>
.mask { position: fixed; inset: 0; z-index: 90; display: grid; place-items: center;
  padding: 24px; background: rgba(0,0,0,.66); backdrop-filter: blur(4px); }
.modal { position: relative; width: min(760px, 100%); max-height: 88vh; overflow-y: auto;
  border-radius: 16px; border: 1px solid rgba(var(--c-rgb),.35);
  background: var(--panel-solid);
  box-shadow: 0 30px 80px rgba(0,0,0,.6), 0 0 60px rgba(var(--c-rgb),.12);
  animation: cardIn .32s cubic-bezier(.2,.8,.3,1) both; }
.modal::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 3px;
  background: linear-gradient(90deg, transparent, var(--c-hex), transparent); }
.close { position: absolute; top: 14px; right: 14px; width: 28px; height: 28px; border-radius: 50%;
  cursor: pointer; color: var(--muted); background: rgba(0,0,0,.25);
  border: 1px solid rgba(212,175,55,.25); font-size: 12px; }
.close:hover { color: var(--c-hex); border-color: var(--c-hex); }

.m-head { display: flex; gap: 14px; padding: 24px 24px 16px; align-items: center; }
.m-head.no-icon { padding-top: 18px; }
/* ---------- 异火插图 ---------- */
.m-hero { position: relative; height: 232px; overflow: hidden; border-radius: 15px 15px 0 0; }
.m-hero img { display: block; width: 100%; height: 100%; object-fit: cover; }
.hero-veil { position: absolute; inset: 0; pointer-events: none;
  background: linear-gradient(to bottom, rgba(0,0,0,.28) 0%, rgba(0,0,0,.04) 38%, rgba(0,0,0,.42) 78%, var(--panel-solid) 100%); }
.hero-rank { position: absolute; left: 20px; bottom: 14px; font-size: 11.5px; font-weight: 700;
  letter-spacing: 1px; color: #1a1206; padding: 4px 10px; border-radius: 5px;
  background: linear-gradient(90deg, #c99a2e, #f5d76e); box-shadow: 0 4px 14px rgba(0,0,0,.4); }
.hero-cat { position: absolute; right: 20px; bottom: 14px; font-size: 11px; letter-spacing: 1px;
  color: #f6e9c9; padding: 4px 10px; border-radius: 5px; background: rgba(0,0,0,.45);
  border: 1px solid rgba(212,175,55,.4); }
.immersive-btn { position: absolute; left: 50%; top: 50%; transform: translate(-50%,-50%);
  height: 40px; padding: 0 22px; border-radius: 22px; cursor: pointer; white-space: nowrap;
  font-size: 13px; letter-spacing: 2px; color: #fff5dd; font-weight: 700;
  background: rgba(0,0,0,.5); border: 1px solid rgba(var(--c-rgb),.75);
  box-shadow: 0 6px 22px rgba(0,0,0,.5), inset 0 0 18px rgba(var(--c-rgb),.14);
  backdrop-filter: blur(3px); transition: .22s; opacity: 0; }
.m-hero:hover .immersive-btn { opacity: 1; }
.immersive-btn:hover { color: #fff; border-color: var(--c-hex); transform: translate(-50%,-50%) scale(1.06);
  box-shadow: 0 6px 26px rgba(0,0,0,.5), 0 0 24px rgba(var(--c-rgb),.5); }
.immersive-btn .ib-ico { font-size: 15px; margin-right: 6px; vertical-align: -1px; color: var(--c-hex); }
@media (hover: none) { .immersive-btn { opacity: 1; } }
.m-icon { width: 62px; height: 62px; border-radius: 14px; display: grid; place-items: center;
  font-size: 32px; background: rgba(var(--c-rgb),.12); border: 1px solid rgba(var(--c-rgb),.4);
  box-shadow: 0 0 26px rgba(var(--c-rgb),.22); flex-shrink: 0; }
.m-name { font-size: 22px; color: var(--txt); letter-spacing: 2px; font-weight: 700;
  display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.rank { font-size: 11px; padding: 3px 8px; border-radius: 5px; lettring-spacing: .5px;
  color: #1a1206; background: linear-gradient(90deg, #c99a2e, #f5d76e); font-weight: 700; }
.m-tags { margin-top: 8px; display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.grade { font-size: 11px; padding: 3px 8px; border-radius: 5px; }
.g-tian { color: #ffd8a8; background: rgba(226,84,42,.18); border: 1px solid rgba(255,140,66,.4); }
.g-di { color: #d7c2ff; background: rgba(140,110,220,.16); border: 1px solid rgba(160,130,240,.32); }
.g-xuan { color: #b7d8ff; background: rgba(80,140,220,.15); border: 1px solid rgba(110,170,240,.3); }
.g-huang { color: #c9c2b2; background: rgba(160,160,160,.12); border: 1px solid rgba(180,180,180,.22); }
.cat { font-size: 11px; color: var(--muted); padding: 3px 8px; border-radius: 5px;
  border: 1px solid rgba(212,175,55,.22); }
.src { font-size: 11.5px; color: var(--label); }

.m-body { padding: 4px 24px 8px; }
.row2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px; }
.block label { display: block; font-size: 11.5px; letter-spacing: 2px; color: var(--label);
  margin-bottom: 7px; }
.block label em { font-style: normal; color: var(--muted); opacity: .7; letter-spacing: 0; }
.form, .method, .desc { font-size: 13px; line-height: 1.9; color: var(--sub); }
.desc { padding: 10px 12px; border-radius: 8px; background: rgba(var(--c-rgb),.06);
  border-left: 2px solid var(--c-hex); }
.diff { display: flex; align-items: center; gap: 10px; }
.stars i { font-style: normal; font-size: 15px; color: rgba(212,175,55,.2); margin-right: 3px; }
.stars i.on { color: var(--c-hex); text-shadow: 0 0 8px rgba(var(--c-rgb),.7); }
.diff-txt { font-style: normal; font-size: 12px; color: var(--c-hex); }
.swatches { margin-top: 9px; display: flex; gap: 6px; }
.sw { width: 16px; height: 16px; border-radius: 50%; cursor: pointer; opacity: .55;
  border: 1px solid rgba(255,255,255,.2); transition: .2s; }
.sw:hover { opacity: 1; transform: scale(1.15); }
.sw.on { opacity: 1; box-shadow: 0 0 0 2px rgba(255,255,255,.35); }
.chips { display: flex; gap: 6px; flex-wrap: wrap; }
.chip { font-size: 12px; padding: 4px 10px; border-radius: 20px; color: var(--txt);
  background: rgba(var(--c-rgb),.1); border: 1px solid rgba(var(--c-rgb),.3); }
.none { font-size: 12px; color: var(--muted); }

.quote { margin: 4px 0 14px; padding: 14px 18px; border-radius: 10px; text-align: center;
  font-size: 15px; letter-spacing: 1px; color: var(--c-hex);
  background: linear-gradient(90deg, rgba(var(--c-rgb),.04), rgba(var(--c-rgb),.12), rgba(var(--c-rgb),.04));
  border-top: 1px dashed rgba(var(--c-rgb),.25); border-bottom: 1px dashed rgba(var(--c-rgb),.25); }
.q-mark { opacity: .5; margin: 0 3px; font-size: 18px; }

.note-row { display: flex; gap: 8px; align-items: flex-start; }
.note-row textarea { flex: 1; resize: vertical; padding: 8px 10px; border-radius: 8px;
  font-size: 12.5px; color: var(--txt); background: var(--panel);
  border: 1px solid rgba(212,175,55,.25); outline: none; }
.note-row textarea:focus { border-color: var(--c-hex); }

.comment-block { margin-top: 6px; }
.comment-input { display: flex; gap: 8px; margin-bottom: 12px; }
.comment-input input { flex: 1; height: 34px; padding: 0 12px; border-radius: 8px; font-size: 12.5px;
  color: var(--txt); background: var(--panel); border: 1px solid rgba(212,175,55,.25); outline: none; }
.comment-input input:focus { border-color: var(--c-hex); }
.comment-list { display: flex; flex-direction: column; gap: 10px; max-height: 190px; overflow-y: auto; }
.cm { display: flex; gap: 9px; }
.cm-av { width: 26px; height: 26px; border-radius: 50%; display: grid; place-items: center;
  font-size: 11px; color: var(--c-hex); background: rgba(var(--c-rgb),.12);
  border: 1px solid rgba(var(--c-rgb),.3); flex-shrink: 0; }
.cm-main { flex: 1; min-width: 0; }
.cm-top { display: flex; gap: 8px; align-items: baseline; }
.cm-top b { font-size: 12px; color: var(--txt); font-weight: 600; }
.cm-top i { font-size: 10.5px; color: var(--label); font-style: normal; }
.cm-main p { font-size: 12.5px; color: var(--sub); line-height: 1.7; margin-top: 2px; word-break: break-all; }
.empty-cm { font-size: 12px; color: var(--label); padding: 8px 0; }

.m-foot { position: sticky; bottom: 0; display: flex; align-items: center; justify-content: space-between;
  gap: 12px; padding: 14px 24px; border-top: 1px solid rgba(212,175,55,.16);
  background: var(--panel-solid); }
.foot-actions { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
.btn.imm { height: 38px; padding: 0 15px; letter-spacing: 1px; font-weight: 600;
  color: var(--c-hex); background: rgba(var(--c-rgb),.08); border: 1px solid rgba(var(--c-rgb),.5); }
.btn.imm:hover { background: rgba(var(--c-rgb),.16); }
.btn.imm .ib-ico { font-size: 14px; margin-right: 3px; }
.foot-hint { font-size: 11.5px; color: var(--label); }
.foot-hint.ok { color: var(--c-hex); font-weight: 600; animation: hintIn .3s ease both; }
.foot-hint.warn { color: #ff9a76; font-weight: 600; }
@keyframes hintIn { from { opacity: 0; transform: translateY(4px) } to { opacity: 1; transform: none } }
.btn { height: 34px; padding: 0 16px; border-radius: 8px; cursor: pointer; font-size: 13px;
  color: #1a1206; border: none; font-weight: 700; letter-spacing: 1px;
  background: linear-gradient(90deg, var(--c-dim), var(--c-hex)); }
.btn:hover { filter: brightness(1.08); }
.btn.ghost { color: var(--c-hex); background: transparent; border: 1px solid rgba(var(--c-rgb),.4); }
.btn.big { height: 38px; padding: 0 24px; letter-spacing: 3px; }
.btn.big.on { background: transparent; color: var(--c-hex); border: 1px solid rgba(var(--c-rgb),.5); }
.btn.big.busy { opacity: .7; cursor: progress; letter-spacing: 2px; }
.btn.big.warn-btn { background: linear-gradient(90deg, #e2542a, #ffb347); color: #1a1206; }
.btn:disabled { opacity: .6; cursor: default; }

@media (max-width: 640px) {
  .row2 { grid-template-columns: 1fr; }
  .m-head { padding: 20px 16px 12px; }
  .m-body { padding: 0 16px; }
  .m-foot { padding: 12px 16px; flex-wrap: wrap; }
  .foot-hint { flex-basis: 100%; }
  .foot-actions { width: 100%; justify-content: flex-end; }
  .btn.imm { padding: 0 12px; }
}
</style>
