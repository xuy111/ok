package com.fenglin.springboottest.util;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Base64;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 令牌仓库：签发 / 校验登录令牌。
 *
 * <p>令牌是「自校验」的签名串（payload + HMAC-SHA256），不依赖内存表，
 * 所以重启后端不会再把所有人的登录状态清空（旧实现是内存 Map，重启即全员 401，
 * 表现就是「点收服没反应 / 我的异火永远是 0」）。</p>
 *
 * <p>格式：base64url(userId|签发时间|过期时间).hmac</p>
 */
@Component
public class TokenStore {

    /** 令牌有效期：7 天 */
    private static final long TTL_MILLIS = 7L * 24 * 60 * 60 * 1000;

    /** 主动登出的令牌（内存黑名单，重启后自然清空，无副作用） */
    private final Set<String> revoked = ConcurrentHashMap.newKeySet();

    @Value("${app.token.secret:doupo-flame-token-secret-2026}")
    private String secret;

    public String issue(Long userId) {
        long now = System.currentTimeMillis();
        String payload = userId + "|" + now + "|" + (now + TTL_MILLIS);
        String body = Base64.getUrlEncoder().withoutPadding()
                .encodeToString(payload.getBytes(StandardCharsets.UTF_8));
        return body + "." + sign(body);
    }

    public Long resolve(String token) {
        if (token == null || token.isBlank() || revoked.contains(token.trim())) {
            return null;
        }
        String t = token.trim();
        int dot = t.lastIndexOf('.');
        if (dot <= 0 || dot == t.length() - 1) {
            return null;
        }
        String body = t.substring(0, dot);
        String sig = t.substring(dot + 1);
        if (!MessageDigest.isEqual(
                sign(body).getBytes(StandardCharsets.UTF_8),
                sig.getBytes(StandardCharsets.UTF_8))) {
            return null;
        }
        try {
            String payload = new String(Base64.getUrlDecoder().decode(body), StandardCharsets.UTF_8);
            String[] parts = payload.split("\\|");
            if (parts.length != 3) {
                return null;
            }
            long expireAt = Long.parseLong(parts[2]);
            if (System.currentTimeMillis() > expireAt) {
                return null;
            }
            return Long.parseLong(parts[0]);
        } catch (Exception e) {
            return null;
        }
    }

    public void revoke(String token) {
        if (token != null && !token.isBlank()) {
            revoked.add(token.trim());
        }
    }

    private String sign(String body) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return Base64.getUrlEncoder().withoutPadding()
                    .encodeToString(mac.doFinal(body.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException("令牌签名失败", e);
        }
    }

    /** 从 "Bearer xxx" 中取出裸 token */
    public static String strip(String authorization) {
        if (authorization == null || authorization.isBlank()) {
            return null;
        }
        String s = authorization.trim();
        if (s.toLowerCase().startsWith("bearer ")) {
            return s.substring(7).trim();
        }
        return s;
    }
}
