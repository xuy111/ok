package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fenglin.springboottest.common.BizException;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.UserMapper;
import com.fenglin.springboottest.util.TokenStore;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 认证业务：注册 / 登录 / 后台登录 / 令牌校验。
 * 密码明文比对（需求明确要求不加密）。
 */
@Service
public class AuthService {

    public static final int ROLE_ADMIN = 0;
    public static final int ROLE_DEFAULT = 1;

    private final UserMapper userMapper;
    private final TokenStore tokenStore;

    public AuthService(UserMapper userMapper, TokenStore tokenStore) {
        this.userMapper = userMapper;
        this.tokenStore = tokenStore;
    }

    public boolean usernameExists(String username) {
        return userMapper.selectCount(
                new LambdaQueryWrapper<User>().eq(User::getUsername, username)) > 0;
    }

    /** 注册：新用户一律默认权限 role=1 */
    public Map<String, Object> register(String username, String password, String nickname) {
        return register(username, password, nickname, null, null, null);
    }

    /**
     * 注册（可携带灵魂力天赋）。
     * 天赋来自前端的「天赋测试」，是可选的展示属性，非法值直接忽略而不是报错，
     * 免得测试页改动导致注册整体失败。
     */
    public Map<String, Object> register(String username, String password, String nickname,
                                        String talent, String talentRank, String talentScore) {
        if (!StringUtils.hasText(username)) {
            throw new BizException("用户名不能为空");
        }
        username = username.trim();
        if (username.length() < 2 || username.length() > 20) {
            throw new BizException("用户名需为 2-20 位");
        }
        if (!StringUtils.hasText(password)) {
            throw new BizException("密码不能为空");
        }
        if (password.length() < 3) {
            throw new BizException("密码至少 3 位");
        }
        if (usernameExists(username)) {
            throw new BizException("该用户名已被注册");
        }
        User u = new User();
        u.setUsername(username);
        u.setPassword(password);
        u.setNickname(StringUtils.hasText(nickname) ? nickname.trim() : username);
        u.setRole(ROLE_DEFAULT);
        u.setStatus(1);
        u.setCreateTime(LocalDateTime.now());
        u.setTalent(trimTo(talent, 50));
        u.setTalentRank(trimTo(talentRank, 20));
        u.setTalentScore(parseScore(talentScore));
        userMapper.insert(u);

        Map<String, Object> data = new HashMap<>();
        data.put("id", u.getId());
        data.put("username", u.getUsername());
        data.put("role", u.getRole());
        data.put("talent", u.getTalent());
        data.put("talentRank", u.getTalentRank());
        data.put("talentScore", u.getTalentScore());
        return data;
    }

    /** 截断到指定长度，空值统一转空串，避免 null 进库 */
    private String trimTo(String s, int max) {
        if (!StringUtils.hasText(s)) {
            return "";
        }
        String t = s.trim();
        return t.length() > max ? t.substring(0, max) : t;
    }

    /** 灵魂力 40-99，非法输入按 0 处理 */
    private Integer parseScore(String s) {
        try {
            int v = Integer.parseInt(String.valueOf(s).trim());
            return Math.max(0, Math.min(99, v));
        } catch (Exception e) {
            return 0;
        }
    }

    /**
     * 保存（或重测）灵魂力天赋。
     * 老账号没有天赋、或想重新测一次时走这里；结果直接覆盖。
     */
    public Map<String, Object> saveTalent(User user, Map<String, String> body) {
        if (body == null) {
            throw new BizException("缺少天赋数据");
        }
        String talent = trimTo(body.get("talent"), 50);
        if (!StringUtils.hasText(talent)) {
            throw new BizException("天赋名称不能为空");
        }
        String rank = trimTo(body.get("talentRank"), 20);
        Integer score = parseScore(body.get("talentScore"));

        User patch = new User();
        patch.setId(user.getId());
        patch.setTalent(talent);
        patch.setTalentRank(rank);
        patch.setTalentScore(score);
        userMapper.updateById(patch);

        Map<String, Object> data = new HashMap<>();
        data.put("talent", talent);
        data.put("talentRank", rank);
        data.put("talentScore", score);
        return data;
    }

    /** 普通登录：默认权限与管理员都可登录前台 */
    public Map<String, Object> login(String username, String password) {
        User u = checkPassword(username, password);
        return buildLoginResult(u);
    }

    /** 后台登录：必须是管理员（role=0） */
    public Map<String, Object> adminLogin(String username, String password) {
        User u = checkPassword(username, password);
        if (!Integer.valueOf(ROLE_ADMIN).equals(u.getRole())) {
            throw new BizException(403, "当前账号无管理员权限，无法登录后台");
        }
        return buildLoginResult(u);
    }

    private User checkPassword(String username, String password) {
        if (!StringUtils.hasText(username) || !StringUtils.hasText(password)) {
            throw new BizException("用户名和密码不能为空");
        }
        User u = userMapper.selectOne(
                new LambdaQueryWrapper<User>().eq(User::getUsername, username.trim()));
        if (u == null || !password.equals(u.getPassword())) {
            throw new BizException("用户名或密码错误");
        }
        if (Integer.valueOf(0).equals(u.getStatus())) {
            throw new BizException(403, "该账号已被禁用");
        }
        // 记录最近登录时间
        User patch = new User();
        patch.setId(u.getId());
        patch.setLastLoginTime(LocalDateTime.now());
        userMapper.updateById(patch);
        u.setLastLoginTime(patch.getLastLoginTime());
        return u;
    }

    private Map<String, Object> buildLoginResult(User u) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", u.getId());
        data.put("username", u.getUsername());
        data.put("nickname", u.getNickname());
        data.put("role", u.getRole());
        data.put("talent", u.getTalent());
        data.put("talentRank", u.getTalentRank());
        data.put("talentScore", u.getTalentScore());
        data.put("token", tokenStore.issue(u.getId()));
        return data;
    }

    /** 由请求头解析当前用户，未登录抛 401 */
    public User currentUser(String authorization) {
        Long userId = tokenStore.resolve(TokenStore.strip(authorization));
        if (userId == null) {
            throw new BizException(401, "登录状态已失效，请重新登录");
        }
        User u = userMapper.selectById(userId);
        if (u == null) {
            throw new BizException(401, "账号不存在，请重新登录");
        }
        return u;
    }

    /** 由请求头解析管理员，非管理员抛 403 */
    public User requireAdmin(String authorization) {
        User u = currentUser(authorization);
        if (!Integer.valueOf(ROLE_ADMIN).equals(u.getRole())) {
            throw new BizException(403, "无管理员权限");
        }
        return u;
    }

    public void logout(String authorization) {
        tokenStore.revoke(TokenStore.strip(authorization));
    }
}
