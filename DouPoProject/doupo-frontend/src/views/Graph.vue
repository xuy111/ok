<template>
  <div class="graph-page">
    <TopNav ref="nav" active="graph" />

    <section class="head">
      <h1>关系图谱</h1>
      <p class="slogan">异火 · 人物 · 功法　—　谁握着谁的火</p>
    </section>

    <section class="board">
      <div class="legend-bar">
        <span class="lg"><i class="dot c0"></i>异火</span>
        <span class="lg"><i class="dot c1"></i>收服功法</span>
        <span class="lg"><i class="dot c2"></i>人物</span>
        <span class="hint">拖拽节点 / 滚轮缩放，点异火节点可看详情</span>
        <button class="btn" @click="reload" :disabled="loading">{{ loading ? '加载中' : '重新布局' }}</button>
      </div>
      <div ref="chart" class="chart"></div>
      <div v-if="error" class="err">{{ error }}</div>
    </section>

    <DetailModal :show="detailShow" :item="current" @close="detailShow = false"
                 @accent="setAccent" @changed="noop" />
  </div>
</template>

<script>
import * as echarts from 'echarts'
import api from '../api'
import { store } from '../store'
import { colorOf } from '../theme'
import TopNav from '../components/TopNav.vue'
import DetailModal from '../components/DetailModal.vue'

export default {
  name: 'Graph',
  components: { TopNav, DetailModal },
  data() {
    return {
      chart: null,
      loading: true,
      error: '',
      detailShow: false,
      current: {},
      raw: null
    }
  },
  computed: {
    light() {
      return document.body.classList.contains('light')
    }
  },
  async mounted() {
    await this.load()
    window.addEventListener('resize', this.resize)
  },
  beforeUnmount() {
    window.removeEventListener('resize', this.resize)
    if (this.chart) this.chart.dispose()
  },
  methods: {
    resize() {
      if (this.chart) this.chart.resize()
    },
    async load() {
      this.loading = true
      this.error = ''
      try {
        const res = await api.graph()
        if (res && res.code === 200) {
          this.raw = res.data
          this.$nextTick(() => this.draw())
        } else {
          this.error = (res && res.msg) || '图谱数据为空'
        }
      } catch (e) {
        this.error = e.message
      } finally {
        this.loading = false
      }
    },
    async reload() {
      await this.load()
    },
    draw() {
      const el = this.$refs.chart
      if (!el) return
      if (this.chart) this.chart.dispose()
      this.chart = echarts.init(el)

      const isLight = this.light
      const catColors = [null, '#9d7cff', '#f5d76e']

      const nodes = (this.raw.nodes || []).map(n => {
        let color = catColors[n.category]
        if (n.category === 0) color = colorOf(n.color).hex
        return {
          id: n.id,
          name: n.name,
          category: n.category,
          symbolSize: n.symbolSize || 30,
          value: n.value || 30,
          itemId: n.itemId,
          itemStyle: {
            color: color,
            borderColor: n.category === 2 ? '#c99a2e' : 'transparent',
            borderWidth: n.category === 2 ? 2 : 0,
            shadowBlur: n.category === 0 ? 16 : 6,
            shadowColor: color
          },
          label: {
            show: true,
            position: 'right',
            distance: 6,
            color: isLight ? '#33291d' : '#e8dcc0',
            fontSize: n.category === 0 ? 12 : 11,
            fontWeight: n.category === 2 ? 600 : 400
          }
        }
      })

      const links = (this.raw.links || []).map(l => ({
        source: l.source,
        target: l.target,
        value: l.label,
        lineStyle: {
          color: isLight ? 'rgba(150,120,60,.35)' : 'rgba(212,175,55,.28)',
          curveness: 0.12,
          width: 1
        },
        label: { show: true, formatter: l.label, fontSize: 10, color: isLight ? '#8a7355' : '#8c7a5c' }
      }))

      this.chart.setOption({
        backgroundColor: 'transparent',
        tooltip: {
          backgroundColor: isLight ? 'rgba(255,252,246,.96)' : 'rgba(18,16,14,.94)',
          borderColor: 'rgba(212,175,55,.4)',
          textStyle: { color: isLight ? '#33291d' : '#e8dcc0', fontSize: 12 },
          formatter: p => {
            if (p.dataType === 'edge') {
              return `${p.data.source} <b style="color:#f5d76e">${p.value || ''}</b> ${p.data.target}`
            }
            return `${p.name}<br/><span style="opacity:.7">${['异火', '收服功法', '人物'][p.data.category] || ''}</span>`
          }
        },
        series: [{
          type: 'graph',
          layout: 'force',
          roam: true,
          draggable: true,
          zoom: 0.8,
          force: {
            repulsion: 620,
            edgeLength: [90, 190],
            gravity: 0.06,
            friction: 0.14
          },
          emphasis: {
            focus: 'adjacency',
            lineStyle: { width: 2, color: '#ff8c42' }
          },
          data: nodes,
          links,
          categories: [
            { name: '异火' },
            { name: '收服功法' },
            { name: '人物' }
          ]
        }]
      })

      this.chart.on('click', p => {
        if (p.dataType === 'node' && p.data.itemId) {
          this.openDetail(p.data.itemId)
        }
      })
    },
    async openDetail(itemId) {
      try {
        const res = await api.itemDetail(itemId)
        if (res && res.code === 200) {
          this.current = res.data
          this.detailShow = true
        }
      } catch (e) { /* 忽略 */ }
    },
    setAccent(key) {
      if (this.$refs.nav && this.$refs.nav.setAccent) this.$refs.nav.setAccent(key)
    },
    noop() { /* 图谱页不需要刷新列表 */ }
  }
}
</script>

