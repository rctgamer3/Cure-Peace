START TRANSACTION;

-- set database name here
USE `precure_bot`;

-- -------------- --

-- fix old things
UPDATE `kirakira_recipe` SET `created_at` = '2021-03-20 11:49:51' WHERE `id` = '10';
UPDATE `pinky_data` SET `created_at` = '2021-02-25 14:25:28' WHERE `id_pinky` = 'pi052';

--
ALTER DATABASE `precure_bot` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE `precure_bot`.`card_avatar` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`card_data` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`card_inventory` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`card_leaderboard` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`card_party` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`card_user_data` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`enemy_data` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`guild_data` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`item_data` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`item_data_equip` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`item_inventory` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`kirakira_recipe` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`log_error` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`pinky_data` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`pinky_inventory` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`tradeboard` CONVERT TO CHARSET utf8mb4;
ALTER TABLE `precure_bot`.`user_data` CONVERT TO CHARSET utf8mb4;

ALTER TABLE `precure_bot`.`card_avatar` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`card_data` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`card_inventory` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`card_leaderboard` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`card_party` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`card_user_data` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`enemy_data` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`guild_data` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`item_data` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`item_data_equip` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`item_inventory` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`kirakira_recipe` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`log_error` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`pinky_data` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`pinky_inventory` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`tradeboard` COLLATE 'utf8mb4_unicode_ci';
ALTER TABLE `precure_bot`.`user_data` COLLATE 'utf8mb4_unicode_ci';

ALTER TABLE `card_avatar`
	CHANGE COLUMN `id_user` `id_user` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' FIRST,
	CHANGE COLUMN `id_main` `id_main` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_user`,
	CHANGE COLUMN `item_equip` `item_equip` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_main`,
	CHANGE COLUMN `id_support1` `id_support1` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `item_equip`,
	CHANGE COLUMN `id_support2` `id_support2` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_support1`;

ALTER TABLE `card_data`
	CHANGE COLUMN `id_card` `id_card` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci' FIRST,
	CHANGE COLUMN `color` `color` ENUM('pink','blue','yellow','purple','red','green','white') NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_card`,
	CHANGE COLUMN `series` `series` ENUM('max_heart','splash_star','yes5gogo','fresh','heartcatch','suite','smile','dokidoki','happiness_charge','go_princess','mahou_tsukai','kirakira','hugtto','star_twinkle','healin_good','tropical_rouge') NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `color`,
	CHANGE COLUMN `pack` `pack` ENUM('nagisa','honoka','hikari','saki','mai','nozomi','rin','urara','komachi','karen','mimino','love','miki','inori','setsuna','tsubomi','erika','itsuki','yuri','hibiki','kanade','ellen','ako','miyuki','akane','yayoi','nao','reika','mana','rikka','alice','makoto','aguri','megumi','hime','yuko','iona','haruka','minami','kirara','towa','mirai','riko','kotoha','ichika','himari','aoi','yukari','akira','ciel','hana','saaya','homare','emiru','ruru','hikaru','lala','elena','madoka','yuni','nodoka','chiyu','hinata','kurumi','manatsu','sango','minori','asuka') NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `series`,
	CHANGE COLUMN `name` `name` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `rarity`,
	CHANGE COLUMN `img_url` `img_url` VARCHAR(1024) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `name`,
	CHANGE COLUMN `img_url_upgrade1` `img_url_upgrade1` VARCHAR(1024) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `img_url`,
	CHANGE COLUMN `patch_ver` `patch_ver` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `is_copyable`;

ALTER TABLE `card_inventory`
	CHANGE COLUMN `id_user` `id_user` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id`,
	CHANGE COLUMN `id_card` `id_card` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_user`;

