package com.fenglin.springboottest.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

/**
 * 轻量级 JWT 工具（HMAC-SHA256 签名，纯 JDK 实现，无第三方依赖）
 * Token 结构: base64url(header).base64url(payload).base64url(signature)
 * payload: {"username":"xxx","exp":毫秒时间戳}
 */
public final class JwtUtil {

    /** 签名密钥（生产环境请放到配置文件并定期更换） */
    private static final String SECRET = "onepiece-grand-line-secret-2026";

    /** Token 有效期：24 小时（毫秒） */
    private static final long EXPIRE_MS = 24 * 60 * 60 * 1000L;

    private JwtUtil() {
    }

    /** 为指定用户名生成 token */
    public static String createToken(String username) {
        long exp = System.currentTimeMillis() + EXPIRE_MS;
        String header = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
        String payload = "{\"username\":\"" + escape(username) + "\",\"exp\":" + exp + "}";
        String h = base64Url(header.getBytes(StandardCharsets.UTF_8));
        String p = base64Url(payload.getBytes(StandardCharsets.UTF_8));
        String sign = hmac(h + "." + p);
        return h + "." + p + "." + sign;
    }

    /**
     * 校验 token 并返回用户名
     * @return 用户名；token 非法或已过期返回 null
     */
    public static String verify(String token) {
        if (token == null || token.isBlank()) {
            return null;
        }
        String[] parts = token.split("\\.");
        if (parts.length != 3) {
            return null;
        }
        // 验签
        String expected = hmac(parts[0] + "." + parts[1]);
        if (!expected.equals(parts[2])) {
            return null;
        }
        // 解析 payload
        String payload = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8);
        int i = payload.indexOf("\"username\":\"");
        int j = payload.indexOf("\",\"exp\":");
        if (i < 0 || j <= i) {
            return null;
        }
        String username = payload.substring(i + 12, j);
        int k = payload.lastIndexOf(':');
        long exp;
        try {
            exp = Long.parseLong(payload.substring(k + 1, payload.length() - 1));
        } catch (NumberFormatException e) {
            return null;
        }
        if (System.currentTimeMillis() > exp) {
            return null;
        }
        return username;
    }

    private static String hmac(String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return base64Url(mac.doFinal(data.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException("JWT 签名失败", e);
        }
    }

    private static String base64Url(byte[] bytes) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private static String escape(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
