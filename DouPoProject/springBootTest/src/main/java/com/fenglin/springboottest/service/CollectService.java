package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fenglin.springboottest.common.BizException;
import com.fenglin.springboottest.entity.Collect;
import com.fenglin.springboottest.entity.Item;
import com.fenglin.springboottest.mapper.CollectMapper;
import com.fenglin.springboottest.mapper.ItemMapper;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 收藏（收服）业务：收服 / 放生 / 我的图鉴 / 私人笔记。
 */
@Service
public class CollectService {

    private final CollectMapper collectMapper;
    private final ItemMapper itemMapper;

    public CollectService(CollectMapper collectMapper, ItemMapper itemMapper) {
        this.collectMapper = collectMapper;
        this.itemMapper = itemMapper;
    }

    private Collect find(Long userId, Long itemId) {
        return collectMapper.selectOne(new LambdaQueryWrapper<Collect>()
                .eq(Collect::getUserId, userId)
                .eq(Collect::getItemId, itemId));
    }

    public int count(Long userId) {
        return Math.toIntExact(collectMapper.selectCount(
                new LambdaQueryWrapper<Collect>().eq(Collect::getUserId, userId)));
    }

    public List<Long> ids(Long userId) {
        List<Collect> list = collectMapper.selectList(
                new LambdaQueryWrapper<Collect>().eq(Collect::getUserId, userId)
                        .orderByDesc(Collect::getId));
        List<Long> ids = new ArrayList<>();
        for (Collect c : list) {
            ids.add(c.getItemId());
        }
        return ids;
    }

    /** itemId -> note */
    public Map<String, String> notes(Long userId) {
        List<Collect> list = collectMapper.selectList(
                new LambdaQueryWrapper<Collect>().eq(Collect::getUserId, userId));
        Map<String, String> m = new LinkedHashMap<>();
        for (Collect c : list) {
            if (c.getNote() != null && !c.getNote().isEmpty()) {
                m.put(String.valueOf(c.getItemId()), c.getNote());
            }
        }
        return m;
    }

    /** 收服（已存在则更新笔记） */
    public Map<String, Object> collect(Long userId, Long itemId, String note) {
        Item item = itemMapper.selectById(itemId);
        if (item == null) {
            throw new BizException(404, "该条目不存在");
        }
        Collect c = find(userId, itemId);
        if (c == null) {
            c = new Collect();
            c.setUserId(userId);
            c.setItemId(itemId);
            c.setNote(note == null ? "" : note.trim());
            c.setCreateTime(LocalDateTime.now());
            collectMapper.insert(c);
        } else if (note != null) {
            c.setNote(note.trim());
            collectMapper.updateById(c);
        }
        return result(userId, itemId, true);
    }

    /** 放生（取消收藏） */
    public Map<String, Object> release(Long userId, Long itemId) {
        collectMapper.delete(new LambdaQueryWrapper<Collect>()
                .eq(Collect::getUserId, userId)
                .eq(Collect::getItemId, itemId));
        return result(userId, itemId, false);
    }

    /** 只改笔记 */
    public void saveNote(Long userId, Long itemId, String note) {
        Collect c = find(userId, itemId);
        if (c == null) {
            collect(userId, itemId, note);
            return;
        }
        c.setNote(note == null ? "" : note.trim());
        collectMapper.updateById(c);
    }

    private Map<String, Object> result(Long userId, Long itemId, boolean collected) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("collected", collected);
        m.put("itemId", itemId);
        m.put("count", count(userId));
        m.put("ids", ids(userId));
        return m;
    }
}
