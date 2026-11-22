# 斗破苍穹 · 异火图鉴

一个「斗破苍穹」主题的全栈小项目：暗金 + 异火配色的登录 / 注册 / 首页 / 后台管理系统。

- 前端：Vue 3 + Vite + Vue Router + Axios
- 后端：Spring Boot 3.4.5 + MyBatis-Plus 3.5.9
- 数据库：MySQL 8（库名 `doupo`，账号 `root / 123456`）
- 主题：登录页与首页统一为「墨黑 + 鎏金 + 异火橙」，火星粒子上升动画

---

## 一、目录结构

```
C:\Users\III\Desktop\DouPoProject
├─ doupo-frontend\            前端（Vue 3 + Vite + ECharts）
│  ├─ src\views\Login.vue      登录
│  ├─ src\views\Register.vue   注册
│  ├─ src\views\Home.vue       首页（导航 + 搜索 + 分级分类 + 高级排序）
│  ├─ src\views\MyFire.vue     我的异火（收集进度 / 剪影 / 成就）
│  ├─ src\views\Graph.vue      关系图谱（ECharts）
│  ├─ src\views\Simulator.vue  异火融合 / 吞噬模拟器
│  ├─ src\views\Alchemy.vue    炼药模拟器（选药材 + 异火 + 火候控炉小游戏）
│  ├─ src\views\Talent.vue     灵魂力天赋测试（5 题 → 斗气大陆身份证）
│  ├─ src\views\AdminLogin.vue 后台登录（仅管理员）
│  ├─ src\views\Admin.vue      后台管理（图鉴数据增删改查）
│  ├─ src\components\TopNav.vue      导航栏（境界、签到、抽卡、主题）
│  ├─ src\components\ItemCard.vue    异火卡片（入场动画、收服）
│  ├─ src\components\DetailModal.vue 详情弹窗（形态/持有者/功法/台词/笔记/评论）
│  ├─ src\components\DrawModal.vue   抽卡弹窗（翻牌 + Web Audio 音效）
│  ├─ src\api\index.js         接口层（自动带 token）
│  ├─ src\store.js             轻量全局状态（用户档案 / 境界）
│  ├─ src\theme.js             异火配色、强调色、白昼黑夜
│  ├─ src\art.js               异火插图映射（image 优先，空值按名称兜底）
│  ├─ src\talent.js            天赋题库 + 五行/风格判定 + 身份证编号
│  └─ vite.config.js           代理 /api -> localhost:8080
├─ springBootTest\            后端（Spring Boot，由空壳 springBootTest 改造）
│  └─ src\main\java\com\fenglin\springboottest
│     ├─ controller\AuthController.java    注册 / 登录 / 后台登录 / 当前用户
│     ├─ controller\ItemController.java    首页展示、分级分类搜索、评论
│     ├─ controller\UserController.java    档案、签到、收服、笔记、抽卡
│     ├─ controller\GraphController.java   关系图谱数据
│     ├─ controller\AdminController.java   后台管理接口（需管理员令牌）
│     ├─ service\                          认证 / 图鉴 / 收藏 / 玩法 / 评论 / 图谱
│     ├─ util\Realm.java                   境界换算
│     ├─ util\TokenStore.java              内存令牌
│     ├─ entity\ mapper\ config\
├─ sql\doupo.sql             建库建表 + 27 条图鉴数据（含 12 朵完整异火）
├─ scripts\                  启动 / 停止脚本（GBK + CRLF，相对路径）
├─ docs\preview-*.png        各页面实机截图
├─ 启动.bat                  一键启动（双击这个）
├─ 停止.bat                  一键停止
└─ login.html                最初的原生 HTML 登录页（主题原型，可直接双击打开）
```

---

## 二、最快启动方式（推荐）

**双击项目根目录的 `启动.bat`**（不用进 scripts 文件夹）。脚本会自动：

1. 启动 MySQL（本机绿色版，非系统服务）
2. 检查 `doupo` 库是否存在，不存在就自动导入 `sql\doupo.sql`
3. 打开后端窗口：缺 `target` 就自动 `mvn package`，然后起 8080
4. 打开前端窗口：缺 `node_modules` 就自动 `npm install`，然后起 5173
5. **每 3 秒轮询 8080 / 5173，两个端口都监听后才打开浏览器**（不会提前打开一个打不开的页面）

停止：双击根目录 `停止.bat`；查看状态：`scripts\status.bat`。

> 因为这台电脑每次开机会清掉 `node_modules` 与 `target`，脚本都会自动重建，
> 所以**不需要**手动先装依赖。首次冷启动要等 1~3 分钟（npm install + mvn 打包），
> 期间不要关掉 `DouPo-Backend` / `DouPo-Frontend` 那两个窗口。

### 打不开怎么办

