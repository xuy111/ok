package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.common.JwtUtil;
import com.fenglin.springboottest.entity.CrewUser;
import com.fenglin.springboottest.service.CrewUserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 面向 Vue 前端的登录 / 注册 REST 接口
 */
@RestController
@RequestMapping("/api/user")
public class ApiController {

    @Autowired
    private CrewUserService crewUserService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * 登录
     * body: { "user": "luffy", "pass": "123456" }
     */
    @PostMapping("/login")
    public Result<?> login(@RequestBody Map<String, String> body) {
        String username = body.get("user");
        String password = body.get("pass");

        if (!StringUtils.hasText(username) || !StringUtils.hasText(password)) {
            return Result.fail("船长之名和口令不能为空");
        }

        CrewUser user = crewUserService.findByUsername(username.trim());
        if (user == null) {
            return Result.fail("该船长尚未登记，请先招募（注册）");
        }
        if (!passwordEncoder.matches(password, user.getPassword())) {
            return Result.fail("口令错误，请重新输入");
        }

        Map<String, Object> data = new HashMap<>();
        data.put("username", user.getUsername());
        data.put("crew", user.getCrew());
        data.put("token", jwtUtil.generate(user.getUsername(), user.getCrew()));
        return Result.ok("航海日志已记录，欢迎上船！", data);
    }

    /**
     * 注册
     * body: { "user": "nami", "pass": "123456", "crew": "straw" }
     */
    @PostMapping("/register")
    public Result<?> register(@RequestBody Map<String, String> body) {
        String username = body.get("user");
        String password = body.get("pass");
        String crew = body.get("crew");

        if (!StringUtils.hasText(username)) {
            return Result.fail("船长之名不能为空");
        }
        if (!StringUtils.hasText(password) || password.length() < 6) {
            return Result.fail("航海口令至少 6 位");
        }

        String name = username.trim();
        if (crewUserService.findByUsername(name) != null) {
            return Result.fail("该名字已被登记，换一个吧");
        }

        CrewUser user = new CrewUser();
        user.setUsername(name);
        user.setPassword(passwordEncoder.encode(password));
        user.setCrew(StringUtils.hasText(crew) ? crew : "straw");

        boolean saved = crewUserService.save(user);
        if (!saved) {
            return Result.fail("登记失败，请稍后再试");
        }

        return Result.ok("船员名册已登记，欢迎上船！");
    }

    /**
     * 健康检查
     */
    @GetMapping("/test")
    public Result<String> test() {
        return Result.ok("后端连接正常", "OK");
    }

    /**
     * 当前登录用户信息（需携带 Authorization: Bearer <token>）
     */
    @GetMapping("/info")
    public Result<?> info(HttpServletRequest request) {
        String username = (String) request.getAttribute("username");
        if (!StringUtils.hasText(username)) {
            return Result.fail(401, "未登录");
        }
        CrewUser user = crewUserService.findByUsername(username);
        if (user == null) {
            return Result.fail(401, "用户不存在");
        }
        Map<String, Object> data = new HashMap<>();
        data.put("username", user.getUsername());
        data.put("crew", user.getCrew());
        return Result.ok("已登录", data);
    }
}
