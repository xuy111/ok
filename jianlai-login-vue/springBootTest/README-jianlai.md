# 剑来 · 山门登录 —— 后端（Spring Boot 3 + MyBatis-Plus + MySQL）

对接前端 `jianlai-login-vue`（Vue 3 + Vite，端口 5173）。

## 一、准备数据库

```sql
-- 方式 1：命令行
mysql -uroot -p123456 < sql/jianlai.sql

-- 方式 2：IDEA / Navicat 打开 sql/jianlai.sql 全选执行
```

脚本内容：建库 `jianlai` → 建表 `sys_user` → 插入演示账号

| 道号 | 剑诀 |
| --- | --- |
| 陈平安 | 123456 |
| 宁姚 | 123456 |

## 二、启动

```bash
# 方式 1：IDEA 直接运行 SpringBootTestApplication
# 方式 2：命令行
mvn spring-boot:run
```

默认 `dev`  profile，端口 **8081**（`application-dev.properties`）。

数据源（`application.properties`）：

```properties
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/jianlai?...&createDatabaseIfNotExist=true
spring.datasource.username=root
spring.datasource.password=123456
```

> 注意：url 里带了 `createDatabaseIfNotExist=true`，库会自动建，但**表必须执行 sql/jianlai.sql 才有**。

## 三、接口

统一返回 `{ code, msg, data }`，`code=200` 成功，`400` 业务失败（msg 直接显示在前端卡片上）。

| 方法 | 路径 | 入参 | 说明 |
| --- | --- | --- | --- |
| GET | `/api/auth/ping` | - | 连通性自检 |
| POST | `/api/auth/login` | `{uid, pwd, remember}` | 仗剑入山 → `{uid, sect, token}` |
| POST | `/api/auth/register` | `{uid, pwd, confirm, invite, sect, agree}` | 开宗立派 → `{uid, sect, token}` |
| POST | `/api/auth/reset` | `{uid, pwd, confirm}` | 重铸剑诀 → `{uid}` |
| GET | `/api/auth/check?uid=xx` | - | 道号是否已占用 → `{uid, exists}` |

自检示例：

```bash
curl http://127.0.0.1:8081/api/auth/ping
curl -X POST http://127.0.0.1:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"uid":"陈平安","pwd":"123456"}'
```

## 四、本次改造新增的文件

```
src/main/java/com/fenglin/springboottest/
├─ common/
│  ├─ Result.java              统一返回体 {code,msg,data}
│  └─ BizException.java        业务异常，msg 透传给前端
├─ config/
│  ├─ CorsConfig.java          放行 5173/5174/8125 跨域
│  ├─ MybatisPlusConfig.java    @MapperScan
│  └─ MetaObjectHandlerConfig.java  create_time/update_time 自动填充
├─ controller/
│  └─ AuthController.java      /api/auth/** 四个接口
├─ dto/AuthRequest.java        入参 + jakarta validation 注解
├─ entity/User.java            @TableName("sys_user")
├─ mapper/UserMapper.java      BaseMapper<User>
├─ service/
│  ├─ UserService.java
│  └─ impl/UserServiceImpl.java 登录/立派/重铸业务逻辑
├─ handler/GlobalExceptionHandler.java
└─ util/
   ├─ Md5Util.java             剑诀摘要 md5(明文+salt)
   └─ TokenStore.java          极简令牌缓存（重启失效，可换 JWT）
sql/jianlai.sql                建库建表脚本（含演示账号）
```

## 五、说明与可扩展点

- 密码存 `md5(明文 + salt)`，不是明文；生产建议换 BCrypt / Spring Security。
- Token 目前是内存 UUID（`TokenStore`），重启即失效；生产建议 JWT + Redis。
- 跨域来源在 `CorsConfig` 里写死为本地开发端口，部署时改成实际域名。
- MyBatis-Plus 3.5.9 的分页插件已拆到 `mybatis-plus-jsqlparser` 模块，本项目未引入；需要分页时加该依赖再注册 `PaginationInnerInterceptor`。
- `sql/SqlRunner.java` 是一个用 JDBC 直接执行脚本的小工具（可选，可删）：

```bash
java -cp <mysql-connector-j-8.0.33.jar> sql/SqlRunner.java sql/jianlai.sql
```
