package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.fenglin.springboottest.common.BizException;
import com.fenglin.springboottest.entity.Item;
import com.fenglin.springboottest.mapper.ItemMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 首页展示数据业务：分级分类搜索 + 首页概览 + 后台统计。
 * 分类：异火/功法/斗技/丹药/法宝；品阶：天阶>地阶>玄阶>黄阶。
 */
@Service
public class ItemService {

    public static final List<String> CATEGORIES = Arrays.asList("异火", "功法", "斗技", "丹药", "法宝");
    public static final List<String> GRADES = Arrays.asList("天阶", "地阶", "玄阶", "黄阶");

    /** 品阶排序：天阶在前，同级按 id 升序 */
    private static final String GRADE_ORDER =
            "ORDER BY FIELD(grade,'天阶','地阶','玄阶','黄阶') ASC, id ASC";

    /** 排序方式：默认品阶 / 异火榜排名 / 收服难度 / 最新收录 */
    private static final String ORDER_RANK =
            "ORDER BY CASE WHEN rank_no = 0 THEN 999 ELSE rank_no END ASC, id ASC";
    private static final String ORDER_DIFFICULTY = "ORDER BY difficulty DESC, id ASC";
    private static final String ORDER_NEWEST = "ORDER BY id DESC";

    private final ItemMapper itemMapper;

    public ItemService(ItemMapper itemMapper) {
        this.itemMapper = itemMapper;
    }

    /** 首页列表 / 分级分类搜索 / 高级搜索（排序、颜色、最低难度） */
    public Map<String, Object> search(String keyword, String category, String grade,
                                      String color, Integer minDiff, String sort,
                                      Integer page, Integer size) {
        int p = (page == null || page < 1) ? 1 : page;
        int s = (size == null || size < 1) ? 12 : Math.min(size, 100);

        LambdaQueryWrapper<Item> qw = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            String kw = keyword.trim();
            qw.and(w -> w.like(Item::getName, kw)
                    .or().like(Item::getDescription, kw)
                    .or().like(Item::getHolders, kw)
                    .or().like(Item::getMethod, kw)
                    .or().like(Item::getSource, kw));
        }
        if (StringUtils.hasText(category)) {
            qw.eq(Item::getCategory, category.trim());
        }
        if (StringUtils.hasText(grade)) {
            qw.eq(Item::getGrade, grade.trim());
        }
        if (StringUtils.hasText(color)) {
            qw.eq(Item::getColor, color.trim());
        }
        if (minDiff != null && minDiff > 0) {
            qw.ge(Item::getDifficulty, minDiff);
        }
        qw.last(orderOf(sort));

