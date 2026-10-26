package com.fenglin.springboottest.config;

import com.fenglin.springboottest.util.JwtUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.nio.charset.StandardCharsets;

/**
 * 校验 Authorization: Bearer <token>
 * 放行路径在 WebConfig 里配置（登录/注册/重铸/自检）
 */
@Component
public class JwtInterceptor implements HandlerInterceptor {

    public static final String ATTR_UID = "currentUid";

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        if (HttpMethod.OPTIONS.matches(request.getMethod())) {
            return true;
        }
        String header = request.getHeader("Authorization");
        String token = null;
        if (header != null && header.startsWith("Bearer ")) {
            token = header.substring(7);
        }
        String uid = JwtUtil.parseUid(token);
        if (uid == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getOutputStream().write(
                    "{\"code\":401,\"msg\":\"剑诀令牌已失效 · 请重新入山\",\"data\":null}"
                            .getBytes(StandardCharsets.UTF_8));
            return false;
        }
        request.setAttribute(ATTR_UID, uid);
        return true;
    }
}
