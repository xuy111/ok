package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.dto.LoginRequest;
import com.fenglin.springboottest.dto.RegisterRequest;
import com.fenglin.springboottest.entity.User;

/**
 * 用户服务
 */
public interface UserService extends IService<User> {

    /** 昵称是否已被注册 */
    boolean isNicknameTaken(String nickname);

    /** 注册新用户，返回带主键的实体 */
    User register(RegisterRequest request);

    /** 登录校验，成功返回用户，失败返回 null */
    User login(LoginRequest request);
}
