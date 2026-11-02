package com.fenglin.springboottest.service;

import com.fenglin.springboottest.entity.User;

import java.util.Map;

/**
 * 用户业务接口
 */
public interface UserService {

    /**
     * 注册新船员
     * @param user 用户名
     * @param pass 明文密码
     * @param crew 海贼团标识
     * @return 提示消息
     */
    String register(String user, String pass, String crew);

    /**
     * 登录校验
     * @return 含 token 和 username 的数据
     */
    Map<String, Object> login(String user, String pass);

    /**
     * 根据 token 获取用户信息
     * @return 含 username 的数据
     */
    Map<String, Object> info(String token);
}
