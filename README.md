# 校园失物招领系统 (Lost & Found System)

## 技术栈

- **后端**: Spring Boot 2.7.18 + JSP + JDBC
- **架构**: MVC (Model2)
- **数据库**: MySQL 8.0
- **前端**: JSP + JSTL + HTML + CSS
- **构建工具**: Maven

## 项目结构

```
LostFound/
├── pom.xml                          # Maven 配置文件
├── sql/
│   └── init.sql                     # 数据库初始化脚本
├── src/main/java/com/lostfound/
│   ├── LostFoundApplication.java    # Spring Boot 启动类
│   ├── config/
│   │   ├── WebConfig.java           # Web 配置 (拦截器 + 静态资源)
│   │   └── LoginInterceptor.java    # 登录拦截器
│   ├── controller/
│   │   ├── AuthController.java      # 登录/注册/登出
│   │   └── PostController.java      # 帖子 CRUD + 搜索
│   ├── dao/
│   │   ├── UserDao.java             # 用户数据访问
│   │   └── PostDao.java             # 帖子数据访问
│   ├── model/
│   │   ├── User.java                # 用户实体
│   │   └── Post.java                # 帖子实体
│   ├── service/
│   │   ├── UserService.java         # 用户业务逻辑
│   │   └── PostService.java         # 帖子业务逻辑
│   └── util/
│       └── MD5Util.java             # MD5 加密工具
├── src/main/resources/
│   ├── application.properties       # Spring Boot 配置
│   └── static/
│       ├── css/style.css            # 全局样式
│       └── upload/                  # 上传图片目录
└── src/main/webapp/WEB-INF/jsp/
    ├── login.jsp                    # 登录页
    ├── register.jsp                 # 注册页
    ├── index.jsp                    # 首页列表
    ├── publish.jsp                  # 发布信息
    ├── detail.jsp                   # 详情页
    ├── edit.jsp                     # 编辑页
    └── user_center.jsp              # 个人中心
```

## 部署步骤

### 1. 环境准备

| 软件 | 版本要求 |
|------|---------|
| JDK | 8+ |
| MySQL | 5.7+ 或 8.0+ |
| Maven | 3.6+ |

### 2. 初始化数据库

```bash
# 登录 MySQL
mysql -u root -p

# 执行初始化脚本
source sql/init.sql
```

或者直接复制 `sql/init.sql` 内容在 MySQL 客户端中执行。

### 3. 修改数据库配置

编辑 `src/main/resources/application.properties`：

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/lost_found?useSSL=false&characterEncoding=utf8&serverTimezone=Asia/Shanghai
spring.datasource.username=root        # 改为你的MySQL用户名
spring.datasource.password=123456      # 改为你的MySQL密码
```

### 4. 启动项目

```bash
# 进入项目目录
cd LostFound

# Maven 编译并启动
mvn clean package -DskipTests
mvn spring-boot:run

# 或者直接运行
mvn spring-boot:run
```

### 5. 访问系统

打开浏览器访问：**http://localhost:8080**

内置测试账号：
- 用户名: `test`，密码: `123456`
- 用户名: `zhangsan`，密码: `123456`

### 6. 打 War 包部署到外部 Tomcat (可选)

```bash
mvn clean package
# war 包位于 target/LostFound.war
# 将 war 包复制到 Tomcat 的 webapps 目录
```

## 功能模块说明

### 用户模块
- **注册**: 用户名 + 密码 + 确认密码，密码 MD5 加密存储
- **登录**: Session 会话保存登录状态
- **登出**: 清除 Session

### 失物招领信息模块
- **发布**: 标题、描述、类型(lost/found)、图片上传、联系方式
- **首页列表**: 分页展示所有信息
- **搜索**: 按关键词 + 类型筛选
- **详情**: 查看完整信息、图片、联系方式

### 个人中心
- **我的发布**: 查看自己发布的信息列表
- **编辑**: 修改自己发布的信息
- **删除**: 软删除（status=1），不会真正删除数据

### 安全机制
- **登录拦截器**: 未登录用户自动跳转登录页
- **权限控制**: 只能编辑/删除自己的信息
- **密码加密**: MD5 加密存储

## 数据库表说明

| 表名 | 说明 | 主要字段 |
|------|------|---------|
| user | 用户表 | id, username, password(MD5), created_time |
| post | 信息表 | id, title, content, type, image_path, contact, user_id, status, create_time |
| admin | 管理员表 | id, username, password(MD5), created_time |

## 运行截图说明

### 登录页面
- 居中卡片式登录表单
- 紫色渐变背景的标题栏
- 用户名/密码输入框 + 登录按钮
- 底部"还没有账号？立即注册"链接

### 注册页面
- 与登录页风格一致的卡片
- 用户名、密码、确认密码三个输入框
- 表单验证提示

### 首页列表
- 顶部紫色导航栏：系统名、发布信息、个人中心、用户名、退出
- 搜索栏：关键词输入框 + 类型下拉框 + 搜索按钮
- 发布按钮
- 信息卡片列表，每条显示类型标签(失物/寻物)、标题、发布者、时间
- 底部分页导航

### 发布页面
- 类型选择下拉框
- 标题输入框
- 描述文本域
- 联系方式输入框
- 图片上传控件
- 发布按钮

### 详情页面
- 返回列表链接
- 类型标签 + 标题
- 发布者、联系方式、发布时间
- 图片展示
- 描述正文

### 个人中心
- 标题"我的发布"
- 信息列表，每条带编辑/删除按钮
- 删除前二次确认弹窗
- 分页导航
