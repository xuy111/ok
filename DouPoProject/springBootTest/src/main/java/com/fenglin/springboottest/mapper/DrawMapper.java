package com.fenglin.springboottest.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.fenglin.springboottest.entity.Draw;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface DrawMapper extends BaseMapper<Draw> {
}
