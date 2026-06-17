package com.lostfound.controller;

import com.lostfound.model.Post;
import com.lostfound.model.User;
import com.lostfound.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.util.Map;
import java.util.UUID;

/**
 * 帖子控制器 - 首页列表/发布/详情/编辑/删除/搜索
 */
@Controller
public class PostController {

    @Autowired
    private PostService postService;

    @Value("${file.upload-dir:upload/}")
    private String uploadDir;

    /**
     * 首页 - 分页列表 + 搜索 + 筛选
     */
    @GetMapping("/")
    public String index(@RequestParam(defaultValue = "1") int page,
                        @RequestParam(required = false) String type,
                        @RequestParam(required = false) String keyword,
                        Model model) {
        Map<String, Object> result = postService.findByPage(page, 10, type, keyword);
        model.addAttribute("posts", result.get("list"));
        model.addAttribute("page", result.get("page"));
        model.addAttribute("total", result.get("total"));
        model.addAttribute("totalPages", result.get("totalPages"));
        model.addAttribute("type", type);
        model.addAttribute("keyword", keyword);
        return "index";
    }

    /**
     * 发布页面
     */
    @GetMapping("/publish")
    public String publishPage() {
        return "publish";
    }

    /**
     * 发布提交
     */
    @PostMapping("/publish")
    public String publish(@RequestParam String title,
                          @RequestParam String content,
                          @RequestParam String type,
                          @RequestParam String contact,
                          @RequestParam(required = false) MultipartFile image,
                          HttpSession session,
                          RedirectAttributes redirectAttributes) {
        User user = (User) session.getAttribute("user");

        Post post = new Post();
        post.setTitle(title);
        post.setContent(content);
        post.setType(type);
        post.setContact(contact);
        post.setUserId(user.getId());

        // 处理图片上传
        if (image != null && !image.isEmpty()) {
            String filename = saveImage(image);
            post.setImagePath("/upload/" + filename);
        }

        postService.save(post);
        redirectAttributes.addFlashAttribute("success", "发布成功");
        return "redirect:/";
    }

    /**
     * 详情页
     */
    @GetMapping("/detail/{id}")
    public String detail(@PathVariable Integer id, Model model) {
        Post post = postService.findById(id);
        if (post == null) {
            return "redirect:/";
        }
        model.addAttribute("post", post);
        return "detail";
    }

    /**
     * 编辑页面
     */
    @GetMapping("/edit/{id}")
    public String editPage(@PathVariable Integer id, Model model, HttpSession session) {
        Post post = postService.findById(id);
        User user = (User) session.getAttribute("user");
        if (post == null || !post.getUserId().equals(user.getId())) {
            return "redirect:/";
        }
        model.addAttribute("post", post);
        return "edit";
    }

    /**
     * 编辑提交
     */
    @PostMapping("/edit/{id}")
    public String edit(@PathVariable Integer id,
                       @RequestParam String title,
                       @RequestParam String content,
                       @RequestParam String type,
                       @RequestParam String contact,
                       @RequestParam(required = false) MultipartFile image,
                       HttpSession session,
                       RedirectAttributes redirectAttributes) {
        User user = (User) session.getAttribute("user");
        Post post = postService.findById(id);
        if (post == null || !post.getUserId().equals(user.getId())) {
            return "redirect:/";
        }

        post.setTitle(title);
        post.setContent(content);
        post.setType(type);
        post.setContact(contact);

        if (image != null && !image.isEmpty()) {
            String filename = saveImage(image);
            post.setImagePath("/upload/" + filename);
        }

        postService.update(post);
        redirectAttributes.addFlashAttribute("success", "修改成功");
        return "redirect:/user-center";
    }

    /**
     * 删除(软删除)
     */
    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Integer id, HttpSession session, RedirectAttributes redirectAttributes) {
        User user = (User) session.getAttribute("user");
        int rows = postService.softDelete(id, user.getId());
        if (rows > 0) {
            redirectAttributes.addFlashAttribute("success", "删除成功");
        } else {
            redirectAttributes.addFlashAttribute("error", "删除失败");
        }
        return "redirect:/user-center";
    }

    /**
     * 个人中心
     */
    @GetMapping("/user-center")
    public String userCenter(@RequestParam(defaultValue = "1") int page,
                             HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        Map<String, Object> result = postService.findByUserId(user.getId(), page, 10);
        model.addAttribute("posts", result.get("list"));
        model.addAttribute("page", result.get("page"));
        model.addAttribute("total", result.get("total"));
        model.addAttribute("totalPages", result.get("totalPages"));
        return "user_center";
    }

    /**
     * 保存上传图片
     */
    private String saveImage(MultipartFile file) {
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        String originalName = file.getOriginalFilename();
        String suffix = originalName != null && originalName.contains(".") 
                ? originalName.substring(originalName.lastIndexOf(".")) : ".jpg";
        String filename = UUID.randomUUID().toString() + suffix;
        try {
            file.transferTo(new File(dir, filename));
        } catch (IOException e) {
            e.printStackTrace();
        }
        return filename;
    }
}