ALTER TABLE `card_leaderboard`
	CHANGE COLUMN `id_guild` `id_guild` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id`,
	CHANGE COLUMN `id_user` `id_user` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_guild`,
	CHANGE COLUMN `category` `category` ENUM('color','pack','color_gold','pack_gold','series','series_gold') NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_user`,
	CHANGE COLUMN `completion` `completion` VARCHAR(512) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `category`;

ALTER TABLE `card_party`
	CHANGE COLUMN `id_guild` `id_guild` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id`,
	CHANGE COLUMN `id_user` `id_user` VARCHAR(30) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_guild`,
	CHANGE COLUMN `name` `name` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_user`,
	CHANGE COLUMN `party_data` `party_data` MEDIUMTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `name`,
	CHANGE COLUMN `spawn_token` `spawn_token` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `special_point`;

ALTER TABLE `card_user_data`
	CHANGE COLUMN `id_user` `id_user` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' FIRST,
	CHANGE COLUMN `daily_last` `daily_last` VARCHAR(2) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_user`,
	CHANGE COLUMN `sale_token` `sale_token` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `daily_last`,
	CHANGE COLUMN `spawn_token` `spawn_token` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `sale_token`,
	CHANGE COLUMN `card_id_selected` `card_id_selected` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `spawn_token`,
	CHANGE COLUMN `card_avatar_form` `card_avatar_form` VARCHAR(255) NULL DEFAULT 'normal' COLLATE 'utf8mb4_unicode_ci' AFTER `card_id_selected`,
	CHANGE COLUMN `card_set_token` `card_set_token` VARCHAR(512) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `card_avatar_form`,
	CHANGE COLUMN `status_effect` `status_effect` VARCHAR(512) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `card_set_token`,
	CHANGE COLUMN `status_effect_2` `status_effect_2` VARCHAR(512) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `status_effect`,
	CHANGE COLUMN `daily_quest` `daily_quest` VARCHAR(1024) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `mofucoin`,
	CHANGE COLUMN `color` `color` ENUM('pink','blue','yellow','purple','red','green','white') NULL DEFAULT 'pink' COLLATE 'utf8mb4_unicode_ci' AFTER `special_point`,
	CHANGE COLUMN `series_set` `series_set` ENUM('sp001','sp002','sp003','sp004','sp005','sp006','sp007','sp008','sp009','sp010','sp011','sp012','sp013','sp014','sp015') NULL DEFAULT 'sp001' COLLATE 'utf8mb4_unicode_ci' AFTER `color_point_white`,
	CHANGE COLUMN `wish_data` `wish_data` VARCHAR(512) NULL DEFAULT '{"wish_point":3,"wish_week":1}' COLLATE 'utf8mb4_unicode_ci' AFTER `battle_points`;

ALTER TABLE `enemy_data`
	CHANGE COLUMN `name` `name` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id`,
	CHANGE COLUMN `series` `series` ENUM('max_heart','splash_star','yes5gogo','fresh','heartcatch','suite','smile','dokidoki','happiness_charge','go_princess','mahou_tsukai','kirakira','hugtto','star_twinkle','healin_good','tropical_rouge') NOT NULL DEFAULT 'max_heart' COLLATE 'utf8mb4_unicode_ci' AFTER `name`,
	CHANGE COLUMN `img` `img` VARCHAR(512) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `series`,
	CHANGE COLUMN `weakness_color` `weakness_color` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `img`,
	CHANGE COLUMN `buff_desc` `buff_desc` VARCHAR(1024) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `weakness_color`,
	CHANGE COLUMN `buff_effect` `buff_effect` MEDIUMTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `buff_desc`;

