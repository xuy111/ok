package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 收藏/收服记录（t_collect），一个用户对同一条目只允许一条。 */
@Data
@TableName("t_collect")
public class Collect implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private Long itemId;

    /** 私人笔记 */
    private String note;

    private LocalDateTime createTime;
}
