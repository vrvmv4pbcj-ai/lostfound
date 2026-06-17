-- ============================================
-- 校园失物招领系统 - 数据库初始化脚本
-- ============================================

CREATE DATABASE IF NOT EXISTS lost_found DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE lost_found;

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password` VARCHAR(64) NOT NULL,
  `created_time` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 信息表
CREATE TABLE IF NOT EXISTS `post` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(200) NOT NULL,
  `content` TEXT NOT NULL,
  `type` VARCHAR(10) NOT NULL,
  `image_path` VARCHAR(500) DEFAULT '',
  `contact` VARCHAR(100) NOT NULL,
  `user_id` INT NOT NULL,
  `status` TINYINT DEFAULT 0,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 管理员表
CREATE TABLE IF NOT EXISTS `admin` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password` VARCHAR(64) NOT NULL,
  `created_time` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 默认管理员
INSERT INTO `admin` (`username`, `password`) VALUES ('admin', MD5('admin123'));

-- 测试用户
INSERT INTO `user` (`username`, `password`) VALUES ('test', MD5('123456'));
INSERT INTO `user` (`username`, `password`) VALUES ('zhangsan', MD5('123456'));

-- 测试数据
INSERT INTO `post` (`title`, `content`, `type`, `image_path`, `contact`, `user_id`, `status`) VALUES
('校园卡丢失', '本人于今天下午在图书馆二楼丢失一张校园卡，卡号为20240001，如有捡到请联系我，非常感谢！', 'lost', '', 'QQ: 12345678', 1, 0),
('捡到钥匙一串', '在操场跑道旁捡到一串钥匙，上面有蓝色小熊挂件，请失主联系我认领。', 'found', '', '电话: 13800138000', 2, 0),
('华为手机丢失', '周一上午在教学楼A座302教室丢失一部华为手机，黑色外壳，内含重要资料，恳请捡到者联系。', 'lost', '', '微信: lost_phone_2024', 1, 0);
