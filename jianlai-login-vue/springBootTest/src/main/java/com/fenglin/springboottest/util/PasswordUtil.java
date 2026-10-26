package com.fenglin.springboottest.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 剑诀加密：新密码一律 BCrypt；旧库里的 md5(明文+salt) 仍可登录，登录成功后自动升级
 */
public final class PasswordUtil {

    private static final BCryptPasswordEncoder ENCODER = new BCryptPasswordEncoder();

    private PasswordUtil() {
    }

    public static String encode(String raw) {
        return ENCODER.encode(raw);
    }

    /** 是否为 BCrypt 摘要 */
    public static boolean isBcrypt(String stored) {
        return stored != null && (stored.startsWith("$2a$") || stored.startsWith("$2b$") || stored.startsWith("$2y$"));
    }

    /**
     * 校验：BCrypt 走 BCrypt；否则按旧规则 md5(明文+salt) 校验
     *
     * @return true 表示通过
     */
    public static boolean matches(String raw, String salt, String stored) {
        if (stored == null) {
            return false;
        }
        if (isBcrypt(stored)) {
            return ENCODER.matches(raw, stored);
        }
        return Md5Util.matches(raw, salt, stored);
    }
}
