<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${post.title} - 校园失物招领</title>
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
    <a href="${pageContext.request.contextPath}/" style="color:#667eea;font-size:14px;">&larr; 返回列表</a>

    <div class="card" style="margin-top:12px;">
        <div class="detail-header">
            <h2>
                <span class="post-type ${post.type == 'lost' ? 'type-lost' : 'type-found'}">
                    ${post.type == 'lost' ? '失物招领' : '寻物启事'}
                </span>
                ${post.title}
            </h2>
        </div>

        <div class="detail-meta">
            <div>发布者：${post.username}</div>
            <div>联系方式：${post.contact}</div>
            <div>发布时间：<fmt:formatDate value="${post.createTime}" pattern="yyyy-MM-dd HH:mm:ss"/></div>
        </div>

        <c:if test="${not empty post.imagePath}">
            <img src="${post.imagePath}" alt="图片" class="detail-image">
        </c:if>

        <div class="detail-content">
            ${post.content}
        </div>
    </div>
</div>

<div class="footer">
    &copy; 2024 校园失物招领系统
</div>

</body>
</html>
