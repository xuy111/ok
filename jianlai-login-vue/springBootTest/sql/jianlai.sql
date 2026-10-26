-- =============================================================
-- 剑来 · 山门登录  数据库脚本
-- 数据库：jianlai      表：sys_user
-- 执行方式（任选其一）：
--   1) mysql -uroot -p123456 < sql/jianlai.sql
--   2) 在 IDEA / Navicat 里打开本文件全选执行
--   3) 应用启动时 url 带 createDatabaseIfNotExist=true，会自动建库，
--      但表仍需执行本脚本创建
-- =============================================================

CREATE DATABASE IF NOT EXISTS jianlai
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE jianlai;

DROP TABLE IF EXISTS sys_user;

CREATE TABLE sys_user (
  id               BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  uid              VARCHAR(32)  NOT NULL                COMMENT '道号 / 账号',
  pwd_hash         VARCHAR(64)  NOT NULL                COMMENT '剑诀摘要 md5(明文+salt)',
  salt             VARCHAR(16)  NOT NULL                COMMENT '盐',
  sect             VARCHAR(8)   NOT NULL DEFAULT '剑'    COMMENT '儒/道/释/兵/剑',
  invite           VARCHAR(32)  NOT NULL DEFAULT ''      COMMENT '山门引荐',
  status           TINYINT      NOT NULL DEFAULT 1       COMMENT '1 在籍  0 逐出山门',
  create_time      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '入门时间',
  update_time      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  last_login_time  DATETIME     NULL                     COMMENT '最近入山时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_uid (uid),
  KEY idx_status (status)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_general_ci
  COMMENT = '山门弟子表';

-- -------------------------------------------------------------
-- 演示账号（可直接登录体验）
--   道号：陈平安     剑诀：123456     salt：jl888888
--   道号：宁姚       剑诀：123456     salt：jl888888
-- -------------------------------------------------------------
INSERT INTO sys_user (uid, pwd_hash, salt, sect, invite, status) VALUES
  ('陈平安', '972a73ee94077443470a4967902e9599', 'jl888888', '剑', '骊珠洞天', 1),
  ('宁姚',   '972a73ee94077443470a4967902e9599', 'jl888888', '剑', '剑气长城', 1);

-- -------------------------------------------------------------
-- 常用查询
-- -------------------------------------------------------------
-- SELECT id, uid, sect, invite, status, create_time, last_login_time FROM sys_user;
-- UPDATE sys_user SET status = 0 WHERE uid = '某道号';   -- 逐出山门
-- DELETE FROM sys_user WHERE uid = '某道号';             -- 删除弟子
