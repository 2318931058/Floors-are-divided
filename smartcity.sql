 # Host: 127.0.0.1  (Version 8.0.13)
# Date: 2023-03-23 09:31:25
# Generator: MySQL-Front 6.0  (Build 1.57)
#
# Structure for table "building"
#
DROP TABLE
IF
	EXISTS `building`;
CREATE TABLE `building` (
	`id` INT ( 11 ) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR ( 50 ) DEFAULT NULL,
	`floors_num` INT ( 11 ) DEFAULT NULL,
	`polygon` polygon DEFAULT NULL,
	`create_at` datetime DEFAULT NULL,
	`update_at` datetime DEFAULT NULL,
	`delete_at` datetime DEFAULT NULL,
	PRIMARY KEY ( `id` ) 
) ENGINE = INNODB DEFAULT CHARSET = utf8mb4;#
# Structure for table "household"
#
DROP TABLE
IF
	EXISTS `household`;
CREATE TABLE `household` (
	`id` INT ( 11 ) NOT NULL AUTO_INCREMENT,
	`unit_id` INT ( 11 ) DEFAULT NULL,
	`floor_num` INT ( 11 ) DEFAULT NULL COMMENT '楼层数',
	`min_height` FLOAT DEFAULT NULL,
	`max_height` FLOAT DEFAULT NULL,
	`owner_name` VARCHAR ( 50 ) DEFAULT NULL,
	`id_card` VARCHAR ( 50 ) DEFAULT NULL,
	`phone_num` VARCHAR ( 50 ) DEFAULT NULL,
	`owner_sex` SMALLINT ( 6 ) DEFAULT NULL COMMENT '性别 1男  2女',
	`native_place` VARCHAR ( 50 ) CHARACTER 
	SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '籍贯',
	`owner_img` VARCHAR ( 255 ) DEFAULT NULL,
	`house_type` VARCHAR ( 50 ) CHARACTER 
	SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
	`built_area` FLOAT DEFAULT NULL COMMENT '建筑面积',
	`orientation` VARCHAR ( 50 ) DEFAULT NULL COMMENT '房屋朝向',
	`property_type` SMALLINT ( 6 ) DEFAULT NULL COMMENT '物业类型 1居民物业 2商业物业  3工业物业 4其他',
	`house_img` VARCHAR ( 255 ) DEFAULT NULL,
	`house_address` VARCHAR ( 50 ) DEFAULT NULL COMMENT '房间号码',
	PRIMARY KEY ( `id` ) 
) ENGINE = INNODB DEFAULT CHARSET = utf8mb4;#
# Structure for table "scheme"
#
DROP TABLE
IF
	EXISTS `scheme`;
CREATE TABLE `scheme` (
	`id` INT ( 11 ) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR ( 50 ) DEFAULT NULL COMMENT '名称',
	`src` VARCHAR ( 50 ) DEFAULT NULL COMMENT '模型路径',
	`position` VARCHAR ( 255 ) DEFAULT NULL COMMENT '模型坐标(经度,维度,高度)',
	`tileHeight` FLOAT DEFAULT NULL COMMENT '瓦片高度(压平高度)',
	`heading` INT ( 11 ) DEFAULT NULL COMMENT '模型角度',
	`scale` FLOAT DEFAULT NULL COMMENT '模型尺寸',
	`polygon` polygon DEFAULT NULL COMMENT '压平区域',
	`cameraPosition` VARCHAR ( 255 ) DEFAULT NULL COMMENT '相机位置笛卡尔坐(x,y,z)',
	`cameraOrt` VARCHAR ( 255 ) DEFAULT NULL COMMENT '相机视角(head,pitch,roll)',
	`create_at` datetime DEFAULT NULL,
	`delete_at` datetime DEFAULT NULL,
	PRIMARY KEY ( `id` ) 
) ENGINE = INNODB DEFAULT CHARSET = utf8mb4;#
# Structure for table "unit"
#
DROP TABLE
IF
	EXISTS `unit`;
CREATE TABLE `unit` (
	`id` INT ( 11 ) NOT NULL AUTO_INCREMENT,
	`build_id` INT ( 11 ) DEFAULT NULL,
	`number` INT ( 11 ) DEFAULT NULL,
	`polygon` polygon DEFAULT NULL,
PRIMARY KEY ( `id` ) 
) ENGINE = INNODB DEFAULT CHARSET = utf8mb4;