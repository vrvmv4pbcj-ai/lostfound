<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>校园失物招领系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<div class="header">
    <div class="nav">
        <div class="logo"><a href="${pageContext.request.contextPath}/">校园失物招领</a></div>
        <div class="nav-links">
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

    <!-- 搜索栏 -->
    <form class="search-bar" action="${pageContext.request.contextPath}/" method="get">
        <input type="text" name="keyword" placeholder="搜索标题或描述..." value="${keyword}">
        <select name="type">
            <option value="">全部类型</option>
            <option value="lost" ${type == 'lost' ? 'selected' : ''}>失物招领</option>
            <option value="found" ${type == 'found' ? 'selected' : ''}>寻物启事</option>
        </select>
        <button type="submit" class="btn-search">搜索</button>
    </form>

    <!-- 发布按钮 -->
    <a href="${pageContext.request.contextPath}/publish" class="btn-publish">+ 发布信息</a>

    <!-- 信息列表 -->
    <div class="card">
        <c:if test="${empty posts}">
            <p style="text-align:center;color:#999;padding:40px 0;">暂无相关信息</p>
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
                        发布者：${post.username} | 
                        发布时间：<fmt:formatDate value="${post.createTime}" pattern="yyyy-MM-dd HH:mm"/>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- 分页 -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">
            <c:if test="${page > 1}">
                <a href="/?page=${page-1}&type=${type}&keyword=${keyword}">上一页</a>
            </c:if>
            <c:forEach begin="1" end="${totalPages}" var="p">
                <c:choose>
                    <c:when test="${p == page}">
                        <span class="current">${p}</span>
                    </c:when>
                    <c:otherwise>
                        <a href="/?page=${p}&type=${type}&keyword=${keyword}">${p}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
            <c:if test="${page < totalPages}">
                <a href="/?page=${page+1}&type=${type}&keyword=${keyword}">下一页</a>
            </c:if>
        </div>
    </c:if>
</div>

<div class="footer">
    &copy; 2024 校园失物招领系统 - 课程设计项目
</div>

</body>
</html>
