package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.BizException;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.dto.AuthRequest;
import com.fenglin.springboottest.config.JwtInterceptor;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.service.UserService;
import com.fenglin.springboottest.util.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 山门接口：与前端 jianlai-login-vue 对接
 * 前缀 /api/auth，前端 vite 已配置代理到本服务
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    /** 连通性自检 */
    @GetMapping("/ping")
    public Result<String> ping() {
        return Result.ok("剑气长城 · 在线");
    }

    /** 仗剑入山 */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@Valid @RequestBody AuthRequest.LoginReq req) {
        User user = userService.login(req.getUid(), req.getPwd());
        Map<String, Object> data = new HashMap<>(4);
        data.put("uid", user.getUid());
        data.put("sect", user.getSect());
        data.put("token", JwtUtil.generate(user.getUid(), Boolean.TRUE.equals(req.getRemember())));
        return Result.ok("山门已开", data);
    }

    /** 开宗立派 */
    @PostMapping("/register")
    public Result<Map<String, Object>> register(@Valid @RequestBody AuthRequest.RegisterReq req) {
        if (!req.getPwd().equals(req.getConfirm())) {
            throw new BizException("两遍剑诀不同 · 心不静则剑不纯");
        }
        if (Boolean.FALSE.equals(req.getAgree())) {
            throw new BizException("未允山规 · 不可立派");
        }
        User user = userService.register(req.getUid(), req.getPwd(), req.getInvite(), req.getSect());
        Map<String, Object> data = new HashMap<>(4);
        data.put("uid", user.getUid());
        data.put("sect", user.getSect());
        data.put("token", JwtUtil.generate(user.getUid(), false));
        return Result.ok("山门已立", data);
    }

    /** 重铸剑诀 */
    @PostMapping("/reset")
    public Result<Map<String, Object>> reset(@Valid @RequestBody AuthRequest.ResetReq req) {
        if (!req.getPwd().equals(req.getConfirm())) {
            throw new BizException("两遍剑诀不同 · 心不静则剑不纯");
        }
        userService.resetPwd(req.getUid(), req.getPwd());
        Map<String, Object> data = new HashMap<>(2);
        data.put("uid", req.getUid());
        return Result.ok("剑诀重铸", data);
    }

    /** 山主个人信息：需带 Authorization: Bearer <token> */
    @GetMapping("/me")
    public Result<Map<String, Object>> me(HttpServletRequest request) {
        String uid = (String) request.getAttribute(JwtInterceptor.ATTR_UID);
        User user = userService.profile(uid);
        Map<String, Object> data = new HashMap<>(8);
        data.put("uid", user.getUid());
        data.put("sect", user.getSect());
        data.put("invite", user.getInvite());
        data.put("status", user.getStatus());
        data.put("createTime", user.getCreateTime());
        data.put("lastLoginTime", user.getLastLoginTime());
        return Result.ok(data);
    }

    /** 出山（JWT 无状态，前端丢弃 token 即可） */
    @PostMapping("/logout")
    public Result<String> logout(HttpServletRequest request) {
        String uid = (String) request.getAttribute(JwtInterceptor.ATTR_UID);
        return Result.ok("出山", uid);
    }
    @GetMapping("/check")
    public Result<Map<String, Object>> check(@RequestParam("uid") String uid) {
        Map<String, Object> data = new HashMap<>(2);
        data.put("uid", uid);
        data.put("exists", userService.existsUid(uid));
        return Result.ok(data);
    }
}
