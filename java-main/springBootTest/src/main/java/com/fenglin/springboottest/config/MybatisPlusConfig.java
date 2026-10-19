package com.fenglin.springboottest.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * MyBatis-Plus 配置：
 * - 扫描 Mapper 接口
 * - 提供 BCrypt 密码编码器
 */
@Configuration
@MapperScan("com.fenglin.springboottest.mapper")
public class MybatisPlusConfig {

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
