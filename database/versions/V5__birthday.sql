START TRANSACTION;

-- set database name here
USE `precure_bot`;

-- -------------- --

-- add birthday tables
CREATE TABLE `birthday`
(
	`id`       int(11) NOT NULL AUTO_INCREMENT,
	`id_guild` varchar(18) COLLATE `utf8mb4_unicode_ci` NOT NULL COMMENT 'Server ID',
	`id_user`  varchar(18) COLLATE `utf8mb4_unicode_ci` NOT NULL,
	`birthday` date NOT NULL COMMENT 'Only month and day is used',
	`label`    text COLLATE `utf8mb4_unicode_ci` DEFAULT NULL,
	`notes`    text COLLATE `utf8mb4_unicode_ci` DEFAULT NULL,
	`enabled`  tinyint(1) NOT NULL DEFAULT 1,
	PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = `utf8mb4`
  COLLATE = `utf8mb4_unicode_ci`;

CREATE TABLE `birthday_guild`
(
	`id_guild`                varchar(18) NOT NULL COMMENT 'Discord Server ID',
	`id_notification_channel` varchar(18) DEFAULT NULL COMMENT 'Channel ID where to send birthday reminders to',
	`notification_hour`       time NOT NULL DEFAULT '09:00:00' COMMENT 'GMT (not UTC) when to send a ping to the notif channel',
	`enabled`                 tinyint(1) NOT NULL DEFAULT 0
) ENGINE = InnoDB
  DEFAULT CHARSET = `utf8mb4`;