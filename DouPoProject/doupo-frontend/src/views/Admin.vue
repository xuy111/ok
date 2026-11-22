<template>
  <div class="admin">
    <div class="embers">
      <span v-for="i in 18" :key="i" class="ember"
        :style="{ left: embers[i-1].left, animationDuration: embers[i-1].dur, animationDelay: embers[i-1].delay, opacity: embers[i-1].op }"></span>
    </div>

    <!-- 顶栏 -->
    <header class="topbar">
      <div class="tb-left">
        <span class="logo-mark">斗</span>
        <div>
          <b>斗破苍穹 · 后台管理</b>
          <i>ADMIN CONSOLE</i>
        </div>
      </div>
      <div class="tb-right">
        <span class="who">管理员 · {{ admin.nickname || admin.username }}</span>
        <button class="ghost" @click="$router.push('/home')">返回首页</button>
        <button class="ghost danger" @click="logout">退出登录</button>
      </div>
    </header>

    <div class="body">
      <!-- 侧栏 -->
      <aside class="side">
        <a :class="{ on: tab === 'overview' }" @click="tab = 'overview'">数据概览</a>
        <a :class="{ on: tab === 'items' }" @click="tab = 'items'">图鉴管理</a>
        <a :class="{ on: tab === 'users' }" @click="tab = 'users'">用户列表</a>
        <div class="side-tip">
          管理范围：首页展示的图鉴条目（异火 / 功法 / 斗技 / 丹药 / 法宝）
        </div>
      </aside>

      <!-- 内容 -->
      <main class="main">
        <div class="crumb">后台管理 / {{ tabName }}</div>

        <!-- ============ 概览 ============ -->
        <section v-if="tab === 'overview'" class="pane">
          <div class="cards">
            <div class="stat-card">
              <span>图鉴条目</span>
              <b>{{ stats.total || 0 }}</b>
            </div>
            <div class="stat-card">
              <span>注册用户</span>
              <b>{{ stats.users || 0 }}</b>
            </div>
            <div class="stat-card">
              <span>天阶条目</span>
              <b>{{ (stats.grades && stats.grades['天阶']) || 0 }}</b>
            </div>
            <div class="stat-card">
              <span>分类数量</span>
              <b>{{ (stats.categoryList || []).length }}</b>
            </div>
          </div>

          <div class="panel">
            <h3>分类分布</h3>
            <div class="bars">
              <div v-for="c in stats.categoryList || []" :key="c.name" class="bar-row">
                <span class="bar-name">{{ c.name }}</span>
                <div class="bar-track">
                  <div class="bar-fill" :style="{ width: barWidth(c.count) }"></div>
                </div>
                <span class="bar-num">{{ c.count }}</span>
              </div>
            </div>
          </div>

          <div class="panel">
            <h3>品阶分布</h3>
            <div class="chips">
              <span v-for="(v, k) in stats.grades || {}" :key="k" class="chip">{{ k }} · {{ v }} 条</span>
            </div>
          </div>
        </section>

        <!-- ============ 图鉴管理 ============ -->
        <section v-if="tab === 'items'" class="pane">
          <div class="toolbar">
            <input class="inp" v-model="kw" @keyup.enter="loadItems(1)" placeholder="按名称 / 简介搜索…" />
            <button class="primary" @click="loadItems(1)">搜索</button>
            <button class="gold" @click="openCreate">＋ 新增条目</button>
            <span class="spacer"></span>
            <span class="muted">共 {{ itemTotal }} 条</span>
          </div>

          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th style="width:56px">ID</th>
                  <th style="width:190px">名称</th>
                  <th style="width:80px">分类</th>
                  <th style="width:80px">品阶</th>
                  <th>简介</th>
                  <th style="width:110px">出处</th>
                  <th style="width:130px">操作</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="it in items" :key="it.id">
                  <td class="muted">{{ it.id }}</td>
                  <td>
                    <span class="ico thumb" v-if="it.image"><img :src="it.image" :alt="it.name" /></span>
                    <span class="ico" v-else>{{ it.icon || '🔥' }}</span><b class="nm">{{ it.name }}</b>
                  </td>
                  <td>{{ it.category }}</td>
                  <td><span class="grade" :class="gradeClass(it.grade)">{{ it.grade }}</span></td>
                  <td class="desc">{{ it.description }}</td>
                  <td class="muted">{{ it.source }}</td>
                  <td>
                    <button class="link" @click="openEdit(it)">编辑</button>
                    <button class="link danger" @click="remove(it)">删除</button>
                  </td>
                </tr>
                <tr v-if="!items.length">
                  <td colspan="7" class="empty">暂无数据</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="pager">
            <button :disabled="page <= 1" @click="loadItems(page - 1)">上一页</button>
            <span>{{ page }} / {{ pages }}</span>
            <button :disabled="page >= pages" @click="loadItems(page + 1)">下一页</button>
          </div>
        </section>

        <!-- ============ 用户列表 ============ -->
        <section v-if="tab === 'users'" class="pane">
          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th style="width:60px">ID</th>
                  <th style="width:160px">用户名</th>
                  <th style="width:160px">昵称</th>
                  <th style="width:130px">权限</th>
                  <th style="width:110px">状态</th>
                  <th>最近登录</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="u in users" :key="u.id">
                  <td class="muted">{{ u.id }}</td>
                  <td><b class="nm">{{ u.username }}</b></td>
                  <td>{{ u.nickname || '-' }}</td>
                  <td>
                    <span v-if="u.role === 0" class="tag admin">管理员（0）</span>
                    <span v-else class="tag">默认权限（1）</span>
                  </td>
                  <td class="muted">{{ u.status === 1 ? '正常' : '禁用' }}</td>
                  <td class="muted">{{ u.lastLoginTime ? u.lastLoginTime.replace('T', ' ') : '从未登录' }}</td>
                </tr>
                <tr v-if="!users.length">
                  <td colspan="6" class="empty">暂无数据</td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </main>
    </div>

    <!-- ============ 弹窗表单 ============ -->
    <div v-if="showForm" class="mask" @click.self="showForm = false">
      <div class="dialog">
        <h3>{{ form.id ? '编辑条目' : '新增条目' }}</h3>
        <div class="dlg-body">
          <div class="row2">
            <div class="fld">
              <label>名称 *</label>
              <input v-model="form.name" class="inp" placeholder="如：青莲地心火" />
            </div>
            <div class="fld" style="width:110px">
              <label>图标</label>
              <input v-model="form.icon" class="inp" placeholder="🔥" />
            </div>
          </div>
          <div class="fld">
            <label>插图路径 <em>留空则用 emoji 图标</em></label>
            <input v-model="form.image" class="inp" list="artlist" placeholder="/fire/qinglian.jpg" />
            <datalist id="artlist">
              <option v-for="a in artPresets" :key="a.value" :value="a.value">{{ a.label }}</option>
            </datalist>
          </div>
          <div class="row3">
            <div class="fld">
              <label>异火榜排名</label>
              <input v-model.number="form.rankNo" class="inp" type="number" min="0" max="30" placeholder="0 = 未上榜" />
            </div>
            <div class="fld">
              <label>收服难度 1-5</label>
              <input v-model.number="form.difficulty" class="inp" type="number" min="1" max="5" />
            </div>
            <div class="fld">
              <label>主色</label>
              <select v-model="form.color" class="inp">
                <option v-for="(c, k) in colors" :key="k" :value="k">{{ c.label }}</option>
              </select>
            </div>
          </div>
          <div class="row2">
            <div class="fld">
              <label>分类 *</label>
              <select v-model="form.category" class="inp">
                <option v-for="c in categories" :key="c" :value="c">{{ c }}</option>
              </select>
            </div>
            <div class="fld">
              <label>品阶 *</label>
              <select v-model="form.grade" class="inp">
                <option v-for="g in grades" :key="g" :value="g">{{ g }}</option>
              </select>
            </div>
          </div>
          <div class="fld">
            <label>出处</label>
            <input v-model="form.source" class="inp" placeholder="如：异火榜 / 萧炎 / 丹塔" />
          </div>
          <div class="fld">
            <label>异火形态</label>
            <input v-model="form.formDesc" class="inp" placeholder="如：青色莲台悬浮，花瓣缓缓开合" />
          </div>
          <div class="row2">
            <div class="fld">
              <label>历代持有者 <em>逗号分隔</em></label>
              <input v-model="form.holders" class="inp" placeholder="如：药尘,萧炎" />
            </div>
            <div class="fld">
              <label>收服功法</label>
              <input v-model="form.method" class="inp" placeholder="如：焚决·青莲变" />
            </div>
          </div>
          <div class="fld">
            <label>经典台词</label>
            <input v-model="form.quote" class="inp" placeholder="如：从今日起，我也有异火了。" />
          </div>
          <div class="fld">
            <label>简介</label>
            <textarea v-model="form.description" class="inp area" placeholder="最多 500 字"></textarea>
          </div>
          <div class="err">{{ formMsg }}</div>
        </div>
        <div class="dlg-foot">
          <button class="ghost" @click="showForm = false">取消</button>
          <button class="gold" :disabled="saving" @click="save">{{ saving ? '保存中…' : '保存' }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from '../api'
import { FIRE_COLORS } from '../theme'

const CATEGORIES = ['异火', '功法', '斗技', '丹药', '法宝']
const GRADES = ['天阶', '地阶', '玄阶', '黄阶']

/** 已绘制好的异火插图，后台可直接选 */
const ART_PRESETS = [
  { label: '帝炎', value: '/fire/diyan.jpg' },
  { label: '虚无吞炎', value: '/fire/xuwu.jpg' },
  { label: '净莲妖火', value: '/fire/jinglian.jpg' },
  { label: '金帝焚天炎', value: '/fire/jindi.jpg' },
  { label: '生灵之焱', value: '/fire/shengling.jpg' },
  { label: '八荒破灭炎', value: '/fire/bahuang.jpg' },
  { label: '九幽风炎', value: '/fire/jiuyou.jpg' },
  { label: '骨灵冷火', value: '/fire/guling.jpg' },
  { label: '三千焱炎火', value: '/fire/sanqian.jpg' },
  { label: '青莲地心火', value: '/fire/qinglian.jpg' },
  { label: '陨落心炎', value: '/fire/yunluo.jpg' },
  { label: '海心焰', value: '/fire/haixin.jpg' }
]

export default {
  name: 'Admin',
  data() {
    const arr = []
    for (let i = 0; i < 18; i++) {
      arr.push({
        left: (Math.random() * 100) + '%',
        dur: (7 + Math.random() * 9) + 's',
        delay: (Math.random() * 9) + 's',
        op: Math.random() * 0.5 + 0.12
      })
    }
    return {
      admin: {},
      tab: 'overview',
      stats: {},
      items: [],
      itemTotal: 0,
      page: 1,
      size: 8,
      pages: 1,
      kw: '',
      users: [],
      categories: CATEGORIES,
      grades: GRADES,
      colors: FIRE_COLORS,
      artPresets: ART_PRESETS,
      showForm: false,
      saving: false,
      formMsg: '',
      form: this.emptyForm(),
      embers: arr
    }
  },
  computed: {
    tabName() {
      return { overview: '数据概览', items: '图鉴管理', users: '用户列表' }[this.tab]
    }
  },
  created() {
    this.admin = JSON.parse(localStorage.getItem('doupo_admin') || '{}')
    this.loadStats()
    this.loadItems(1)
    this.loadUsers()
  },
  methods: {
    emptyForm() {
      return { id: null, name: '', category: '异火', grade: '天阶', description: '', icon: '🔥', source: '' }
    },
    gradeClass(g) {
      return { '天阶': 'g-tian', '地阶': 'g-di', '玄阶': 'g-xuan', '黄阶': 'g-huang' }[g] || 'g-huang'
    },
    barWidth(count) {
      const max = Math.max(1, ...((this.stats.categoryList || []).map(c => c.count)))
      return Math.round((count / max) * 100) + '%'
    },
    /** 请求层已把业务错误变成异常，这里统一处理 */
    onErr(e) {
      if (e && (e.code === 401 || e.code === 403)) {
        localStorage.removeItem('doupo_admin')
        this.$router.replace({ path: '/admin/login', query: { expired: '1' } })
        return e.message
      }
      return (e && e.message) || '操作失败，请重试'
    },
    /** 统一处理 401 / 403：令牌失效就回后台登录页 */
    guard(res) {
      if (!res) return false
      if (res.code === 401 || res.code === 403) {
        localStorage.removeItem('doupo_admin')
        this.$router.push('/admin/login')
        return false
      }
      return res.code === 200
    },
    async loadStats() {
      try {
        const res = await api.adminStats()
        if (this.guard(res)) this.stats = res.data
      } catch (e) {
        this.formMsg = this.onErr(e)
      }
    },
    async loadItems(p) {
      this.page = p || 1
      try {
        const res = await api.adminItems({ keyword: this.kw || undefined, page: this.page, size: this.size })
        if (this.guard(res)) {
          this.items = res.data.list || []
          this.itemTotal = res.data.total || 0
          this.pages = res.data.pages || 1
        }
      } catch (e) {
        this.formMsg = this.onErr(e)
      }
    },
    async loadUsers() {
      try {
        const res = await api.adminUsers()
        if (this.guard(res)) this.users = res.data || []
      } catch (e) {
        this.formMsg = this.onErr(e)
      }
    },
    openCreate() {
      this.form = this.emptyForm()
      this.formMsg = ''
      this.showForm = true
    },
    openEdit(it) {
      // 注意：要带上全部字段，否则 updateById 时未提交的字段会被默认值覆盖
      this.form = {
        id: it.id,
        name: it.name,
        category: it.category,
        grade: it.grade,
        rankNo: it.rankNo || 0,
        difficulty: it.difficulty || 3,
        color: it.color || 'gold',
        icon: it.icon || '',
        image: it.image || '',
        formDesc: it.formDesc || '',
        holders: it.holders || '',
        method: it.method || '',
        quote: it.quote || '',
        description: it.description || '',
        source: it.source || ''
      }
      this.formMsg = ''
      this.showForm = true
    },
    async save() {
      this.formMsg = ''
      if (!this.form.name.trim()) {
        this.formMsg = '名称不能为空'
        return
      }
      this.saving = true
      try {
        const payload = Object.assign({}, this.form)
        const res = payload.id ? await api.adminUpdate(payload) : await api.adminAdd(payload)
        if (this.guard(res)) {
          this.showForm = false
          await this.loadItems(payload.id ? this.page : 1)
          await this.loadStats()
        } else {
          this.formMsg = (res && res.msg) || '保存失败'
        }
      } catch (e) {
        this.formMsg = this.onErr(e)
      } finally {
        this.saving = false
      }
    },
    async remove(it) {
      if (!window.confirm('确定删除「' + it.name + '」吗？删除后首页将不再展示。')) return
      try {
        const res = await api.adminDelete(it.id)
        if (this.guard(res)) {
          await this.loadItems(this.page)
          await this.loadStats()
        } else {
          this.formMsg = (res && res.msg) || '删除失败'
        }
      } catch (e) {
        this.formMsg = this.onErr(e)
      }
    },
    async logout() {
      localStorage.removeItem('doupo_admin')
      this.$router.push('/admin/login')
    }
  }
}
</script>

<style scoped>
.admin { position: relative; min-height: 100vh; }
.embers { position: fixed; inset: 0; overflow: hidden; pointer-events: none; z-index: 0; }
.ember { position: absolute; bottom: -20px; width: 3px; height: 3px; border-radius: 50%;
  background: var(--flame2); box-shadow: 0 0 8px 2px var(--flame); animation: rise linear infinite; }
@keyframes rise { 0% { transform: translateY(0) scale(1); opacity: .6 } 100% { transform: translateY(-105vh) scale(.2); opacity: 0 } }

.topbar { position: sticky; top: 0; z-index: 20; height: 62px; padding: 0 22px;
  display: flex; align-items: center; justify-content: space-between;
  background: rgba(12,10,9,.9); backdrop-filter: blur(12px); border-bottom: 1px solid var(--line); }
.tb-left { display: flex; align-items: center; gap: 10px; }
.logo-mark { width: 32px; height: 32px; border-radius: 8px; display: grid; place-items: center;
  background: linear-gradient(145deg, #c99a2e, #f5d76e); color: #1a1206; font-weight: 800; }
.tb-left b { display: block; font-size: 15px; color: var(--gold2); letter-spacing: 2px; }
.tb-left i { display: block; font-size: 9.5px; color: var(--muted); letter-spacing: 3px; font-style: normal; }
.tb-right { display: flex; align-items: center; gap: 10px; }
.who { font-size: 12.5px; color: #b9a67e; margin-right: 4px; }
.ghost { height: 32px; padding: 0 14px; border-radius: 7px; cursor: pointer; font-size: 12.5px;
  background: transparent; border: 1px solid rgba(212,175,55,.28); color: #b9a67e; }
.ghost:hover { color: var(--gold2); border-color: var(--gold); }
.ghost.danger:hover { color: #ff8f70; border-color: rgba(226,84,42,.6); }

.body { position: relative; z-index: 1; display: flex; gap: 0; max-width: 1280px; margin: 0 auto; }
.side { width: 196px; flex-shrink: 0; padding: 22px 12px; border-right: 1px solid rgba(212,175,55,.12); }
.side a { display: block; padding: 10px 14px; margin-bottom: 6px; border-radius: 8px; font-size: 13.5px;
  color: #b9a67e; cursor: pointer; border: 1px solid transparent; letter-spacing: 1px; }
.side a:hover { background: rgba(212,175,55,.06); color: var(--gold2); }
.side a.on { color: #1a1206; font-weight: 700; background: linear-gradient(90deg, #c99a2e, #f5d76e); }
.side-tip { margin-top: 18px; padding: 10px 12px; font-size: 11px; line-height: 1.8; color: #7d6c50;
  border: 1px dashed rgba(212,175,55,.18); border-radius: 8px; }

.main { flex: 1; padding: 20px 22px 40px; min-width: 0; }
.crumb { font-size: 12px; color: #7d6c50; letter-spacing: 1px; margin-bottom: 16px; }

.cards { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; }
.stat-card { padding: 18px 20px; border-radius: 12px; border: 1px solid rgba(212,175,55,.2);
  background: linear-gradient(150deg, rgba(30,24,19,.9), rgba(16,13,11,.94)); }
.stat-card span { font-size: 12px; color: var(--muted); letter-spacing: 1px; }
.stat-card b { display: block; margin-top: 8px; font-size: 26px; color: var(--gold2); }

.panel { margin-top: 16px; padding: 18px 20px; border-radius: 12px;
  border: 1px solid rgba(212,175,55,.2); background: rgba(18,14,12,.72); }
.panel h3 { font-size: 14px; color: var(--gold2); margin-bottom: 14px; letter-spacing: 2px; font-weight: 600; }
.bars { display: flex; flex-direction: column; gap: 12px; }
.bar-row { display: flex; align-items: center; gap: 12px; }
.bar-name { width: 46px; font-size: 12.5px; color: #b9a67e; }
.bar-track { flex: 1; height: 8px; border-radius: 6px; background: rgba(212,175,55,.1); overflow: hidden; }
.bar-fill { height: 100%; border-radius: 6px;
  background: linear-gradient(90deg, #e2542a, #f5d76e); box-shadow: 0 0 10px rgba(226,84,42,.4); }
.bar-num { width: 34px; text-align: right; font-size: 12px; color: var(--gold2); }
.chips { display: flex; flex-wrap: wrap; gap: 10px; }
.chip { padding: 6px 12px; border-radius: 20px; font-size: 12px; color: #b9a67e;
  border: 1px solid rgba(212,175,55,.22); background: rgba(212,175,55,.05); }

.toolbar { display: flex; align-items: center; gap: 10px; margin-bottom: 14px; flex-wrap: wrap; }
.spacer { flex: 1; }
.muted { color: #7d6c50; font-size: 12px; }
.inp { height: 36px; padding: 0 12px; border-radius: 7px; font-size: 13px; outline: none;
  color: #f0e4c8; background: rgba(0,0,0,.35); border: 1px solid rgba(212,175,55,.22); }
.inp:focus { border-color: var(--gold); box-shadow: 0 0 10px rgba(212,175,55,.18); }
.toolbar .inp { width: 240px; }
.primary { height: 36px; padding: 0 16px; border-radius: 7px; cursor: pointer; font-size: 13px;
  color: #b9a67e; background: rgba(0,0,0,.3); border: 1px solid rgba(212,175,55,.28); }
.primary:hover { color: var(--gold2); border-color: var(--gold); }
.gold { height: 36px; padding: 0 16px; border-radius: 7px; cursor: pointer; font-size: 13px; font-weight: 700;
  color: #1a1206; border: none; background: linear-gradient(90deg, #c99a2e, #f5d76e); }
.gold:hover:not(:disabled) { filter: brightness(1.1); }
.gold:disabled { opacity: .6; cursor: not-allowed; }

.table-wrap { border-radius: 12px; border: 1px solid rgba(212,175,55,.18); overflow: hidden;
  background: rgba(14,11,10,.7); }
table { width: 100%; border-collapse: collapse; font-size: 13px; }
th { text-align: left; padding: 12px 14px; font-size: 12px; font-weight: 600; letter-spacing: 1px;
  color: #b9a67e; background: rgba(212,175,55,.06); border-bottom: 1px solid rgba(212,175,55,.16); }
td { padding: 12px 14px; color: #cfc0a0; border-bottom: 1px solid rgba(212,175,55,.08); vertical-align: middle; }
tbody tr:hover { background: rgba(212,175,55,.04); }
.ico { margin-right: 8px; font-size: 15px; }
.ico.thumb { display: inline-block; width: 36px; height: 26px; overflow: hidden; border-radius: 4px;
  vertical-align: middle; border: 1px solid rgba(212,175,55,.28); background: rgba(0,0,0,.3); }
.ico.thumb img { display: block; width: 100%; height: 100%; object-fit: cover; }
.nm { color: #f0e4c8; font-weight: 600; }
.desc { color: #9c8a68; font-size: 12.5px; max-width: 320px; overflow: hidden;
  text-overflow: ellipsis; white-space: nowrap; }
.grade { font-size: 11px; padding: 2px 8px; border-radius: 5px; }
.g-tian { color: #ffd8a8; background: rgba(226,84,42,.18); border: 1px solid rgba(255,140,66,.4); }
.g-di { color: #d7c2ff; background: rgba(140,110,220,.16); border: 1px solid rgba(160,130,240,.32); }
.g-xuan { color: #b7d8ff; background: rgba(80,140,220,.15); border: 1px solid rgba(110,170,240,.3); }
.g-huang { color: #c9c2b2; background: rgba(160,160,160,.12); border: 1px solid rgba(180,180,180,.22); }
.tag { font-size: 11.5px; padding: 3px 9px; border-radius: 5px; color: #b9a67e;
  border: 1px solid rgba(212,175,55,.22); }
.tag.admin { color: #ffd8a8; background: rgba(226,84,42,.14); border-color: rgba(255,140,66,.4); }
.link { background: none; border: none; cursor: pointer; font-size: 12.5px; color: var(--gold2); padding: 0 6px; }
.link:hover { text-decoration: underline; }
.link.danger { color: #ff8f70; }
.empty { text-align: center; padding: 30px; color: #7d6c50; }
.pager { display: flex; justify-content: center; align-items: center; gap: 14px; margin-top: 18px; }
.pager button { height: 32px; padding: 0 14px; border-radius: 7px; cursor: pointer; font-size: 12.5px;
  color: #b9a67e; background: rgba(0,0,0,.3); border: 1px solid rgba(212,175,55,.25); }
.pager button:hover:not(:disabled) { color: var(--gold2); border-color: var(--gold); }
.pager button:disabled { opacity: .4; cursor: not-allowed; }
.pager span { font-size: 12px; color: #8c7a5c; }

.mask { position: fixed; inset: 0; z-index: 40; background: rgba(0,0,0,.62); backdrop-filter: blur(3px);
  display: grid; place-items: center; padding: 20px; }
.dialog { width: 560px; max-width: 94vw; max-height: 88vh; display: flex; flex-direction: column;
  border-radius: 14px; border: 1px solid var(--line);
  background: linear-gradient(150deg, rgba(30,24,19,.99), rgba(14,11,10,.99));
  box-shadow: 0 24px 70px rgba(0,0,0,.7); }
.dialog h3 { padding: 18px 22px; font-size: 16px; color: var(--gold2); letter-spacing: 3px;
  border-bottom: 1px solid rgba(212,175,55,.16); font-weight: 600; flex-shrink: 0; }
.dlg-body { padding: 18px 22px 6px; overflow-y: auto; }
.row2 { display: flex; gap: 12px; }
.row3 { display: flex; gap: 12px; }
.fld { flex: 1; margin-bottom: 14px; }
.fld label { display: block; font-size: 12px; color: #b9a67e; margin-bottom: 7px; letter-spacing: 1px; }
.fld label em { font-style: normal; color: #7f6f52; margin-left: 4px; letter-spacing: 0; }
.fld .inp { width: 100%; height: 38px; }
select.inp { cursor: pointer; }
.area { height: 88px; padding: 10px 12px; resize: vertical; line-height: 1.7; }
.err { min-height: 18px; font-size: 12.5px; color: #ff7a5c; }
.dlg-foot { display: flex; justify-content: flex-end; gap: 10px; padding: 14px 22px 20px; }

@media (max-width: 900px) {
  .cards { grid-template-columns: repeat(2, 1fr); }
  .side { width: 132px; }
  .desc { max-width: 140px; }
}
</style>
