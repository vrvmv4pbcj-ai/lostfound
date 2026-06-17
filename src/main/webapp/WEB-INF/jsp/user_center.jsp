<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人中心 - 校园失物招领</title>
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
    <c:if test="${not empty success}">
        <div class="alert alert-success">${success}</div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-error">${error}</div>
    </c:if>

    <h2 style="color:#667eea;margin-bottom:16px;">我的发布</h2>

    <div class="card">
        <c:if test="${empty posts}">
            <p style="text-align:center;color:#999;padding:40px 0;">您还没有发布任何信息</p>
        </c:if>
        <c:forEach items="${posts}" var="post">
            <div class="post-item">
                <div class="post-info">
                    <a href="${pageContext.request.contextPath}/detail/${post.id}" class="post-title">
                        <span class="post-type ${post.type == 'lost' ? 'type-lost' : 'type-found'}">
                            ${post.type == 'lost' ? '失物' : '寻物'}
                        </span>
                        ${post.title}
                    </a>
                    <div class="post-meta">
                        发布时间：<fmt:formatDate value="${post.createTime}" pattern="yyyy-MM-dd HH:mm"/>
                    </div>
                </div>
                <div style="display:flex;gap:8px;">
                    <a href="${pageContext.request.contextPath}/edit/${post.id}" class="btn btn-primary">编辑</a>
                    <a href="${pageContext.request.contextPath}/delete/${post.id}" class="btn btn-danger" onclick="return confirm('确认删除？')">删除</a>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- 分页 -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">
            <c:if test="${page > 1}">
                <a href="/user-center?page=${page-1}">上一页</a>
            </c:if>
            <c:forEach begin="1" end="${totalPages}" var="p">
                <c:choose>
                    <c:when test="${p == page}">
                        <span class="current">${p}</span>
                    </c:when>
                    <c:otherwise>
                        <a href="/user-center?page=${p}">${p}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
            <c:if test="${page < totalPages}">
                <a href="/user-center?page=${page+1}">下一页</a>
            </c:if>
        </div>
    </c:if>
</div>

<div class="footer">
    &copy; 2024 校园失物招领系统
</div>

</body>
</html>
