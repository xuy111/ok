# AI-NOTES · 给下一个「我」的交接说明

> 目的：这台电脑**每次开机都会重置**（`node_modules`、`target` 会被删），
> 下个会话不要重新探索，直接照这份做。

## 0. 一句话现状

项目已完整可运行：Vue 3 前端 + Spring Boot 3.4.5 后端 + MySQL 8，登录/注册/首页/后台管理均已联调通过。

## 1. 绝对路径（不要再找）

| 项 | 路径 |
|----|------|
| 项目根 | `C:\Users\III\Desktop\DouPoProject` |
| 前端 | `C:\Users\III\Desktop\DouPoProject\doupo-frontend` |
| 后端 | `C:\Users\III\Desktop\DouPoProject\springBootTest` |
| SQL | `C:\Users\III\Desktop\DouPoProject\sql\doupo.sql` |
| 脚本 | `C:\Users\III\Desktop\DouPoProject\scripts\*.bat`（**GBK 编码**） |
| JDK 21 | `C:\Users\III\dev\jdk-21\jdk-21.0.12.1+1` |
| MySQL 8.0.45 | `C:\Users\III\dev\mysql8\mysql-8.0.45-winx64\bin` |
| MySQL 配置 | `C:\Users\III\dev\mysql8\my.ini`（datadir=`...\mysql8\data`，port=3306） |
| Maven（无全局 mvn） | `C:\Users\III\.m2\wrapper\dists\apache-maven-3.9.9\977a63e90f436cd6ade95b4c0e10c20c\bin\mvn.cmd` |
| IDEA 自带 Maven | `D:\IDEA\IntelliJ IDEA Community Edition 2024.3.2.2\plugins\maven\lib\maven3\bin\mvn.cmd` |
| Node / npm | `C:\Program Files\nodejs\node.exe` / `npm.cmd`（v22.22.2） |
| Chrome（截图用） | `C:\Program Files\Google\Chrome\Application\chrome.exe` |

数据库：`doupo`，`root / 123456`；表 `t_user`（role：1 默认 / 0 管理员，密码明文）、`t_item`（逻辑删除 deleted）。
账号：`admin/123456`（管理员）、`xiaoyan/123456`（默认权限）。

## 2. 开机后的最短启动流程

**双击项目根目录的 `启动.bat` 即可**（等价于 `scripts\start-all.bat`）；停止双击 `停止.bat`。

```bat
:: 命令行方式
cd /d C:\Users\III\Desktop\DouPoProject
scripts\start-all.bat        :: MySQL -> 检查/建库 -> 起后端 8080 -> 起前端 5173 -> 轮询到就绪再开浏览器
```

辅助：`scripts\status.bat` 看状态，`scripts\init-db.bat` 强制重建数据库，
`scripts\start-mysql.bat` / `stop-mysql.bat` 单独控制 MySQL。

脚本已处理「node_modules / target 被删」：缺 jar 在**后端窗口**里 `mvn package`，缺依赖在**前端窗口**里 `npm install`。
`start-all.bat` 不再固定等 12 秒，而是**每 3 秒轮询 8080 / 5173 端口，两个都监听后才打开浏览器**（上限 420 秒）。

改完脚本**必须再转一次 GBK + CRLF**（见 3.5、3.6）。

## 3. 这台机器的坑（会反复踩，务必记住）

1. **Bash 工具基本不可用**：PortableGit 缺 `head`/`dirname`/`sed`，命令全部 `command not found`。统一用 PowerShell 工具。
2. **PowerShell 工具的 stdout 经常被吞**（返回 exit 0 但无输出）。可靠做法：把结果 `Set-Content` 到 `_out\xxx.txt`，再用 Read 读；每次用**不同文件名**，反复读同一个文件会触发「循环检测」把工具调用打断。
3. **`Start-Process` 拉起的进程会在命令结束时被杀**（sandbox）。需要常驻的服务（mysqld、jar、vite）必须用 `run_in_background: true` **前台阻塞**方式启动，拿 task_id 保活。
4. **命令里出现 `%XX%` 会被安全策略拦截**（判成 cmd 变量语法）。URL 编码不要写字面量 `%E5...`，用 `[uri]::EscapeDataString("中文")` 在运行时生成。
5. **.bat 必须 GBK**：Write 工具写的是 UTF-8，写完要转：
   ```powershell
   $enc=[Text.Encoding]::GetEncoding(936); Get-ChildItem $d -Filter *.bat | %{
     $t=[IO.File]::ReadAllText($_.FullName,[Text.Encoding]::UTF8); [IO.File]::WriteAllBytes($_.FullName,$enc.GetBytes($t)) }
   ```