        IPage<Item> pageInfo = itemMapper.selectPage(new Page<>(p, s), qw);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("list", pageInfo.getRecords());
        data.put("total", pageInfo.getTotal());
        data.put("pages", pageInfo.getPages());
        data.put("current", pageInfo.getCurrent());
        data.put("size", pageInfo.getSize());
        return data;
    }

    private String orderOf(String sort) {
        if ("rank".equals(sort)) {
            return ORDER_RANK;
        }
        if ("difficulty".equals(sort)) {
            return ORDER_DIFFICULTY;
        }
        if ("newest".equals(sort)) {
            return ORDER_NEWEST;
        }
        return GRADE_ORDER;
    }

    public Item detail(Long id) {
        Item item = itemMapper.selectById(id);
        if (item == null) {
            throw new BizException(404, "条目不存在或已下架");
        }
        return item;
    }

    /** 筛选字典：分类、品阶、主色（含各自条目数） */
    public Map<String, Object> facets() {
        List<Item> all = itemMapper.selectList(new LambdaQueryWrapper<Item>());
        Map<String, Integer> catCount = new LinkedHashMap<>();
        Map<String, Integer> gradeCount = new LinkedHashMap<>();
        Map<String, Integer> colorCount = new LinkedHashMap<>();
        for (String c : CATEGORIES) {
            catCount.put(c, 0);
        }
        for (String g : GRADES) {
            gradeCount.put(g, 0);
        }
        for (Item it : all) {
            if (it.getCategory() != null) {
                catCount.merge(it.getCategory(), 1, Integer::sum);
            }
            if (it.getGrade() != null) {
                gradeCount.merge(it.getGrade(), 1, Integer::sum);
            }
            if (it.getColor() != null) {
                colorCount.merge(it.getColor(), 1, Integer::sum);
            }
        }
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("categories", catCount);
        data.put("grades", gradeCount);
        data.put("colors", colorCount);
        data.put("total", all.size());
        return data;
    }

    /** 首页概览：统计 + 推荐（天阶优先的最新 8 条） */
    public Map<String, Object> overview() {
        Map<String, Object> facets = facets();

        LambdaQueryWrapper<Item> qw = new LambdaQueryWrapper<>();
        qw.last(GRADE_ORDER + " LIMIT 8");
        List<Item> featured = itemMapper.selectList(qw);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("total", facets.get("total"));
        data.put("categories", facets.get("categories"));
        data.put("grades", facets.get("grades"));
        data.put("colors", facets.get("colors"));
        data.put("featured", featured);
        data.put("hotKeywords", Arrays.asList("异火榜", "焚决", "萧炎", "天阶斗技", "药尘", "玄重尺"));
        return data;
    }

    /* ============================ 后台管理 ============================ */

    /** 后台列表（含分页与关键字） */
    public Map<String, Object> adminList(String keyword, Integer page, Integer size) {
        int p = (page == null || page < 1) ? 1 : page;
        int s = (size == null || size < 1) ? 10 : Math.min(size, 100);
        LambdaQueryWrapper<Item> qw = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            String kw = keyword.trim();
            qw.and(w -> w.like(Item::getName, kw).or().like(Item::getDescription, kw));
        }
        qw.orderByDesc(Item::getId);
        IPage<Item> pageInfo = itemMapper.selectPage(new Page<>(p, s), qw);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("list", pageInfo.getRecords());
        data.put("total", pageInfo.getTotal());
        data.put("pages", pageInfo.getPages());
        data.put("current", pageInfo.getCurrent());
        return data;
    }

    /** 新增 */
    public void create(Item item) {
        validate(item);
        item.setId(null);
        item.setDeleted(0);
        item.setCreateTime(LocalDateTime.now());
        itemMapper.insert(item);
    }

    /** 修改 */
    public void update(Item item) {
        if (item == null || item.getId() == null) {
            throw new BizException("缺少条目 id");
        }
        validate(item);
        itemMapper.updateById(item);
    }

    /** 逻辑删除 */
    public void delete(Long id) {
        if (id == null) {
            throw new BizException("缺少条目 id");
        }
        itemMapper.deleteById(id);
    }

    private void validate(Item item) {
        if (item == null) {
            throw new BizException("参数不能为空");
        }
        if (!StringUtils.hasText(item.getName())) {
            throw new BizException("名称不能为空");
        }
        if (!StringUtils.hasText(item.getCategory()) || !CATEGORIES.contains(item.getCategory())) {
            throw new BizException("分类必须是：" + String.join("/", CATEGORIES));
        }
        if (!StringUtils.hasText(item.getGrade()) || !GRADES.contains(item.getGrade())) {
            throw new BizException("品阶必须是：" + String.join("/", GRADES));
        }
        if (item.getDescription() != null && item.getDescription().length() > 500) {
            throw new BizException("简介最多 500 字");
        }
        if (item.getIcon() == null) {
            item.setIcon("");
        }
        if (item.getImage() == null) {
            item.setImage("");
        }
        if (item.getImage().length() > 200) {
            throw new BizException("图片路径最多 200 字符");
        }
        if (item.getSource() == null) {
            item.setSource("");
        }
        if (item.getRankNo() == null) {
            item.setRankNo(0);
        }
        if (item.getDifficulty() == null || item.getDifficulty() < 1 || item.getDifficulty() > 5) {
            item.setDifficulty(3);
        }
        if (item.getColor() == null || !item.getColor().matches("gold|black|pink|green|blue|ice|purple|red")) {
            item.setColor("gold");
        }
        if (item.getFormDesc() == null) {
            item.setFormDesc("");
        }
        if (item.getHolders() == null) {
            item.setHolders("");
        }
        if (item.getMethod() == null) {
            item.setMethod("");
        }
        if (item.getQuote() == null) {
            item.setQuote("");
        }
    }

    /** 后台统计：总条目 + 各分类数量 */
    public Map<String, Object> stats() {
        Map<String, Object> facets = facets();
        Map<String, Object> data = new LinkedHashMap<>(facets);
        List<Map<String, Object>> list = new ArrayList<>();
        @SuppressWarnings("unchecked")
        Map<String, Integer> cats = (Map<String, Integer>) facets.get("categories");
        for (Map.Entry<String, Integer> e : cats.entrySet()) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("name", e.getKey());
            row.put("count", e.getValue());
            list.add(row);
        }
        data.put("categoryList", list);
        return data;
    }
}
