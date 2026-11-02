package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.time.LocalDateTime;

/**
 * 用户表实体（对应 onepiece 库的 user 表）
 */
@TableName("user")
public class User {

    /** 主键 */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户名（船长之名） */
    @TableField("username")
    private String username;

    /** 密码（SHA-256 摘要存储） */
    @TableField("password")
    private String password;

    /** 所属海贼团：straw/redhair/blackbeard/whitebeard */
    @TableField("crew")
    private String crew;

    /** 注册时间 */
    @TableField("create_time")
    private LocalDateTime createTime;

    public User() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getCrew() {
        return crew;
    }

    public void setCrew(String crew) {
        this.crew = crew;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    @Override
    public String toString() {
        return "User{id=" + id + ", username='" + username + "', crew='" + crew + "', createTime=" + createTime + "}";
    }
}