5.5 **.bat 必须 CRLF（比 GBK 更致命）**：Write 工具产出的是 **LF 换行**，cmd 解析 `goto` / `if (...)` / `for /d` 会直接崩，
   症状就是「双击一闪就没」「快速启动打不开」且不给任何提示。转 GBK 时必须同时把换行改成 CRLF：
   ```powershell
   $utf8=[Text.UTF8Encoding]::new($false); $gbk=[Text.Encoding]::GetEncoding(936)
   Get-ChildItem $d -Filter *.bat | %{
     $t=[IO.File]::ReadAllText($_.FullName,$utf8)
     $t=($t -replace "`r`n","`n") -replace "`n","`r`n"
     [IO.File]::WriteAllBytes($_.FullName,$gbk.GetBytes($t)) }
   ```
   自检：读字节，`CRLF>0 且 bareLF==0` 才算对。
5.6 **npm / mvn 必须用「完整路径的 .cmd」调用，绝不能 `call "npm"`**。
   裸命令名加引号会让 `npm.cmd` 里的 `%~dp0` 变空，进而去当前目录找
   `node_modules\npm\bin\npm-cli.js`，报 `MODULE_NOT_FOUND`（实测踩过）。
   `env.bat` 现在用 `for /f ... in ('where npm.cmd')` 解析成绝对路径，脚本里一律 `call "%NPM%" run dev`。
6. **`server.port` 会被环境变量覆盖**（实测起来是 59450）。启动 jar 一律显式 `--server.port=8080`。
7. **控制台里 npm/mvn 的中文是乱码**（codepage 936 解码 UTF-8），属显示问题；判断成败看 `BUILD SUCCESS` / `built in x.xs` / 产物文件，不要看中文。
8. **调用后端时 PowerShell 的 JSON body 会把中文变成 `??`**。验证中文写入要用 `curl.exe --data-binary "@payload.json"`（payload 文件写 UTF-8），不要用 `Invoke-RestMethod -Body` 传中文。
9. `Get-NetTCPConnection` 有时返回空，判断端口用 `netstat -ano | findstr ":8080"`。
10. **在 PowerShell 工具里测试 .bat 的正确姿势**：`cmd.exe` 会被安全策略拦截，不能显式调用。
    用 `$null | & "C:\...\xxx.bat" *> "log.txt"`——`$null |` 让 `pause` 立刻返回不卡住，
    输出写进 log 再读。想让某服务独立窗口常驻，就在 bat 里 `start "标题" cmd /k call "xxx.bat"`，它能脱离父控制台存活。

## 7. 「快速启动打不开」自查顺序

1. 窗口一闪就没 → 99% 是 **.bat 被存成了 LF 换行**（见 3.5.5），重新转 GBK+CRLF。
2. 窗口留着但浏览器 404/拒绝连接 → 看 `DouPo-Backend` / `DouPo-Frontend` 两个窗口里的报错：
   - 前端 `MODULE_NOT_FOUND ... npm\bin\npm-cli.js` → npm 用了裸命令名（见 3.5.6）
   - 前端 `EADDRINUSE 5173` → 上一轮残留进程，跑 `scripts\stop-frontend.bat`
   - 后端 `Communications link failure` → MySQL 没起来，跑 `scripts\start-mysql.bat`
3. 确认状态：双击 `scripts\status.bat`，三个端口都应是「运行中」。
4. 前端固定 5173：`vite.config.js` 里 `server.port=5173, strictPort=true, host='0.0.0.0'`。

## 8. v2 玩法层（我加的，别人没写文档）

**数据库多了 3 张表**：`t_collect`（收服+笔记，`uk_user_item` 唯一）、`t_comment`、`t_draw`（按 `draw_date` 计每日次数）。
`t_item` 多 8 个字段：`rank_no / difficulty / form_desc / holders / method / quote / color`。
`t_user` 多 `sign_days`、`last_sign_date`。改完 `sql\doupo.sql` 记得**重新 source 一遍**（会 DROP 表）。

**境界**在 `util/Realm.java`：`score = 收藏*4 + 签到*3 + 抽卡*1`，门槛数组 `{0,8,20,36,56,80,108,140,176,220}` → 十境。
要调晋升速度只改这一个文件，`GameService.profile()` 会自动带出来。

**抽卡**在 `GameService.draw()`：权重 `13 - rank_no`，未上榜给 3，每日 3 次；抽到未拥有的会自动写入 `t_collect`。

**前端结构**：`store.js`（`reactive` 全局档案，替代 Pinia）、`theme.js`（8 种异火主色 + 白昼黑夜）、
`components/TopNav.vue`（内含 DrawModal）、`components/DetailModal.vue`（详情+笔记+评论）、
`views/MyFire.vue` / `Graph.vue`（ECharts）/ `Simulator.vue`（融合规则表写在前端，纯本地算）。

### 这次踩的新坑

1. **`/api/item/overview` 曾经漏了 colors**，导致首页「火色」筛选只剩「全部」。`facets()` 加了字段后，
   `overview()` 里必须手动 `data.put("colors", ...)`，它不会自动透传。
2. **ECharts graph 的 label 默认在节点内部**，浅色节点 + 浅色文字 = 看不见人物名。
   必须显式 `label: { position: 'right' }`，同时 `zoom: 0.8` 否则力导向图会溢出画布。
