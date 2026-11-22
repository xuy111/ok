package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/** 异火评论（t_comment） */
@Data
@TableName("t_comment")
public class Comment implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long itemId;

    private Long userId;

    private String nickname;

    private String content;

    private LocalDateTime createTime;

    @TableLogic
    private Integer deleted;
}
