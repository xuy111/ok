package com.fenglin.springboottest.controller;

import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.ItemMapper;
import com.fenglin.springboottest.service.AuthService;
import com.fenglin.springboottest.service.CollectService;
import com.fenglin.springboottest.service.GameService;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 前台用户玩法接口：档案/境界、签到、收服、抽卡。
 * 统一从 Authorization 头解析当前用户。
 */
@RestController
@RequestMapping("/api/user")
public class UserController {

    private final AuthService authService;
    private final GameService gameService;
    private final CollectService collectService;
    private final ItemMapper itemMapper;

    public UserController(AuthService authService, GameService gameService,
                          CollectService collectService, ItemMapper itemMapper) {
        this.authService = authService;
        this.gameService = gameService;
        this.collectService = collectService;
        this.itemMapper = itemMapper;
    }

    /** 个人档案：境界、收服数、签到、抽卡余量、成就、已收服 id 与笔记 */
    @GetMapping("/profile")
    public Result<Map<String, Object>> profile(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        User u = authService.currentUser(authorization);
        int total = Math.toIntExact(itemMapper.selectCount(null));
        return Result.ok(gameService.profile(u, total));
    }

    /** 每日签到 */
    @PostMapping("/sign")
    public Result<Map<String, Object>> sign(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        User u = authService.currentUser(authorization);
        return Result.ok(gameService.sign(u));
    }

    /** 重测 / 补测灵魂力天赋（覆盖本账号的天赋三项） */
    @PostMapping("/talent")
    public Result<Map<String, Object>> saveTalent(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody(required = false) Map<String, String> body) {
        User u = authService.currentUser(authorization);
        return Result.ok(authService.saveTalent(u, body));
    }

    /** 我的图鉴：已收服 id 列表 + 笔记 */
    @GetMapping("/collection")
    public Result<Map<String, Object>> collection(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        User u = authService.currentUser(authorization);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("ids", collectService.ids(u.getId()));
        data.put("notes", collectService.notes(u.getId()));
        data.put("count", collectService.count(u.getId()));
        return Result.ok(data);
    }

    /** 收服 */
    @PostMapping("/collect/{itemId}")
    public Result<Map<String, Object>> collect(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable Long itemId,
            @RequestBody(required = false) Map<String, String> body) {
        User u = authService.currentUser(authorization);
        String note = body == null ? null : body.get("note");
        return Result.ok(collectService.collect(u.getId(), itemId, note));
    }

    /** 放生（取消收服） */
    @DeleteMapping("/collect/{itemId}")
    public Result<Map<String, Object>> release(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable Long itemId) {
        User u = authService.currentUser(authorization);
        return Result.ok(collectService.release(u.getId(), itemId));
    }

    /** 只保存私人笔记 */
    @PutMapping("/note/{itemId}")
    public Result<Map<String, Object>> note(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable Long itemId,
            @RequestBody Map<String, String> body) {
        User u = authService.currentUser(authorization);
        collectService.saveNote(u.getId(), itemId, body.get("note"));
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("ok", true);
        return Result.ok(data);
    }

    /** 今日抽卡余量 */
    @GetMapping("/draw/info")
    public Result<Map<String, Object>> drawInfo(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        User u = authService.currentUser(authorization);
        return Result.ok(gameService.drawInfo(u.getId()));
    }

    /** 异火降临：抽一次 */
    @PostMapping("/draw")
    public Result<Map<String, Object>> draw(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        User u = authService.currentUser(authorization);
        return Result.ok(gameService.draw(u.getId()));
    }
}