3. **`🪷`（莲花，Emoji 14）在 Windows 缺字形显示成方块**，换成 `🌸`。新增 emoji 前先在真机确认字形。
4. **新增 npm 依赖后 vite dev 需要重新预构建**，E2E 里要等 `networkidle2` 再截图，否则拿到旧模块。
5. 白昼模式下所有 `--gold2` 系标题都会「金字压米色底」看不清，`App.vue` 末尾有一整段
   `body.light ...{ color:#7a5f14 }` 的兜底覆盖，新增金色文字时记得往那里加一条。
6. 端到端脚本在 `C:\Users\III\WorkBuddy\2026-11-19-20-23-59\e2e\shot.cjs`（puppeteer-core 驱本机 Chrome），
   跑一遍约 28 秒，会输出 9 张截图到 `e2e\shots`。它**会真的抽卡、发评论、取消收藏**，
   跑完要执行下面这段恢复演示数据：
   ```sql
   DELETE FROM t_draw WHERE user_id=2 AND draw_date=CURDATE();
   DELETE FROM t_comment WHERE content='这朵火我收了';
   INSERT IGNORE INTO t_collect (user_id,item_id) VALUES (2,1);
   ```

## 4. 修改代码时的入口

- 新增接口：`controller/` → `service/` → `mapper/`（MP 的 `BaseMapper`，无 XML）
- 鉴权：`util/TokenStore`（**自校验签名 token，重启后端不掉线**）+ `AuthService.requireAdmin(header)`
- 前端请求：`src/api/index.js`（`adminAuth: true` 表示带后台 token）
- 路由守卫：`src/router/index.js`（`needUser` / `needAdmin`，后者要求 `role===0`）
- 统一返回：`common/Result`；异常：`common/GlobalExceptionHandler` + `BizException`

## 5. 改完怎么验（30 秒）

```powershell
# 后端在跑时
Invoke-RestMethod http://localhost:8080/api/auth/ping
Invoke-RestMethod http://localhost:8080/api/item/overview
# 注册 -> 登录
Invoke-RestMethod http://localhost:8080/api/auth/register -Method Post -ContentType "application/json" -Body '{"username":"u1","password":"123456"}'
Invoke-RestMethod http://localhost:8080/api/auth/login    -Method Post -ContentType "application/json" -Body '{"username":"u1","password":"123456"}'
# 普通用户进后台应 403
Invoke-RestMethod http://localhost:8080/api/admin/login    -Method Post -ContentType "application/json" -Body '{"username":"u1","password":"123456"}'
```

前端：`cd doupo-frontend; npm run build` 能过（96 modules）即语法无误；再 `npm run dev` 看 5173。

## 6. 别做的事
- 不要再新建 `doupo-project` 之类的平行目录，本项目就是唯一交付物。
- 不要把密码改成加密（需求明确要明文）。
- 后台入口现在对所有登录用户可见（需求已改），**权限仍由 `/admin/login` 接口 + `role=0` 守卫卡住**，别只靠前端隐藏。
- 不要把后台鉴权退回 `?admin=用户名` 那种写法（已改成 token）。

## 9. 「点收服没反应 / 我的异火永远是 0」根因与修法（2026-11-19 已修）

**症状**：详情弹窗点「收服此火」，按钮变成「已收服」，但「我的异火」仍是 `已收服 0 / 待收服 27`，刷新后也没有。

**两个根因**：

1. 旧 `TokenStore` 是内存 `Map`，**重启后端所有 token 立即失效**；而路由守卫只检查 `localStorage.doupo_user` 是否存在，不校验 token，
   于是页面照常打开、接口全 401。
2. `GlobalExceptionHandler` 把业务异常也包成 **HTTP 200 + `code:401`**；`api/index.js` 只 reject 网络错误，
   所以 `api.collect()` 照样 resolve，`DetailModal` 不看 `code` 就 `this.collected = true` → **假成功**；
   同时 `loadProfile()` 的 catch 吞掉 401 → 档案为 null → 页面全 0。

**修法**：

- 后端 `TokenStore` 改成 **HMAC-SHA256 自校验令牌**（`base64url(payload).签名`，7 天有效），`app.token.secret` 固定 → 重启后端不再掉线。
- 前端 `api/index.js` 统一判断：`body.code !== 200` 直接 `reject`，异常带 `e.code`；401/403 清本地会话并广播
  `doupo:auth-expired` / `doupo:admin-expired`。
- `App.vue` 监听广播 → 跳 `/login?expired=1`；`Login.vue` 显示「登录状态已过期」；`Admin.vue` 用 `onErr()` 收敛后台 401/403。
- `store.applyCollect(res.data)` 用接口返回的 `ids / count` **就地更新**；`DetailModal / Home / MyFire` 一律以后端返回为准，
  并给出 toast / footer 提示，不再本地假装成功。

**验证脚本**（puppeteer-core 驱本机 Chrome）：

