package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 山门弟子（对应表 sys_user）
 */
@Data
@TableName("sys_user")
public class User {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 道号 / 账号 */
    private String uid;

    /** md5(剑诀 + salt) */
    private String pwdHash;

    /** 盐 */
    private String salt;

    /** 儒 / 道 / 释 / 兵 / 剑 */
    private String sect;

    /** 山门引荐 */
    private String invite;

    /** 1 在籍  0 逐出山门 */
    private Integer status;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    private LocalDateTime lastLoginTime;
}
