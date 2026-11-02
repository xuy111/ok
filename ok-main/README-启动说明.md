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

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/user/login` | POST | 登录，body `{user, pass}`，返回 `{code, msg, data:{token, username, crew}}` |
| `/api/user/register` | POST | 注册，body `{user, pass, crew}` |
| `/api/user/info` | GET | 需要 `Authorization: Bearer <token>`，返回 `{data:{username, crew}}` |
| `/api/user/ping` | GET | 健康检查 |

返回结构统一为 `{code, msg, data}`：`200` 成功、`400` 业务错误、`401` 登录过期（前端自动清除缓存并提示重新登录）。

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
├── config/WebConfig.java            # CORS 跨域配置
├── controller/UserController.java   # 登录/注册/信息接口
├── entity/User.java                 # 用户实体（@TableName("user")）
├── mapper/UserMapper.java           # MyBatis-Plus BaseMapper
├── service/UserService.java         # 业务接口
├── service/impl/UserServiceImpl.java# 业务实现（注册查重/登录校验/SHA-256）
└── util/JwtUtil.java                # JWT 生成与校验
```

## 常见问题

1. **前端提示"无法连接后端"**：确认后端已在 8081 端口启动（访问 `http://localhost:8081/api/user/ping` 应返回 JSON）。
2. **数据库连接失败**：确认 MySQL 服务已启动、`onepiece` 库已初始化、账号密码为 `root/123456`（可在 `application.properties` 修改）。
3. **端口冲突**：8081 被占用时修改 `application.properties` 的 `server.port`，同时同步修改前端 `src/api.js` 的 `BASE` 地址。
