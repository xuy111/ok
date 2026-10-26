package com.fenglin.springboottest.handler;

import com.fenglin.springboottest.common.BizException;
import com.fenglin.springboottest.common.Result;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

/**
 * 统一异常处理：业务异常直接把提示语透给前端卡片
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(BizException.class)
    public Result<?> handleBiz(BizException e) {
        return Result.fail(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<?> handleValid(MethodArgumentNotValidException e) {
        String msg = e.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.joining("；"));
        return Result.fail(msg);
    }

    @ExceptionHandler(Exception.class)
    public Result<?> handleOther(Exception e) {
        log.error("山门异常", e);
        return Result.fail(500, "山门出岔子了 · 请稍后再试");
    }
}
