package com.fenglin.springboottest.common;

import lombok.Getter;

/**
 * 业务异常：直接把 msg 展示给前端卡片
 */
@Getter
public class BizException extends RuntimeException {

    private final Integer code;

    public BizException(String message) {
        super(message);
        this.code = 400;
    }

    public BizException(Integer code, String message) {
        super(message);
        this.code = code;
    }
}