| 现象 | 原因 | 处理 |
|---|---|---|
| 窗口一闪就没 | 脚本被存成了 LF 换行 | 见 `AI-NOTES.md` 3.5.5，需 GBK + CRLF |
| 浏览器「拒绝连接」 | 服务还在编译/安装 | 等两个窗口出现 `Local: http://localhost:5173/` |
| 5173 打不开但窗口没报错 | 被之前残留进程占着 | 先 `scripts\stop-frontend.bat` 再启动 |
| 后端起不来 | MySQL 没起 / 连不上 | 先 `scripts\start-mysql.bat`，再 `scripts\status.bat` |

### 也可以手动启动

```bat
rem 1. 启动 MySQL
scripts\start-mysql.bat

rem 2. 导入数据库（首次或重置后）
scripts\init-db.bat

rem 3. 启动后端
scripts\start-backend.bat

rem 4. 启动前端（或在 doupo-frontend 目录 npm install && npm run dev）
scripts\start-frontend.bat
```

---

## 三、账号

| 账号 | 密码 | 权限 | 说明 |
|------|------|------|------|
| `admin` | `123456` | 0 = 管理员 | 首页导航栏会显示「后台管理系统」按钮 |
| `xiaoyan` | `123456` | 1 = 默认权限 | 看不到后台入口，也无法登录后台 |
| 注册的新用户 | 自定 | 1 = 默认权限 | 注册后即为默认权限 |

> 按需求，用户表密码为**明文存储**，未做加密。

---

## 四、功能清单

**图鉴（/home）**

- 卡片墙：按品阶 / 异火榜 / 收服难度 / 最新收录排序，支持分类 × 品阶 × 火色 × 最低难度组合筛选
- 点击卡片弹出**详情弹窗**：异火形态、收服难度星级、历代持有者、收服功法、经典台词、简介
- 详情里可以「收服 / 放生」、写**私人笔记**（存数据库）、发评论
- 卡片入场火焰浮现动画、背景火星 + 流光微动效
- 导航栏右上角：仅 `role=0` 的管理员可见「后台管理系统」按钮

**境界系统（右上角）**

- 修为分 = 收服数×4 + 签到天数×3 + 当日抽卡数×1
- 十境：斗者 → 斗师 → 大斗师 → 斗灵 → 斗王 → 斗皇 → 斗宗 → 斗尊 → 斗圣 → 斗帝
- 导航栏显示当前境界与进度条，首页横幅同步显示「距下一境还差多少」

**异火降临（抽卡）**

- 每日 3 次免费机会，按异火榜排名做权重（排名越前越稀罕）
- 翻牌动画 + Web Audio 合成火焰声（不依赖任何音频文件），抽到即自动入图鉴

**我的异火（/mine）**

- 图鉴完成度圆环、已收服 / 待收服统计
- 已收服正常展示，未收服用**黑色剪影**占位
- 成就系统：青莲初生、药老传人、炎帝之路、焚决大成、十火归元，带进度

**关系图谱（/graph）**

- ECharts 力导向图：异火 — 持有者（人物）— 收服功法 三类节点
- 可拖拽 / 缩放，点异火节点直接打开详情弹窗

**异火融合（/sim）**

- 选择两朵异火做「融合」或「吞噬」，按原著设定给结果
  （例：青莲地心火 + 陨落心炎 = 琉璃莲心火）
- 左右两个槽位都以异火原图铺满展示，左上角标异火榜排名，悬浮出现「换一朵」
- 结果卡会带上相关异火的原图（吞噬取胜者，融合取名中含有的那朵）
- 融合过程有汇聚与爆发的 CSS 动画

**炼药模拟器（/alchemy）**

- 抓 2~4 味药材（每味影响完美区宽度 / 品相 / 风险），再引一朵异火
- 点「开炉炼制」后指针在火候条上往返，进入金色「完美」区时点「控火」
  - 命中完美区中心 → 品相高（丹纹 1~5 道）；勉强进圈 → 只能出中低品
  - 错过区间 / 三个来回不控火 → **炸炉**：鼎盖炸飞、炉身焦黑开裂、浓烟碎片 + 全屏震动
- 异火决定难度与上限：骨灵冷火完美区 ×1.38、指针 ×0.70（最好上手）；
  九幽风炎指针会随风忽快忽慢；虚无吞炎窗口最窄但成丹必是高品
- 丹药名取自图鉴里真实的「丹药」条目，品相决定品阶（黄→天）
- 战绩（炼制数 / 成丹率 / 最近 6 炉）存 localStorage，Web Audio 合成开炉 / 成丹 / 炸炉音效

**灵魂力天赋测试（/talent，登录前可玩）**

- 登录页「点击测试你的初始天赋」进入；答 5 道斗气大陆情境题（遇强敌 / 拍卖残卷 / 丹炉不稳 …），无对错
- 每题选项暗加分到 **五行属性**（火木金水土）与 **行事风格**（狂暴 / 沉稳 / 匠心 / 机变），
  取主属性 + 主风格匹配 15 条天赋档案，生成「木属性·天生炼药师」「火属性·狂暴斗者」等称号
