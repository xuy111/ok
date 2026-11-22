package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;

/** 抽卡记录（t_draw）：按 draw_date 统计每日次数 */
@Data
@TableName("t_draw")
public class Draw implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private Long itemId;

    private LocalDate drawDate;

    private LocalDateTime createTime;
}
