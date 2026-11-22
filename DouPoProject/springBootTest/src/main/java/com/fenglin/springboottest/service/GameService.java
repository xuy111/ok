package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fenglin.springboottest.common.BizException;
import com.fenglin.springboottest.entity.Draw;
import com.fenglin.springboottest.entity.Item;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.DrawMapper;
import com.fenglin.springboottest.mapper.ItemMapper;
import com.fenglin.springboottest.mapper.UserMapper;
import com.fenglin.springboottest.util.Realm;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

/**
 * 玩法业务：异火降临抽卡、签到、境界与成就。
 */
@Service
public class GameService {

    /** 每日免费抽卡次数 */
    public static final int DAILY_LIMIT = 3;

    private static final Random RND = new Random();

    private final DrawMapper drawMapper;
    private final ItemMapper itemMapper;
    private final UserMapper userMapper;
    private final CollectService collectService;

    public GameService(DrawMapper drawMapper, ItemMapper itemMapper,
                       UserMapper userMapper, CollectService collectService) {
        this.drawMapper = drawMapper;
        this.itemMapper = itemMapper;
        this.userMapper = userMapper;
        this.collectService = collectService;
    }

    /* ------------------------- 抽卡 ------------------------- */

    private int todayDrawCount(Long userId) {
        return Math.toIntExact(drawMapper.selectCount(new LambdaQueryWrapper<Draw>()
                .eq(Draw::getUserId, userId)
                .eq(Draw::getDrawDate, LocalDate.now())));
    }

    public Map<String, Object> drawInfo(Long userId) {
        int used = todayDrawCount(userId);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("limit", DAILY_LIMIT);
        m.put("used", used);
        m.put("left", Math.max(0, DAILY_LIMIT - used));
        return m;
    }

    /** 抽一次：按异火榜排名做权重，排名越靠前越稀有 */
    public Map<String, Object> draw(Long userId) {
        int used = todayDrawCount(userId);
        if (used >= DAILY_LIMIT) {
            throw new BizException(429, "今日 " + DAILY_LIMIT + " 次机会已用完，明日再来");
        }
        List<Item> pool = itemMapper.selectList(new LambdaQueryWrapper<Item>()
                .eq(Item::getCategory, "异火"));
        if (pool.isEmpty()) {
            throw new BizException("异火池为空");
        }

        int total = 0;
        int[] weights = new int[pool.size()];
        for (int i = 0; i < pool.size(); i++) {
            Item it = pool.get(i);
            int rank = it.getRankNo() == null ? 0 : it.getRankNo();
            // 1 名权重最高（12），排名越后越高概率；未上榜给 3
            int w = rank <= 0 ? 3 : Math.max(1, 13 - rank);
            weights[i] = w;
            total += w;
        }
        int r = RND.nextInt(total);
        Item picked = pool.get(pool.size() - 1);
        for (int i = 0; i < pool.size(); i++) {
            r -= weights[i];
            if (r < 0) {
                picked = pool.get(i);
                break;
            }
        }

        boolean isNew = !collectService.ids(userId).contains(picked.getId());
        if (isNew) {
            collectService.collect(userId, picked.getId(), "");
        }

        Draw d = new Draw();
        d.setUserId(userId);
        d.setItemId(picked.getId());
        d.setDrawDate(LocalDate.now());
        d.setCreateTime(LocalDateTime.now());
        drawMapper.insert(d);

        Map<String, Object> m = new LinkedHashMap<>();
        m.put("item", picked);
        m.put("isNew", isNew);
        m.putAll(drawInfo(userId));
        return m;
    }

    /* ------------------------- 签到 ------------------------- */

    public Map<String, Object> sign(User user) {
        LocalDate today = LocalDate.now();
        Map<String, Object> m = new LinkedHashMap<>();
        if (today.equals(user.getLastSignDate())) {
            m.put("signed", false);
            m.put("msg", "今日已签到");
            m.put("signDays", user.getSignDays() == null ? 0 : user.getSignDays());
            return m;
        }
        int days = (user.getSignDays() == null ? 0 : user.getSignDays()) + 1;
        User patch = new User();
        patch.setId(user.getId());
        patch.setSignDays(days);
        patch.setLastSignDate(today);
        userMapper.updateById(patch);

        m.put("signed", true);
        m.put("msg", "签到成功，斗气 +1");
        m.put("signDays", days);
        return m;
    }

    /* ------------------------- 档案 / 境界 ------------------------- */

    public Map<String, Object> profile(User user, int totalItems) {
        int collectCount = collectService.count(user.getId());
        int signDays = user.getSignDays() == null ? 0 : user.getSignDays();
        int drawUsed = todayDrawCount(user.getId());

        Map<String, Object> realm = Realm.of(collectCount, signDays, drawUsed);

        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", user.getId());
        m.put("username", user.getUsername());
        m.put("nickname", user.getNickname());
        m.put("role", user.getRole());
        m.put("signDays", signDays);
        m.put("talent", user.getTalent());
        m.put("talentRank", user.getTalentRank());
        m.put("talentScore", user.getTalentScore());
        m.put("signedToday", LocalDate.now().equals(user.getLastSignDate()));
        m.put("collectCount", collectCount);
        m.put("totalItems", totalItems);
        m.put("drawLimit", DAILY_LIMIT);
        m.put("drawLeft", Math.max(0, DAILY_LIMIT - drawUsed));
        m.put("realm", realm);
        m.put("realmLadder", Realm.ladder());
        m.put("ids", collectService.ids(user.getId()));
        m.put("notes", collectService.notes(user.getId()));
        m.put("achievements", achievements(user.getId()));
        return m;
    }

    /** 成就：按收集组合解锁 */
    private List<Map<String, Object>> achievements(Long userId) {
        List<Long> ids = collectService.ids(userId);
        List<Item> owned = ids.isEmpty() ? new ArrayList<>()
                : itemMapper.selectBatchIds(ids);
        Set<String> names = new HashSet<>();
        int fireCount = 0;
        for (Item it : owned) {
            names.add(it.getName());
            if ("异火".equals(it.getCategory())) {
                fireCount++;
            }
        }

        List<Map<String, Object>> list = new ArrayList<>();
        list.add(ach("青莲初生", "收服青莲地心火与陨落心炎",
                Arrays.asList("青莲地心火", "陨落心炎"), names, false));
        list.add(ach("药老传人", "收服骨灵冷火与生灵之焱",
                Arrays.asList("骨灵冷火", "生灵之焱"), names, false));
        list.add(ach("炎帝之路", "集齐异火榜前三：帝炎、虚无吞炎、净莲妖火",
                Arrays.asList("帝炎", "虚无吞炎", "净莲妖火"), names, false));
        list.add(ach("焚决大成", "同时拥有焚决与天火三玄变",
                Arrays.asList("焚决", "天火三玄变"), names, false));
        list.add(ach("十火归元", "累计收服 10 朵异火", new ArrayList<>(), names, fireCount >= 10));
        return list;
    }

    private Map<String, Object> ach(String name, String desc, List<String> need,
                                    Set<String> owned, boolean force) {
        boolean ok = force || (!need.isEmpty() && owned.containsAll(need));
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("name", name);
        m.put("desc", desc);
        m.put("unlocked", ok);
        m.put("progress", need.isEmpty() ? (ok ? need.size() : 0)
                : countHit(need, owned));
        m.put("need", need.size());
        return m;
    }

    private int countHit(List<String> need, Set<String> owned) {
        int n = 0;
        for (String s : need) {
            if (owned.contains(s)) {
                n++;
            }
        }
        return n;
    }
}
