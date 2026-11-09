# 海贼王登录系统 · 前后端联调说明

## 项目结构

| 目录/文件 | 说明 |
|------|------|
| `new-java-main/onepiece-login/` | 前端：Vue 3 + Vite（登录/注册页） |
| `springBootTest/` | 后端：Spring Boot 3.4.5 + MyBatis-Plus + MySQL |
| `sql/onepiece.sql` | 数据库初始化脚本（`springBootTest/onepiece.sql` 也有一份） |
| `启动项目.bat` | 一键启动（自动装依赖/构建/初始化库） |
| `停止项目.bat` | 一键停止前后端 |
| `AI-快速启动指南.txt` | 给 AI 助手读的环境与操作速查（环境路径、命令、坑） |
| `验证截图-登录成功.png` | 浏览器端到端登录验证截图 |

## 技术栈

- 前端：Vue 3、Vite 6，端口 `5173`
- 后端：Spring Boot 3.4.5（Java 17+）、MyBatis-Plus 3.5.7，端口 `8081`，上下文路径 `/api`
- 数据库：MySQL 8.x，库名 `onepiece`，账号 `root / 123456`
- 认证：JWT（HMAC-SHA256，纯 JDK 实现，有效期 24 小时），密码 SHA-256 摘要存储

## 接口约定（前端 `src/api.js` 已对接）

返回结构统一为 `{code, msg, data}`：`200` 成功、`400` 业务错误、`401` 登录过期（前端自动清除缓存并提示重新登录）。

### 用户接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/user/login` | POST | 登录，body `{user, pass}`，返回 `{data:{token, username, crew}}` |
| `/api/user/register` | POST | 注册，body `{user, pass, crew}` |
| `/api/user/info` | GET | 需认证，返回 `{data:{username, crew}}` |
| `/api/user/ping` | GET | 健康检查 |

### 首页接口（除 ping/login 外均需 `Authorization: Bearer <token>`）

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/home/search` | GET | 分级分类搜索（分页），参数 `keyword`/`category`/`subcategory`/`page`/`size`，返回 `{data:{total, page, size, list}}` |
| `/api/home/recommend?limit=8` | GET | 首页热门推荐（按热度排序） |
| `/api/home/categories` | GET | 分级分类目录树 |
| `/api/home/crew?crew=straw` | GET | 按海贼团查船员（crew 为空返回全部） |
| `/api/home/island?region=东海` | GET | 按海域查岛屿（region 为空返回全部） |
| `/api/home/bounty?crew=straw` | GET | 悬赏榜（按数值降序） |
| `/api/home/timeline` | GET | 航海日志时间线 |
| `/api/home/favorite?contentId=1` | POST | 收藏 |
| `/api/home/unfavorite?contentId=1` | POST | 取消收藏 |
| `/api/home/favorites` | GET | 我的收藏列表 |
| `/api/home/favorite/check?contentId=1` | GET | 是否已收藏 |

## 启动步骤

### 方式一：一键脚本（推荐）

- **双击 `启动项目.bat`**：自动检查 MySQL → 初始化数据库（仅库不存在时）→ 缺 jar 自动 Maven 构建 → 启动后端(8081) → 缺 node_modules 自动 npm install → 启动前端(5173)
- **双击 `停止项目.bat`**：按端口停止前后端，不影响 MySQL

> 电脑每次开机会清除 `node_modules` 和 `target`，脚本会自动重新安装/构建，无需手动操作。

### 方式二：手动启动

### 1. 初始化数据库（只需一次）

```bash
mysql -uroot -p123456 < sql/onepiece.sql
```

> 种子账号：`luffy / zoro / shanks / teach / newgate`，密码均为 `123456`

### 2. 启动后端（IDEA 打开 `springBootTest` 运行主类，或命令行）

```bash
cd springBootTest
mvn spring-boot:run
# 或打包运行
mvn -DskipTests package
java -jar target/springBootTest-0.0.1-SNAPSHOT.jar
```

看到 `Tomcat started on port 8081` 即成功。

### 3. 启动前端

```bash
cd new-java-main/onepiece-login
npm install   # 首次
npm run dev
```

浏览器自动打开 `http://localhost:5173`，用 `luffy / 123456` 登录即可看到「伟大航道已为你敞开！」。

## 后端代码结构

```
src/main/java/com/fenglin/springboottest/
├── SpringBootTestApplication.java   # 启动类（@MapperScan 扫描 mapper 包）
├── common/Result.java               # 统一返回 {code, msg, data}
├── config/
│   └── WebConfig.java               # CORS 跨域配置（全局放行）
│                                    # 注：图鉴搜索用内存分页，不依赖分页插件
├── controller/
│   ├── UserController.java          # 登录/注册/信息接口
│   └── HomeController.java          # 首页搜索/船员/岛屿/悬赏/时间线/收藏接口
├── entity/
│   ├── User.java                    # 用户实体（@TableName("user")）
│   ├── Content.java                 # 航海图鉴实体（@TableName("content")）
│   ├── Timeline.java                # 时间线实体（@TableName("timeline")）
│   └── Favorite.java                # 收藏实体（@TableName("favorite")）
├── mapper/
│   ├── UserMapper.java              # MyBatis-Plus BaseMapper
│   ├── ContentMapper.java
│   ├── TimelineMapper.java
│   └── FavoriteMapper.java
├── service/
│   ├── UserService.java             # 用户业务接口
│   └── HomeService.java             # 首页业务实现（搜索/分类/推荐/船员/岛屿/悬赏/时间线/收藏）
├── service/impl/
│   └── UserServiceImpl.java         # 注册查重/登录校验/SHA-256
└── util/JwtUtil.java                # JWT 生成与校验
```

## 数据库表结构

| 表 | 说明 |
|------|------|
| `user` | 船员名册（登录账号） |
| `content` | 航海图鉴（首页搜索/展示/船员/岛屿/悬赏数据源，含分级分类字段） |
| `timeline` | 航海日志（剧情时间线） |
| `favorite` | 用户收藏（我的航海日志） |

> **完整初始化脚本为 `sql/onepiece.sql`**（含 4 张表 + 全部种子数据：5 个账号、99 条图鉴、15 条时间线）。其余 `sql/onepiece_*.sql` 为开发过程中的增量脚本，仅供追溯，实际部署只需执行 `onepiece.sql`。

## 常见问题

1. **前端提示"无法连接后端"**：确认后端已在 8081 端口启动（访问 `http://localhost:8081/api/user/ping` 应返回 JSON）。
2. **数据库连接失败**：确认 MySQL 服务已启动、`onepiece` 库已初始化、账号密码为 `root/123456`（可在 `application.properties` 修改）。
3. **端口冲突**：8081 被占用时修改 `application.properties` 的 `server.port`，同时同步修改前端 `src/api.js` 的 `BASE` 地址。
4. **改了后端代码却不生效**：`启动项目.bat` 只在 jar 不存在时才构建。修改 `springBootTest/src` 下的 Java 代码后，需先删除 `springBootTest/target/springBootTest-0.0.1-SNAPSHOT.jar`，或手动执行 `mvn -DskipTests clean package` 再启动，否则一直运行旧 jar。
5. **首页接口返回 401**：`/home/*` 全部需要 JWT（有效期 24 小时）。请先登录；token 过期时前端会自动清除本地缓存并退回登录页。
6. **首页数据为空**：确认 `onepiece` 库已用 `sql/onepiece.sql` 初始化（`content` 约 99 条、`timeline` 15 条）。启动脚本只在数据库不存在时导入，旧库请手动补导。
