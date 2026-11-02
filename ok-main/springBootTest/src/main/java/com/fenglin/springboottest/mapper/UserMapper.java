package com.fenglin.springboottest.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.fenglin.springboottest.entity.User;

/**
 * 用户 Mapper（MyBatis-Plus BaseMapper，通用 CRUD 无需写 SQL）
 */
public interface UserMapper extends BaseMapper<User> {
}
