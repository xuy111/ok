package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.dto.LoginRequest;
import com.fenglin.springboottest.dto.RegisterRequest;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.service.UserService;
import com.fenglin.springboottest.vo.UserVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

/**
 * 注册 / 登录 接口
 * 前端注册页面（shinchan-vue）通过 /api/register 提交注册
 */
@RestController
@RequestMapping("/api")
public class AuthController {

    @Autowired
    private UserService userService;

    /**
     * 注册接口
     * 接收 JSON：{ "nickname": "...", "password": "...", "snack": "..." }
     */
    @PostMapping("/register")
    public Result<UserVO> register(@RequestBody RegisterRequest request) {
        if (request == null
                || !StringUtils.hasText(request.getNickname())
                || !StringUtils.hasText(request.getPassword())) {
            return Result.fail("昵称和密码不能为空");
        }

        if (userService.isNicknameTaken(request.getNickname())) {
            return Result.fail("该昵称已被注册啦~换一个吧");
        }

        User user = userService.register(request);
        return Result.success(UserVO.from(user));
    }

    /**
     * 登录接口
     * 接收 JSON：{ "nickname": "...", "password": "..." }
     */
    @PostMapping("/login")
    public Result<UserVO> login(@RequestBody LoginRequest request) {
        if (request == null
                || !StringUtils.hasText(request.getNickname())
                || !StringUtils.hasText(request.getPassword())) {
            return Result.fail("昵称和密码不能为空");
        }

        User user = userService.login(request);
        if (user == null) {
            return Result.fail("昵称或密码错误");
        }
        return Result.success(UserVO.from(user));
    }
}
