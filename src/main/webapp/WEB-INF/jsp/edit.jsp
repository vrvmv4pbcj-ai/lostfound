<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>编辑信息 - 校园失物招领</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<div class="header">
    <div class="nav">
        <div class="logo"><a href="${pageContext.request.contextPath}/">校园失物招领</a></div>
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/">首页</a>
            <a href="${pageContext.request.contextPath}/publish">发布信息</a>
            <a href="${pageContext.request.contextPath}/user-center">个人中心</a>
            <span style="color:rgba(255,255,255,0.7);font-size:13px;">欢迎，${user.username}</span>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出</a>
        </div>
    </div>
</div>

<div class="container">
    <div class="card">
        <h2 style="color:#667eea;margin-bottom:20px;">编辑信息</h2>

        <form action="${pageContext.request.contextPath}/edit/${post.id}" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label>信息类型</label>
                <select name="type" required>
                    <option value="lost" ${post.type == 'lost' ? 'selected' : ''}>失物招领</option>
                    <option value="found" ${post.type == 'found' ? 'selected' : ''}>寻物启事</option>
                </select>
            </div>
            <div class="form-group">
                <label>标题</label>
                <input type="text" name="title" value="${post.title}" required>
            </div>
            <div class="form-group">
                <label>详细描述</label>
                <textarea name="content" required>${post.content}</textarea>
            </div>
            <div class="form-group">
                <label>联系方式</label>
                <input type="text" name="contact" value="${post.contact}" required>
            </div>
            <div class="form-group">
                <label>上传新图片（可选）</label>
                <input type="file" name="image" accept="image/*">
                <c:if test="${not empty post.imagePath}">
                    <div style="margin-top:8px;">
                        <img src="${post.imagePath}" alt="当前图片" style="max-width:200px;border-radius:6px;">
                    </div>
                </c:if>
            </div>
            <div class="form-group">
                <button type="submit" class="btn-submit">保存修改</button>
            </div>
        </form>
    </div>
</div>

<div class="footer">
    &copy; 2024 校园失物招领系统
</div>

</body>
</html>
