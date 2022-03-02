START TRANSACTION;

-- set database name here
USE `precure_bot`;

-- -------------- --

-- add `card_battle` table
CREATE TABLE IF NOT EXISTS `card_battle`
(
    `id_user`          varchar(30) NOT NULL,
    `card_id_selected` varchar(30) DEFAULT NULL,
    `status_effect`    varchar(255) DEFAULT NULL,
    `hp`               int(11) DEFAULT 0,
    `atk`              int(11) DEFAULT 0,
    `sk_point`         int(11) DEFAULT 0,
    `item_equip`       varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id_user`)
) ENGINE = InnoDB
  DEFAULT CHARSET = `latin1`;

-- migrate series enums

-- extend enum with new
ALTER TABLE `card_data`
    MODIFY COLUMN `series`
	enum ('max heart','splash star','yes! precure 5 gogo!','fresh','heartcatch','suite','smile',
    'doki doki!','happiness','go! princess','mahou tsukai','kirakira','hugtto','star twinkle','healin'' good',
    'max_heart','splash_star','yes5gogo','dokidoki', 'happiness_charge', 'go_princess', 'mahou_tsukai','star_twinkle',
        'healin_good','tropical_rouge') NOT NULL;

-- replace series with shorter version
UPDATE `card_data` SET `series` = 'max_heart' WHERE `series` = 'max heart';
UPDATE `card_data` SET `series` = 'splash_star' WHERE `series` = 'splash star';
UPDATE `card_data` SET `series` = 'yes5gogo' WHERE `series` = 'yes! precure 5 gogo!';
UPDATE `card_data` SET `series` = 'dokidoki' WHERE `series` = 'doki doki!';
UPDATE `card_data` SET `series` = 'happiness_charge' WHERE `series` = 'happiness';
UPDATE `card_data` SET `series` = 'go_princess' WHERE `series` = 'go! princess';
UPDATE `card_data` SET `series` = 'mahou_tsukai' WHERE `series` = 'mahou tsukai';
UPDATE `card_data` SET `series` = 'star_twinkle' WHERE `series` = 'star twinkle';
-- fix healin' good
UPDATE `card_data` SET `series` = 'healin_good' WHERE `series` = 'healin'' good';

-- drop the old ones
ALTER TABLE `card_data`
	MODIFY COLUMN `series` enum ('max_heart','splash_star','yes5gogo','fresh','heartcatch', 'suite', 'smile',
		'dokidoki', 'happiness_charge', 'go_princess', 'mahou_tsukai', 'kirakira','hugtto','star_twinkle',
		'healin_good','tropical_rouge') NOT NULL;

ALTER TABLE `card_data`
    MODIFY COLUMN `pack` enum ('nagisa','honoka','hikari','saki','mai','nozomi','rin','urara','komachi','karen',
        'mimino','love','miki', 'inori','setsuna','tsubomi','erika','itsuki','yuri','hibiki','kanade','ellen','ako','miyuki','akane', 'yayoi','nao','reika','mana','rikka','alice','makoto','aguri','megumi','hime','yuko','iona','haruka', 'minami','kirara','towa','mirai','riko','kotoha','ichika','himari','aoi','yukari','akira','ciel', 'hana','saaya','homare','emiru','ruru','hikaru','lala','elena','madoka','yuni','nodoka','chiyu', 'hinata','kurumi','manatsu','sango','minori','asuka') NOT NULL;
ALTER TABLE `card_data`
    RENAME COLUMN `max_hp` TO `hp_base`;
ALTER TABLE `card_data`
    DROP COLUMN `skill1`,
    DROP COLUMN `skill2`,
    DROP COLUMN `special`,
    ADD COLUMN `atk_base`     int(11) NOT NULL AFTER `hp_base`,
    ADD COLUMN `is_spawnable` tinyint(1) DEFAULT 0 AFTER `atk_base`,
    ADD COLUMN `is_copyable`  tinyint(1) DEFAULT 0 AFTER `is_spawnable`,
    ADD COLUMN `patch_ver`    varchar(255) DEFAULT NULL AFTER `is_copyable`;

-- drop `card_guild`
DROP TABLE `card_guild`;
-- drop `card_enemies`
DROP TABLE `card_enemies`;

-- drop `is_metal`
ALTER TABLE `card_inventory`
    DROP COLUMN `is_metal`;

-- drop `card_tradeboard`
RENAME TABLE `card_tradeboard` TO `tradeboard`;

ALTER TABLE `tradeboard`
    DROP COLUMN `id_card_want`,
    DROP COLUMN `id_card_have`,
    ADD COLUMN
        `category`   enum ('item','card') DEFAULT NULL AFTER `id_user`,
    -- How can this be a def null if it's an enum?
    ADD COLUMN
        `data_trade` longtext DEFAULT '{}' AFTER `category`;

-- rename `hp` to `battle_points`, move after `sp015`
ALTER TABLE `card_user_data`
    RENAME COLUMN `hp` TO `battle_points`;
ALTER TABLE `card_user_data`
    MODIFY COLUMN `battle_points` int(11) DEFAULT 0 AFTER `sp015`;

-- add `enemy_data`
CREATE TABLE IF NOT EXISTS `enemy_data`
(
    `id`             int(11) NOT NULL AUTO_INCREMENT,
    `name`           varchar(255) NOT NULL,
    `series`         enum ('max_heart','splash_star','yes5gogo','fresh','heartcatch','suite', 'smile','dokidoki','happiness_charge','go_princess','mahou_tsukai','kirakira','hugtto', 'star_twinkle','healin_good','tropical_rouge') NOT NULL DEFAULT 'max_heart',
    `img`            varchar(512) NOT NULL,
    `weakness_color` varchar(255) NOT NULL,
    `buff_desc`      varchar(1024) DEFAULT NULL,
    `buff_effect`    text DEFAULT NULL,
    `created_at`     datetime DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = `latin1`;

-- add `guild_data`
CREATE TABLE IF NOT EXISTS `guild_data`
(
    `id_guild`                varchar(30) NOT NULL,
    `id_channel_spawn`        varchar(30) DEFAULT NULL,
    `id_roleping_cardcatcher` varchar(30) DEFAULT NULL,
    `id_last_message_spawn`   varchar(30) DEFAULT NULL,
    `spawn_interval`          int(11) DEFAULT 40,
    `spawn_token`             varchar(255) DEFAULT NULL,
    `spawn_type`              varchar(100) DEFAULT NULL,
    `spawn_data`              varchar(1024) DEFAULT NULL,
    `completion_date_pinky`   datetime DEFAULT NULL,
    `sale_shop_data_hariham`  longtext DEFAULT NULL,
    PRIMARY KEY (`id_guild`)
) ENGINE = InnoDB
  DEFAULT CHARSET = `latin1`;

ALTER TABLE `item_data`
    ADD COLUMN `keyword_search` longtext DEFAULT NULL AFTER `name`,
    MODIFY COLUMN `category` varchar(255) NOT NULL DEFAULT '',
    RENAME COLUMN `is_purchasable_shop` TO `is_purchasable`,
    RENAME COLUMN `price_mofucoin` TO `price_data`;
ALTER TABLE `item_data`
    MODIFY COLUMN `price_data` longtext NOT NULL DEFAULT '{"mofucoin":0}',
    MODIFY COLUMN `img_url` longtext DEFAULT NULL,
    MODIFY COLUMN `description` longtext DEFAULT NULL,
    DROP COLUMN `drop_rate`;

CREATE TABLE IF NOT EXISTS `item_data_equip`
(
    `id`             varchar(255) NOT NULL,
    `name`           varchar(255) NOT NULL,
    `series`         enum ('max_heart','splash_star','yes5gogo','fresh','heartcatch','suite','smile','dokidoki',
        'happiness_charge','go_princess','mahou_tsukai','kirakira','hugtto','star_twinkle','healin_good','tropical_rouge') NOT NULL,
    `pack`           longtext NOT NULL,
    `keyword_search` longtext DEFAULT NULL,
    `effect_data`    int(11) DEFAULT NULL,
    `created_at`     datetime DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = `latin1`;

ALTER TABLE `user_data`
    DROP COLUMN `gardening_level`,
    RENAME COLUMN `gardening_plot_data` TO `gardening_data`;
ALTER TABLE `user_data`
    MODIFY COLUMN `gardening_data` longtext DEFAULT '{"size":"small","plotData":{"a":{"1":null,"2":null,"3":null},"b":{"1":null,"2":null,"3":null},"c":{"1":null,"2":null,"3":null}}}',
    DROP COLUMN `gardening_activity_data`;

ALTER TABLE `user_data`
    ADD COLUMN `server_id_login`     varchar(40) DEFAULT NULL AFTER `id_user`,
    ADD COLUMN `daily_data`          longtext DEFAULT '{"lastCheckInDate":"","lastQuestDate":"","quest":{"card":[],"kirakiraDelivery":[],"battle":[]}}' COMMENT 'used for daily' AFTER `server_id_login`,
    ADD COLUMN `token_sale`          varchar(40) DEFAULT NULL COMMENT 'used for limited shop' AFTER `daily_data`,
    ADD COLUMN `token_cardspawn`     longtext DEFAULT NULL AFTER `token_sale`,
    ADD COLUMN `point_peace`         int(5) DEFAULT 0 AFTER `token_cardspawn`,
    ADD COLUMN `avatar_main_data`    longtext DEFAULT '{"id_card":null,"form":"normal"}' AFTER `point_peace`,
    ADD COLUMN `avatar_support_data` longtext DEFAULT '{"1":null,"2":null}' AFTER `avatar_main_data`,
    ADD COLUMN `status_effect_data`  longtext DEFAULT '{}' AFTER `avatar_support_data`,
    ADD COLUMN `battle_item_data`    longtext DEFAULT '{}' AFTER `status_effect_data`,
    ADD COLUMN `equip_data`          longtext DEFAULT '{}' AFTER `battle_item_data`,
    ADD COLUMN `set_color`           enum ('pink','blue','yellow','green','red', 'purple','white') DEFAULT 'pink' AFTER `equip_data`,
    ADD COLUMN `set_series`          enum ('max_heart','splash_star','yes5gogo', 'fresh', 'heartcatch','suite', 'smile','dokidoki','happiness_charge', 'go_princess','mahou_tsukai', 'kirakira', 'hugtto','star_twinkle', 'healin_good','tropical_rouge') DEFAULT 'max_heart' AFTER `set_color`,
    ADD COLUMN `currency_data`       longtext CHARACTER SET `utf8mb4` COLLATE `utf8mb4_bin` DEFAULT '{"mofucoin":0,"jewel":0}' AFTER `set_series`,
    ADD COLUMN`color_data`           longtext CHARACTER SET `utf8mb4` COLLATE `utf8mb4_bin` DEFAULT '{"pink":{"level":1,"point":0},"blue":{"level":1,"point":0},"yellow":{"level":1,"point":0},"green":{"level":1,"point":0},"red":{"level":1,"point":0},"purple":{"level":1,"point":0},"white":{"level":1,"point":0}}' AFTER `currency_data`,
    ADD COLUMN `series_data`         longtext CHARACTER SET `utf8mb4` COLLATE `utf8mb4_bin` DEFAULT '{"max_heart":0,"splash_star":0,"yes5gogo":0,"fresh":0,"heartcatch":0,"suite":0,"smile":0,"dokidoki":0,"happiness_charge":0,"go_princess":0,"mahou_tsukai":0,"kirakira":0,"hugtto":0,"star_twinkle":0,"healin_good":0,"tropical_rouge":0}' AFTER `color_data`;

-- add `card_avatar`
CREATE TABLE `card_avatar`
(
	`id_user`     varchar(30) NOT NULL,
	`id_main`     varchar(255) DEFAULT NULL,
	`item_equip`  varchar(255) DEFAULT NULL,
	`id_support1` varchar(255) DEFAULT NULL,
	`id_support2` varchar(255) DEFAULT NULL,
	PRIMARY KEY (`id_user`)
) ENGINE = InnoDB
  DEFAULT CHARSET = `latin1`;

-- drop `card_battle`
DROP TABLE `card_battle`;

-- change `card_data` & `user_data`
ALTER TABLE `card_data` DROP `ability1`;
ALTER TABLE `card_data` DROP `ability2`;
ALTER TABLE `card_data` DROP `max_atk`;
ALTER TABLE `user_data` ADD `avatar_equip_data` longtext DEFAULT '{}';
ALTER TABLE `user_data` DROP `battle_item_data`;
ALTER TABLE `user_data` DROP `equip_data`;

-- change data
DELETE FROM `item_data` WHERE `id` = 'ca001';
DELETE FROM `item_data` WHERE `id` = 'ca002';
DELETE FROM `item_data` WHERE `id` = 'ca003';
DELETE FROM `item_data` WHERE `id` = 'ca004';
DELETE FROM `item_data` WHERE `id` = 'ca005';
DELETE FROM `item_data` WHERE `id` = 'ca006';
DELETE FROM `item_data` WHERE `id` = 'ca007';
DELETE FROM `item_data` WHERE `id` = 'ca008';
DELETE FROM `item_data` WHERE `id` = 'ca009';
DELETE FROM `item_data` WHERE `id` = 'ca010';
DELETE FROM `item_data` WHERE `id` = 'ca011';
DELETE FROM `item_data` WHERE `id` = 'ca012';
DELETE FROM `item_data` WHERE `id` = 'ca013';
DELETE FROM `item_data` WHERE `id` = 'ca014';
DELETE FROM `item_data` WHERE `id` = 'ca015';
DELETE FROM `item_data` WHERE `id` = 'ca016';
DELETE FROM `item_data` WHERE `id` = 'ca017';
DELETE FROM `item_data` WHERE `id` = 'ca018';
DELETE FROM `item_data` WHERE `id` = 'ca019';
DELETE FROM `item_data` WHERE `id` = 'ca020';
DELETE FROM `item_data` WHERE `id` = 'ca021';
DELETE FROM `item_data` WHERE `id` = 'ca022';
DELETE FROM `item_data` WHERE `id` = 'ca023';
DELETE FROM `item_data` WHERE `id` = 'ca024';
DELETE FROM `item_data` WHERE `id` = 'ca025';
DELETE FROM `item_data` WHERE `id` = 'ca026';
DELETE FROM `item_data` WHERE `id` = 'ca027';
DELETE FROM `item_data` WHERE `id` = 'ca028';
DELETE FROM `item_data` WHERE `id` = 'ca029';
DELETE FROM `item_data` WHERE `id` = 'ca030';
DELETE FROM `item_data` WHERE `id` = 'ca031';
DELETE FROM `item_data` WHERE `id` = 'ca032';
DELETE FROM `item_data` WHERE `id` = 'ca033';
DELETE FROM `item_data` WHERE `id` = 'ca034';
DELETE FROM `item_data` WHERE `id` = 'ca035';
DELETE FROM `item_data` WHERE `id` = 'fo007';
DELETE FROM `item_data` WHERE `id` = 'fo008';
DELETE FROM `kirakira_recipe` WHERE `id` = '8';
DELETE FROM `kirakira_recipe` WHERE `id` = '9';

-- insert new things
INSERT INTO `card_data` VALUES('agma601','red','dokidoki','aguri','6','Cure Ace','https://cdn.discordapp.com/attachments/793388428150046740/793388574661673000/Puzzlun_0_Aguri_001.jpg','https://cdn.discordapp.com/attachments/793388428150046740/827403056496115732/image0.jpg','30','10','0','1',NULL,'2020-12-30 14:16:05');
INSERT INTO `card_data` VALUES('akhi601','red','smile','akane','6','Cure Sunny','https://cdn.discordapp.com/attachments/793386538045276171/793386681205915688/Puzzlun_0_Akane_001.jpg','https://cdn.discordapp.com/attachments/793386538045276171/827305291170971670/image0.jpg','30','10','0','1',NULL,'2020-12-30 11:33:23');
INSERT INTO `card_data` VALUES('akke601','red','kirakira','akira','6','Cure Chocolat','https://cdn.discordapp.com/attachments/793393018614841355/793393252287119410/Puzzlun_0_Akira_001.jpg','https://cdn.discordapp.com/attachments/793393018614841355/827797687117152286/image0.jpg','30','10','0','1',NULL,'2020-12-30 19:51:33');
INSERT INTO `card_data` VALUES('aksh601','yellow','suite','ako','6','Cure Muse','https://cdn.discordapp.com/attachments/793384267753193482/793384726822912050/Puzzlun_0_Ako_001.jpg','https://cdn.discordapp.com/attachments/793384267753193482/827098848296042496/image0.jpg','30','10','0','1',NULL,'2020-12-30 10:46:49');
INSERT INTO `card_data` VALUES('alyo601','yellow','dokidoki','alice','6','Cure Rosetta','https://cdn.discordapp.com/attachments/793388055583129601/793388187954839572/Puzzlun_0_Alice_001.jpg','https://cdn.discordapp.com/attachments/793388055583129601/827393515839422474/image0.jpg','30','10','0','1',NULL,'2020-12-30 13:54:57');
INSERT INTO `card_data` VALUES('amru601','purple','hugtto','ruru','6','Cure Amour','https://cdn.discordapp.com/attachments/793395175695187980/793395506948603914/Puzzlun_0_Ruru_001.jpg','https://cdn.discordapp.com/attachments/793395175695187980/827821584890855464/image0.jpg','30','10','0','1',NULL,'2020-12-30 21:27:55');
INSERT INTO `card_data` VALUES('aota601','blue','kirakira','aoi','6','Cure Gelato','https://cdn.discordapp.com/attachments/793392456019345418/793392764829171722/Puzzlun_0_Aoi_001.jpg','https://cdn.discordapp.com/attachments/793392456019345418/827766509622788166/image0.jpg','30','10','0','1',NULL,'2020-12-30 19:31:07');
INSERT INTO `card_data` VALUES('asta101','red','tropical_rouge','asuka','1','Asuka Takizawa','https://cdn.discordapp.com/attachments/832841288172175390/832844697239945226/asta101.jpg','https://cdn.discordapp.com/attachments/832841288172175390/832844697239945226/asta101.jpg','10','5','1','1','1','2021-12-24 15:26:37');
INSERT INTO `card_data` VALUES('asta201','red','tropical_rouge','asuka','2','Asuka Takizawa & Cure Flamingo','https://cdn.discordapp.com/attachments/832841288172175390/832918224106029086/asta201.jpg','https://cdn.discordapp.com/attachments/832841288172175390/832918224106029086/asta201.jpg','10','5','1','1','1','2021-12-24 15:27:17');
INSERT INTO `card_data` VALUES('asta601','red','tropical_rouge','asuka','6','Cure Flamingo','https://cdn.discordapp.com/attachments/832841288172175390/832844711357841459/asta601.jpg','https://cdn.discordapp.com/attachments/832841288172175390/832844711357841459/asta601.jpg','30','10','0','1',NULL,'2022-01-25 15:43:30');
INSERT INTO `card_data` VALUES('chsa601','blue','healin_good','chiyu','6','Cure Fontaine','https://cdn.discordapp.com/attachments/793396832717111347/793396910639022080/Puzzlun_0_Chiyu_001.jpg','https://cdn.discordapp.com/attachments/793396832717111347/827999267204890686/image0.jpg','30','10','0','1',NULL,'2020-12-30 22:24:40');
INSERT INTO `card_data` VALUES('ciki601','green','kirakira','ciel','6','Cure Parfait','https://cdn.discordapp.com/attachments/793393296957243403/793393485713375272/Puzzlun_0_Ciel_001.jpg','https://cdn.discordapp.com/attachments/793393296957243403/827807118055833600/image0.jpg','30','10','0','1',NULL,'2020-12-30 20:23:57');
INSERT INTO `card_data` VALUES('elam601','yellow','star_twinkle','elena','6','Cure Soleil','https://cdn.discordapp.com/attachments/793396010227204117/793396158436212736/Puzzlun_0_Elena_001.jpg','https://cdn.discordapp.com/attachments/793396010227204117/827962989293338644/image0.jpg','30','10','0','1',NULL,'2020-12-30 22:01:15');
INSERT INTO `card_data` VALUES('elku601','blue','suite','ellen','6','Cure Beat','https://cdn.discordapp.com/attachments/793384071107575838/793384253424533534/Puzzlun_0_Ellen_001.jpg','https://cdn.discordapp.com/attachments/793384071107575838/827096184878399528/image0.jpg','30','10','0','1',NULL,'2020-12-30 10:38:58');
INSERT INTO `card_data` VALUES('emai601','red','hugtto','emiru','6','Cure Macherie','https://cdn.discordapp.com/attachments/793394965690318898/793395157738717194/Puzzlun_0_Emiru_001.jpg','https://cdn.discordapp.com/attachments/793394965690318898/827819213430718494/image0.jpg','30','10','0','1',NULL,'2020-12-30 21:16:21');
INSERT INTO `card_data` VALUES('erku601','blue','heartcatch','erika','6','Cure Marine','https://cdn.discordapp.com/attachments/793382673749377075/793382976275611658/Puzzlun_0_Erika_001.jpg','https://cdn.discordapp.com/attachments/793382673749377075/827074422711517204/image0.jpg','30','10','0','1',NULL,'2020-12-30 09:39:09');
INSERT INTO `card_data` VALUES('haha601','pink','go_princess','haruka','6','Cure Flora','https://cdn.discordapp.com/attachments/793389561606045737/793389743076409364/Puzzlun_0_Haruka_001.jpg','https://cdn.discordapp.com/attachments/793389561606045737/827642222539178024/image0.jpg','30','10','0','1',NULL,'2020-12-30 16:57:40');
INSERT INTO `card_data` VALUES('hano601','pink','hugtto','hana','6','Cure Yell','https://cdn.discordapp.com/attachments/793393652348354600/793394476550586368/Puzzlun_0_Hana_001.jpg','https://cdn.discordapp.com/attachments/793393652348354600/827811295113117726/image0.jpg','30','10','0','1',NULL,'2020-12-30 20:35:53');
INSERT INTO `card_data` VALUES('hiar601','yellow','kirakira','himari','6','Cure Custard','https://cdn.discordapp.com/attachments/793392228168237086/793392508062793748/Puzzlun_0_Himari_000.jpg','https://cdn.discordapp.com/attachments/793392228168237086/827753759563841586/image0.jpg','30','10','0','1',NULL,'2020-12-30 19:21:48');
INSERT INTO `card_data` VALUES('hihi601','yellow','healin_good','hinata','6','Cure Sparkle','https://cdn.discordapp.com/attachments/793396923054686219/793397010216648714/Puzzlun_0_Hinata_001.jpg','https://cdn.discordapp.com/attachments/793396923054686219/827999446109126736/image0.jpg','30','10','0','1',NULL,'2020-12-30 22:28:06');
INSERT INTO `card_data` VALUES('hiho601','pink','suite','hibiki','6','Cure Melody','https://cdn.discordapp.com/attachments/793383641119850556/793383829145911296/Puzzlun_0_Hibiki_001.jpg','https://cdn.discordapp.com/attachments/793383641119850556/827089425120755712/image0.jpg','30','10','0','1',NULL,'2020-12-30 10:14:52');
INSERT INTO `card_data` VALUES('hiku302','yellow','max_heart','hikari','3','Hikari Kujo: Bear Pochette','https://cdn.discordapp.com/attachments/793378136871010364/793378267117387789/Puzzlun_3_Hikari_002.jpg','https://cdn.discordapp.com/attachments/793378136871010364/826990968708136970/image0.jpg','20','10','1','1','2','2020-12-29 18:45:13');
INSERT INTO `card_data` VALUES('hiku303','yellow','max_heart','hikari','3','Hikari Kujo: Kiwi Corde','https://cdn.discordapp.com/attachments/793378136871010364/793378286428356648/Puzzlun_3_Hikari_003.jpg','https://cdn.discordapp.com/attachments/793378136871010364/826990985707126794/image0.jpg','20','10','1','1','2','2020-12-29 18:46:31');
INSERT INTO `card_data` VALUES('hiku402','yellow','max_heart','hikari','4','Hikari Kujo: Banana Dress','https://cdn.discordapp.com/attachments/793378136871010364/793378345717858334/Puzzlun_4_Hikari_002.jpg','https://cdn.discordapp.com/attachments/793378136871010364/826991073506492446/image0.jpg','20','10','1','1','2','2020-12-29 18:50:22');
INSERT INTO `card_data` VALUES('hiku403','yellow','max_heart','hikari','4','Hikari Kujo: With gratitude','https://cdn.discordapp.com/attachments/793378136871010364/793378365217832960/Puzzlun_4_Hikari_003.jpg','https://cdn.discordapp.com/attachments/793378136871010364/826991092921532424/image0.jpg','20','10','1','1','2','2020-12-29 18:51:02');
INSERT INTO `card_data` VALUES('hise601','pink','star_twinkle','hikaru','6','Cure Star','https://cdn.discordapp.com/attachments/793395639512989727/793395839015190528/Puzzlun_0_Hikaru_001.jpg','https://cdn.discordapp.com/attachments/793395639512989727/827958373915295795/image0.jpg','30','10','0','1',NULL,'2020-12-30 21:43:11');
INSERT INTO `card_data` VALUES('hish601','blue','happiness_charge','hime','6','Cure Princess','https://cdn.discordapp.com/attachments/793388907429232650/793389061791547412/Puzzlun_0_Hime_001.jpg','https://cdn.discordapp.com/attachments/793388907429232650/827409126140149760/image0.jpg','30','10','0','1',NULL,'2020-12-30 14:58:33');
INSERT INTO `card_data` VALUES('hoka601','yellow','hugtto','homare','6','Cure Etoile','https://cdn.discordapp.com/attachments/793394718305419265/793394928402432000/Puzzlun_0_Homare_001.jpg','https://cdn.discordapp.com/attachments/793394718305419265/827816697872384020/image0.jpg','30','10','0','1',NULL,'2020-12-30 21:07:06');
INSERT INTO `card_data` VALUES('hoyu102','white','max_heart','honoka','1','Honoka Yukishiro: School Uniform','https://cdn.discordapp.com/attachments/793377043646775297/793377265433051146/Puzzlun_1_Honoka_002.jpg','https://cdn.discordapp.com/attachments/793377043646775297/826983295828754493/image0.jpg','10','5','1','1','2','2020-12-29 18:14:05');
INSERT INTO `card_data` VALUES('hoyu302','white','max_heart','honoka','3','Honoka Yukishiro: Dot Dress','https://cdn.discordapp.com/attachments/793377043646775297/793377312547536896/Puzzlun_3_Honoka_002.jpg','https://cdn.discordapp.com/attachments/793377043646775297/826983624431501312/image0.jpg','20','10','1','1','2','2020-12-29 18:17:31');
INSERT INTO `card_data` VALUES('hoyu303','white','max_heart','honoka','3','Honoka Yukishiro: Grapefruit Coordination','https://cdn.discordapp.com/attachments/793377043646775297/793377338062274579/Puzzlun_3_Honoka_003.jpg','https://cdn.discordapp.com/attachments/793377043646775297/826983653039931433/image0.jpg','20','10','1','1','2','2020-12-29 18:18:27');
INSERT INTO `card_data` VALUES('hoyu402','white','max_heart','honoka','4','Honoka Yukishiro: Grape Dress','https://cdn.discordapp.com/attachments/793377043646775297/793377457742807050/Puzzlun_4_Honoka_002.jpg','https://cdn.discordapp.com/attachments/793377043646775297/826983888915267584/image0.jpg','20','10','1','1','2','2020-12-29 18:29:39');
INSERT INTO `card_data` VALUES('hoyu403','white','max_heart','honoka','4','Honoka Yukishiro: Pouring Chocolate','https://cdn.discordapp.com/attachments/793377043646775297/793377478650363904/Puzzlun_4_Honoka_003.jpg','https://cdn.discordapp.com/attachments/793377043646775297/826983918019936286/image0.jpg','20','10','1','1','2','2020-12-29 18:30:26');
INSERT INTO `card_data` VALUES('hoyu502','white','max_heart','honoka','5','Honoka Yukishiro: New Year\'s Joy','https://cdn.discordapp.com/attachments/793377043646775297/793377540701290506/Puzzlun_5_Honoka_002.jpg','https://cdn.discordapp.com/attachments/793377043646775297/826984046558838804/image0.jpg','30','10','1','1','2','2020-12-29 18:35:38');
INSERT INTO `card_data` VALUES('icus601','pink','kirakira','ichika','6','Cure Whip','https://cdn.discordapp.com/attachments/793391968322322462/793392184744345601/Puzzlun_0_Ichika_001.jpg','https://cdn.discordapp.com/attachments/793391968322322462/827748528897130506/image0.jpg','30','10','0','1',NULL,'2020-12-30 19:07:45');
INSERT INTO `card_data` VALUES('inya601','yellow','fresh','inori','6','Cure Pine','https://cdn.discordapp.com/attachments/793381839938519040/793382002597560330/Puzzlun_0_Inori_001.jpg','https://cdn.discordapp.com/attachments/793381839938519040/827054681326223390/image0.jpg','30','10','0','1',NULL,'2020-12-30 02:51:25');
INSERT INTO `card_data` VALUES('iohi601','purple','happiness_charge','iona','6','Cure Fortune','https://cdn.discordapp.com/attachments/793389261570965504/793389421726531594/Puzzlun_0_Iona_001.jpg','https://cdn.discordapp.com/attachments/793389261570965504/827421698743468041/image0.jpg','30','10','0','1',NULL,'2020-12-30 16:41:53');
INSERT INTO `card_data` VALUES('itmy601','yellow','heartcatch','itsuki','6','Cure Sunshine','https://cdn.discordapp.com/attachments/793383020336906259/793383220950728744/Puzzlun_0_Itsuki_001.jpg','https://cdn.discordapp.com/attachments/793383020336906259/827080276508803102/image0.jpg','30','10','0','1',NULL,'2020-12-30 09:48:10');
INSERT INTO `card_data` VALUES('kami601','white','suite','kanade','6','Cure Rhythm','https://cdn.discordapp.com/attachments/793383859348701195/793384054560653382/Puzzlun_0_Kanade_001.jpg','https://cdn.discordapp.com/attachments/793383859348701195/827093113176064000/image0.jpg','30','10','0','1',NULL,'2020-12-30 10:24:45');
INSERT INTO `card_data` VALUES('kamin302','blue','yes5gogo','karen','3','Karen Minazuki: Intellectual Tennis Showdown','https://cdn.discordapp.com/attachments/793380588223856651/793380673686994994/Puzzlun_3_Karen_002.jpg','https://cdn.discordapp.com/attachments/793380588223856651/827034744088821770/image0.jpg','20','10','1','1','2','2020-12-30 01:36:19');
INSERT INTO `card_data` VALUES('kamin303','blue','yes5gogo','karen','3','Karen Minazuki: Pumpkin Dress','https://cdn.discordapp.com/attachments/793380588223856651/793380688509534248/Puzzlun_3_Karen_003.jpg','https://cdn.discordapp.com/attachments/793380588223856651/827034778640449596/image0.jpg','20','10','1','1','2','2020-12-30 01:36:55');
INSERT INTO `card_data` VALUES('kamin402','blue','yes5gogo','karen','4','Karen Minazuki: Queen without Baba','https://cdn.discordapp.com/attachments/793380588223856651/793380752564682762/Puzzlun_4_Karen_002.jpg','https://cdn.discordapp.com/attachments/793380588223856651/827034876351610891/image0.png','20','10','1','1','2','2020-12-30 01:40:09');
INSERT INTO `card_data` VALUES('kamin403','blue','yes5gogo','karen','4','Karen Minazuki: Take a break in the shade of a tree','https://cdn.discordapp.com/attachments/793380588223856651/793380771762667551/Puzzlun_4_Karen_003.jpg','https://cdn.discordapp.com/attachments/793380588223856651/827034890435428372/image0.jpg','20','10','1','1','2','2020-12-30 01:41:26');
INSERT INTO `card_data` VALUES('kamin601','blue','yes5gogo','karen','6','Cure Aqua','https://cdn.discordapp.com/attachments/793380588223856651/793380818180636715/Puzzlun_0_Karen_001.jpg','https://cdn.discordapp.com/attachments/793380588223856651/827034926988656660/image0.jpg','30','10','0','1','2','2020-12-30 01:43:26');
INSERT INTO `card_data` VALUES('kiam601','yellow','go_princess','kirara','6','Cure Twinkle','https://cdn.discordapp.com/attachments/793389968457859093/793390188947701770/Puzzlun_0_Kirara_001.jpg','https://cdn.discordapp.com/attachments/793389968457859093/827657034803052564/image0.jpg','30','10','0','1',NULL,'2020-12-30 17:36:18');
INSERT INTO `card_data` VALUES('koak302','green','yes5gogo','komachi','3','Komachi Akimoto: Gracefully walk','https://cdn.discordapp.com/attachments/793380333194051614/793380414638653440/Puzzlun_3_Komachi_002.jpg','https://cdn.discordapp.com/attachments/793380333194051614/827030602376937472/image0.jpg','20','10','1','1','2','2020-12-30 01:23:58');
INSERT INTO `card_data` VALUES('koak303','green','yes5gogo','komachi','3','Komachi Akimoto: Komachi O Lantern','https://cdn.discordapp.com/attachments/793380333194051614/793380430342127616/Puzzlun_3_Komachi_003.jpg','https://cdn.discordapp.com/attachments/793380333194051614/827030622273798184/image0.jpg','20','10','1','1','2','2020-12-30 01:25:06');
INSERT INTO `card_data` VALUES('koak402','green','yes5gogo','komachi','4','Komachi Akimoto: Detective without Baba','https://cdn.discordapp.com/attachments/793380333194051614/793380481449066516/Puzzlun_4_Komachi_002.jpg','https://cdn.discordapp.com/attachments/793380333194051614/827030712782946365/image0.jpg','20','10','1','1','2','2020-12-30 01:28:06');
INSERT INTO `card_data` VALUES('koak403','green','yes5gogo','komachi','4','Komachi Akimoto: New Year!','https://cdn.discordapp.com/attachments/793380333194051614/793380499527172146/Puzzlun_4_Komachi_003.jpg','https://cdn.discordapp.com/attachments/793380333194051614/827030743959470090/image0.jpg','20','10','1','1','2','2020-12-30 01:28:59');
INSERT INTO `card_data` VALUES('koak601','green','yes5gogo','komachi','6','Cure Mint','https://cdn.discordapp.com/attachments/793380333194051614/793380551490273280/Puzzlun_0_Komachi_001.jpg','https://cdn.discordapp.com/attachments/793380333194051614/827030800603676692/image0.jpg','30','10','0','1','2','2020-12-30 01:32:03');
INSERT INTO `card_data` VALUES('koha601','green','mahou_tsukai','kotoha','6','Cure Felice','https://cdn.discordapp.com/attachments/793391246495449088/793391434387685426/Puzzlun_0_Kotoha_001.jpg','https://cdn.discordapp.com/attachments/793391246495449088/827740637607886908/image0.jpg','30','10','0','1',NULL,'2020-12-30 18:49:17');
INSERT INTO `card_data` VALUES('kumi302','purple','yes5gogo','kurumi','3','Kurumi Mimino: Adventures of Princes','https://cdn.discordapp.com/attachments/793380840255389716/793380942550925322/Puzzlun_3_Kurumi_002.jpg','https://cdn.discordapp.com/attachments/793380840255389716/827037705182642176/image0.jpg','20','10','1','1','2','2020-12-30 01:50:52');
INSERT INTO `card_data` VALUES('kumi402','purple','yes5gogo','kurumi','4','Kurumi Mimino: Revenge on the Queen!','https://cdn.discordapp.com/attachments/793380840255389716/793380983759568926/Puzzlun_4_Kurumi_002.jpg','https://cdn.discordapp.com/attachments/793380840255389716/827037754977157180/image0.jpg','20','10','1','1','2','2020-12-30 01:53:44');
INSERT INTO `card_data` VALUES('kumi403','purple','yes5gogo','kurumi','4','Kurumi Mimino: Ku!Be!Tsu!To!!','https://cdn.discordapp.com/attachments/793380840255389716/793380997584519188/Puzzlun_4_Kurumi_003.jpg','https://cdn.discordapp.com/attachments/793380840255389716/827037790473682964/image0.jpg','20','10','1','1','2','2020-12-30 01:54:45');
INSERT INTO `card_data` VALUES('kumi502','purple','yes5gogo','kurumi','5','Kurumi Mimino: Valentine Illuminations','https://cdn.discordapp.com/attachments/793380840255389716/793381081847955466/Puzzlun_5_Kurumi_002.jpg','https://cdn.discordapp.com/attachments/793380840255389716/827037870644133928/image0.jpg','30','10','1','1','2','2020-12-30 01:58:15');
INSERT INTO `card_data` VALUES('kumi601','purple','yes5gogo','kurumi','6','Milky Rose','https://cdn.discordapp.com/attachments/793380840255389716/793381113312575498/Puzzlun_0_Kurumi_001.jpg','https://cdn.discordapp.com/attachments/793380840255389716/827037885927653406/image0.jpg','30','10','0','1','2','2020-12-30 01:58:56');
INSERT INTO `card_data` VALUES('laha601','green','star_twinkle','lala','6','Cure Milky','https://cdn.discordapp.com/attachments/793395855654518814/793396008947810314/Puzzlun_0_Lala_001.jpg','https://cdn.discordapp.com/attachments/793395855654518814/827960664571248660/image0.jpg','30','10','0','1',NULL,'2020-12-30 21:50:22');
INSERT INTO `card_data` VALUES('lomo601','pink','fresh','love','6','Cure Peach','https://cdn.discordapp.com/attachments/793381447062913064/793381616629317642/Puzzlun_0_Love_001.jpg','https://cdn.discordapp.com/attachments/793381447062913064/827050129734369380/image0.jpg','30','10','0','1',NULL,'2020-12-30 02:10:19');
INSERT INTO `card_data` VALUES('maai601','pink','dokidoki','mana','6','Cure Heart','https://cdn.discordapp.com/attachments/793387637527805973/793387803626700830/Puzzlun_0_Mana_001.jpg','https://cdn.discordapp.com/attachments/793387637527805973/827385115755151390/image0.jpg','30','10','0','1',NULL,'2020-12-30 13:36:22');
INSERT INTO `card_data` VALUES('maka601','purple','star_twinkle','madoka','6','Cure Selene','https://cdn.discordapp.com/attachments/793396194697019412/793396363094261760/Puzzlun_0_Madoka_001.jpg','https://cdn.discordapp.com/attachments/793396194697019412/827966292765573140/image0.jpg','30','10','0','1',NULL,'2020-12-30 22:10:02');
INSERT INTO `card_data` VALUES('make601','purple','dokidoki','makoto','6','Cure Sword','https://cdn.discordapp.com/attachments/793388248139300864/793388416807993364/Puzzlun_0_Makoto_001.jpg','https://cdn.discordapp.com/attachments/793388248139300864/827396526933671986/image0.jpg','30','10','0','1',NULL,'2020-12-30 14:07:17');
INSERT INTO `card_data` VALUES('mami302','white','splash_star','mai','3','Mai Mishou: Starry Ribbon Coat','https://cdn.discordapp.com/attachments/793379085069844520/793379165801938954/Puzzlun_3_Mai_002.jpg','https://cdn.discordapp.com/attachments/793379085069844520/827008070093242438/image0.jpg','20','10','1','1','2','2020-12-29 19:38:08');
INSERT INTO `card_data` VALUES('mami303','white','splash_star','mai','3','Mai Mishou: Glitter Night Sky Skirt','https://cdn.discordapp.com/attachments/793379085069844520/793379184960602142/Puzzlun_3_Mai_003.jpg','https://cdn.discordapp.com/attachments/793379085069844520/827008089004965928/image0.jpg','20','10','1','1','2','2020-12-29 19:38:57');
INSERT INTO `card_data` VALUES('mami402','white','splash_star','mai','4','Mai Mishou: The world of stars seen from the telescope','https://cdn.discordapp.com/attachments/793379085069844520/793379223166648340/Puzzlun_4_Mai_002.jpg','https://cdn.discordapp.com/attachments/793379085069844520/827008145250844722/image0.png','20','10','1','1','2','2020-12-29 19:40:48');
INSERT INTO `card_data` VALUES('mami502','white','splash_star','mai','5','Mai Mishou: Easter Egg Paint','https://cdn.discordapp.com/attachments/793379085069844520/793379269791186954/Puzzlun_5_Mai_002.jpg','https://cdn.discordapp.com/attachments/793379085069844520/827008169661562900/image0.jpg','30','10','1','1','2','2020-12-30 00:45:27');
INSERT INTO `card_data` VALUES('mami601','white','splash_star','mai','6','Cure Egret','https://cdn.discordapp.com/attachments/793379085069844520/793460074168188948/Puzzlun_0_Mai_001.jpg','https://cdn.discordapp.com/attachments/793379085069844520/827008188514566154/image0.jpg','30','10','0','1','2','2020-12-30 00:46:35');
INSERT INTO `card_data` VALUES('manat101','pink','tropical_rouge','manatsu','1','Natsuumi Manatsu','https://cdn.discordapp.com/attachments/832840763087519752/832844510974312488/manat101.jpg','https://cdn.discordapp.com/attachments/832840763087519752/832844510974312488/manat101.jpg','10','5','1','1','1','2021-12-24 15:12:02');
INSERT INTO `card_data` VALUES('manat102','pink','tropical_rouge','manatsu','2','Natsuumi Manatsu & Cure Summer!','https://cdn.discordapp.com/attachments/832840763087519752/832917954445705236/manat201.jpg','https://cdn.discordapp.com/attachments/832840763087519752/832917954445705236/manat201.jpg','10','5','1','1',NULL,'2021-12-24 15:13:53');
INSERT INTO `card_data` VALUES('manat601','pink','tropical_rouge','manatsu','6','Cure Summer','https://cdn.discordapp.com/attachments/832840763087519752/832844526087307304/manat601.jpg','https://cdn.discordapp.com/attachments/832840763087519752/832844526087307304/manat601.jpg','30','10','0','1',NULL,'2022-01-25 15:39:42');
INSERT INTO `card_data` VALUES('meai601','pink','happiness_charge','megumi','6','Cure Lovely','https://cdn.discordapp.com/attachments/793388697474564157/793388828856418344/Puzzlun_0_Megumi_001.jpg','https://cdn.discordapp.com/attachments/793388697474564157/827411977059565598/image0.jpg','30','10','0','1',NULL,'2020-12-30 14:36:43');
INSERT INTO `card_data` VALUES('miao601','blue','fresh','miki','6','Cure Berry','https://cdn.discordapp.com/attachments/793381635424387073/793381803612307466/Puzzlun_0_Miki_001.jpg','https://cdn.discordapp.com/attachments/793381635424387073/827052367500410880/image0.jpg','30','10','0','1',NULL,'2020-12-30 02:30:59');
INSERT INTO `card_data` VALUES('mias601','pink','mahou_tsukai','mirai','6','Cure Miracle Diamond Style','https://cdn.discordapp.com/attachments/793390659046080512/793391007815303168/Puzzlun_0_Mirai_001.jpg','https://cdn.discordapp.com/attachments/793390659046080512/827727031021862922/image0.jpg','30','10','0','1',NULL,'2020-12-30 18:25:24');
INSERT INTO `card_data` VALUES('miho601','pink','smile','miyuki','6','Cure Happy','https://cdn.discordapp.com/attachments/793384875465506816/793385075383205898/Puzzlun_0_Miyuki_001.jpg','https://cdn.discordapp.com/attachments/793384875465506816/827288342877175828/image0.jpg','30','10','0','1',NULL,'2020-12-30 11:05:46');
INSERT INTO `card_data` VALUES('miic101','yellow','tropical_rouge','minori','1','Minori Ichinose','https://cdn.discordapp.com/attachments/832841249597030451/832844647105691668/miic101.jpg','https://cdn.discordapp.com/attachments/832841249597030451/832844647105691668/miic101.jpg','10','5','1','1','1','2021-12-24 15:24:12');
INSERT INTO `card_data` VALUES('miic201','yellow','tropical_rouge','minori','2','Minori Ichinose & Cure Papaya','https://cdn.discordapp.com/attachments/832841249597030451/832918171387297802/miic201.jpg','https://cdn.discordapp.com/attachments/832841249597030451/832918171387297802/miic201.jpg','10','5','1','1','1','2021-12-24 15:24:55');
INSERT INTO `card_data` VALUES('miic601','yellow','tropical_rouge','minori','6','Cure Papaya','https://cdn.discordapp.com/attachments/832841249597030451/832844664075583539/miic601.jpg','https://cdn.discordapp.com/attachments/832841249597030451/832844664075583539/miic601.jpg','30','10','0','1',NULL,'2022-01-25 15:42:33');
INSERT INTO `card_data` VALUES('mikai601','blue','go_princess','minami','6','Cure Mermaid','https://cdn.discordapp.com/attachments/793389777361174549/793389955518955530/Puzzlun_0_Minami_001.jpg','https://cdn.discordapp.com/attachments/793389777361174549/827648612652679168/image0.jpg','30','10','0','1',NULL,'2020-12-30 17:20:44');
INSERT INTO `card_data` VALUES('nami102','pink','max_heart','nagisa','1','Nagisa Misumi: School Uniform','https://cdn.discordapp.com/attachments/793374640839458837/793376076277350410/Puzzlun_1_Nagisa_002.jpg','https://cdn.discordapp.com/attachments/793374640839458837/826972909275709460/image0.jpg','10','5','1','1','2','2020-12-29 17:15:54');
INSERT INTO `card_data` VALUES('nami302','pink','max_heart','nagisa','3','Nagisa Misumi: Black Ribbon','https://cdn.discordapp.com/attachments/793374640839458837/793376120720457758/Puzzlun_3_Nagisa_002.jpg','https://cdn.discordapp.com/attachments/793374640839458837/826974219337203712/image0.jpg','20','10','1','1','2','2020-12-29 17:23:36');
INSERT INTO `card_data` VALUES('nami303','pink','max_heart','nagisa','3','Nagisa Misumi: Raspberry Corde','https://cdn.discordapp.com/attachments/793374640839458837/793376137875161108/Puzzlun_3_Nagisa_003.jpg','https://cdn.discordapp.com/attachments/793374640839458837/826974245589352498/image0.jpg','20','10','1','1','2','2020-12-29 17:28:03');
INSERT INTO `card_data` VALUES('nami402','pink','max_heart','nagisa','4','Nagisa Misumi: La France Dress','https://cdn.discordapp.com/attachments/793374640839458837/793376194846261268/Puzzlun_4_Nagisa_002.jpg','https://cdn.discordapp.com/attachments/793374640839458837/826974355166330880/image0.jpg','20','10','1','1','2','2020-12-29 17:33:40');
INSERT INTO `card_data` VALUES('nami403','pink','max_heart','nagisa','4','Nagisa Misumi: Mix and mix sweet chocolate making','https://cdn.discordapp.com/attachments/793374640839458837/793376212633255936/Puzzlun_4_Nagisa_003.jpg','https://cdn.discordapp.com/attachments/793374640839458837/826974381690454070/image0.jpg','20','10','1','1','2','2020-12-29 17:34:36');
INSERT INTO `card_data` VALUES('naomi601','green','smile','nao','6','Cure March','https://cdn.discordapp.com/attachments/793386892137332756/793387101319856149/Puzzlun_0_Nao_001.jpg','https://cdn.discordapp.com/attachments/793386892137332756/827311122742509618/image0.jpg','30','10','0','1',NULL,'2020-12-30 13:14:15');
INSERT INTO `card_data` VALUES('noha601','pink','healin_good','nodoka','6','Cure Grace','https://cdn.discordapp.com/attachments/793396698117701632/793396811079352330/Puzzlun_0_Nodoka_001.jpg','https://cdn.discordapp.com/attachments/793396698117701632/827998797103366224/image0.jpg','30','10','0','1',NULL,'2020-12-30 22:20:41');
INSERT INTO `card_data` VALUES('noyu302','pink','yes5gogo','nozomi','3','Nozomi Yumehara: to Villa Tanken','https://cdn.discordapp.com/attachments/793379464753971220/793379706409320458/Puzzlun_3_Nozomi_002.jpg','https://cdn.discordapp.com/attachments/793379464753971220/827010641897979914/image0.jpg','20','10','1','1','2','2020-12-30 00:52:21');
INSERT INTO `card_data` VALUES('noyu303','pink','yes5gogo','nozomi','3','Nozomi Yumehara: Dream Chia','https://cdn.discordapp.com/attachments/793379464753971220/793379722121838612/Puzzlun_3_Nozomi_003.jpg','https://cdn.discordapp.com/attachments/793379464753971220/827010664865333298/image0.jpg','20','10','1','1','2','2020-12-30 00:53:12');
INSERT INTO `card_data` VALUES('noyu402','pink','yes5gogo','nozomi','4','Nozomi Yumehara: Which one!','https://cdn.discordapp.com/attachments/793379464753971220/793379775401033758/Puzzlun_4_Nozomi_002.jpg','https://cdn.discordapp.com/attachments/793379464753971220/827010840321327124/image0.jpg','20','10','1','1','2','2020-12-30 00:56:03');
INSERT INTO `card_data` VALUES('noyu403','pink','yes5gogo','nozomi','4','Nozomi Yumehara: A gift full of dreams','https://cdn.discordapp.com/attachments/793379464753971220/793379791910600704/Puzzlun_4_Nozomi_003.jpg','https://cdn.discordapp.com/attachments/793379464753971220/827010858928177222/image0.jpg','20','10','1','1','2','2020-12-30 00:57:02');
INSERT INTO `card_data` VALUES('noyu601','pink','yes5gogo','nozomi','6','Cure Dream','https://cdn.discordapp.com/attachments/793379464753971220/793379832813715496/Puzzlun_0_Nozomi_001.jpg','https://cdn.discordapp.com/attachments/793379464753971220/827010914619228200/image0.jpg','30','10','0','1','2','2020-12-30 00:59:01');
INSERT INTO `card_data` VALUES('reao601','blue','smile','reika','6','Cure Beauty','https://cdn.discordapp.com/attachments/793387120341155850/793387423178555402/Puzzlun_0_Reika_001.jpg','https://cdn.discordapp.com/attachments/793387120341155850/827381228294504448/image0.jpg','30','10','0','1',NULL,'2020-12-30 13:23:57');
INSERT INTO `card_data` VALUES('rihi601','blue','dokidoki','rikka','6','Cure Diamond','https://cdn.discordapp.com/attachments/793387811922903040/793388036976410624/Puzzlun_0_Rikka_001.jpg','https://cdn.discordapp.com/attachments/793387811922903040/827388999484178443/image0.jpg','30','10','0','1',NULL,'2020-12-30 13:46:55');
INSERT INTO `card_data` VALUES('riiz601','purple','mahou_tsukai','riko','6','Cure Magical Diamond Style','https://cdn.discordapp.com/attachments/793391024067837972/793391213792591892/Puzzlun_0_Riko_001.jpg','https://cdn.discordapp.com/attachments/793391024067837972/827735131439235112/image0.jpg','30','10','0','1',NULL,'2020-12-30 18:36:43');
INSERT INTO `card_data` VALUES('rina302','red','yes5gogo','rin','3','Rin Natsuki: Passionate Tennis Showdown','https://cdn.discordapp.com/attachments/793379843483631626/793379925692121089/Puzzlun_3_Rin_002.jpg','https://cdn.discordapp.com/attachments/793379843483631626/827016208909598730/image0.jpg','20','10','1','1','2','2020-12-30 01:03:15');
INSERT INTO `card_data` VALUES('rina303','red','yes5gogo','rin','3','Rin Natsuki: High Collar Modern Yukata','https://cdn.discordapp.com/attachments/793379843483631626/793379944792981504/Puzzlun_3_Rin_003.jpg','https://cdn.discordapp.com/attachments/793379843483631626/827016228484284416/image0.jpg','20','10','1','1','2','2020-12-30 01:03:59');
INSERT INTO `card_data` VALUES('rina402','red','yes5gogo','rin','4','Rin Natsuki: Barre Barre!','https://cdn.discordapp.com/attachments/793379843483631626/793379980843024414/Puzzlun_4_Rin_002.jpg','https://cdn.discordapp.com/attachments/793379843483631626/827016282926481459/image0.jpg','20','10','1','1','2','2020-12-30 01:06:19');
INSERT INTO `card_data` VALUES('rina403','red','yes5gogo','rin','4','Rin Natsuki: Rolling a big ball with passion','https://cdn.discordapp.com/attachments/793379843483631626/793379998010572820/Puzzlun_4_Rin_003.jpg','https://cdn.discordapp.com/attachments/793379843483631626/827016303629828106/image0.jpg','20','10','1','1','2','2020-12-30 01:07:11');
INSERT INTO `card_data` VALUES('rina601','red','yes5gogo','rin','6','Cure Rouge','https://cdn.discordapp.com/attachments/793379843483631626/793380070004883466/Puzzlun_0_Rin_001.jpg','https://cdn.discordapp.com/attachments/793379843483631626/827016363578621972/image0.jpg','30','10','0','1','2','2020-12-30 01:09:48');
INSERT INTO `card_data` VALUES('sahy302','pink','splash_star','saki','3','Saki Hyuuga: Fluffy Star Poncho','https://cdn.discordapp.com/attachments/793378822976045096/793378921013313546/Puzzlun_3_Saki_0002.jpg','https://cdn.discordapp.com/attachments/793378822976045096/826996436520271882/image0.jpg','20','10','1','1','2','2020-12-29 18:59:25');
INSERT INTO `card_data` VALUES('sahy303','pink','splash_star','saki','3','Saki Hyuuga: Star Wappen School Coordination','https://cdn.discordapp.com/attachments/793378822976045096/793378936364990464/Puzzlun_3_Saki_003.jpg','https://cdn.discordapp.com/attachments/793378822976045096/826996455272873984/image0.jpg','20','10','1','1','2','2020-12-29 19:00:30');
INSERT INTO `card_data` VALUES('sahy402','pink','splash_star','saki','4','Saki Hyuuga: Glitter Full of konpeito!??','https://cdn.discordapp.com/attachments/793378822976045096/793379014182043708/Puzzlun_4_Saki_002.jpg','https://cdn.discordapp.com/attachments/793378822976045096/826996548789075998/image0.jpg','20','10','1','1','2','2020-12-29 19:04:20');
INSERT INTO `card_data` VALUES('sahy403','pink','splash_star','saki','4','Saki Hyuuga: Little Devil Heart Devil','https://cdn.discordapp.com/attachments/793378822976045096/793379032502239232/Puzzlun_4_Saki_003.jpg','https://cdn.discordapp.com/attachments/793378822976045096/826996568451579904/image0.jpg','20','10','1','1','2','2020-12-29 19:05:16');
INSERT INTO `card_data` VALUES('sahy601','pink','splash_star','saki','6','Cure Bloom','https://cdn.discordapp.com/attachments/793378822976045096/793379072893124628/Puzzlun_0_Saki_001.jpg','https://cdn.discordapp.com/attachments/793378822976045096/826996603864088586/image0.jpg','30','10','0','1','2','2020-12-29 19:09:44');
INSERT INTO `card_data` VALUES('sasu101','purple','tropical_rouge','sango','1','Sango Suzumura','https://cdn.discordapp.com/attachments/832841200494837772/832844577357692928/sasu101.jpg','https://cdn.discordapp.com/attachments/832841200494837772/832844577357692928/sasu101.jpg','10','10','1','1','1','2021-12-24 15:21:47');
INSERT INTO `card_data` VALUES('sasu201','purple','tropical_rouge','sango','2','Sango Suzumura & Cure Coral','https://cdn.discordapp.com/attachments/832841200494837772/832918076022063114/sasu201.jpg','https://cdn.discordapp.com/attachments/832841200494837772/832918076022063114/sasu201.jpg','10','5','1','1','1','2021-12-24 15:22:55');
INSERT INTO `card_data` VALUES('sasu601','purple','tropical_rouge','sango','6','Cure Coral','https://cdn.discordapp.com/attachments/832841200494837772/832844596999749632/sasu601.jpg','https://cdn.discordapp.com/attachments/832841200494837772/832844596999749632/sasu601.jpg','30','10','0','1',NULL,'2022-01-25 15:41:23');
INSERT INTO `card_data` VALUES('saya601','blue','hugtto','saaya','6','Cure Ange','https://cdn.discordapp.com/attachments/793394491431714838/793394674823725066/Puzzlun_0_Saaya_001.jpg','https://cdn.discordapp.com/attachments/793394491431714838/827814168023138304/image0.jpg','30','10','0','1',NULL,'2020-12-30 20:46:34');
INSERT INTO `card_data` VALUES('sehi601','red','fresh','setsuna','6','Cure Passion','https://cdn.discordapp.com/attachments/793382021044371507/793382202498351134/Puzzlun_0_Setsuna_001.jpg','https://cdn.discordapp.com/attachments/793382021044371507/827062998085402654/image0.jpg','30','10','0','1',NULL,'2020-12-30 03:03:01');
INSERT INTO `card_data` VALUES('toak601','red','go_princess','towa','6','Cure Scarlet','https://cdn.discordapp.com/attachments/793390200070864908/793390401662222376/Puzzlun_0_Towa_001.jpg','https://cdn.discordapp.com/attachments/793390200070864908/827662618515996752/image0.jpg','30','10','0','1',NULL,'2020-12-30 18:12:50');
INSERT INTO `card_data` VALUES('tsha601','pink','heartcatch','tsubomi','6','Cure Blossom','https://cdn.discordapp.com/attachments/793382427551727636/793382724521951262/Puzzlun_0_Tsubomi_001.jpg','https://cdn.discordapp.com/attachments/793382427551727636/827067293690888242/image0.jpg','30','10','0','1',NULL,'2020-12-30 03:15:14');
INSERT INTO `card_data` VALUES('urka302','yellow','yes5gogo','urara','3','Urara Kasugano: watching tennis with syrup','https://cdn.discordapp.com/attachments/793380077173735424/793380169371877416/Puzzlun_3_Urara_002.jpg','https://cdn.discordapp.com/attachments/793380077173735424/827022363903131658/image0.jpg','20','10','1','1','2','2020-12-30 01:12:56');
INSERT INTO `card_data` VALUES('urka303','yellow','yes5gogo','urara','3','Urara Kasugano: Naughty cat','https://cdn.discordapp.com/attachments/793380077173735424/793380185935839242/Puzzlun_3_Urara_003.jpg','https://cdn.discordapp.com/attachments/793380077173735424/827022391758422046/image0.jpg','20','10','1','1','2','2020-12-30 01:14:19');
INSERT INTO `card_data` VALUES('urka402','yellow','yes5gogo','urara','4','Urara Kasugano: Poker Face','https://cdn.discordapp.com/attachments/793380077173735424/793380245281308682/Puzzlun_4_Urara_002.jpg','https://cdn.discordapp.com/attachments/793380077173735424/827022835809517598/image0.jpg','20','10','1','1','2','2020-12-30 01:17:14');
INSERT INTO `card_data` VALUES('urka403','yellow','yes5gogo','urara','4','Urara Kasugano: Easter Egg Lace','https://cdn.discordapp.com/attachments/793380077173735424/793380266529652756/Puzzlun_4_Urara_003.jpg','https://cdn.discordapp.com/attachments/793380077173735424/827022858043654155/image0.jpg','20','10','1','1','2','2020-12-30 01:18:05');
INSERT INTO `card_data` VALUES('urka601','yellow','yes5gogo','urara','6','Cure Lemonade','https://cdn.discordapp.com/attachments/793380077173735424/793380314155188234/Puzzlun_0_Urara_001.jpg','https://cdn.discordapp.com/attachments/793380077173735424/827023038662443048/image0.jpg','30','10','0','1','2','2020-12-30 01:20:19');
INSERT INTO `card_data` VALUES('yaki601','yellow','smile','yayoi','6','Cure Peace','https://cdn.discordapp.com/attachments/793386748356067349/793386895731195915/Puzzlun_0_Yayoi_001.jpg','https://cdn.discordapp.com/attachments/793386748356067349/827308918891479050/image0.jpg','30','10','0','1',NULL,'2020-12-30 12:59:59');
INSERT INTO `card_data` VALUES('yuko601','purple','kirakira','yukari','6','Cure Macaron','https://cdn.discordapp.com/attachments/793392786367316038/793392998771195940/Puzzlun_0_Yukari_001.jpg','https://cdn.discordapp.com/attachments/793392786367316038/827781460843954176/image0.jpg','30','10','0','1',NULL,'2020-12-30 19:41:29');
INSERT INTO `card_data` VALUES('yuni601','blue','star_twinkle','yuni','6','Cure Cosmo','https://cdn.discordapp.com/attachments/793396381406199809/793396513816182814/Puzzlun_0_Yuni_001.jpg','https://cdn.discordapp.com/attachments/793396381406199809/827967641033375774/image0.jpg','30','10','0','1',NULL,'2020-12-30 22:16:30');
INSERT INTO `card_data` VALUES('yuom601','yellow','happiness_charge','yuko','6','Cure Honey','https://cdn.discordapp.com/attachments/793389083162050581/793389218943991818/Puzzlun_0_Yuko_001.jpg','https://cdn.discordapp.com/attachments/793389083162050581/827416355849633802/image0.jpg','30','10','0','1',NULL,'2020-12-30 16:25:47');
INSERT INTO `card_data` VALUES('yuts601','purple','heartcatch','yuri','6','Cure Moonlight','https://cdn.discordapp.com/attachments/793383243750703144/793383413389459476/Puzzlun_0_Yuri_001.jpg','https://cdn.discordapp.com/attachments/793383243750703144/827085487482601492/image0.jpg','30','10','0','1',NULL,'2020-12-30 09:59:16');
INSERT INTO `enemy_data` VALUES('1','Roller Coaster','max_heart','https://static.wikia.nocookie.net/prettycure/images/d/d2/FwPC01_Roller_Coaster_Zakenna.png','pink,white','Pink/white max heart cure max hp+30%','{\"hp_max\":30}','2022-02-02 10:13:59');
INSERT INTO `enemy_data` VALUES('10','Sculpture','yes5gogo','https://static.wikia.nocookie.net/prettycure/images/9/96/-4.png','blue','Blue yes 5 cure max hp+30%','{\"hp_max\":30}','2022-02-02 10:33:44');
INSERT INTO `enemy_data` VALUES('11','Soccer Ball','yes5gogo','https://static.wikia.nocookie.net/prettycure/images/8/81/-5.png','red','Red yes 5 cure atk+30%','{\"atk\":30}','2022-02-02 10:34:32');
INSERT INTO `enemy_data` VALUES('12','Boat','yes5gogo','https://static.wikia.nocookie.net/prettycure/images/7/71/-11.png','purple','Purple yes 5 cure start with 20% special point','{\"sp\":2}','2022-02-02 10:36:01');
INSERT INTO `enemy_data` VALUES('13','House','yes5gogo','https://static.wikia.nocookie.net/prettycure/images/5/56/Hoshina.06.png','green','Green yes 5 cure max hp+30%','{\"hp_max\":30}','2022-02-02 10:38:10');
INSERT INTO `enemy_data` VALUES('14','Rabbit Doll','yes5gogo','https://static.wikia.nocookie.net/prettycure/images/3/38/Hoshina.22.png','pink,blue,yellow,green,red,purple','Yes 5 cure start with 20% special point','{\"sp\":2}','2022-02-02 10:49:10');
INSERT INTO `enemy_data` VALUES('15','Speaker','fresh','https://static.wikia.nocookie.net/prettycure/images/b/b2/Nakewameke_01.jpg','pink','Pink fresh cure max hp+30%','{\"hp_max\":30}','2022-02-02 10:43:55');
INSERT INTO `enemy_data` VALUES('16','Drink Vending Machine','fresh','https://static.wikia.nocookie.net/prettycure/images/1/1e/Nakewameke_02.jpg','blue','Blue fresh cure max hp+30%','{\"hp_max\":30}','2022-02-02 10:44:26');
INSERT INTO `enemy_data` VALUES('17','Lucky','fresh','https://static.wikia.nocookie.net/prettycure/images/7/7d/Nakewameke_03.jpg','yellow','Yellow fresh cure start with 20% special point','{\"sp\":2}','2022-02-02 10:44:51');
INSERT INTO `enemy_data` VALUES('18','Swimming Ring','fresh','https://static.wikia.nocookie.net/prettycure/images/6/64/Nakewameke_26.jpg','red','Red fresh cure atk+30%','{\"atk\":30}','2022-02-02 10:47:07');
INSERT INTO `enemy_data` VALUES('19','Pitching Machine','fresh','https://static.wikia.nocookie.net/prettycure/images/9/9f/Nakewameke_31.jpg','pink,blue,yellow,red','Fresh cure atk+30%','{\"atk\":30}','2022-02-02 10:47:44');
INSERT INTO `enemy_data` VALUES('2','Vacuum Cleaner','max_heart','https://static.wikia.nocookie.net/prettycure/images/4/46/FwPC02_Zakenna_Vacuum.png','pink,white','Pink/white max heart cure atk+30%','{\"atk\":30}','2022-02-02 10:14:21');
INSERT INTO `enemy_data` VALUES('20','Lost Doll','heartcatch','https://static.wikia.nocookie.net/prettycure/images/e/e2/Desertrian_01.jpg','pink','Pink heartcatch cure max hp+30%','{\"hp_max\":30}','2022-02-02 10:51:30');
INSERT INTO `enemy_data` VALUES('21','Soccer Ball','heartcatch','https://static.wikia.nocookie.net/prettycure/images/a/a1/Desertrian_02.jpg','blue','Blue heartcatch cure atk+30%','{\"atk\":30}','2022-02-02 10:52:16');
INSERT INTO `enemy_data` VALUES('22','Wheelchair','heartcatch','https://static.wikia.nocookie.net/prettycure/images/2/27/Desertrian_23.jpg','yellow','Yellow heartcatch cure start with 20% special point','{\"sp\":2}','2022-02-02 10:54:22');
INSERT INTO `enemy_data` VALUES('23','Movie Recorder','heartcatch','https://static.wikia.nocookie.net/prettycure/images/c/ca/Desertrian_35.jpg','purple','Purple heartcatch cure atk+30%','{\"atk\":30}','2022-02-02 10:57:12');
INSERT INTO `enemy_data` VALUES('24','Cupcake Box','suite','https://static.wikia.nocookie.net/prettycure/images/6/67/Nega06.gif','pink','Pink suite cure atk+30%','{\"atk\":30}','2022-02-02 10:59:42');
INSERT INTO `enemy_data` VALUES('25','Cymbals','suite','https://static.wikia.nocookie.net/prettycure/images/c/cc/Nega11.gif','white','White suite cure start with 20% special point','{\"sp\":2}','2022-02-02 11:01:33');
INSERT INTO `enemy_data` VALUES('26','Record','suite','https://static.wikia.nocookie.net/prettycure/images/7/72/Nega0102.gif','pink,white','Pink/white suite cure gain atk+30%','{\"atk\":30}','2022-02-02 11:02:17');
INSERT INTO `enemy_data` VALUES('27','Kitten Doll','suite','https://static.wikia.nocookie.net/prettycure/images/c/c9/Nega23.gif','blue','Blue suite cure gain atk+30%','{\"atk\":30}','2022-02-02 11:03:30');
INSERT INTO `enemy_data` VALUES('28','Jack O\' Lantern','suite','https://static.wikia.nocookie.net/prettycure/images/2/21/Nega37.gif','yellow','Yellow suite cure start with 20% special point','{\"sp\":2}','2022-02-02 11:04:50');
INSERT INTO `enemy_data` VALUES('29','Road Roller','suite','https://static.wikia.nocookie.net/prettycure/images/b/bf/Nega31.gif','pink,white,blue,yellow','Suite cure gain atk+30%','{\"atk\":30}','2022-02-02 11:06:12');
INSERT INTO `enemy_data` VALUES('3','Statue Of Roosters','max_heart','https://static.wikia.nocookie.net/prettycure/images/8/80/MH.Zakenna04.png','yellow','Yellow max heart cure start with 20% special point','{\"sp\":2}','2022-02-02 10:24:04');
INSERT INTO `enemy_data` VALUES('30','House','smile','https://static.wikia.nocookie.net/prettycure/images/4/46/Akanbe_01.jpg','pink','Pink smile cure max hp+30%','{\"hp_max\":30}','2022-02-02 11:07:20');
INSERT INTO `enemy_data` VALUES('31','Volleyball','smile','https://static.wikia.nocookie.net/prettycure/images/c/c9/Akanbe_02.jpg','red','Red smile cure gain atk+30%','{\"atk\":30}','2022-02-02 11:07:49');
INSERT INTO `enemy_data` VALUES('32','Soccer Goalpost','smile','https://static.wikia.nocookie.net/prettycure/images/9/9d/Akanbe04.jpg','green','Green smile cure max hp+30%','{\"hp_max\":30}','2022-02-02 11:08:22');
INSERT INTO `enemy_data` VALUES('33','Mirror Prop','smile','https://static.wikia.nocookie.net/prettycure/images/4/44/Gfxg.jpg','blue','Blue smile cure gain atk+30%','{\"atk\":30}','2022-02-02 11:08:58');
INSERT INTO `enemy_data` VALUES('34','Tennis Court Roller','smile','https://static.wikia.nocookie.net/prettycure/images/0/06/Akanbe.ep.9.jpg','yellow','Yellow smile cure start with 20% special point','{\"sp\":2}','2022-02-02 11:09:32');
INSERT INTO `enemy_data` VALUES('35','Gachapon Machine','smile','https://static.wikia.nocookie.net/prettycure/images/2/2c/Akanbe12.jpg','pink,red,green,blue,yellow','Smile cure max hp+30%','{\"hp_max\":30}','2022-02-02 11:10:10');
INSERT INTO `enemy_data` VALUES('36','Dark Crab','dokidoki','https://static.wikia.nocookie.net/prettycure/images/4/47/Jikochuu_marmo.png','pink','Pink dokidoki cure max hp+30%','{\"hp_max\":30}','2022-02-02 11:11:09');
INSERT INTO `enemy_data` VALUES('37','Goat/Mailbox','dokidoki','https://static.wikia.nocookie.net/prettycure/images/7/77/GoatJikochuu2.png','blue','Blue dokidoki cure start with 20% special point','{\"sp\":2}','2022-02-02 11:13:18');
INSERT INTO `enemy_data` VALUES('38','Boom Box','dokidoki','https://static.wikia.nocookie.net/prettycure/images/6/6f/Jikochuu_BBox.png','yellow','Yellow dokidoki cure max hp+30%','{\"hp_max\":30}','2022-02-02 11:14:02');
INSERT INTO `enemy_data` VALUES('39','Microphone','dokidoki','https://static.wikia.nocookie.net/prettycure/images/7/79/DDPC24.Jikoch%C5%AB.jpg','purple','Purple dokidoki cure gain atk+30%','{\"atk\":30}','2022-02-02 11:14:40');
INSERT INTO `enemy_data` VALUES('4','Octopus','max_heart','https://static.wikia.nocookie.net/prettycure/images/4/43/MH.Zakenna06.png','yellow','Yellow max heart cure max hp+30%','{\"hp_max\":30}','2022-02-02 10:24:36');
INSERT INTO `enemy_data` VALUES('40','Recycle Bin','dokidoki','https://static.wikia.nocookie.net/prettycure/images/3/30/Episode_34_Jikochuu_1.jpg','red','Red dokidoki cure gain atk+30%','{\"atk\":30}','2022-02-02 11:16:36');
INSERT INTO `enemy_data` VALUES('41','Cup','dokidoki','https://static.wikia.nocookie.net/prettycure/images/6/69/Jikochu.ep32.png','pink,blue,yellow,purple,red','Dokidoki cure gain atk+30%','{\"atk\":30}','2022-02-02 11:20:16');
INSERT INTO `enemy_data` VALUES('42','Newspaper','happiness_charge','https://static.wikia.nocookie.net/prettycure/images/1/17/HCPC03.saiark.PNG','pink','Pink happiness charge cure atk+30%','{\"atk\":30}','2022-02-02 11:20:44');
INSERT INTO `enemy_data` VALUES('43','Parking Cone','happiness_charge','https://static.wikia.nocookie.net/prettycure/images/b/bf/Saiarks.jpg','blue','Blue happiness charge cure max hp+30%','{\"hp_max\":30}','2022-02-02 11:21:12');
INSERT INTO `enemy_data` VALUES('44','Matsuri','happiness_charge','https://static.wikia.nocookie.net/prettycure/images/4/41/Saiarksmonster.jpg','purple','Purple pappiness charge cure start with 20% special point','{\"sp\":2}','2022-02-02 11:22:33');
INSERT INTO `enemy_data` VALUES('45','Scarecrow','happiness_charge','https://static.wikia.nocookie.net/prettycure/images/a/a4/Hcpc11saiars.jpg','yellow','Yellow happiness charge cure start with 20% special point','{\"sp\":2}','2022-02-02 11:23:08');
INSERT INTO `enemy_data` VALUES('46','Tree','happiness_charge','https://static.wikia.nocookie.net/prettycure/images/2/2a/HCPC31Saiark.jpg','pink,blue,purple,yellow','Happiness charge cure atk+30%','{\"atk\":30}','2022-02-02 11:24:29');
INSERT INTO `enemy_data` VALUES('47','Picture Book','go_princess','https://static.wikia.nocookie.net/prettycure/images/e/ee/Book_Zetsuborg.png','pink','Pink go princess cure atk+30%','{\"atk\":30}','2022-02-02 11:27:08');
INSERT INTO `enemy_data` VALUES('48','Soccer Trophy','go_princess','https://static.wikia.nocookie.net/prettycure/images/f/f3/Episode2Zetsuborg.jpg','blue','Blue go princess cure max hp+30%','{\"hp_max\":30}','2022-02-02 11:27:36');
INSERT INTO `enemy_data` VALUES('49','Math Teacher','go_princess','https://static.wikia.nocookie.net/prettycure/images/7/78/This_episodes_Zetsuborg_ep_5.jpg','yellow','Yellow go princess cure start with 20% special point','{\"sp\":2}','2022-02-02 11:28:11');
INSERT INTO `enemy_data` VALUES('5','Tree','splash_star','https://static.wikia.nocookie.net/prettycure/images/b/b7/FwPCSS01_-_Uzaina.png','pink,white','Splash star cure atk+30%','{\"atk\":30}','2022-02-02 10:25:11');
INSERT INTO `enemy_data` VALUES('50','Donut','go_princess','https://static.wikia.nocookie.net/prettycure/images/f/fc/GPPC12_Zetsuborg.jpg','pink,blue,yellow','Pink/blue/yellow go princess cure atk+30%','{\"atk\":30}','2022-02-02 11:29:38');
INSERT INTO `enemy_data` VALUES('51','Crystal','go_princess','https://static.wikia.nocookie.net/prettycure/images/0/0e/This_Episodes_Zetsuborg_%2823%29.jpg','red','Red go princess cure atk+30%','{\"atk\":30}','2022-02-02 11:30:57');
INSERT INTO `enemy_data` VALUES('52','Flower','go_princess','https://static.wikia.nocookie.net/prettycure/images/5/54/ThisEpisodesZetsuborg31.jpg','pink,blue,yellow,red','Go princess cure max hp+30%','{\"hp_max\":30}','2022-02-02 11:32:07');
INSERT INTO `enemy_data` VALUES('53','Truck Feather','mahou_tsukai','https://static.wikia.nocookie.net/prettycure/images/e/ed/MTPC01_-_Yokubaru.png','pink,purple','Pink/purple mahou tsukai cure atk+30%','{\"atk\":30}','2022-02-02 11:36:19');
INSERT INTO `enemy_data` VALUES('54','Broom & Frozen Orange','mahou_tsukai','https://static.wikia.nocookie.net/prettycure/images/7/74/Dream_stars_yokubaru.png','green','Green mahou tsukai cure start with 20% special point','{\"sp\":2}','2022-02-02 11:38:57');
INSERT INTO `enemy_data` VALUES('55','Snow Ice','mahou_tsukai','https://static.wikia.nocookie.net/prettycure/images/0/0a/MTPC05_Yokubaru.png','pink,purple','Pink/purple mahou tsukai cure atk+30%','{\"atk\":30}','2022-02-02 11:40:38');
INSERT INTO `enemy_data` VALUES('56','Clam Seaweed','mahou_tsukai','https://static.wikia.nocookie.net/prettycure/images/6/64/MTPC07_Yokubaru.png','pink,purple','Pink/purple mahou tsukai cure max hp+30%','{\"hp_max\":30}','2022-02-02 11:46:41');
INSERT INTO `enemy_data` VALUES('57','Gummy','kirakira','https://static.wikia.nocookie.net/prettycure/images/8/80/KKPCALM_01_Gummy%27s_second_form.png','pink','Pink kirakira cure max hp+30%','{\"hp_max\":30}','2022-02-02 11:49:02');
INSERT INTO `enemy_data` VALUES('58','Pulupulu','kirakira','https://static.wikia.nocookie.net/prettycure/images/f/f7/Pulupulu%27s_second_form.png','yellow','Yellow kirakira cure start with 20% special point','{\"sp\":2}','2022-02-02 11:49:24');
INSERT INTO `enemy_data` VALUES('59','Hotto','kirakira','https://static.wikia.nocookie.net/prettycure/images/a/af/KKPCALM03_Hotto%27s_second_form.jpg','blue','Blue kirakira cure atk+30%','{\"atk\":30}','2022-02-02 11:51:13');
INSERT INTO `enemy_data` VALUES('6','Book','splash_star','https://static.wikia.nocookie.net/prettycure/images/f/fa/FwPCSS05_-_Uzaina.png','pink,white','Splash star cure max hp+30%','{\"hp_max\":30}','2022-02-02 10:26:07');
INSERT INTO `enemy_data` VALUES('60','Maquillon','kirakira','https://static.wikia.nocookie.net/prettycure/images/b/bd/Maquillon_appears.png','purple','Purple kirakira cure max hp+30%','{\"hp_max\":30}','2022-02-02 11:52:49');
INSERT INTO `enemy_data` VALUES('61','Bitard','kirakira','https://static.wikia.nocookie.net/prettycure/images/b/b3/KKPCALM06_Bitard_power_up.png','red','Red kirakira cure atk+30%','{\"atk\":30}','2022-02-02 11:54:32');
INSERT INTO `enemy_data` VALUES('62','Cookacookie','kirakira','https://static.wikia.nocookie.net/prettycure/images/c/c0/KKPCALM09_Cookacookie_powerup_the_second.png','green','Green kirakira cure max hp+30%','{\"hp_max\":30}','2022-02-02 11:57:19');
INSERT INTO `enemy_data` VALUES('63','Clock','hugtto','https://static.wikia.nocookie.net/prettycure/images/d/d6/HuPC01_Oshimaid%C4%81.png','pink','Pink huggto cure start with 20% special point','{\"sp\":2}','2022-02-02 11:58:35');
INSERT INTO `enemy_data` VALUES('64','Vending Machine','hugtto','https://static.wikia.nocookie.net/prettycure/images/b/bc/HuPC12_Oshimaida.jpg','pink,blue,yellow','Pink/blue/yellow huggto cure atk+30%','{\"atk\":30}','2022-02-02 12:00:23');
INSERT INTO `enemy_data` VALUES('65','Trolley','hugtto','https://static.wikia.nocookie.net/prettycure/images/3/36/HuPC14_Oshimaida.jpg','pink,blue,yellow','Pink/blue/yellow huggto max hp+30%','{\"hp_max\":30}','2022-02-02 12:01:10');
INSERT INTO `enemy_data` VALUES('66','Balloon','hugtto','https://static.wikia.nocookie.net/prettycure/images/7/7a/Oshimaida_03.jpg','pink','Pink huggto cure max hp+30%','{\"hp_max\":30}','2022-02-02 12:01:55');
INSERT INTO `enemy_data` VALUES('67','Refracting Telescope','star_twinkle','https://static.wikia.nocookie.net/prettycure/images/c/cd/STPC06_Nottoriga.jpg','pink,green','Pink/green star twinkle cure max hp+30%','{\"hp_max\":30}','2022-02-02 12:07:14');
INSERT INTO `enemy_data` VALUES('68','Student Council','star_twinkle','https://static.wikia.nocookie.net/prettycure/images/9/95/STPC09_Nottoreiga.jpeg','purple','Purple star twinkle cure start with 20% special point','{\"sp\":2}','2022-02-02 12:08:20');
INSERT INTO `enemy_data` VALUES('69','Video Camera','star_twinkle','https://static.wikia.nocookie.net/prettycure/images/b/b9/STPC12_Nottoriga.jpeg','pink,green,purple,yellow','Pink/green/purple/yellow star twinkle cure atk+30%','{\"atk\":30}','2022-02-02 12:09:31');
INSERT INTO `enemy_data` VALUES('7','Seaweed','splash_star','https://static.wikia.nocookie.net/prettycure/images/d/db/FwPCSS06_-_Uzaina.png','pink,white','Splash star cure start with 20% special point','{\"sp\":2}','2022-02-02 10:26:39');
INSERT INTO `enemy_data` VALUES('70','Aiwarn','star_twinkle','https://static.wikia.nocookie.net/prettycure/images/7/7f/STPC20_Aiwarn%27s_Nottoriga_form.jpg','blue','Blue star twinkle cure atk+30%','{\"atk\":30}','2022-02-02 14:03:34');
INSERT INTO `enemy_data` VALUES('71','Flower Element Spirit','healin_good','https://static.wikia.nocookie.net/prettycure/images/a/ab/HGPC01_Megabyogen.png','pink','Pink healin good max hp+30%','{\"hp_max\":30}','2022-02-02 12:10:30');
INSERT INTO `enemy_data` VALUES('72','Water Element Spirit','healin_good','https://static.wikia.nocookie.net/prettycure/images/0/05/HGPC03_Megabyogen.jpg','blue','Blue healin good cure atk+30%','{\"atk\":30}','2022-02-02 12:11:16');
INSERT INTO `enemy_data` VALUES('73','Light Element Spirit','healin_good','https://static.wikia.nocookie.net/prettycure/images/f/f0/HGPC04_This_episode%27s_Megabyogen.jpg','yellow','Yellow healin good cure start with 20% special point','{\"sp\":2}','2022-02-02 12:11:49');
INSERT INTO `enemy_data` VALUES('74','Tree Element Spirit','healin_good','https://static.wikia.nocookie.net/prettycure/images/4/4e/HGPC02_Megabyogen.jpg','pink','Pink healin good cure atk+30%','{\"atk\":30}','2022-02-02 12:13:15');
INSERT INTO `enemy_data` VALUES('75','Palm Tree','tropical_rouge','https://static.wikia.nocookie.net/prettycure/images/c/c8/TRPC01_Yaraneeda.jpg','pink','Pink tropical rouge cure atk+30%','{\"atk\":30}','2022-02-02 12:15:15');
INSERT INTO `enemy_data` VALUES('76','Dogu','tropical_rouge','https://static.wikia.nocookie.net/prettycure/images/c/ca/TRPC04_Yaraneeda.jpg','yellow','Yellow tropical rouge cure start with 20% special point','{\"sp\":2}','2022-02-02 12:16:08');
INSERT INTO `enemy_data` VALUES('77','Totem Pole','tropical_rouge','https://static.wikia.nocookie.net/prettycure/images/4/40/TRPC05_Yaraneeda.jpg','red','Red tropical rouge cure atk+30%','{\"atk\":30}','2022-02-02 12:16:34');
INSERT INTO `enemy_data` VALUES('78','Film Light','tropical_rouge','https://static.wikia.nocookie.net/prettycure/images/d/d1/TRPC09_Yaraneeda.jpg','purple','Purple tropical rouge cure max hp+30%','{\"hp_max\":30}','2022-02-02 12:17:06');
INSERT INTO `enemy_data` VALUES('79','English Text Book','tropical_rouge','https://static.wikia.nocookie.net/prettycure/images/7/73/TRPC10_Zenzen_Yaraneeda.jpg','pink,yellow,red,purple','Tropical rouge cure atk+30%','{\"atk\":30}','2022-02-02 12:17:46');
INSERT INTO `enemy_data` VALUES('8','Bookcase','yes5gogo','https://static.wikia.nocookie.net/prettycure/images/9/97/Hoshina.01.png','pink','Pink yes 5 cure atk+30%','{\"atk\":30}','2022-02-02 10:32:43');
INSERT INTO `enemy_data` VALUES('9','Stone Stoves','yes5gogo','https://static.wikia.nocookie.net/prettycure/images/3/36/-3.png','yellow','Yellow yes 5 cure max hp+30%','{\"hp_max\":30}','2022-02-02 10:33:13');
INSERT INTO `item_data_equip` VALUES('eq001','Heartful Communes','max_heart','nagisa,honoka','Heartful Communes',NULL,'2022-02-01 22:37:41');
INSERT INTO `item_data_equip` VALUES('eq002','Touch Commune','max_heart','hikari','Touch Commune',NULL,'2022-02-01 22:38:55');
INSERT INTO `item_data_equip` VALUES('eq003','Mix Communes','splash_star','saki,mai','Mix Communes',NULL,'2022-02-01 22:44:57');
INSERT INTO `item_data_equip` VALUES('eq004','CureMo','yes5gogo','nozomi,karen,urara,komachi','CureMo',NULL,'2022-02-01 22:46:17');
INSERT INTO `item_data_equip` VALUES('eq005','Milky Palette','yes5gogo','kurumi','Milky Palette',NULL,'2022-02-01 23:02:03');
INSERT INTO `item_data_equip` VALUES('eq006','Linkrun','fresh','love,miki,inori','Linkrun',NULL,'2022-02-01 23:02:51');
INSERT INTO `item_data_equip` VALUES('eq007','Passion Harp','fresh','setsuna','Passion Harp',NULL,'2022-02-01 23:04:06');
INSERT INTO `item_data_equip` VALUES('eq008','Heart perfumes','heartcatch','tsubomi,erika,itsuki','Heart perfumes',NULL,'2022-02-01 23:04:26');
INSERT INTO `item_data_equip` VALUES('eq009','Heart Pot','heartcatch','yuri','Heart Pot',NULL,'2022-02-01 23:06:41');
INSERT INTO `item_data_equip` VALUES('eq010','Cure Modules','suite','hibiki,kanade,ako,ellen','Cure Modules',NULL,'2022-02-01 23:08:03');
INSERT INTO `item_data_equip` VALUES('eq011','Smile Pact','smile','miyuki,reika,yayoi,nao,akane','Smile Pact',NULL,'2022-02-01 23:12:38');
INSERT INTO `item_data_equip` VALUES('eq012','Cure Loveads','dokidoki','mana,rikka,alice,makoto','Cure Loveads',NULL,'2022-02-01 23:17:11');
INSERT INTO `item_data_equip` VALUES('eq013','Love Eyes Palette','dokidoki','aguri','Love Eyes Palette',NULL,'2022-02-01 23:17:42');
INSERT INTO `item_data_equip` VALUES('eq014','PreChanMirror','happiness_charge','megumi,hime,yuko,iona','PreChanMirror',NULL,'2022-02-01 23:18:46');
INSERT INTO `item_data_equip` VALUES('eq015','Princess Perfume','go_princess','haruka,minami,kirara,towa','Princess Perfume',NULL,'2022-02-01 23:19:29');
INSERT INTO `item_data_equip` VALUES('eq016','Linkle Sticks','mahou_tsukai','mirai,riko','Linkle Sticks',NULL,'2022-02-01 23:24:22');
INSERT INTO `item_data_equip` VALUES('eq017','Flower Echo Wand','mahou_tsukai','kotoha','Flower Echo Wand',NULL,'2022-02-01 23:24:38');
INSERT INTO `item_data_equip` VALUES('eq018','Sweets Pact','kirakira','ichika,aoi,himari,yukari,akira,ciel','Sweets Pact',NULL,'2022-02-01 23:25:50');
INSERT INTO `item_data_equip` VALUES('eq019','Preheart','hugtto','hana,saaya,homare,emiru,ruru','Preheart',NULL,'2022-02-01 23:26:57');
INSERT INTO `item_data_equip` VALUES('eq020','Star Color Pendant','star_twinkle','hikaru,yuni,elena,lala,madoka','Star Color Pendant',NULL,'2022-02-01 23:27:28');
INSERT INTO `item_data_equip` VALUES('eq021','Healing Stick','healin_good','nodoka,chiyu,hinata','Healing Stick',NULL,'2022-02-01 23:27:54');
INSERT INTO `item_data_equip` VALUES('eq022','Tropical Pact','tropical_rouge','manatsu,sango,minori,asuka','Tropical Pact',NULL,'2022-02-01 23:28:21');
INSERT INTO `item_data_equip` VALUES('eq023','Sparkle Bracelets','max_heart','nagisa,honoka','Sparkle Bracelets',NULL,'2022-02-01 23:29:28');
INSERT INTO `item_data_equip` VALUES('eq024','Heart Baton','max_heart','hikari','Heart Baton',NULL,'2022-02-01 23:29:49');
INSERT INTO `item_data_equip` VALUES('eq025','Spiral Rings','splash_star','saki,mai','Spiral Rings',NULL,'2022-02-01 23:30:32');
INSERT INTO `item_data` VALUES('cfrg016','Card Fragment - Tropical Rouge',NULL,'misc_fragment','0','0','{\"mofucoin\":0}',NULL,'Card fragment for **tropical rouge** series.',NULL,NULL,'2022-01-11 18:14:04');
INSERT INTO `item_data` VALUES('eq030','Cure module',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:44:32');
INSERT INTO `item_data` VALUES('eq031','Miracle Belltier',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:44:42');
INSERT INTO `item_data` VALUES('eq032','Love Guitar Rod',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:44:50');
INSERT INTO `item_data` VALUES('eq033','Fantastic Belltier',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:44:59');
INSERT INTO `item_data` VALUES('eq034','Smile pact',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:45:08');
INSERT INTO `item_data` VALUES('eq035','Princess Candle',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:45:16');
INSERT INTO `item_data` VALUES('eq036','Cure Loveads',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:45:25');
INSERT INTO `item_data` VALUES('eq037','Magical Lovely Harp',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:45:39');
INSERT INTO `item_data` VALUES('eq038','Love Heart Arrow (Heart)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:48:00');
INSERT INTO `item_data` VALUES('eq039','Love Heart Arrow (Diamond)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:48:10');
INSERT INTO `item_data` VALUES('eq040','Love Heart Arrow (Rosetta)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:48:24');
INSERT INTO `item_data` VALUES('eq041','Love Heart Arrow (Sword)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:48:36');
INSERT INTO `item_data` VALUES('eq042','Love Eyes Palette',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:48:49');
INSERT INTO `item_data` VALUES('eq043','Love Kiss Rouge',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:49:14');
INSERT INTO `item_data` VALUES('eq044','PreChanMirror',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:49:29');
INSERT INTO `item_data` VALUES('eq045','LovePreBrace',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:50:42');
INSERT INTO `item_data` VALUES('eq046','Triple dance honey baton',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:50:53');
INSERT INTO `item_data` VALUES('eq047','Fortune Tambourine',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:51:03');
INSERT INTO `item_data` VALUES('eq048','Princess Perfume',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:51:15');
INSERT INTO `item_data` VALUES('eq049','Crystal Princess Rods',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:51:25');
INSERT INTO `item_data` VALUES('eq050','Scarlet Violin',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:51:35');
INSERT INTO `item_data` VALUES('eq051','Linkle Sticks',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:51:45');
INSERT INTO `item_data` VALUES('eq052','Flower Echo Wand',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:51:56');
INSERT INTO `item_data` VALUES('eq053','Sweets Pact',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:52:06');
INSERT INTO `item_data` VALUES('eq054','Candy Rod (Whip)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:52:14');
INSERT INTO `item_data` VALUES('eq055','Candy Rod (Gelato)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:52:27');
INSERT INTO `item_data` VALUES('eq056','Candy Rod (Custard)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:52:34');
INSERT INTO `item_data` VALUES('eq057','Candy Rod (Chocolat)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:52:45');
INSERT INTO `item_data` VALUES('eq058','Candy Rod (Parfait)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:52:55');
INSERT INTO `item_data` VALUES('eq059','Rainbow Ribbon',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:53:34');
INSERT INTO `item_data` VALUES('eq060','Preheart (Yell)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:53:45');
INSERT INTO `item_data` VALUES('eq061','Yell Tact',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:53:53');
INSERT INTO `item_data` VALUES('eq062','PreHeart (Ange)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:54:02');
INSERT INTO `item_data` VALUES('eq063','Ange Harp',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:54:11');
INSERT INTO `item_data` VALUES('eq064','PreHeart (Etoile)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:54:22');
INSERT INTO `item_data` VALUES('eq065','Etoile Flute',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:54:45');
INSERT INTO `item_data` VALUES('eq066','PreHeart (Macherie)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:54:58');
INSERT INTO `item_data` VALUES('eq067','Macherie Bazooka',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:55:08');
INSERT INTO `item_data` VALUES('eq068','PreHeart (Amour)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:55:16');
INSERT INTO `item_data` VALUES('eq069','Amour Arrow',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:55:25');
INSERT INTO `item_data` VALUES('eq070','Star Color Pendant',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:55:35');
INSERT INTO `item_data` VALUES('eq071','Twinkle Stick',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:55:45');
INSERT INTO `item_data` VALUES('eq072','Rainbow Perfume',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:55:55');
INSERT INTO `item_data` VALUES('eq073','Healing Stick',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:56:04');
INSERT INTO `item_data` VALUES('eq074','Tropical Pact',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:56:13');
INSERT INTO `item_data` VALUES('eq075','Heart Kuru Ring (Summer)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:56:24');
INSERT INTO `item_data` VALUES('eq076','Heart Rouge Rod (Summer)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:56:34');
INSERT INTO `item_data` VALUES('eq077','Heart Kuru Ring (Coral)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:56:43');
INSERT INTO `item_data` VALUES('eq078','Heart Rouge Rod (Coral)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:56:54');
INSERT INTO `item_data` VALUES('eq079','Heart Kuru Ring (Papaya)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:58:28');
INSERT INTO `item_data` VALUES('eq080','Heart Rouge Rod (Papaya)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:58:37');
INSERT INTO `item_data` VALUES('eq081','Heart Kuru Ring (Flamingo)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:58:47');
INSERT INTO `item_data` VALUES('eq082','Heart Rouge Rod (Flamingo)',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:58:55');
INSERT INTO `item_data` VALUES('eqaqcu','Aqua CureMo',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:39:56');
INSERT INTO `item_data` VALUES('eqberro','Berry rod',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:43:06');
INSERT INTO `item_data` VALUES('eqblota','Blossom tact',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:43:57');
INSERT INTO `item_data` VALUES('eqcryfl','Crystal Fleuret',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:39:41');
INSERT INTO `item_data` VALUES('eqdrecu','Dream CureMo',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:39:28');
INSERT INTO `item_data` VALUES('eqfirfl','Fire Fleuret',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:42:33');
INSERT INTO `item_data` VALUES('eqheaba','Heart Baton',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:37:32');
INSERT INTO `item_data` VALUES('eqheabr','Heartiel Brooch',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:37:50');
INSERT INTO `item_data` VALUES('eqheaco','Heartful Communes',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:31:55');
INSERT INTO `item_data` VALUES('eqheape','Heart perfumes',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:43:48');
INSERT INTO `item_data` VALUES('eqlemcu','Lemonade CureMo',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:40:29');
INSERT INTO `item_data` VALUES('eqlinkrun','Linkrun',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:42:43');
INSERT INTO `item_data` VALUES('eqmarta','Marine tact',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:44:05');
INSERT INTO `item_data` VALUES('eqmico','Mix communes',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:38:01');
INSERT INTO `item_data` VALUES('eqmilmi','Milky Mirror',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:41:53');
INSERT INTO `item_data` VALUES('eqmilpa','Milky Palette',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:41:29');
INSERT INTO `item_data` VALUES('eqmincu','Mint CureMo',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:42:05');
INSERT INTO `item_data` VALUES('eqmoonta','Moon Tact',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:44:22');
INSERT INTO `item_data` VALUES('eqpasha','Passion harp',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:43:35');
INSERT INTO `item_data` VALUES('eqpearo','Peach rod',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:42:57');
INSERT INTO `item_data` VALUES('eqpinfl','Pine flute',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:43:27');
INSERT INTO `item_data` VALUES('eqprofl','Protect Fleuret',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:42:14');
INSERT INTO `item_data` VALUES('eqroucu','Rouge CureMo',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:42:27');
INSERT INTO `item_data` VALUES('eqshifl','Shining Fleuret',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:41:23');
INSERT INTO `item_data` VALUES('eqshitam','Shiny Tambourine',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:44:17');
INSERT INTO `item_data` VALUES('eqspabr','Sparkle Bracelets',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:33:05');
INSERT INTO `item_data` VALUES('eqspiri','Spiral Rings',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:38:12');
INSERT INTO `item_data` VALUES('eqtorfl','Tornado Fleuret',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:40:09');
INSERT INTO `item_data` VALUES('eqtouco','Touch Commune',NULL,'equip','1','0','{\"mofucoin\":0}',NULL,NULL,NULL,NULL,'2022-01-11 14:37:17');
INSERT INTO `item_data` VALUES('it001','Sparkle Bracelets',NULL,'usable','1','0','{\"mofucoin\":100}',NULL,'Provide second chance SE','second_chance',NULL,'2021-02-25 22:46:37');
INSERT INTO `item_data` VALUES('it002','Clover Box',NULL,'usable','1','0','{\"mofucoin\":1000}','https://cdn.discordapp.com/attachments/846689371067383828/846689737171140618/latest.png','Provide lucky number SE','lucky_number',NULL,'2021-02-25 23:46:54');
INSERT INTO `item_data` VALUES('it003','Legendary Score',NULL,'usable','1','0','{\"mofucoin\":200}','https://cdn.discordapp.com/attachments/846689371067383828/846691424496910346/latest.png','Remove debuff/clear SE','clear_status_all',NULL,'2021-02-26 15:00:13');
INSERT INTO `item_data` VALUES('it004','Linkle Smartbook: Fear',NULL,'usable','1','0','{\"mofucoin\":10}',NULL,'Remove fear debuff','remove_debuff_fear',NULL,'2021-03-05 01:28:30');
INSERT INTO `item_data` VALUES('it006','Heart Pot',NULL,'usable','1','0','{\"mofucoin\":40}','https://cdn.discordapp.com/attachments/846689371067383828/846692341099790356/latest.png','Provide Special Protection','precure_protection',NULL,'2021-03-05 16:40:24');
INSERT INTO `item_data` VALUES('it007','Cure Module',NULL,'usable','1','0','{\"mofucoin\":100}','https://cdn.discordapp.com/attachments/846689371067383828/846692420670193664/latest.png','Provide Special Break SE','special_break',NULL,'2021-03-19 00:59:32');
INSERT INTO `item_data` VALUES('it008','Healing Stick',NULL,'usable','1','0','{\"mofucoin\":50}',NULL,'Scan for enemy drop reward','scan_tsunagarus',NULL,'2021-04-13 12:31:32');

COMMIT;