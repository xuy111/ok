# 剑来 · 山门登录

《剑来》主题登录页，Vue 3 + Vite + Vue Router 单页工程。水墨夜色 + 青绿剑气，与原静态页视觉一致。

## 运行

```bash
npm install
npm run dev      # http://127.0.0.1:5173
npm run build    # 输出到 dist/（base 为 ./，可直接静态打开）
npm run preview  # 预览构建产物
```

## 路由（hash 模式）

| 路径 | 页面 | 主按钮 |
| --- | --- | --- |
| `#/login` | 山门登录 | 仗剑入山 |
| `#/register` | 开宗立派 | 开宗立派 |
| `#/reset` | 重铸剑诀 | 重铸剑诀 |
| `#/home` | 山主道碑（需登录） | 重铸剑诀 / 出山 |
| `#/hall` | 山门名录 | 搜索 + 分页浏览在籍弟子 |

`#/home` 带 `needAuth` 守卫：localStorage 里没有 `jianlai:token` 会被打回 `#/login`。

## 登录态

- 登录 / 注册成功后后端返回 JWT，前端存 `jianlai:token`
- `http.js` 自动给每个请求加 `Authorization: Bearer <token>`；遇到 401 自动清 token 并提示「剑诀令牌已失效」
- 令牌默认 7 天，勾「记住此山」30 天
- 「出山」按钮 → 调 `/auth/logout` → 清 token 与道号 → 剑气斩屏后回登录页
- 山主道碑展示：道号/门派/引荐/入门时间/最近入山/**入山次数**/**山门弟子总数**，以及近五次入山记录（成功绿点、失败红点，失败原因与登录提示一致）

左侧题字与背景（远山、明月、剑气、长剑）在三页间保持不动，右侧卡片做剑气掠影式切换动画。

## 目录结构

```
jianlai-login-vue/
├─ index.html
├─ vite.config.js                base: './'
└─ src/
   ├─ main.js                    入口（挂载 router）
   ├─ App.vue                    装配：背景 + BrandPanel + router-view + 遮罩
   ├─ router/index.js            三页路由 + 标题守卫
   ├─ api/mock.js                模拟接口：login / register / resetPwd（700~1100ms 延迟）
   ├─ styles/main.css            全局样式（水墨主题变量 / 全部版式）
   ├─ composables/
   │  ├─ useSwordFx.js           Canvas 粒子引擎：灵光点 + 剑气光刃，导出 burstQi()
   │  └─ useSlash.js             斩屏遮罩共享状态，导出 openSlash()
   └─ components/
      ├─ SwordStage.vue          背景层：天空 / 明月 / 三层远山 / 雾气 / 长剑 / 粒子画布 / 暗角
      ├─ BrandPanel.vue          左侧题字：剑来、印章、偈语、山头标签
      ├─ SwordField.vue          通用输入框（图标 + 显隐密码 + v-model + 回车提交）
      ├─ LoginCard.vue           山门：校验、加载态、三教入口
      ├─ RegisterCard.vue        立派：两遍剑诀 + 引荐 + 山规三条
      ├─ ResetCard.vue           重铸：新剑诀两遍 + 重铸须知
      ├─ HomeCard.vue            山主道碑：道号/门派/引荐/入门时间 + 出山
      └─ SlashOverlay.vue        成功遮罩：剑气斩击 + 大字
```

## 交互说明

| 位置 | 行为 |
| --- | --- |
| 道号 | 为空 → 卡片抖动 + 「道号不可为空 · 请留下姓名」 |
| 剑诀 | 少于 6 位 → 「剑诀不足六字 · 尚难登门」 |
| 两遍剑诀不一致 | 「两遍剑诀不同 · 心不静则剑不纯」 |
| 提交中 | 按钮转圈 + 「剑气凝聚中」，输入框禁用 |
| 提交成功 | 催发 4 道剑气 → 全屏斩击 → 「山门已开 / 山门已立 / 剑诀重铸」→ 2.6s 后散去 |
| 道号含「魔」 | mock 接口主动 reject，用来演示失败态 |
| 三教通行 | 演示占位提示 |

## 注册页 `#/register`

从登录页点「在此开宗立派」进入，字段与校验：

| 字段 | 规则 |
| --- | --- |
| 道号 | 必填，≤12 字 |
| 剑诀 | ≥6 字，带实时剑意强度条（未成 / 初入境 / 渐凝 / 圆满） |
| 再诵剑诀 | 必须一致，右侧显示「两诀相合 / 两诀不合」 |
| 山门引荐 | 选填 |
| 择一脉 | 儒 / 道 / 释 / 兵，默认「剑」，下方显示对应天下 |
| 山规三条 | 必须勾选 |

提交成功后：剑气斩屏「山门已立」→ 道号写入 localStorage → 2.6s 后自动跳回 `#/login`。

## 记住此山

`composables/useRemember.js` 用 localStorage 存道号（key `jianlai:uid`）：

- 登录勾选「记住此山」→ 成功后写入；不勾选 → 清除
- 登录页挂载时自动回填道号
- 注册成功也会写入，跳转登录页后即可看到

## 后端对接（Spring Boot + MyBatis-Plus + MySQL）

后端项目：`D:\workSpace\springBootTest`（Spring Boot 3.4.5 / Java 17 / 端口 8081 / 库 `jianlai`）

1. 执行 `springBootTest/sql/jianlai.sql` 建库建表（含演示账号 陈平安 / 宁姚，剑诀 123456）
2. 启动后端：`mvn spring-boot:run` 或用 IDEA 运行 `SpringBootTestApplication`
3. 启动前端：`npm run dev`（5173），`/api` 已由 vite 代理转发到 8081，无跨域问题

接口：`GET /api/auth/ping`、`POST /api/auth/login`、`POST /api/auth/register`、`POST /api/auth/reset`、`GET /api/auth/check?uid=`

### 接口层

`src/api/auth.js` 是前端唯一入口，通过环境变量切换真实后端 / 本地 mock：

```bash
# .env
VITE_USE_MOCK=false     # false 连后端；true 离线演示
VITE_API_BASE=/api      # vite 代理前缀
```

- `http.js`：fetch 封装，非 200 直接 `throw new Error(msg)`，卡片自动抖动显示
- `auth.js`：login / register / resetPwd / checkUid / ping
- `useRemember.js`：localStorage 存 `jianlai:uid`（记住此山）与 `jianlai:token`（登录令牌）

无后端时把 `VITE_USE_MOCK` 改成 `true`，三页照常演示。

## 接真实接口

`src/api/mock.js` 三个函数签名固定，替换为 axios / fetch 即可，组件无需改动：

```js
login({ uid, pwd })          // -> { ok, uid, token }
register({ uid, pwd, confirm, invite }) // -> { ok, uid, invite }
resetPwd({ uid, pwd, confirm })         // -> { ok, uid }
```

失败时 `throw new Error(msg)`，卡片会自动抖动并显示该消息。

## 主题变量

`src/styles/main.css` 顶部 `:root`：

- `--jade #7fd3c4` 剑气青
- `--gold #e3c177` 描金
- `--seal #b0342c` 印章朱红
- `--ink #060b12` 墨底

改这几个值即可整体换肤（例如把 `--ink` 换成 `#efe7d8` 宣纸色，可转成浅色版）。
