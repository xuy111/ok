package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.service.AuthService;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 前台认证接口：注册 / 登录 / 当前用户 / 退出。
 * 约定：请求头 Authorization: Bearer {token}
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /** 连通性自检 */
    @GetMapping("/ping")
    public Result<String> ping() {
        return Result.ok("pong");
    }

    /** 注册（新用户 role=1 默认权限；可带测试出来的灵魂力天赋） */
    @PostMapping("/register")
    public Result<Map<String, Object>> register(@RequestBody Map<String, String> body) {
        return Result.ok(authService.register(
                body.get("username"), body.get("password"), body.get("nickname"),
                body.get("talent"), body.get("talentRank"), body.get("talentScore")));
    }

    /** 前台登录 */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        return Result.ok(authService.login(body.get("username"), body.get("password")));
    }

    /** 后台登录：仅管理员（role=0）可通过 */
    @PostMapping("/admin/login")
    public Result<Map<String, Object>> adminLogin(@RequestBody Map<String, String> body) {
        return Result.ok(authService.adminLogin(body.get("username"), body.get("password")));
    }

    /** 当前登录用户信息 */
    @GetMapping("/me")
    public Result<Map<String, Object>> me(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        User u = authService.currentUser(authorization);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("id", u.getId());
        data.put("username", u.getUsername());
        data.put("nickname", u.getNickname());
        data.put("role", u.getRole());
        return Result.ok(data);
    }

    /** 用户名是否已被占用 */
    @GetMapping("/check")
    public Result<Map<String, Object>> check(@RequestParam("username") String username) {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("exists", authService.usernameExists(username));
        return Result.ok(data);
    }

    /** 退出登录 */
    @PostMapping("/logout")
    public Result<Map<String, Object>> logout(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        authService.logout(authorization);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("ok", true);
        return Result.ok(data);
    }
}
