package com.lostfound.service;

import com.lostfound.dao.PostDao;
import com.lostfound.model.Post;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 信息业务逻辑层
 */
@Service
public class PostService {

    @Autowired
    private PostDao postDao;

    public int save(Post post) {
        return postDao.save(post);
    }

    public int update(Post post) {
        return postDao.update(post);
    }

    public int softDelete(Integer id, Integer userId) {
        return postDao.softDelete(id, userId);
    }

    public Post findById(Integer id) {
        return postDao.findById(id);
    }

    /**
     * 分页查询结果
     */
    public Map<String, Object> findByPage(int page, int pageSize, String type, String keyword) {
        int offset = (page - 1) * pageSize;
        List<Post> list = postDao.findByPage(offset, pageSize, type, keyword);
        int total = postDao.count(type, keyword);
        int totalPages = (int) Math.ceil((double) total / pageSize);

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("page", page);
        result.put("pageSize", pageSize);
        result.put("total", total);
        result.put("totalPages", totalPages);
        return result;
    }

    public Map<String, Object> findByUserId(Integer userId, int page, int pageSize) {
        int offset = (page - 1) * pageSize;
        List<Post> list = postDao.findByUserId(userId, offset, pageSize);
        int total = postDao.countByUserId(userId);
        int totalPages = (int) Math.ceil((double) total / pageSize);

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("page", page);
        result.put("pageSize", pageSize);
        result.put("total", total);
        result.put("totalPages", totalPages);
        return result;
    }
}
