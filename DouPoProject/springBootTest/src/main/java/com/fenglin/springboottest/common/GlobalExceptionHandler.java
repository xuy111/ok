package com.fenglin.springboottest.common;

import org.mybatis.spring.MyBatisSystemException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.jdbc.CannotGetJdbcConnectionException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.sql.SQLException;

/**
 * 全局异常处理：保证前端拿到的永远是 { code, msg, data } 结构。
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /** 给用户看的话，别把 JDBC 栈信息甩到页面上 */
    private static final String DB_DOWN_MSG = "数据库未连接：请先启动 MySQL（双击项目根目录的 启动.bat 即可）";

    @ExceptionHandler(BizException.class)
    public Result<Void> handleBiz(BizException e) {
        return Result.fail(e.getCode(), e.getMessage());
    }

    /**
     * MyBatis 的包装异常：真正原因藏在 cause 链里，可能是连不上库，也可能是 SQL 写错，
     * 所以要往下一层层找，只有确认是连接问题才给 503 的友好文案。
     */
    @ExceptionHandler(MyBatisSystemException.class)
    public Result<Void> handleMyBatis(MyBatisSystemException e) {
        if (isDbDown(e)) {
            log.error("数据库不可用：{}", e.getMessage());
            return Result.fail(503, DB_DOWN_MSG);
        }
        log.error("数据库访问异常", e);
        return Result.fail(500, "数据库访问异常，请稍后重试");
    }

    /** 数据库连不上（MySQL 没启动 / 3306 掉线）：返回 503 + 明确文案 */
    @ExceptionHandler({CannotGetJdbcConnectionException.class,
            DataAccessResourceFailureException.class,
            SQLException.class})
    public Result<Void> handleDbDown(Exception e) {
        log.error("数据库不可用：{}", e.getMessage());
        return Result.fail(503, DB_DOWN_MSG);
    }

    @ExceptionHandler(Exception.class)
    public Result<Void> handleOther(Exception e) {
        if (isDbDown(e)) {
            log.error("数据库不可用：{}", e.getMessage());
            return Result.fail(503, DB_DOWN_MSG);
        }
        log.error("接口异常", e);
        String msg = e.getMessage() == null ? e.getClass().getSimpleName() : e.getMessage();
        return Result.fail(500, "服务异常：" + msg);
    }

    /** 沿 cause 链判断是否为「数据库连不上」 */
    private boolean isDbDown(Throwable e) {
        for (Throwable t = e; t != null; t = t.getCause()) {
            if (t instanceof CannotGetJdbcConnectionException || t instanceof SQLException) return true;
            String m = t.getMessage();
            if (m == null) continue;
            String low = m.toLowerCase();
            if (low.contains("connection is not available")
                    || low.contains("failed to obtain jdbc connection")
                    || low.contains("could not get jdbc connection")
                    || low.contains("communications link failure")
                    || low.contains("unable to acquire jdbc connection")
                    || low.contains("connection refused")) {
                return true;
            }
        }
        return false;
    }
}
