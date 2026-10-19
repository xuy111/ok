package com.fenglin.springboottest.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.dto.LoginRequest;
import com.fenglin.springboottest.dto.RegisterRequest;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.UserMapper;
import com.fenglin.springboottest.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Override
    public boolean isNicknameTaken(String nickname) {
        return this.lambdaQuery()
                .eq(User::getNickname, nickname)
                .count() > 0;
    }

    @Override
    public User register(RegisterRequest request) {
        User user = new User();
        user.setNickname(request.getNickname());
        // 密码使用 BCrypt 哈希后存储
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setSnack(request.getSnack());
        user.setCreateTime(LocalDateTime.now());
        this.save(user);
        return user;
    }

    @Override
    public User login(LoginRequest request) {
        User user = this.lambdaQuery()
                .eq(User::getNickname, request.getNickname())
                .one();
        if (user == null) {
            return null;
        }
        // 校验密码（哈希比对）
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            return null;
        }
        return user;
    }
}
