package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户实体，对应数据库 user 表
 */
@Data
@TableName("user")
public class User {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 昵称 / 账号 */
    private String nickname;

    /** 密码（BCrypt 哈希，不对外暴露） */
    private String password;

    /** 最喜欢的零食 */
    private String snack;

    /** 注册时间 */
    private LocalDateTime createTime;
}
