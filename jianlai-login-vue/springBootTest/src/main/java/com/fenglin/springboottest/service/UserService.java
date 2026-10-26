package com.fenglin.springboottest.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.fenglin.springboottest.entity.User;

public interface UserService extends IService<User> {

    /** 入山：校验道号与剑诀 */
    User login(String uid, String pwd);

    /** 立派：新增弟子 */
    User register(String uid, String pwd, String invite, String sect);

    /** 重铸剑诀 */
    void resetPwd(String uid, String pwd);

    /** 道号是否已被占用 */
    boolean existsUid(String uid);

    /** 山主个人信息 */
    User profile(String uid);
}
