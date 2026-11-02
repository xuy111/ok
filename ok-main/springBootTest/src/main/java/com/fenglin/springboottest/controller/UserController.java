package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.service.UserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 用户接口（对接 onepiece-login 前端）
 * 前端约定：POST /api/user/login、POST /api/user/register、GET /api/user/info
 * 请求体: { user, pass, crew }，响应: { code, msg, data }
 */
@RestController
@RequestMapping("/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /** 登录：POST /api/user/login  body: {user, pass} */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        try {
            Map<String, Object> data = userService.login(body.get("user"), body.get("pass"));
            return Result.ok("伟大航道已为你敞开！", data);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        }
    }

    /** 注册：POST /api/user/register  body: {user, pass, crew} */
    @PostMapping("/register")
    public Result<Void> register(@RequestBody Map<String, String> body) {
        try {
            String msg = userService.register(body.get("user"), body.get("pass"), body.get("crew"));
            return Result.ok(msg);
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        }
    }

    /** 当前用户信息：GET /api/user/info （需携带 Authorization: Bearer xxx） */
    @GetMapping("/info")
    public Result<Map<String, Object>> info(@RequestHeader(value = "Authorization", required = false) String auth) {
        String token = null;
        if (auth != null && auth.startsWith("Bearer ")) {
            token = auth.substring(7);
        }
        try {
            Map<String, Object> data = userService.info(token);
            return Result.ok("欢迎回来，船长！", data);
        } catch (IllegalStateException e) {
            // 401：登录过期，前端会清除本地缓存并提示重新登录
            return Result.error(401, "登录已过期，请重新上船！");
        }
    }

    /** 健康检查：GET /api/user/ping */
    @GetMapping("/ping")
    public Result<Void> ping() {
        return Result.ok("后端运行中 ⚓");
    }
}
