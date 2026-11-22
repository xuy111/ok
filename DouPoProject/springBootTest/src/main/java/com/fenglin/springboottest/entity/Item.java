package com.fenglin.springboottest.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 图鉴条目（t_item）：首页展示数据，由后台管理系统维护。
 * category：异火 / 功法 / 斗技 / 丹药 / 法宝
 * grade：黄阶 / 玄阶 / 地阶 / 天阶
 * 详情扩展：异火榜排名、收服难度、形态、持有者、收服功法、经典台词、主色
 */
@Data
@TableName("t_item")
public class Item implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private String category;

    private String grade;

    /** 异火榜排名，0 = 未上榜 */
    private Integer rankNo;

    /** 收服难度 1-5 */
    private Integer difficulty;

    private String description;

    /** 异火形态描述 */
    private String formDesc;

    /** 历代持有者，逗号分隔 */
    private String holders;

    /** 收服功法 */
    private String method;

    /** 经典台词 */
    private String quote;

    /** 主色：gold/black/pink/green/blue/ice/purple/red */
    private String color;

    private String icon;

    /** 异火插图：public 下的相对路径，如 /fire/diyan.jpg */
    private String image;

    private String source;

    private LocalDateTime createTime;

    /** 逻辑删除：0 正常 / 1 已删除 */
    @TableLogic
    private Integer deleted;
}
