package com.fenglin.springboottest.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis-Plus 配置
 *
 * 说明：3.5.9 起 PaginationInnerInterceptor 拆到了 mybatis-plus-jsqlparser 模块，
 * 本项目只用单表 CRUD，暂不引入分页插件。若后续需要分页，加依赖：
 *   com.baomidou:mybatis-plus-jsqlparser:3.5.9
 * 再注册 MybatisPlusInterceptor + PaginationInnerInterceptor(DbType.MYSQL) 即可。
 */
@Configuration
@MapperScan("com.fenglin.springboottest.mapper")
public class MybatisPlusConfig {
}
