<template>
  <article class="card" :class="[colorKey]" :style="enterStyle" @click="$emit('open', item)">
    <div class="card-glow"></div>

    <!-- 异火插图：按原著形态绘制，失败时回退 emoji -->
    <div v-if="showArt" class="cover">
      <img :src="art" :alt="item.name" loading="lazy" @error="broken = true" />
      <span class="cover-veil"></span>
      <div class="cover-badges">
        <span v-if="item.rankNo > 0" class="rank" :class="'r' + Math.min(item.rankNo, 9)">#{{ item.rankNo }}</span>
        <span class="grade" :class="gradeClass">{{ item.grade }}</span>
      </div>
      <span class="cover-cat">{{ item.category }}</span>
    </div>

    <div v-else class="card-top">
      <div class="icon">{{ item.icon || '🔥' }}</div>
      <div class="badges">
        <span v-if="item.rankNo > 0" class="rank" :class="'r' + Math.min(item.rankNo, 9)">#{{ item.rankNo }}</span>
        <span class="grade" :class="gradeClass">{{ item.grade }}</span>
        <span class="cat">{{ item.category }}</span>
      </div>
    </div>

    <h3>{{ item.name }}</h3>
    <p>{{ item.description || '暂无简介' }}</p>

    <div class="meta">
      <span class="diff" :title="'收服难度 ' + item.difficulty + '/5'">
        <i v-for="n in 5" :key="n" :class="{ on: n <= (item.difficulty || 0) }">✦</i>
      </span>
      <span class="holder">{{ firstHolder }}</span>
    </div>

    <div class="card-foot">
      <span class="src">出处 · {{ item.source || '不详' }}</span>
      <button class="collect" :class="{ on: collected }" @click.stop="toggle">
        {{ collected ? '已收服' : '收服' }}
      </button>
    </div>
  </article>
</template>

<script>
import { colorOf } from '../theme'
import { artOf } from '../art'

export default {
  name: 'ItemCard',
  props: {
    item: { type: Object, required: true },
    collected: { type: Boolean, default: false },
    index: { type: Number, default: 0 }
  },
  emits: ['open', 'toggle'],
  data() {
    return { broken: false }
  },
  computed: {
    art() {
      return artOf(this.item)
    },
    showArt() {
      return !!this.art && !this.broken
    },
    colorKey() {
      return 'c-' + (this.item.color || 'gold')
    },
    color() {
      return colorOf(this.item.color)
    },
    enterStyle() {
      return {
        animationDelay: Math.min(this.index, 12) * 55 + 'ms',
        '--c-hex': this.color.hex,
        '--c-dim': this.color.dim,
        '--c-rgb': this.color.rgb
      }
    },
    gradeClass() {
      return {
        '天阶': 'g-tian',
        '地阶': 'g-di',
        '玄阶': 'g-xuan',
        '黄阶': 'g-huang'
      }[this.item.grade] || 'g-huang'
    },
    firstHolder() {
      const h = this.item.holders
      if (!h) return '无记载'
      const arr = h.split(',').filter(Boolean)
      return arr.length ? arr[0] + (arr.length > 1 ? ' 等' : '') : '无记载'
    }
  },
  methods: {
    toggle() {
      this.$emit('toggle', this.item)
    }
  }
}
</script>

<style scoped>
.card { position: relative; padding: 18px 18px 14px; border-radius: 12px; cursor: pointer;
  border: 1px solid var(--card-line); background: var(--card);
  transition: transform .25s, border-color .25s, box-shadow .25s;
  overflow: hidden; animation: cardIn .5s cubic-bezier(.2,.7,.3,1) both; }
.card:hover { transform: translateY(-4px); border-color: var(--c-hex);
  box-shadow: var(--shadow), 0 0 22px rgba(var(--c-rgb),.22); }
.card-glow { position: absolute; inset: -40% -60% auto auto; width: 180px; height: 180px;
  background: radial-gradient(circle, rgba(var(--c-rgb),.22), transparent 70%);
  opacity: 0; transition: opacity .3s; pointer-events: none; }
.card:hover .card-glow { opacity: 1; }
.card::before { content: ""; position: absolute; top: 0; left: 0; right: 0; height: 2px;
  background: linear-gradient(90deg, transparent, var(--c-hex), transparent); opacity: .45; }