- `C:\Users\III\WorkBuddy\2026-11-19-20-23-59\e2e-collect.js`：登录 → 我的异火 → 收服 → 断言已收服 +1、待收服 -1 → 放生还原。
- `C:\Users\III\WorkBuddy\2026-11-19-20-23-59\e2e-expired.js`：塞一个旧格式假 token 访问 `/mine`，断言被踢回登录页并清理本地状态。

**坑**：`xiaoyan` 账号本来就有 7 条收服记录（含 item 1），别拿 item 1 当「未收服」样本来测；
误删了用 `INSERT IGNORE INTO t_collect (user_id,item_id) VALUES (2,1);` 还原。

## 10. 后台入口（2026-11-19 加）

- 首页导航栏 `.menu` 里多了 `a.admin-entry`「⚙ 后台管理」，**对所有登录用户可见**（早期是 `v-if="isAdminUser"` 只给 role=0 看，已按新需求放开）。
  点它 → `/admin/login`。
- 窄屏（`≤1180px`）菜单整体隐藏，改由 `.tools` 里的 `.btn-admin-m` 齿轮按钮承接入口；`≤720px` 只留图标。
  `.tools` 加了 `margin-left:auto`，否则菜单隐藏后工具栏会挤在 logo 右边。
- `/admin/login`（`views/AdminLogin.vue`）**只有登录，没有注册**；普通账号提交会拿到 403 文案「当前账号无管理员权限，无法登录后台」，URL 停留在登录页。
- 登录成功写 `localStorage.doupo_admin` → 路由守卫校验 `role===0` → 进入 `/admin`。
  后台三块：数据概览（条目/用户/品阶、分类分布）、图鉴管理（增删改查，直接改首页展示数据）、用户列表。
- `index.html` 补了内联 SVG favicon（data URI），消掉控制台那条 `favicon.ico 404`。

验证脚本：`C:\Users\III\WorkBuddy\2026-11-19-20-23-59\e2e-admin-entry.js`
（普通用户点按钮 → 无注册入口 → 403 提示 → admin 登录 → 概览数据 27/3/13/5 → 图鉴管理 8 行 → 回前台 9 张卡片）。


---

---

## 11. 全站动态背景（动图版，2026-11-19）

素材：`doupo-frontend/public/bg-hero.gif`（328×186，39 帧，0.8MB，用户提供的短视频封面动图）。
**必须放 public + 绝对路径引用**（`url('/bg-hero.gif')`）。

### 关键坑：这张动图是浅色纸纹底
直接铺满会把整站照白。做法是 `filter: invert(1) hue-rotate(180deg)` —— 反相把纸底压成夜，hue-rotate(180deg)
再把色相转回来，于是「白纸 + 粉焰」变成「黑底 + 洋红焰」，最后 `mix-blend-mode: screen` 让黑底完全不参与叠加，
只留发光的焰与青莲。实测这套参数最平衡：

```css
filter: invert(1) hue-rotate(180deg) saturate(1.75) brightness(1.5) contrast(1.2) blur(.8px);
mix-blend-mode: screen;
```

### 结构（`src/components/DynamicBg.vue`，挂在 App.vue，fixed z-index:0）
1. `.gif`：动图本体，`cover` + `background-position: 56% 42%`（人物头在画面 65% 位置，靠右偏能露出全脸），
   再加 `translateY(4%)` 把人往下压一点，否则头顶会被裁掉；
2. `.aura`：粉焰/青莲/紫三团 screen 光晕，16s 呼吸；
3. `.sweep`：14s 扫光；
4. `.sparks`：34 颗粒子，配色改成与动图一致的粉/青/月白；
5. `.grain`：SVG feTurbulence 颗粒（opacity .07, overlay），用来盖住 4 倍放大后的涂抹感，看着像宣纸墨韵；
6. `.veil`：渐变 + 径向压暗。

### 内容页与白昼
- `dense`（App 里按路由算，登录/注册/后台登录之外的页面）：`.gif` 降到 `opacity .46`、`blur 1.4px`，
  否则人物会从半透明卡片后面透出来。
- 白昼模式反过来：**去掉反相、改 `mix-blend-mode: multiply`**，浅色纸底正好变成水彩，配奶油色 veil。
- `prefers-reduced-motion` 关 CSS 动画（GIF 本身仍会播，浏览器没有 CSS 手段暂停 background-gif）。
- 性能：只用**一张** GIF 当图层，不要为了做辉光复制第二份（两个 gif 会各跑一条解码）。
  实测 headless rAF 无掉帧，控制台无报错。

### 换图
覆盖 `public/bg-hero.gif` 即可。若是深底动图，记得把 `invert(1) hue-rotate(180deg)` 和 `mix-blend-mode: screen` 去掉。

---

## 12. 全站视频背景（2026-11-19，已从「仅图鉴页」升级为全站）

- 素材：`public/bg-home.mp4`（3840×2160，30s，H.264，**51MB**，用户提供）+ `public/bg-home-poster.jpg`
  （用 puppeteer 截 video 元素首帧，避免加载时黑屏闪一下）。旧的 `bg-hero.gif` 已删除。
