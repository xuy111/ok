package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.Comment;
import com.fenglin.springboottest.entity.Item;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.service.AuthService;
import com.fenglin.springboottest.service.CommentService;
import com.fenglin.springboottest.service.ItemService;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 首页展示与搜索接口（浏览无需登录，评论需要登录）。
 */
@RestController
@RequestMapping("/api/item")
public class ItemController {

    private final ItemService itemService;
    private final CommentService commentService;
    private final AuthService authService;

    public ItemController(ItemService itemService, CommentService commentService,
                          AuthService authService) {
        this.itemService = itemService;
        this.commentService = commentService;
        this.authService = authService;
    }

    /**
     * 首页列表 / 分级分类搜索 / 高级搜索
     *
     * @param keyword  关键字（名称、简介、持有者、功法、出处）
     * @param category 分类：异火/功法/斗技/丹药/法宝
     * @param grade    品阶：天阶/地阶/玄阶/黄阶
     * @param color    主色：gold/black/pink/green/blue/ice/purple/red
     * @param minDiff  最低收服难度 1-5
     * @param sort     grade(默认) | rank(异火榜) | difficulty(收服难度) | newest(最新)
     */
    @GetMapping("/list")
    public Result<Map<String, Object>> list(@RequestParam(required = false) String keyword,
                                            @RequestParam(required = false) String category,
                                            @RequestParam(required = false) String grade,
                                            @RequestParam(required = false) String color,
                                            @RequestParam(required = false) Integer minDiff,
                                            @RequestParam(required = false) String sort,
                                            @RequestParam(required = false) Integer page,
                                            @RequestParam(required = false) Integer size) {
        return Result.ok(itemService.search(keyword, category, grade, color, minDiff, sort, page, size));
    }

    /** 首页概览：统计 + 推荐 + 热词 */
    @GetMapping("/overview")
    public Result<Map<String, Object>> overview() {
        return Result.ok(itemService.overview());
    }

    /** 分类、品阶、主色字典（带数量） */
    @GetMapping("/categories")
    public Result<Map<String, Object>> categories() {
        return Result.ok(itemService.facets());
    }

    /** 条目详情 */
    @GetMapping("/{id}")
    public Result<Item> detail(@PathVariable Long id) {
        return Result.ok(itemService.detail(id));
    }

    /** 某条目的评论列表 */
    @GetMapping("/{id}/comments")
    public Result<Map<String, Object>> comments(@PathVariable Long id) {
        List<Comment> list = commentService.list(id);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("list", list);
        data.put("total", list.size());
        return Result.ok(data);
    }

    /** 发表评论（需登录） */
    @PostMapping("/{id}/comments")
    public Result<Comment> addComment(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        User u = authService.currentUser(authorization);
        return Result.ok(commentService.add(u, id, body.get("content")));
    }
}
