-- ============================================================
--  springBootTest 数据库初始化脚本
--  数据库：MySQL 8.0
--  执行账号：root / 123456
--  说明：根据前端注册页面（昵称 / 密码 / 确认密码 / 最喜欢的零食）
--        设计用户表，密码使用 BCrypt 哈希存储
-- ============================================================

-- 1. 创建数据库
CREATE DATABASE IF NOT EXISTS `springboot_test`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE `springboot_test`;

-- 2. 创建用户表
CREATE TABLE IF NOT EXISTS `user` (
  `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `nickname`    VARCHAR(50)   NOT NULL                COMMENT '昵称/账号',
  `password`    VARCHAR(100)  NOT NULL                COMMENT '密码（BCrypt 哈希）',
  `snack`       VARCHAR(100)  DEFAULT NULL            COMMENT '最喜欢的零食',
  `create_time` DATETIME      DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_nickname` (`nickname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
