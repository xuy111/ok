package com.fenglin.springboottest.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;

/**
 * 剑诀加密：md5(明文 + salt)
 */
public final class Md5Util {

    private static final char[] HEX = "0123456789abcdef".toCharArray();
    private static final char[] SALT_CHARS = "abcdefghijklmnopqrstuvwxyz0123456789".toCharArray();
    private static final SecureRandom RANDOM = new SecureRandom();

    private Md5Util() {
    }

    public static String md5(String raw) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] bytes = md.digest(raw.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(bytes.length * 2);
            for (byte b : bytes) {
                sb.append(HEX[(b >> 4) & 0x0f]).append(HEX[b & 0x0f]);
            }
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException("MD5 not supported", e);
        }
    }

    /** 生成 8 位随机盐 */
    public static String salt() {
        StringBuilder sb = new StringBuilder(8);
        for (int i = 0; i < 8; i++) {
            sb.append(SALT_CHARS[RANDOM.nextInt(SALT_CHARS.length)]);
        }
        return sb.toString();
    }

    /** 明文 + 盐 后取 md5 */
    public static String encrypt(String raw, String salt) {
        return md5(raw + salt);
    }

    public static boolean matches(String raw, String salt, String hash) {
        return hash != null && hash.equals(encrypt(raw, salt));
    }
}