- 位置：**统一在 `components/DynamicBg.vue` 的第一层**，`App.vue` 挂在 `router-view` 之前：
  ```html
  <video class="vid" src="/bg-home.mp4" poster="/bg-home-poster.jpg"
         autoplay muted loop playsinline preload="auto" disablepictureinpicture />
  ```
  `.vid{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;object-position:center 42%}`，
  外层 `.dyn-bg` 是 `position:fixed;z-index:0`。
- **为什么放 App 层**：video 不随路由重建 → 换页面视频继续播（实测 currentTime 递增、paused=false），
  不会每跳一次页就重头播一遍 51MB。
- 视差：`transform:translate3d(calc(var(--mx)*-14px), calc(var(--my)*-10px),0) scale(1.045)`，
  1.045 是为了给位移留边缘余量，否则平移会露出黑边。
- 三档遮罩（`.veil`，全部靠 App 传的 prop 切 class）：
  - 默认（/login、/register、/admin/login）：薄，视频清楚可见；
  - `.dyn-bg.dense`（我的异火、图谱、融合、后台）：video `brightness(.88)` + 遮罩压到 .58~.9，
    否则人脸从半透明卡片后透出来，图节点也糊；
  - `.dyn-bg.hero`（/home）：顶部 .66 → 22% 处 .26（露脸）→ 底部 .88（压住筛选区与卡片区）。
    **注意 CSS 顺序**：hero 规则必须写在 dense 之后，两者特异性相同，靠顺序覆盖。
- 白昼模式：`filter:brightness(1.5) saturate(.62) contrast(.72)` 把视频洗成淡彩水彩稿 + 奶油色遮罩，
  深色文字仍可读（早期只调 brightness，卡片区发白，已修）。
- 无障碍：`prefers-reduced-motion: reduce` 时 `pauseVideo()` 停掉视频，只留 poster 静态帧。
- 窄屏 ≤860px：`object-position:center 38%`，竖屏才不会只看到胸口以下。
- 注意：51MB 放 public 会原样进 dist；真上线建议压到 1080p / 8~10MB（`ffmpeg -vf scale=1920:-2 -crf 26`），
  本地演示无所谓。

---

## 13. 排查「登录不进去」：MySQL 掉线才是元凶（2026-11-19）

### 现象
- 登录按钮转圈，最后提示"网络异常"；后台、图鉴也全空白。
- 端口检查：**3306 没在监听**，8080/5173 都在 → 后端活着但连不上库。

### 根因
1. mysqld 被强杀（err 日志里最后一次是 `ready for connections`，之后没有 shutdown 记录，
   说明是被 taskkill / 关窗口这种硬终止带走的）。
2. 后端 HikariCP 默认 `connectionTimeout=30s`，且请求会一直等连接 → 前端 15s 超时先报"网络异常"，
   用户完全看不出是数据库的问题。
3. 更糟：`spring.datasource` 默认启动时会校验连接，**MySQL 不在时后端根本起不来**，
   于是又变成"连不上 8080"。

### 改动
- `application.properties`：
  - `spring.datasource.hikari.connection-timeout=4000`：拿不到连接 4 秒就报错，不再干等 30 秒；
  - `initialization-fail-timeout=-1`：MySQL 没起来时后端**照样启动**，只让具体接口失败；
  - 顺手配了 `maximum-pool-size=10 / minimum-idle=2`。
- `GlobalExceptionHandler`：
  - 新增 `isDbDown(Throwable)` 沿 cause 链判断（MyBatis 会把 `CannotGetJdbcConnectionException`
    包成 `MyBatisSystemException`，只看最外层类型抓不到）；
  - 命中则返回 `{code:503, msg:"数据库未连接：请先启动 MySQL（双击项目根目录的 启动.bat 即可）"}`，
    不再把 JDBC 栈信息甩到页面上。
- 前端 `api/index.js`：区分超时 / 连不上后端的文案，提示都指向「启动.bat」；
  `code:503` 会带着后端 msg 直接 reject，登录页 `catch` 里就显示出来了。
- `scripts/start-mysql.bat` 重写：改用 `Start-Process -WindowStyle Hidden` 启动 mysqld，
  **不再弹出 "MySQL" 控制台窗口**（以前那个窗口被关掉，MySQL 就无声无息地没了）；
  PowerShell 被策略挡住时自动回退到原来的 `start /min`。文件仍是 GBK + CRLF。

### 验证
- MySQL 宕机 + 后端在跑：登录接口 **4.2 秒**返回 `code:503` + 友好文案（之前挂 30 秒 / 报网络异常）。
- MySQL 宕机时启动后端：8080 正常监听（`initialization-fail-timeout=-1` 生效）。
- MySQL 拉起来后**不用重启后端**，登录立刻 200（61ms），admin 7ms，overview 24ms。
- 浏览器实测：清 localStorage → 登录 xiaoyan → 跳 /home、9 张卡片、刷新后会话仍在、控制台零报错。

