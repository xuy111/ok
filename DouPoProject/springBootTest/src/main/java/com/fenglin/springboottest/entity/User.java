package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 用户（t_user）。密码按需求存明文。
 * role：1 = 默认权限，0 = 管理员权限。
 */
@Data
@TableName("t_user")
public class User implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;

    /** 明文密码，序列化时永远不返回给前端 */
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String password;

    private String nickname;

    /** 1 默认权限 / 0 管理员 */
    private Integer role;

    /** 1 正常 / 0 禁用 */
    private Integer status;

    /** 累计签到天数 */
    private Integer signDays;

    /** 灵魂力天赋：属性·职业，如「木属性·天生炼药师」 */
    private String talent;

    /** 天赋评级：凡品/良品/上品/极品/天品 */
    private String talentRank;

    /** 灵魂力强度 40-99 */
    private Integer talentScore;

    /** 最近签到日期 */
    private LocalDate lastSignDate;

    private LocalDateTime lastLoginTime;

    private LocalDateTime createTime;
}
