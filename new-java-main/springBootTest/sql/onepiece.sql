-- ============================================================
-- 海贼王登录/注册系统 数据库初始化脚本
-- 数据库：onepiece
-- 说明：本地 MySQL，用户名 root，密码 123456
-- 用法：在 MySQL 客户端执行，或命令行：
--   mysql -uroot -p123456 < onepiece.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS `onepiece`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE `onepiece`;

-- ------------------------------------------------------------
-- 船员用户表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `t_user`;

CREATE TABLE `t_user` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username`    VARCHAR(50)  NOT NULL COMMENT '船长之名（登录名）',
  `password`    VARCHAR(100) NOT NULL COMMENT '航海口令（密码）',
  `crew`        VARCHAR(20)  NOT NULL DEFAULT 'straw' COMMENT '所属海贼团',
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT = '船员用户表';

-- ------------------------------------------------------------
-- 演示数据（口令为 123456，已用 BCrypt 加密存储）
-- ------------------------------------------------------------
INSERT INTO `t_user` (`username`, `password`, `crew`)
VALUES ('luffy', '$2b$10$Ot37GtnveXQme9nenHvjr.sT9rKO.5f3W6H0MvU0diKoUb60WDvNe', 'straw');
