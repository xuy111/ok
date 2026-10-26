package com.fenglin.springboottest.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * 山门接口入参
 */
public class AuthRequest {

    @Data
    public static class LoginReq {
        @NotBlank(message = "道号不可为空 · 请留下姓名")
        private String uid;

        @NotBlank(message = "剑诀不可为空")
        @Size(min = 6, message = "剑诀不足六字 · 尚难登门")
        private String pwd;

        /** 记住此山 */
        private Boolean remember;
    }

    @Data
    public static class RegisterReq {
        @NotBlank(message = "道号不可为空 · 无名何以立派")
        @Size(max = 12, message = "道号过长 · 山门石碑刻不下")
        private String uid;

        @NotBlank(message = "剑诀不可为空")
        @Size(min = 6, message = "剑诀不足六字 · 尚难护山")
        private String pwd;

        @NotBlank(message = "请再诵一遍剑诀")
        private String confirm;

        /** 山门引荐，可空 */
        private String invite;

        /** 儒 / 道 / 释 / 兵 */
        private String sect;

        /** 是否允诺山规 */
        private Boolean agree;
    }

    @Data
    public static class ResetReq {
        @NotBlank(message = "道号不可为空 · 无主之剑不可重铸")
        private String uid;

        @NotBlank(message = "新剑诀不可为空")
        @Size(min = 6, message = "新剑诀不足六字 · 难承剑意")
        private String pwd;

        @NotBlank(message = "请再诵一遍新剑诀")
        private String confirm;
    }
}
