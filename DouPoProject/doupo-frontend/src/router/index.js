import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Register from '../views/Register.vue'
import Home from '../views/Home.vue'
import MyFire from '../views/MyFire.vue'
import Graph from '../views/Graph.vue'
import Journey from '../views/Journey.vue'
import PhotoWall from '../views/PhotoWall.vue'
import CgWall from '../views/CgWall.vue'
import Simulator from '../views/Simulator.vue'
import Alchemy from '../views/Alchemy.vue'
import Talent from '../views/Talent.vue'
import AdminLogin from '../views/AdminLogin.vue'
import Admin from '../views/Admin.vue'

const routes = [
  { path: '/', redirect: '/login' },
  { path: '/login', component: Login, meta: { title: '登录' } },
  { path: '/register', component: Register, meta: { title: '注册' } },
  { path: '/talent', component: Talent, meta: { title: '灵魂力天赋测试' } },
  { path: '/home', component: Home, meta: { title: '首页', needUser: true } },
  { path: '/mine', component: MyFire, meta: { title: '我的异火', needUser: true } },
  { path: '/graph', component: Graph, meta: { title: '关系图谱', needUser: true } },
  { path: '/journey', component: Journey, meta: { title: '人物历程', needUser: true } },
  { path: '/gallery', component: PhotoWall, meta: { title: '群像照片墙' } },
  { path: '/cg', component: CgWall, meta: { title: '名场面 CG' } },
  { path: '/sim', component: Simulator, meta: { title: '异火融合', needUser: true } },
  { path: '/alchemy', component: Alchemy, meta: { title: '炼药模拟器', needUser: true } },
  { path: '/admin/login', component: AdminLogin, meta: { title: '后台登录' } },
  { path: '/admin', component: Admin, meta: { title: '后台管理', needAdmin: true } },
  { path: '/:pathMatch(.*)*', redirect: '/login' }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

function read(key) {
  try {
    return JSON.parse(localStorage.getItem(key) || 'null')
  } catch (e) {
    return null
  }
}

/**
 * 路由守卫
 * - 前台页面需要登录
 * - /admin 需要后台管理员登录，并且 role 必须为 0
 */
router.beforeEach((to, from, next) => {
  if (to.meta.needUser && !read('doupo_user')) {
    return next('/login')
  }
  if (to.meta.needAdmin) {
    const admin = read('doupo_admin')
    if (!admin || !admin.token || admin.role !== 0) {
      return next('/admin/login')
    }
  }
  document.title = (to.meta.title ? to.meta.title + ' · ' : '') + '斗破苍穹 · 异火图鉴'
  next()
})

export default router
