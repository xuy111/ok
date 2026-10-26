package com.fenglin.springboottest.util;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 极简令牌缓存（演示用，重启即失效）
 * 真实项目请换成 JWT / Spring Security / Redis
 */
public final class TokenStore {

    private static final Map<String, String> TOKEN_UID = new ConcurrentHashMap<>();

    private TokenStore() {
    }

    public static String issue(String uid) {
        String token = UUID.randomUUID().toString().replace("-", "");
        TOKEN_UID.put(token, uid);
        return token;
    }

    public static String uidOf(String token) {
        return token == null ? null : TOKEN_UID.get(token);
    }

    public static void remove(String token) {
        if (token != null) {
            TOKEN_UID.remove(token);
        }
    }
}
