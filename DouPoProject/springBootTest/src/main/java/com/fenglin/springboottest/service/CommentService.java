package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fenglin.springboottest.common.BizException;
import com.fenglin.springboottest.entity.Comment;
import com.fenglin.springboottest.entity.User;
import com.fenglin.springboottest.mapper.CommentMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

/** 评论业务：每个条目下方的讨论区 */
@Service
public class CommentService {

    private final CommentMapper commentMapper;

    public CommentService(CommentMapper commentMapper) {
        this.commentMapper = commentMapper;
    }

    public List<Comment> list(Long itemId) {
        return commentMapper.selectList(new LambdaQueryWrapper<Comment>()
                .eq(Comment::getItemId, itemId)
                .orderByDesc(Comment::getId)
                .last("LIMIT 60"));
    }

    public Comment add(User user, Long itemId, String content) {
        if (!StringUtils.hasText(content)) {
            throw new BizException("说点什么再发吧");
        }
        String text = content.trim();
        if (text.length() > 300) {
            throw new BizException("评论最多 300 字");
        }
        Comment c = new Comment();
        c.setItemId(itemId);
        c.setUserId(user.getId());
        c.setNickname(StringUtils.hasText(user.getNickname()) ? user.getNickname() : user.getUsername());
        c.setContent(text);
        c.setCreateTime(LocalDateTime.now());
        c.setDeleted(0);
        commentMapper.insert(c);
        return c;
    }
}
