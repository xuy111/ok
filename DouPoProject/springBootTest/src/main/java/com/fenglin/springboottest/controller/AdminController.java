package com.fenglin.springboottest.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fenglin.springboottest.common.Result;
import com.fenglin.springboottest.entity.Item;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.UserMapper;
import com.fenglin.springboottest.service.AuthService;
import com.fenglin.springboottest.service.ItemService;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 后台管理系统接口：对首页展示的图鉴条目做增删改查。
 * 除 /login 外，全部要求请求头携带管理员 token（role=0）。
 */
@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final AuthService authService;
    private final ItemService itemService;
    private final UserMapper userMapper;

    public AdminController(AuthService authService, ItemService itemService, UserMapper userMapper) {
        this.authService = authService;
        this.itemService = itemService;
        this.userMapper = userMapper;
    }

    /** 后台登录：只有管理员能进 */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        return Result.ok(authService.adminLogin(body.get("username"), body.get("password")));
    }

    /** 条目列表（分页 + 关键字） */
    @GetMapping("/items")
    public Result<Map<String, Object>> items(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size) {
        authService.requireAdmin(authorization);
        return Result.ok(itemService.adminList(keyword, page, size));
    }

    /** 新增条目 */
    @PostMapping("/items")
    public Result<String> create(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody Item item) {
        authService.requireAdmin(authorization);
        itemService.create(item);
        return Result.ok("新增成功");
    }

    /** 修改条目 */
    @PutMapping("/items")
    public Result<String> update(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody Item item) {
        authService.requireAdmin(authorization);
        itemService.update(item);
        return Result.ok("修改成功");
    }

    /** 删除条目（逻辑删除） */
    @DeleteMapping("/items/{id}")
    public Result<String> delete(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @PathVariable Long id) {
        authService.requireAdmin(authorization);
        itemService.delete(id);
        return Result.ok("删除成功");
    }

    /** 后台概览统计 */
    @GetMapping("/stats")
    public Result<Map<String, Object>> stats(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        authService.requireAdmin(authorization);
        Map<String, Object> data = itemService.stats();
        data.put("users", userMapper.selectCount(new LambdaQueryWrapper<User>()));
        return Result.ok(data);
    }

    /** 用户列表（只读，方便核对权限字段） */
    @GetMapping("/users")
    public Result<List<User>> users(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        authService.requireAdmin(authorization);
        List<User> list = userMapper.selectList(
                new LambdaQueryWrapper<User>().orderByAsc(User::getId));
        return Result.ok(list);
    }

    /** 当前管理员信息 */
    @GetMapping("/me")
    public Result<Map<String, Object>> me(
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        User u = authService.requireAdmin(authorization);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("id", u.getId());
        data.put("username", u.getUsername());
        data.put("nickname", u.getNickname());
        data.put("role", u.getRole());
        return Result.ok(data);
    }
}
