package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.common.BizException;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.UserMapper;
import com.fenglin.springboottest.service.UserService;
import com.fenglin.springboottest.util.Md5Util;
import com.fenglin.springboottest.util.PasswordUtil;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public User login(String uid, String pwd) {
        User user = getByUid(uid);
        if (user == null) {
            throw new BizException("此道号未入山门 · 请先开宗立派");
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new BizException("此道号已被逐出山门");
        }
        if (!PasswordUtil.matches(pwd, user.getSalt(), user.getPwdHash())) {
            throw new BizException("剑诀有误 · 再想想");
        }
        // 旧库里的 md5 摘要，登录成功后自动升级为 BCrypt
        boolean needUpgrade = !PasswordUtil.isBcrypt(user.getPwdHash());
        User up = new User();
        up.setId(user.getId());
        up.setLastLoginTime(LocalDateTime.now());
        if (needUpgrade) {
            up.setPwdHash(PasswordUtil.encode(pwd));
            up.setSalt("");
        }
        updateById(up);
        user.setLastLoginTime(up.getLastLoginTime());
        return user;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public User register(String uid, String pwd, String invite, String sect) {
        if (uid.contains("魔")) {
            throw new BizException("此道号被剑气长城除名");
        }
        if (existsUid(uid)) {
            throw new BizException("此道号已有人用 · 换一个吧");
        }
        User user = new User();
        user.setUid(uid);
        user.setSalt("");
        user.setPwdHash(PasswordUtil.encode(pwd));
        user.setSect(StringUtils.hasText(sect) ? sect.trim() : "剑");
        user.setInvite(invite == null ? "" : invite.trim());
        user.setStatus(1);
        save(user);
        return user;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void resetPwd(String uid, String pwd) {
        User user = getByUid(uid);
        if (user == null) {
            throw new BizException("无主之剑不可重铸 · 请先立派");
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new BizException("此道号已被逐出山门");
        }
        User up = new User();
        up.setId(user.getId());
        up.setSalt("");
        up.setPwdHash(PasswordUtil.encode(pwd));
        updateById(up);
    }

    @Override
    public User profile(String uid) {
        User user = getByUid(uid);
        if (user == null) {
            throw new BizException("查无此人 · 令牌与道号不符");
        }
        user.setPwdHash(null);
        user.setSalt(null);
        return user;
    }

    @Override
    public boolean existsUid(String uid) {
        return getByUid(uid) != null;
    }

    private User getByUid(String uid) {
        if (!StringUtils.hasText(uid)) {
            return null;
        }
        return getOne(new LambdaQueryWrapper<User>()
                .eq(User::getUid, uid.trim())
                .last("limit 1"));
    }
}