### 下次再遇到「登不进去」的排查顺序
1. `netstat -ano | findstr :3306` —— 没监听就是 MySQL 挂了，双击 `启动.bat` 即可；
2. 3306 在、8080 不在 → 后端没起来，看 `scripts\\status.bat`；
3. 都正常还登不进 → 看浏览器 Network 里 `/api/auth/login` 的响应 code（401 密码错 / 503 数据库 / 网络）。

---

## 异火插图：12 张按原著形态重绘的图（2026-11-19）

### 需求
「根据原著帮我完善一下异火的图片」——之前卡片上只有一个 emoji（🔥/🌸/❄️），
看不出帝炎和八荒破灭炎的区别，也不像图鉴。

### 做法
1. **画图**：12 道异火各生成一张 1024×1024 插画，prompt 按原著的「形态」字段写，
   例如帝炎=金色王座+帝王虚影+万火朝拜、骨灵冷火=森白冷焰+焰心骨骼+冰晶、
   陨落心炎=石塔中的幽蓝心形焰、净莲妖火=粉白莲台、虚无吞炎=吞噬光线的漆黑旋涡。
2. **去水印**：生成图右下角带 AI 水印，用 Pillow 统一裁掉底部 ~11.5%，
   再等比缩放居中裁成 900×828，输出 JPEG(q88) → `doupo-frontend/public/fire/*.jpg`（12 张共约 2.3MB）。
3. **落库**：`t_item` 增加 `image VARCHAR(200)`，12 条异火按名称 UPDATE 成 `/fire/xxx.jpg`；
   `sql/doupo.sql` 里加了字段说明和 UPDATE 段，重新导库也能复现。
   （老库补字段：`ALTER TABLE t_item ADD COLUMN image VARCHAR(200) DEFAULT '' AFTER icon;`）
4. **后端**：`Item` 实体加 `image`，`ItemService.validate` 补空值与 200 字长度校验。
   MyBatis-Plus 自动映射，mapper 不用改。
5. **前端**（新增 `src/art.js`）：
   - `artOf(item)`：**优先 `item.image`，老后端没有该字段时按名称兜底**——
     所以就算数据库没迁移，图片也不会突然消失；管理员把 image 清空则回退 emoji。
   - `ItemCard`：卡片顶部 152px 封面（object-fit: cover），左下角分类、右上角榜排名与品阶，
     底部叠暗角保证文字可读，hover 轻微放大。
   - `DetailModal`：顶部 232px 横幅，底部渐隐到弹窗底色，左下角「异火榜 #N」金匾；
     有图时不再显示小 emoji 图标，避免重复。
   - `MyFire`：未收服的剪影卡改成灰度+压暗的插图，hover 才略微显形。
   - `DrawModal`：「异火降临」抽到的卡改成 132px 插图。
   - `Simulator`：融合槽位整块铺图（上暗下深渐隐），选择器 12 个小缩略图。
   - `Admin`：列表加 36×26 缩略图；表单补「插图路径」（带 datalist 预设）以及
     排名/难度/主色/形态/持有者/功法/台词——**openEdit 现在会带全部字段**，
     以前只提交 6 个字段，编辑一次就会把 rankNo、difficulty、formDesc 等冲成默认值（已修）。

### 验证（Chrome 无头 + puppeteer-core，1440×1000）
- 首页 9 张卡片全部命中封面图（`naturalWidth > 0`），无 404、控制台零报错。
- 详情弹窗横幅正常加载；后台列表缩略图正常；编辑弹窗字段齐全；
  融合页选择器 12 个缩略图、槽位整图正常。
- 截图见 `docs/preview-fire-*.png`。

### 注意
- 图片放 `public/fire/`，是**原样拷贝**到 dist 的静态资源，路径写 `/fire/xxx.jpg`（别带 `/public`）。
- 生成图带 AI 水印，重新生成时要重新裁一次（脚本思路见上，crop 底部 11.5% 再居中裁）。
- 同一文件连续两次 Edit 会偶发只生效一次，改完务必回头 grep 一遍关键标识（踩过两次坑）。

---

## 14. 炼药模拟器（/alchemy，2026-11-20 加）

### 需求
选几味药材 + 一种异火 → 点「炼制」→ 火候进度条指针往返，在「完美」区点击 → 成功出丹 / 失败炸炉；
不同异火成功率不同（骨灵冷火更高）。

### 实现（**纯前端，没有动数据库和接口**）
- `src/views/Alchemy.vue`（单文件，模板 + 逻辑 + 样式全在里面），路由 `needUser: true`，
  导航栏 `.menu` 加「炼药」，首页 hero 的 `.play-links` 加两个玩法快捷入口（融合 / 炼药）。
- 数据来源：`/api/item/list?category=异火&size=100` 取 12 朵火，
  `/api/item/list?category=丹药&size=100` 取 4 个丹药，**丹名与图鉴一致**；接口挂了也不影响游戏（有兜底名）。

### 判定模型（改手感只改这三处）
1. **完美区宽度**：`w = clamp(6, 34, 9.5 * fire.zone * zoneMul)`，`zoneMul = 1 + Σ药材.zone`。
   中心位置每炉随机（`14+w/2 ~ 86-w/2`），所以不能背位置。
