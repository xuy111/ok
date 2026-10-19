package com.fenglin.springboottest.dto;

import lombok.Data;

/**
 * 登录请求参数
 */
@Data
public class LoginRequest {

    /** 昵称 / 账号 */
    private String nickname;

    /** 密码 */
    private String password;
}
