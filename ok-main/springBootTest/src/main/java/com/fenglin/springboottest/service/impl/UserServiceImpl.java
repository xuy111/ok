package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.UserMapper;
import com.fenglin.springboottest.service.UserService;
import com.fenglin.springboottest.util.JwtUtil;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * 用户业务实现（MyBatis-Plus）
 */
@Service
public class UserServiceImpl implements UserService {

    private static final Set<String> VALID_CREWS = Set.of("straw", "redhair", "blackbeard", "whitebeard");

    private final UserMapper userMapper;

    public UserServiceImpl(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    @Override
    public String register(String user, String pass, String crew) {
        if (user == null || user.isBlank()) {
            throw new IllegalArgumentException("船长之名不能为空！");
        }
        if (pass == null || pass.length() < 6) {
            throw new IllegalArgumentException("航海口令至少 6 位哦！");
        }
        String crewKey = (crew == null || !VALID_CREWS.contains(crew)) ? "straw" : crew;
        String name = user.trim();

        // 用户名唯一校验
        Long count = userMapper.selectCount(new QueryWrapper<User>().eq("username", name));
        if (count != null && count > 0) {
            throw new IllegalArgumentException("这个名字已被其他海贼抢注啦，换一个吧！");
        }

        User u = new User();
        u.setUsername(name);
        u.setPassword(sha256(pass));
        u.setCrew(crewKey);
        u.setCreateTime(LocalDateTime.now());
        userMapper.insert(u);
        return "船员名册已更新，去登录启航吧！";
    }

    @Override
    public Map<String, Object> login(String user, String pass) {
        if (user == null || pass == null || user.isBlank() || pass.isBlank()) {
            throw new IllegalArgumentException("船长之名与航海口令不能为空！");
        }
        User u = userMapper.selectOne(new QueryWrapper<User>().eq("username", user.trim()));
        if (u == null || !u.getPassword().equals(sha256(pass))) {
            throw new IllegalArgumentException("口令不对哦，海军的奸细！再试一次？");
        }
        Map<String, Object> data = new HashMap<>();
        data.put("token", JwtUtil.createToken(u.getUsername()));
        data.put("username", u.getUsername());
        data.put("crew", u.getCrew());
        return data;
    }

    @Override
    public Map<String, Object> info(String token) {
        String username = JwtUtil.verify(token);
        if (username == null) {
            // 前端约定 401 为登录过期
            throw new IllegalStateException("@401");
        }
        User u = userMapper.selectOne(new QueryWrapper<User>().eq("username", username));
        if (u == null) {
            throw new IllegalStateException("@401");
        }
        Map<String, Object> data = new HashMap<>();
        data.put("username", u.getUsername());
        data.put("crew", u.getCrew());
        return data;
    }

    /** SHA-256 摘要（十六进制小写） */
    private String sha256(String text) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(text.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(bytes.length * 2);
            for (byte b : bytes) {
                sb.append(Character.forDigit((b >> 4) & 0xF, 16));
                sb.append(Character.forDigit(b & 0xF, 16));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException("密码摘要计算失败", e);
        }
    }
}
