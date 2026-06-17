<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lostfound.model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>校园失物招领系统</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="navbar">
    <a href="${pageContext.request.contextPath}/" class="logo">🏫 校园失物招领</a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/">首页</a>
        <a href="${pageContext.request.contextPath}/publish">发布信息</a>
        <a href="${pageContext.request.contextPath}/user-center">个人中心</a>
        <% if (sessionUser != null) { %>
            <span class="username">👤 <%= sessionUser.getUsername() %></span>
            <a href="${pageContext.request.contextPath}/logout">退出</a>
        <% } %>
    </div>
</div>