ALTER TABLE `guild_data`
	CHANGE COLUMN `id_guild` `id_guild` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' FIRST,
	CHANGE COLUMN `id_channel_spawn` `id_channel_spawn` VARCHAR(30) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_guild`,
	CHANGE COLUMN `id_roleping_cardcatcher` `id_roleping_cardcatcher` VARCHAR(30) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_channel_spawn`,
	CHANGE COLUMN `id_last_message_spawn` `id_last_message_spawn` VARCHAR(30) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_roleping_cardcatcher`,
	CHANGE COLUMN `spawn_token` `spawn_token` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `spawn_interval`,
	CHANGE COLUMN `spawn_type` `spawn_type` VARCHAR(100) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `spawn_token`,
	CHANGE COLUMN `spawn_data` `spawn_data` VARCHAR(1024) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `spawn_type`,
	CHANGE COLUMN `sale_shop_data_hariham` `sale_shop_data_hariham` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `completion_date_pinky`;

ALTER TABLE `item_data`
	CHANGE COLUMN `id` `id` VARCHAR(100) NOT NULL COLLATE 'utf8mb4_unicode_ci' FIRST,
	CHANGE COLUMN `name` `name` VARCHAR(512) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id`,
	CHANGE COLUMN `keyword_search` `keyword_search` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `name`,
	CHANGE COLUMN `category` `category` VARCHAR(255) NOT NULL DEFAULT '' COLLATE 'utf8mb4_unicode_ci' AFTER `keyword_search`,
	CHANGE COLUMN `price_data` `price_data` LONGTEXT NOT NULL DEFAULT '{"mofucoin":0}' COLLATE 'utf8mb4_unicode_ci' AFTER `is_tradable`,
	CHANGE COLUMN `img_url` `img_url` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `price_data`,
	CHANGE COLUMN `description` `description` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `img_url`,
	CHANGE COLUMN `effect_data` `effect_data` MEDIUMTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `description`,
	CHANGE COLUMN `extra_data` `extra_data` MEDIUMTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `effect_data`;

ALTER TABLE `item_data_equip`
	CHANGE COLUMN `id` `id` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci' FIRST,
	CHANGE COLUMN `name` `name` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id`,
	CHANGE COLUMN `series` `series` ENUM('max_heart','splash_star','yes5gogo','fresh','heartcatch','suite','smile','dokidoki','happiness_charge','go_princess','mahou_tsukai','kirakira','hugtto','star_twinkle','healin_good','tropical_rouge') NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `name`,
	CHANGE COLUMN `pack` `pack` LONGTEXT NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `series`,
	CHANGE COLUMN `keyword_search` `keyword_search` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `pack`;

ALTER TABLE `item_inventory`
	CHANGE COLUMN `id_user` `id_user` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id`,
	CHANGE COLUMN `id_item` `id_item` VARCHAR(100) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_user`,
	CHANGE COLUMN `additional_effect` `additional_effect` VARCHAR(1024) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `stock`;

ALTER TABLE `kirakira_recipe`
	CHANGE COLUMN `id_item` `id_item` VARCHAR(100) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id`,
	CHANGE COLUMN `id_item_ingredient` `id_item_ingredient` VARCHAR(255) NOT NULL AFTER `difficulty`,
	CHANGE COLUMN `created_at` `created_at` DATETIME NULL DEFAULT current_timestamp() COLLATE 'utf8mb4_unicode_ci' AFTER `id_item_ingredient`;

ALTER TABLE `pinky_data`
	CHANGE COLUMN `id_pinky` `id_pinky` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci' FIRST,
	CHANGE COLUMN `name` `name` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_pinky`,
	CHANGE COLUMN `category` `category` ENUM('mystery','sea','animal','plant','bird') NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `name`,
	CHANGE COLUMN `img_url` `img_url` VARCHAR(1024) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `category`;

ALTER TABLE `pinky_inventory`
	CHANGE COLUMN `id_guild` `id_guild` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id`,
	CHANGE COLUMN `id_user` `id_user` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_guild`,
	CHANGE COLUMN `id_pinky` `id_pinky` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_user`;

