package com.lostfound.service;

import com.lostfound.dao.UserDao;
import com.lostfound.model.User;
import com.lostfound.util.MD5Util;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * 用户业务逻辑层
 */
@Service
public class UserService {

    @Autowired
    private UserDao userDao;

    /**
     * 注册 - 返回 null 表示成功，否则返回错误信息
     */
    public String register(String username, String password, String confirmPassword) {
        if (username == null || username.trim().isEmpty()) return "用户名不能为空";
        if (password == null || password.trim().isEmpty()) return "密码不能为空";
        if (password.length() < 4) return "密码长度不能少于4位";
        if (!password.equals(confirmPassword)) return "两次密码输入不一致";

        User exist = userDao.findByUsername(username);
        if (exist != null) return "用户名已存在";

        User user = new User();
        user.setUsername(username);
        user.setPassword(MD5Util.md5(password));
        userDao.save(user);
        return null;
    }

    /**
     * 登录 - 返回 User 表示成功，null 表示失败
     */
    public User login(String username, String password) {
        User user = userDao.findByUsername(username);
        if (user == null) return null;
        if (MD5Util.md5(password).equals(user.getPassword())) {
            return user;
        }
        return null;
    }
}
