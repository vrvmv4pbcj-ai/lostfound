<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注册 - 校园失物招领</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<div class="form-card">
    <h2>用户注册</h2>

    <c:if test="${not empty error}">
        <div class="alert alert-error">${error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/register" method="post">
        <div class="form-group">
            <label>用户名</label>
            <input type="text" name="username" placeholder="请输入用户名" required>
        </div>
        <div class="form-group">
            <label>密码</label>
            <input type="password" name="password" placeholder="请输入密码(至少4位)" required>
        </div>
        <div class="form-group">
            <label>确认密码</label>
            <input type="password" name="confirmPassword" placeholder="请再次输入密码" required>
        </div>
        <div class="form-group">
            <button type="submit" class="btn-submit">注 册</button>
        </div>
    </form>

    <div class="form-footer">
        已有账号？<a href="${pageContext.request.contextPath}/login">返回登录</a>
    </div>
</div>

</body>
</html>
