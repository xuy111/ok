package com.fenglin.springboottest.vo;

import com.fenglin.springboottest.entity.User;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 返回给前端的用户视图对象（不含密码）
 */
@Data
public class UserVO {

    private Long id;
    private String nickname;
    private String snack;
    private LocalDateTime createTime;

    public static UserVO from(User user) {
        if (user == null) {
            return null;
        }
        UserVO vo = new UserVO();
        vo.setId(user.getId());
        vo.setNickname(user.getNickname());
        vo.setSnack(user.getSnack());
        vo.setCreateTime(user.getCreateTime());
        return vo;
    }
}
