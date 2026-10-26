package com.fenglin.springboottest.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * JWT 工具（HS256）
 * 生产环境请把 secret 与有效期放到配置文件里
 */
public final class JwtUtil {

    /** 至少 32 字节 */
    private static final String SECRET = "jianlai-sword-qi-chang-cheng-secret-key-2026";
    private static final SecretKey KEY = Keys.hmacShaKeyFor(SECRET.getBytes(StandardCharsets.UTF_8));

    /** 默认 7 天；「记住此山」30 天 */
    private static final long EXP_NORMAL = 7L * 24 * 60 * 60 * 1000;
    private static final long EXP_REMEMBER = 30L * 24 * 60 * 60 * 1000;

    private JwtUtil() {
    }

    public static String generate(String uid, boolean remember) {
        long exp = remember ? EXP_REMEMBER : EXP_NORMAL;
        Date now = new Date();
        return Jwts.builder()
                .subject(uid)
                .issuedAt(now)
                .expiration(new Date(now.getTime() + exp))
                .signWith(KEY)
                .compact();
    }

    /** 解析失败（过期/被篡改）返回 null */
    public static String parseUid(String token) {
        if (token == null || token.isBlank()) {
            return null;
        }
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(KEY)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
            return claims.getSubject();
        } catch (JwtException | IllegalArgumentException e) {
            return null;
        }
    }
}
