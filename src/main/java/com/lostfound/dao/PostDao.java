package com.lostfound.dao;

import com.lostfound.model.Post;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * 信息数据访问层
 */
@Repository
public class PostDao {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public int save(Post post) {
        String sql = "INSERT INTO post (title, content, type, image_path, contact, user_id) VALUES (?, ?, ?, ?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, post.getTitle());
            ps.setString(2, post.getContent());
            ps.setString(3, post.getType());
            ps.setString(4, post.getImagePath());
            ps.setString(5, post.getContact());
            ps.setInt(6, post.getUserId());
            return ps;
        }, keyHolder);
        return keyHolder.getKey() != null ? keyHolder.getKey().intValue() : 0;
    }

    public int update(Post post) {
        String sql = "UPDATE post SET title=?, content=?, type=?, image_path=?, contact=? WHERE id=? AND user_id=?";
        return jdbcTemplate.update(sql, post.getTitle(), post.getContent(), post.getType(),
                post.getImagePath(), post.getContact(), post.getId(), post.getUserId());
    }

    public int softDelete(Integer id, Integer userId) {
        String sql = "UPDATE post SET status=1 WHERE id=? AND user_id=?";
        return jdbcTemplate.update(sql, id, userId);
    }

    public Post findById(Integer id) {
        String sql = "SELECT p.*, u.username FROM post p LEFT JOIN user u ON p.user_id = u.id WHERE p.id = ? AND p.status = 0";
        List<Post> list = jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(Post.class), id);
        return list.isEmpty() ? null : list.get(0);
    }

    /**
     * 分页查询
     */
    public List<Post> findByPage(int offset, int limit, String type, String keyword) {
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, u.username FROM post p LEFT JOIN user u ON p.user_id = u.id WHERE p.status = 0");
        List<Object> params = new ArrayList<>();

        if (type != null && !type.isEmpty()) {
            sql.append(" AND p.type = ?");
            params.add(type);
        }
        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (p.title LIKE ? OR p.content LIKE ?)");
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }

        sql.append(" ORDER BY p.create_time DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        return jdbcTemplate.query(sql.toString(), new BeanPropertyRowMapper<>(Post.class), params.toArray());
    }

    /**
     * 统计总数
     */
    public int count(String type, String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM post WHERE status = 0");
        List<Object> params = new ArrayList<>();

        if (type != null && !type.isEmpty()) {
            sql.append(" AND type = ?");
            params.add(type);
        }
        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (title LIKE ? OR content LIKE ?)");
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }

        return jdbcTemplate.queryForObject(sql.toString(), Integer.class, params.toArray());
    }

    /**
     * 根据用户ID分页查询
     */
    public List<Post> findByUserId(Integer userId, int offset, int limit) {
        String sql = "SELECT p.*, u.username FROM post p LEFT JOIN user u ON p.user_id = u.id WHERE p.user_id = ? AND p.status = 0 ORDER BY p.create_time DESC LIMIT ? OFFSET ?";
        return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(Post.class), userId, limit, offset);
    }

    /**
     * 统计用户的帖子数
     */
    public int countByUserId(Integer userId) {
        String sql = "SELECT COUNT(*) FROM post WHERE user_id = ? AND status = 0";
        return jdbcTemplate.queryForObject(sql, Integer.class, userId);
    }
}