<style scoped>
.graph-page { min-height: 100vh; padding-bottom: 30px; }
.head { text-align: center; padding: 38px 20px 6px; }
.head h1 { font-size: 30px; letter-spacing: 12px; color: var(--gold2); font-weight: 800;
  text-shadow: 0 0 24px rgba(212,175,55,.4); }
.slogan { margin-top: 9px; font-size: 12.5px; letter-spacing: 3px; color: var(--muted); }

.board { position: relative; max-width: 1180px; margin: 16px auto 0; padding: 0 20px; }
.legend-bar { display: flex; align-items: center; gap: 16px; flex-wrap: wrap;
  padding: 10px 14px; border-radius: 10px; border: 1px solid var(--line); background: var(--panel); }
.lg { display: inline-flex; align-items: center; gap: 6px; font-size: 12px; color: var(--muted); }
.dot { width: 9px; height: 9px; border-radius: 50%; display: inline-block; }
.dot.c0 { background: #ff8c42; box-shadow: 0 0 8px #ff8c42; }
.dot.c1 { background: #9d7cff; box-shadow: 0 0 8px #9d7cff; }
.dot.c2 { background: #f5d76e; box-shadow: 0 0 8px #f5d76e; }
.hint { font-size: 11.5px; color: var(--label); margin-left: auto; }
.btn { height: 28px; padding: 0 14px; border-radius: 7px; cursor: pointer; font-size: 12px;
  color: var(--muted); background: transparent; border: 1px solid rgba(212,175,55,.28); }
.btn:hover { color: var(--gold2); border-color: var(--gold); }
.btn:disabled { opacity: .5; cursor: default; }

.chart { width: 100%; height: 640px; margin-top: 12px; border-radius: 12px;
  border: 1px solid rgba(212,175,55,.14); background: var(--panel); }
.err { position: absolute; inset: 120px 20px auto; text-align: center; color: #ff9d7a; font-size: 13px; }

@media (max-width: 720px) { .chart { height: 480px; } .hint { display: none; } }
</style>
