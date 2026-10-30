package com.fenglin.springboottest.common;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * JWT 工具类：签发与解析 token
 */
@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    /** 有效期（小时） */
    @Value("${jwt.expire-hours:24}")
    private long expireHours;

    private SecretKey key() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * 生成 token
     */
    public String generate(String username, String crew) {
        long now = System.currentTimeMillis();
        return Jwts.builder()
                .subject(username)
                .claim("crew", crew)
                .issuedAt(new Date(now))
                .expiration(new Date(now + expireHours * 3600_000L))
                .signWith(key())
                .compact();
    }

    /**
     * 解析 token，返回用户名；无效则抛异常
     */
    public String parseUsername(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(key())
                .build()
                .parseSignedClaims(token)
                .getPayload();
        return claims.getSubject();
    }
}