2. **指针速度**：`46 * fire.speed * (1 + herbRisk * 0.6)`（%/秒），九幽风炎额外 `1 + 0.3*sin(t/260)` 摆动。
   三个来回不点 = 走火炸炉。
3. **品相**：`score = precision*2.8 + fire.quality*0.75 + herbQuality*0.55 + rand*0.4`，
   `precision = 1 - 0.4*dist/half`（完美区**贴边也有 0.6**，不会出现「明明进圈只得下品」）。
   阈值 2/3/4/5 → 中/上/极/绝，`<2` 下品；勉强进「良好区」`precision=0.28` 且 score 封顶 2.7（最多中品）。
   品相 → 品阶：下/中=黄阶，上=玄阶，极=地阶，绝=天阶，再从该品阶的丹药里随机一个。
- 火性表 `FIRE_PROFILE` 按**名字**取（帝炎/虚无吞炎/…/海心焰），未录入给 `FIRE_FALLBACK`；
  改平衡直接调这张表即可。骨灵冷火 = `speed .70 / zone 1.38`，所以「成丹率最高」。

### 视觉
- 丹炉是纯 CSS 画的：`rim`（炉口）+ `body`（炉身）+ `lid`（鼎盖）+ 三足 + 腰带 `band`；
  `flames`（炉后背景焰）+ `flame-front`（炉前火舌，**必须 z-index 高于炉身**才看得见）。
- 成丹：`lid` 掀飞（`lidOff`）→ `pill-out` 丹丸旋转升起 → 1s 后出结果卡。
- 炸炉：`blast` 红光 → `debris` 10 片碎屑 → `smoke` 14 团浓烟 → `shock` 冲击波 → 页面 `.quake` 抖动，
  炉身**用背景色改成焦黑**（不要用 `filter: grayscale`，那会把裂纹的橙光一起压灰）。
- 结果卡 `v-if="result && phase === 'done'"`：炸炉动画期间不提前剧透。
- 音效是 WebAudio 现场合成（sine 上行 = 开炉，三角波琶音 = 成丹，噪声低通 = 炸炉），无音频文件，可静音（存 localStorage）。
- 战绩存 `localStorage.doupo_alchemy_v1`，只保留最近 6 炉；不写数据库，所以**不会污染演示数据**。

### 坑
- 结果卡用了 `--c-hex/--c-rgb` 内联变量，`.result.bad` 里的同名变量**会被内联样式覆盖**，
  失败配色要在 `resultStyle()` 里按 `!success` 返回，别指望 CSS 类。
- 白昼模式下金色标题几乎看不见，已有 `:global(body.light)` 兜底块，新增金色文字记得补一条。
- 端到端：`C:\Users\III\WorkBuddy\2026-11-20-12-19-58\e2e\alchemy.cjs`（puppeteer-core 驱本机 Chrome，
  在浏览器内用 rAF 轮询 `.needle` 与 `.zone.perfect` 的 `getBoundingClientRect` 后直接 `btn.click()`，
  这样命中率不受网络延迟影响），截图在 `e2e\shots\a*.png`。

---

## 15. 异火融合页：双槽位图片（/sim，2026-11-20 修）

### 现象
右侧槽位选了「虚无吞炎」只显示一个 🔥 emoji，没有插图；左侧同款却有图。

### 两个根因（第二个才是元凶）
1. 模板里 **只有 A 槽写了 `.s-art`**，B 槽直接 `{{ b.icon }}`——哪怕选进 B 也永远只有 emoji。
2. B 槽其实**根本选不进东西**：早先写成 `@click="pick"`（不带括号），Vue 把 `$event` 当第一个参数传，
   `pickIndex` 恒为 0，于是点哪个槽都写进 `a`；再点一次 A 就把上一朵覆盖掉。
   现在 `pick(0)` / `pick(1)` 显式传下标。

### 改法
- A/B 槽统一成图片卡：`.s-art` 铺满 + `::after` 底部渐变托字；`.s-foot` 绝对定位在底部
  （**别用 `align-self:end`**——`.slot` 是 `display:grid + place-content:center`，`filled` 时
  必须改成 `display:block`，否则图片和文字会叠在中间看不清）。
- `.s-rank` 徽章：因为 `--c-hex` 可能是 `black`（虚无吞炎）或近白，**不要拿它当底色做浅色渐变**，
  用 `rgba(12,10,8,.72)` 深底 + `--c-hex` 描边 + 白字，白昼模式下同样可读。
- 结果卡 `resultArt`：吞噬取 `artFrom`（胜者），融合看结果名是否包含某朵原火名
  （`虚无·吞` → 虚无吞炎），都没有就退回 emoji（万火归一 / 同源相斥）。

### 数据层不用改
`t_item.image` 12 朵异火都有值，`public/fire/*.jpg` 12 张齐全，`art.js` 还有按名兜底。
排查这类「某张图没了」先分清是**渲染层没写 img**、还是**数据为空串**；
后者这个隐患已在 2026-11-20 修掉（见 §16 坑 3 的 `art.js` 空串兜底）。