/* ---------- 异火插图 ---------- */
.cover { position: relative; margin: -18px -18px 14px; height: 152px; overflow: hidden;
  border-bottom: 1px solid rgba(var(--c-rgb),.22); }
.cover img { display: block; width: 100%; height: 100%; object-fit: cover;
  transition: transform .7s cubic-bezier(.2,.7,.3,1); }
.card:hover .cover img { transform: scale(1.06); }
.cover-veil { position: absolute; inset: 0; pointer-events: none;
  background: linear-gradient(to bottom, rgba(0,0,0,0) 42%, rgba(0,0,0,.18) 70%, rgba(0,0,0,.52) 100%); }
.cover-badges { position: absolute; top: 10px; right: 10px; display: flex; gap: 6px; align-items: center;
  padding: 4px 6px; border-radius: 8px; background: rgba(10,8,6,.44); backdrop-filter: blur(4px);
  border: 1px solid rgba(255,255,255,.08); }
.cover-cat { position: absolute; top: 10px; left: 10px; font-size: 11px; letter-spacing: 1px;
  color: #f6e9c9; padding: 3px 8px; border-radius: 5px; background: rgba(0,0,0,.45);
  border: 1px solid rgba(212,175,55,.38); backdrop-filter: blur(3px); }
.cover + h3 { margin-top: 0; }

.card-top { display: flex; align-items: flex-start; justify-content: space-between; }
.icon { width: 42px; height: 42px; border-radius: 10px; display: grid; place-items: center;
  font-size: 22px; background: rgba(var(--c-rgb),.10);
  border: 1px solid rgba(var(--c-rgb),.3); }
.badges { display: flex; gap: 6px; align-items: center; flex-wrap: wrap; justify-content: flex-end; }
.rank { font-size: 11px; padding: 3px 7px; border-radius: 5px; font-weight: 700;
  color: #1a1206; background: linear-gradient(90deg, #c99a2e, #f5d76e); letter-spacing: .5px; }
.grade { font-size: 11px; padding: 3px 8px; border-radius: 5px; letter-spacing: 1px; }
.g-tian { color: #ffd8a8; background: rgba(226,84,42,.18); border: 1px solid rgba(255,140,66,.4); }
.g-di { color: #d7c2ff; background: rgba(140,110,220,.16); border: 1px solid rgba(160,130,240,.32); }
.g-xuan { color: #b7d8ff; background: rgba(80,140,220,.15); border: 1px solid rgba(110,170,240,.3); }
.g-huang { color: #c9c2b2; background: rgba(160,160,160,.12); border: 1px solid rgba(180,180,180,.22); }
.cat { font-size: 11px; color: var(--muted); padding: 3px 8px; border-radius: 5px;
  border: 1px solid rgba(212,175,55,.22); }

h3 { margin: 14px 0 8px; font-size: 16px; color: var(--txt); letter-spacing: 1px; font-weight: 600; }
p { font-size: 12.5px; line-height: 1.85; color: var(--sub); height: 46px; overflow: hidden;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; }

.meta { margin-top: 10px; display: flex; align-items: center; justify-content: space-between; gap: 8px; }
.diff { display: inline-flex; gap: 2px; }
.diff i { font-style: normal; font-size: 11px; color: rgba(212,175,55,.22); }
.diff i.on { color: var(--c-hex); text-shadow: 0 0 6px rgba(var(--c-rgb),.6); }
.holder { font-size: 11px; color: var(--label); overflow: hidden; white-space: nowrap;
  text-overflow: ellipsis; max-width: 55%; }

.card-foot { margin-top: 10px; padding-top: 10px; border-top: 1px dashed rgba(212,175,55,.16);
  display: flex; align-items: center; justify-content: space-between; gap: 8px; }
.src { font-size: 11.5px; color: var(--label); }
.collect { height: 26px; padding: 0 12px; border-radius: 6px; cursor: pointer; font-size: 11.5px;
  color: var(--muted); background: transparent; border: 1px solid rgba(212,175,55,.3);
  transition: .2s; flex-shrink: 0; }
.collect:hover { color: #1a1206; background: linear-gradient(90deg, var(--c-dim), var(--c-hex));
  border-color: transparent; }
.collect.on { color: #1a1206; background: linear-gradient(90deg, var(--c-dim), var(--c-hex));
  border-color: transparent; font-weight: 700; }
</style>
