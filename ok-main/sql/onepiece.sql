-- ============================================================
-- One Piece 登录系统数据库初始化脚本
-- 数据库: onepiece    用户表: user
-- 适配后端: springBootTest (MyBatis-Plus + MySQL 8.x)
-- 密码存储方式: SHA-256 十六进制小写摘要
--   种子账号: luffy / 123456
--   (SHA-256("123456") = 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92)
-- 使用方法:
--   mysql -uroot -p123456 < onepiece.sql
-- ============================================================

DROP DATABASE IF EXISTS `onepiece`;
CREATE DATABASE `onepiece` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `onepiece`;

-- ------------------------------------------------------------
-- 用户表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `username`    VARCHAR(50)  NOT NULL                COMMENT '用户名(船长之名)',
    `password`    VARCHAR(64)  NOT NULL                COMMENT '密码(SHA-256摘要)',
    `crew`        VARCHAR(20)  NOT NULL DEFAULT 'straw' COMMENT '海贼团: straw/redhair/blackbeard/whitebeard',
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '船员名册';

-- ------------------------------------------------------------
-- 种子数据（密码均为 123456 的 SHA-256 摘要）
-- ------------------------------------------------------------
INSERT INTO `user` (`username`, `password`, `crew`) VALUES
('luffy',  '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'straw'),
('zoro',   '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'straw'),
('shanks', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'redhair'),
('teach',  '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'blackbeard'),
('newgate','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'whitebeard');

-- 验证
SELECT id, username, crew, create_time FROM `user`;