ALTER TABLE `tradeboard`
	CHANGE COLUMN `id_guild` `id_guild` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id`,
	CHANGE COLUMN `id_user` `id_user` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_guild`,
	CHANGE COLUMN `category` `category` ENUM('item','card') NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_user`,
	CHANGE COLUMN `data_trade` `data_trade` LONGTEXT NULL DEFAULT '{}' COLLATE 'utf8mb4_unicode_ci' AFTER `category`;

ALTER TABLE `user_data`
	CHANGE COLUMN `id_user` `id_user` VARCHAR(30) NOT NULL COLLATE 'utf8mb4_unicode_ci' FIRST,
	CHANGE COLUMN `server_id_login` `server_id_login` VARCHAR(40) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `id_user`,
	CHANGE COLUMN `daily_data` `daily_data` LONGTEXT NULL DEFAULT '{"lastCheckInDate":"","lastQuestDate":"","quest":{"card":[],"kirakiraDelivery":[],"battle":[]}}' COMMENT 'used for daily' COLLATE 'utf8mb4_unicode_ci' AFTER `server_id_login`,
	CHANGE COLUMN `token_sale` `token_sale` VARCHAR(40) NULL DEFAULT NULL COMMENT 'used for limited shop' COLLATE 'utf8mb4_unicode_ci' AFTER `daily_data`,
	CHANGE COLUMN `token_cardspawn` `token_cardspawn` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci' AFTER `token_sale`,
	CHANGE COLUMN `avatar_main_data` `avatar_main_data` LONGTEXT NULL DEFAULT '{"id_card":null,"form":"normal"}' COLLATE 'utf8mb4_unicode_ci' AFTER `point_peace`,
	CHANGE COLUMN `avatar_support_data` `avatar_support_data` LONGTEXT NULL DEFAULT '{"1":null,"2":null}' COLLATE 'utf8mb4_unicode_ci' AFTER `avatar_main_data`,
	CHANGE COLUMN `status_effect_data` `status_effect_data` LONGTEXT NULL DEFAULT '{}' COLLATE 'utf8mb4_unicode_ci' AFTER `avatar_support_data`,
	CHANGE COLUMN `set_color` `set_color` ENUM('pink','blue','yellow','green','red','purple','white') NULL DEFAULT 'pink' COLLATE 'utf8mb4_unicode_ci' AFTER `status_effect_data`,
	CHANGE COLUMN `set_series` `set_series` ENUM('max_heart','splash_star','yes5gogo','fresh','heartcatch','suite','smile','dokidoki','happiness_charge','go_princess','mahou_tsukai','kirakira','hugtto','star_twinkle','healin_good','tropical_rouge') NULL DEFAULT 'max_heart' COLLATE 'utf8mb4_unicode_ci' AFTER `set_color`,
	CHANGE COLUMN `currency_data` `currency_data` LONGTEXT NULL DEFAULT '{"mofucoin":0,"jewel":0}' COLLATE 'utf8mb4_unicode_ci' AFTER `set_series`,
	CHANGE COLUMN `color_data` `color_data` LONGTEXT NULL DEFAULT '{"pink":{"level":1,"point":0},"blue":{"level":1,"point":0},"yellow":{"level":1,"point":0},"green":{"level":1,"point":0},"red":{"level":1,"point":0},"purple":{"level":1,"point":0},"white":{"level":1,"point":0}}' COLLATE 'utf8mb4_unicode_ci' AFTER `currency_data`,
	CHANGE COLUMN `series_data` `series_data` LONGTEXT NULL DEFAULT '{"max_heart":0,"splash_star":0,"yes5gogo":0,"fresh":0,"heartcatch":0,"suite":0,"smile":0,"dokidoki":0,"happiness_charge":0,"go_princess":0,"mahou_tsukai":0,"kirakira":0,"hugtto":0,"star_twinkle":0,"healin_good":0,"tropical_rouge":0}' COLLATE 'utf8mb4_unicode_ci' AFTER `color_data`,
	CHANGE COLUMN `gardening_data` `gardening_data` LONGTEXT NULL DEFAULT '{"size":"small","plotData":{"a":{"1":null,"2":null,"3":null},"b":{"1":null,"2":null,"3":null},"c":{"1":null,"2":null,"3":null}}}' COLLATE 'utf8mb4_unicode_ci' AFTER `series_data`,
	CHANGE COLUMN `avatar_equip_data` `avatar_equip_data` LONGTEXT NULL DEFAULT '{}' COLLATE 'utf8mb4_unicode_ci' AFTER `gardening_data`;

COMMIT;