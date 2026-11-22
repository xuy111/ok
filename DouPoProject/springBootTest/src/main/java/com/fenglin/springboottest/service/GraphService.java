package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fenglin.springboottest.entity.Item;
import com.fenglin.springboottest.mapper.ItemMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 关系图谱：把 t_item 里的「异火 - 持有者(人物) - 收服功法」解析成图数据，
 * 交给前端 ECharts 画力导向图。
 */
@Service
public class GraphService {

    private final ItemMapper itemMapper;

    public GraphService(ItemMapper itemMapper) {
        this.itemMapper = itemMapper;
    }

    public Map<String, Object> graph() {
        List<Item> all = itemMapper.selectList(new LambdaQueryWrapper<Item>());

        List<Map<String, Object>> nodes = new ArrayList<>();
        List<Map<String, Object>> links = new ArrayList<>();
        Set<String> nodeIds = new LinkedHashSet<>();

        // 异火节点
        for (Item it : all) {
            if (!"异火".equals(it.getCategory())) {
                continue;
            }
            Map<String, Object> n = node(it.getColor());
            n.put("id", "f" + it.getId());
            n.put("name", it.getName());
            n.put("category", 0);
            n.put("value", it.getRankNo() == null || it.getRankNo() <= 0 ? 30 : Math.max(20, 90 - it.getRankNo() * 4));
            n.put("symbolSize", it.getRankNo() != null && it.getRankNo() > 0 && it.getRankNo() <= 3 ? 46 : 32);
            n.put("itemId", it.getId());
            nodes.add(n);
            nodeIds.add("f" + it.getId());
        }

        // 人物节点 + 持有关系
        for (Item it : all) {
            if (!"异火".equals(it.getCategory()) || !StringUtils.hasText(it.getHolders())) {
                continue;
            }
            for (String raw : it.getHolders().split(",")) {
                String p = raw.trim();
                if (p.isEmpty()) {
                    continue;
                }
                String pid = "p_" + p;
                if (!nodeIds.contains(pid)) {
                    Map<String, Object> pn = node("gold");
                    pn.put("id", pid);
                    pn.put("name", p);
                    pn.put("category", 2);
                    pn.put("symbolSize", 34);
                    pn.put("value", 60);
                    nodes.add(pn);
                    nodeIds.add(pid);
                }
                links.add(link(pid, "f" + it.getId(), "持有"));
            }
            // 收服功法 -> 异火
            if (StringUtils.hasText(it.getMethod())) {
                String m = it.getMethod().trim();
                String mid = "m_" + m;
                if (!nodeIds.contains(mid)) {
                    Map<String, Object> mn = node("purple");
                    mn.put("id", mid);
                    mn.put("name", m);
                    mn.put("category", 1);
                    mn.put("symbolSize", 30);
                    mn.put("value", 50);
                    nodes.add(mn);
                    nodeIds.add(mid);
                }
                links.add(link(mid, "f" + it.getId(), "收服"));
            }
        }

        // 人物之间的固定关系（原著设定）
        addPerson(nodes, nodeIds, "魂天帝");
        addPerson(nodes, nodeIds, "陀舍古帝");
        addPerson(nodes, nodeIds, "药尘");
        addPerson(nodes, nodeIds, "萧炎");
        links.add(link("p_萧炎", "p_药尘", "师徒"));
        links.add(link("p_萧炎", "p_魂天帝", "宿敌"));
        links.add(link("p_陀舍古帝", "p_萧炎", "传承"));
        links.add(link("p_魂天帝", "p_虚无吞炎", "本命"));

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("nodes", nodes);
        data.put("links", links);
        data.put("categories", new String[]{"异火", "收服功法", "人物"});
        return data;
    }

    private void addPerson(List<Map<String, Object>> nodes, Set<String> ids, String name) {
        String pid = "p_" + name;
        if (ids.contains(pid)) {
            return;
        }
        Map<String, Object> pn = node("gold");
        pn.put("id", pid);
        pn.put("name", name);
        pn.put("category", 2);
        pn.put("symbolSize", 34);
        pn.put("value", 60);
        nodes.add(pn);
        ids.add(pid);
    }

    private Map<String, Object> node(String color) {
        Map<String, Object> n = new LinkedHashMap<>();
        n.put("color", color == null ? "gold" : color);
        return n;
    }

    private Map<String, Object> link(String source, String target, String label) {
        Map<String, Object> l = new LinkedHashMap<>();
        l.put("source", source);
        l.put("target", target);
        l.put("label", label);
        return l;
    }
}
