package com.fenglin.springboottest.dto;

import lombok.Data;

/**
 * 注册请求参数
 */
@Data
public class RegisterRequest {

    /** 昵称 / 账号（对应前端 regUser） */
    private String nickname;

    /** 密码（对应前端 regPwd） */
    private String password;

    /** 最喜欢的零食（对应前端 regSnack） */
    private String snack;
}
