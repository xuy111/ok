import { createRouter, createWebHashHistory } from 'vue-router'
import LoginCard from '../components/LoginCard.vue'
import RegisterCard from '../components/RegisterCard.vue'
import ResetCard from '../components/ResetCard.vue'
import HomeCard from '../components/HomeCard.vue'
import HallCard from '../components/HallCard.vue'
import { loadToken } from '../composables/useRemember'

const routes = [
  { path: '/', redirect: '/login' },
  { path: '/login', name: 'login', component: LoginCard, meta: { title: '山门' } },
  { path: '/register', name: 'register', component: RegisterCard, meta: { title: '立派' } },
  { path: '/reset', name: 'reset', component: ResetCard, meta: { title: '重铸' } },
  {
    path: '/home',
    name: 'home',
    component: HomeCard,
    meta: { title: '山主', needAuth: true }
  },
  {
    path: '/hall',
    name: 'hall',
    component: HallCard,
    meta: { title: '名录' }
  },
  { path: '/:pathMatch(.*)*', redirect: '/login' }
]

const router = createRouter({
  // 用 hash 模式，dist 直接静态打开也不会 404
  history: createWebHashHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})

// 需要登录的页面（/home）：没有令牌就回山门
router.beforeEach((to) => {
  if (to.meta?.needAuth && !loadToken()) {
    return { path: '/login', query: { from: to.fullPath } }
  }
  return true
})

router.afterEach((to) => {
  const t = to.meta?.title ? `${to.meta.title} · 剑来` : '剑来 · 山门登录'
  document.title = t
})

export default router
