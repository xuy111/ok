package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fenglin.springboottest.entity.CrewUser;
import com.fenglin.springboottest.mapper.CrewUserMapper;
import org.springframework.stereotype.Service;

@Service
public class CrewUserService extends ServiceImpl<CrewUserMapper, CrewUser> {

    /**
     * 按用户名查询船员
     */
    public CrewUser findByUsername(String username) {
        LambdaQueryWrapper<CrewUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CrewUser::getUsername, username);
        return this.getOne(wrapper, false);
    }
}