- 结果是一张「斗气大陆身份证」：证号、天赋、身份、魂力值（40~99）、星级、副属性、适用异火、
  三项属性条、五行偏向图、判词；带翻牌动效，可打印 / 另存为 PDF
- 未登录测完 →「带着天赋去注册」，注册时把 `talent / talentRank / talentScore` 一并提交存库；
  已登录 → 直接存为账号天赋。结果缓存在 `localStorage.doupo_talent`
- 白昼模式身份证换成米白证件纸，黑夜为深色描金；窄屏自动重排为竖版

**主题**

- 黑夜 / 白昼一键切换（`localStorage` 记忆）
- 详情弹窗里的色板可把整站强调色换成该异火的颜色

**后台**

- 仅管理员能登录（`role=1` 会提示「无管理员权限」）
- 数据概览、图鉴管理（增删改查、逻辑删除）、用户列表

---

## 五、接口一览

统一返回 `{ code, msg, data }`，`code=200` 成功。带 🔒 的需要请求头 `Authorization: Bearer {token}`。

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/auth/register` | 注册（role 固定为 1，可携带天赋三项） |
| POST | `/api/auth/login` | 前台登录，返回 token |
| POST | `/api/auth/admin/login` | 后台登录（仅 role=0） |
| GET | `/api/auth/me` | 当前用户 🔒 |
| POST | `/api/auth/logout` | 退出 |
| GET | `/api/item/overview` | 首页概览（统计 + 推荐 + 热词 + 火色分布） |
| GET | `/api/item/list` | 列表/搜索，参数 `keyword/category/grade/color/minDiff/sort/page/size` |
| GET | `/api/item/categories` | 分类、品阶、火色字典（带数量） |
| GET | `/api/item/{id}` | 条目详情（含形态/持有者/功法/台词） |
| GET | `/api/item/{id}/comments` | 评论列表 |
| POST | `/api/item/{id}/comments` | 发表评论 🔒 |
| GET | `/api/user/profile` | 个人档案：境界、收服数、成就、笔记 🔒 |
| POST | `/api/user/sign` | 每日签到 🔒 |
| POST | `/api/user/talent` | 重测 / 补测灵魂力天赋（覆盖三项） 🔒 |
| GET | `/api/user/collection` | 已收服 id 与笔记 🔒 |
| POST | `/api/user/collect/{itemId}` | 收服 🔒 |
| DELETE | `/api/user/collect/{itemId}` | 放生 🔒 |
| PUT | `/api/user/note/{itemId}` | 保存私人笔记 🔒 |
| GET | `/api/user/draw/info` | 今日抽卡余量 🔒 |
| POST | `/api/user/draw` | 异火降临抽一次 🔒 |
| GET | `/api/graph` | 关系图谱节点与连线 |
| POST | `/api/admin/login` | 后台登录（同上） |
| GET | `/api/admin/stats` | 后台统计 |
| GET | `/api/admin/items` | 后台列表（分页、关键字） |
| POST | `/api/admin/items` | 新增条目 |
| PUT | `/api/admin/items` | 修改条目 |
| DELETE | `/api/admin/items/{id}` | 删除条目（逻辑删除） |
| GET | `/api/admin/users` | 用户列表 |

`sort` 取值：`grade`（默认，按品阶）/ `rank`（异火榜）/ `difficulty`（收服难度）/ `newest`（最新）。

---

## 六、数据库

- 库：`doupo`（utf8mb4）
- 表：
  - `t_user`　用户，含 `role`（1 默认 / 0 管理员）、`sign_days`、`last_sign_date`
  - `t_item`　图鉴条目，含 `rank_no` 异火榜排名、`difficulty` 收服难度、`form_desc` 形态、
    `holders` 持有者、`method` 收服功法、`quote` 台词、`color` 主色、`deleted` 逻辑删除
  - `t_collect`　收服记录 + 私人笔记（`uk_user_item` 唯一）
  - `t_comment`　评论
  - `t_draw`　抽卡记录（按 `draw_date` 算每日次数）
- 脚本：`sql\doupo.sql`，可直接 `mysql -uroot -p123456 < sql\doupo.sql`
- 种子：27 条图鉴（其中 12 朵异火，带完整详情）+ 4 条评论 + 演示收藏

---

## 七、已知环境差异

- 本机 MySQL 是绿色版，装在 `C:\Users\III\dev\mysql8`，**不开机自启**，需用脚本拉起
- 本机没有全局 `mvn`，脚本会自动找 `.m2\wrapper\dists` 里的 Maven 或 IDEA 自带 Maven
- 首次 `mvn package` / `npm install` 需要联网下载依赖
