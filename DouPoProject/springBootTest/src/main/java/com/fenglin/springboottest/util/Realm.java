package com.fenglin.springboottest.util;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 境界系统：按「活跃度」换算修为分，映射到斗破的十个境界。
 * 修为分 = 收服数*4 + 签到天数*3 + 抽卡次数*1
 */
public final class Realm {

    /** 十个境界及晋级门槛 */
    private static final String[] NAMES = {
            "斗者", "斗师", "大斗师", "斗灵", "斗王",
            "斗皇", "斗宗", "斗尊", "斗圣", "斗帝"
    };
    private static final int[] NEED = {
            0, 8, 20, 36, 56, 80, 108, 140, 176, 220
    };

    private Realm() {
    }

    public static int score(int collectCount, int signDays, int drawCount) {
        return collectCount * 4 + signDays * 3 + drawCount;
    }

    /** 当前境界信息：名称、等级、修为分、下一境界与还差多少 */
    public static Map<String, Object> of(int collectCount, int signDays, int drawCount) {
        int score = score(collectCount, signDays, drawCount);
        int level = 0;
        for (int i = NEED.length - 1; i >= 0; i--) {
            if (score >= NEED[i]) {
                level = i;
                break;
            }
        }
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("name", NAMES[level]);
        m.put("level", level + 1);
        m.put("score", score);
        m.put("maxLevel", NAMES.length);

        int curBase = NEED[level];
        if (level >= NAMES.length - 1) {
            m.put("nextName", "已至巅峰");
            m.put("nextNeed", 0);
            m.put("remain", 0);
            m.put("progress", 100);
        } else {
            int nextBase = NEED[level + 1];
            int span = nextBase - curBase;
            int done = score - curBase;
            m.put("nextName", NAMES[level + 1]);
            m.put("nextNeed", nextBase);
            m.put("remain", nextBase - score);
            m.put("progress", span <= 0 ? 100 : Math.min(100, done * 100 / span));
        }
        return m;
    }

    /** 全部境界（给前端展示阶梯用） */
    public static List<Map<String, Object>> ladder() {
        List<Map<String, Object>> list = new ArrayList<>();
        for (int i = 0; i < NAMES.length; i++) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("name", NAMES[i]);
            m.put("level", i + 1);
            m.put("need", NEED[i]);
            list.add(m);
        }
        return list;
    }
}