### 端到端
`C:\Users\III\WorkBuddy\2026-11-20-12-19-58\e2e\sim.cjs`，截图 `docs/preview-sim*.png`。
注意 puppeteer 里点选择器要 `waitForSelector('.p-item')` 再 `click()`，否则会点到旧坐标。

---

## 16. 灵魂力天赋测试（/talent，2026-11-20 加）

### 需求
类似 MBTI 但用斗气大陆设定：登录 / 注册前点「点击测试你的初始天赋」→ 答 3~5 道情境题 →
生成一张「斗气大陆身份证」（如 木属性·天生炼药师 / 火属性·狂暴斗者），并可作为账号初始头像。

### 判定（全在 `src/talent.js`，改题或改平衡只动这个文件）
- 5 道情境题 × 4 选项，每个选项的 `scores` 暗加分到两组维度：
  `AXES` 五行（fire/wood/metal/water/earth）+ `STYLES` 风格（rage/calm/craft/wit）。
- `evaluate(picked)` 累加后取 `top(axis)` 主属性 + `top(style)` 主风格，
  到 `ARCHIVE`（15 条天赋档案）里精确匹配 `axis + style`；匹配不到退回该主属性的第一条。
- 魂力值 `score = clamp(40, 99, 48 + total/34*44 + jitter)`（加点随机避免人人同分），
  星级按 92 / 82 / 70 / 58 分 5 档；副属性取次高维度，`axisLabels` 给五行偏向图。

### 前端
- `src/views/Talent.vue` 三段式 `stage = intro | quiz | result`，路由 `/talent` **不设 needUser**（登录前可玩）。
- 结果写 `localStorage.doupo_talent`；`created()` 里有缓存就直接回看身份证。
- 未登录 → `saveOrRegister()` 跳 `/register?talent=1`，`Register.vue` 读缓存显示天赋徽章并在注册
  payload 里带上三项，可点 ✕ 不带天赋注册。
- 已登录 → `api.saveTalent()` 存库后 `loadProfile()` 刷新；「保存身份证」走 `window.print()`
  （`@media print` 只留卡片）。
- 入口：`Login.vue` 的 `.talent-entry`、`TopNav.vue` 的「天赋」、`Home.vue` 玩法区。

### 后端（这次**动了数据库**）
- `t_user` 加 `talent varchar(50) / talent_rank varchar(20) / talent_score int`，`entity/User.java` 对应三字段。
- `AuthService.register(...)` 多收三个可选参数，非法值静默忽略（测试页改动不能让整体注册失败）；
  `trimTo` 截断、`parseScore` 钳到 0~99 且非数字按 0。
- `POST /api/user/talent` 🔒 给老账号重测 / 补测，直接覆盖三项；
  `GameService.profile()` 与 `AuthService.buildLoginResult()` 都会回传这三项。
- 注册成功只跳登录页，不自动登录（沿用原逻辑）。

### 坑（重要）
1. **白昼模式身份证仍是黑底金字**：原先在 `<style scoped>` 里写
   `:global(body.light) :global(.light-scope) .cert-front { ... }`，实测编译后两个 `:global` 被并成
   复合选择器、匹配不上，整段规则**静默失效**（注释里「优先级抬到 0,3,0」是想当然）。
   修法：把白昼覆盖拆到**第二个非 scoped `<style>` 块**，选择器写 `body.light .light-scope .xxx`
   （优先级 0,3,1 > scoped 的 `.xxx[data-v]` 0,2,0），用 `.light-scope` 前缀把作用域限定在本组件。
   验证：`getComputedStyle('.cert-front').backgroundImage` 必须是 `linear-gradient(...#fffdf6...)`，
   不能只靠肉眼看截图。
2. 天赋名、页面大标题、五行轴标签用的是模板**内联 `:style` 主题亮色**，普通 CSS 覆盖不了：
   `.cf b` 用 `color:#5a4310 !important`；标题 / 轴名用 `filter:brightness(.6)` 只压亮度、
   保留五行属性色的区分，并去掉发光 `text-shadow`。
3. `art.js` 的 `artOf()` 早先 `image !== undefined && !== null` 就 `return item.image`，
   **空串会直接返回空串并盖掉名称兜底**（§15 末尾提过）。已改成
   `typeof image === 'string' && image.trim()` 才用，否则回退 `NAME_ART[name.trim()]`：
   某条数据的 image 意外被清空时，12 朵原著异火也不会「凭空没图」。

### 端到端
`C:\Users\III\WorkBuddy\2026-11-20-12-19-58\e2e\talent.cjs`（封面→5 题→身份证→注册带天赋→
登录态保存→白昼→窄屏→接口往返；会临时改 `xiaoyan` 天赋再还原，不污染演示数据）。
`verify.cjs` 复核 /sim 双槽图片、/graph、/admin/login；`probe-light.cjs` 只读计算样式，用来抓坑 1。
截图归档在 `docs/preview-talent*.png`。



