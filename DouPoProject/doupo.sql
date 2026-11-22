/*
 Navicat Premium Dump SQL

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80045 (8.0.45)
 Source Host           : localhost:3306
 Source Schema         : doupo

 Target Server Type    : MySQL
 Target Server Version : 80045 (8.0.45)
 File Encoding         : 65001

 Date: 22/11/2026 19:17:20
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for t_collect
-- ----------------------------
DROP TABLE IF EXISTS `t_collect`;
CREATE TABLE `t_collect`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户',
  `item_id` bigint NOT NULL COMMENT '图鉴条目',
  `note` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '私人笔记',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收服时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_item`(`user_id` ASC, `item_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收藏/收服记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_collect
-- ----------------------------
INSERT INTO `t_collect` VALUES (2, 2, 4, '', '2026-11-19 21:09:47');
INSERT INTO `t_collect` VALUES (5, 2, 11, '', '2026-11-19 21:09:47');
INSERT INTO `t_collect` VALUES (6, 2, 13, '焚决一定要练成第三步', '2026-11-19 21:09:47');
INSERT INTO `t_collect` VALUES (8, 2, 10, '', '2026-11-19 21:19:24');
INSERT INTO `t_collect` VALUES (12, 2, 1, '', '2026-11-19 21:38:42');
INSERT INTO `t_collect` VALUES (15, 3, 3, '', '2026-11-19 21:55:52');
INSERT INTO `t_collect` VALUES (16, 3, 2, '', '2026-11-19 21:56:03');
INSERT INTO `t_collect` VALUES (18, 3, 4, '', '2026-11-19 21:56:05');
INSERT INTO `t_collect` VALUES (19, 3, 5, '', '2026-11-19 21:56:05');
INSERT INTO `t_collect` VALUES (20, 3, 6, '', '2026-11-19 21:56:06');
INSERT INTO `t_collect` VALUES (21, 3, 9, '', '2026-11-19 21:56:30');
INSERT INTO `t_collect` VALUES (23, 3, 1, '', '2026-11-19 23:30:56');
INSERT INTO `t_collect` VALUES (24, 3, 11, '', '2026-11-20 12:17:05');
INSERT INTO `t_collect` VALUES (25, 2, 2, '123', '2026-11-20 20:03:01');
INSERT INTO `t_collect` VALUES (26, 2, 3, '', '2026-11-21 17:03:06');
INSERT INTO `t_collect` VALUES (27, 2, 8, '', '2026-11-21 17:03:47');
INSERT INTO `t_collect` VALUES (28, 2, 5, '', '2026-11-21 17:03:54');

-- ----------------------------
-- Table structure for t_comment
-- ----------------------------
DROP TABLE IF EXISTS `t_comment`;
CREATE TABLE `t_comment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `item_id` bigint NOT NULL COMMENT '图鉴条目',
  `user_id` bigint NOT NULL COMMENT '用户',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '昵称快照',
  `content` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评论内容',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_item`(`item_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '异火评论' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_comment
-- ----------------------------
INSERT INTO `t_comment` VALUES (1, 1, 2, '炎帝', '异火榜第一，名副其实。', '2026-11-19 21:09:47', 0);
INSERT INTO `t_comment` VALUES (2, 1, 1, '丹塔长老', '陀舍古帝留下的东西，不是谁都能碰的。', '2026-11-19 21:09:47', 0);
INSERT INTO `t_comment` VALUES (3, 4, 2, '炎帝', '我的第一道异火，感情最深。', '2026-11-19 21:09:47', 0);
INSERT INTO `t_comment` VALUES (4, 8, 1, '丹塔长老', '老师当年就是靠它撑着灵魂。', '2026-11-19 21:09:47', 0);

-- ----------------------------
-- Table structure for t_draw
-- ----------------------------
DROP TABLE IF EXISTS `t_draw`;
CREATE TABLE `t_draw`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户',
  `item_id` bigint NOT NULL COMMENT '抽到的条目',
  `draw_date` date NOT NULL COMMENT '抽卡日期（用于每日次数限制）',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_date`(`user_id` ASC, `draw_date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '异火降临抽卡记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_draw
-- ----------------------------
INSERT INTO `t_draw` VALUES (5, 3, 2, '2026-11-19', '2026-11-19 21:56:20');
INSERT INTO `t_draw` VALUES (6, 3, 9, '2026-11-19', '2026-11-19 21:56:30');
INSERT INTO `t_draw` VALUES (7, 3, 2, '2026-11-19', '2026-11-19 21:56:36');
INSERT INTO `t_draw` VALUES (8, 3, 3, '2026-11-20', '2026-11-20 12:16:55');
INSERT INTO `t_draw` VALUES (9, 3, 4, '2026-11-20', '2026-11-20 12:17:01');
INSERT INTO `t_draw` VALUES (10, 3, 11, '2026-11-20', '2026-11-20 12:17:05');
INSERT INTO `t_draw` VALUES (11, 2, 2, '2026-11-20', '2026-11-20 20:06:35');

-- ----------------------------
-- Table structure for t_item
-- ----------------------------
DROP TABLE IF EXISTS `t_item`;
CREATE TABLE `t_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '名称',
  `category` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类：异火/功法/斗技/丹药/法宝',
  `grade` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '品阶：黄阶/玄阶/地阶/天阶',
  `rank_no` int NOT NULL DEFAULT 0 COMMENT '异火榜排名，0=未上榜',
  `difficulty` tinyint NOT NULL DEFAULT 3 COMMENT '收服难度 1-5',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '简介',
  `form_desc` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '异火形态',
  `holders` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '历代持有者（逗号分隔）',
  `method` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '收服功法',
  `quote` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '经典台词',
  `color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'gold' COMMENT '主色：gold/black/pink/green/blue/ice/purple/red',
  `icon` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '图标（emoji）',
  `image` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'fire art path',
  `source` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '出处',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0=正常，1=已删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_grade`(`grade` ASC) USING BTREE,
  INDEX `idx_rank`(`rank_no` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '异火图鉴条目表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_item
-- ----------------------------
INSERT INTO `t_item` VALUES (1, '帝炎', '异火', '天阶', 1, 5, '异火榜第一，万火之帝。陀舍古帝本体所化，可统御世间一切异火，得之者可窥斗帝之门。', '金色帝座之形，焰中隐有帝王虚影，万火朝拜', '陀舍古帝,萧炎', '焚决·万火归一', '万火之中，我为帝君。', 'gold', '🔥', '/fire/diyan.jpg', '异火榜', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (2, '虚无吞炎', '异火', '天阶', 2, 5, '异火榜第二，无形无质，可吞噬万物斗气乃至灵魂，魂族至宝。', '漆黑雾焰，无固定形态，靠近时斗气自发溃散', '魂天帝,虚无', '魂族秘法·吞天', '我看不见，可我能吞下你的一切。', 'black', '🌫️', '/fire/xuwu.jpg', '异火榜', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (3, '净莲妖火', '异火', '天阶', 3, 5, '异火榜第三，莲花状火焰，可净化一切污秽与异火，妖火本源诞于天地初开。', '粉白莲台，层层绽放，花瓣皆为实质火焰', '净莲妖圣,萧炎', '焚决·莲华净世', '花开一瞬，焚尽执念。', 'pink', '🌸', '/fire/jinglian.jpg', '异火榜', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (4, '金帝焚天炎', '异火', '天阶', 4, 5, '异火榜第四，金色圣焰，古族镇族异火，可焚天裂地。', '炽金日轮，热浪扭曲空间', '古元,古族', '古族秘法·焚天', '金焰所至，寸草不生。', 'gold', '☀️', '/fire/jindi.jpg', '异火榜', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (5, '生灵之焱', '异火', '天阶', 5, 4, '异火榜第五，蕴含磅礴生机，可生死人肉白骨，亦可焚尽生机。', '碧绿萤火，明灭如呼吸，所过之处草木疯长', '药尘,神农老人', '炼药术·生机引', '生与死，不过一缕绿焰。', 'green', '🌿', '/fire/shengling.jpg', '异火榜', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (6, '八荒破灭炎', '异火', '天阶', 6, 4, '异火榜第六，传说可焚尽八荒的赤色烈焰。', '赤红巨浪，焰尾拖曳如龙', '炎族', '炎族秘法·八荒', '八荒之内，唯火独尊。', 'red', '🔥', '/fire/bahuang.jpg', '异火榜', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (7, '九幽风炎', '异火', '天阶', 7, 4, '异火榜第七，生于九幽之风，风助火势，火借风威。', '幽紫旋风裹焰，无声无形', '风尊者', '风系斗气·御风', '风起时，火已至。', 'purple', '🌪️', '/fire/jiuyou.jpg', '异火榜', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (8, '骨灵冷火', '异火', '天阶', 8, 4, '极寒之火，药尘本命异火，火焰之中蕴含极寒之力，可冻结斗气。', '森白焰骨，焰心呈骨骼状，触之刺骨', '药尘,萧炎', '焚决·寒焰炼骨', '冷到极致，也是燃烧。', 'ice', '❄️', '/fire/guling.jpg', '异火榜', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (9, '三千焱炎火', '异火', '天阶', 9, 4, '星域之中诞生的星辰之火，可焚天煮海，星陨之后仍不灭。', '紫金星辰碎焰，如银河倾泻', '药尘,萧炎', '焚决·星辰引', '星落成灰，我自长明。', 'purple', '✨', '/fire/sanqian.jpg', '异火榜', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (10, '青莲地心火', '异火', '地阶', 19, 3, '生于地心岩浆，青莲形态，萧炎第一道异火，可借莲台之力温养斗气。', '青色莲台悬浮，花瓣缓缓开合', '萧炎', '焚决·青莲变', '从今日起，我也有异火了。', 'green', '🌱', '/fire/qinglian.jpg', '异火榜', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (11, '陨落心炎', '异火', '地阶', 14, 3, '天焚炼气塔下孕育，可淬炼斗气与灵魂，陨落之焰愈燃愈烈。', '幽蓝心形焰，焰心如心脏搏动', '萧炎', '焚决·心炎淬体', '陨落之地，亦可重生。', 'blue', '💠', '/fire/yunluo.jpg', '异火榜', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (12, '海心焰', '异火', '地阶', 16, 3, '深海之底孕育的蓝色火焰，水属性异火，遇水不灭反炽。', '深蓝水纹焰，流动如水', '海波东', '水系斗气·驭海', '海再深，也压不住一团火。', 'blue', '🌊', '/fire/haixin.jpg', '异火榜', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (13, '焚决', '功法', '天阶', 0, 5, '萧炎核心功法，可吞噬异火不断进化，是通往斗帝之路的钥匙。', '', '萧炎', '自创', '吞尽天下异火，方成我道。', 'red', '📜', '', '萧炎', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (14, '天火三玄变', '功法', '地阶', 0, 3, '焚决配套秘法，以异火为引，短时间爆发数倍战力。', '', '萧厉,萧炎', '焚决衍生', '三变更迭，战力翻涌。', 'gold', '📜', '', '萧厉', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (15, '青木诀', '功法', '黄阶', 0, 1, '木属性基础功法，修炼缓慢但根基稳固，萧炎少年所修。', '', '萧炎', '迦南学院', '慢一点，也总能到。', 'green', '📗', '', '迦南学院', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (16, '大天造化掌', '斗技', '天阶', 0, 5, '造化圣者所创，一掌之下可碎山河，蕴含造化之力。', '', '造化圣者', '造化之力', '一掌之间，自成天地。', 'gold', '🖐️', '', '造化圣者', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (17, '焰分噬浪尺', '斗技', '地阶', 0, 3, '玄重尺配合斗气施展，一尺劈开浪潮，重压如山。', '', '萧炎', '玄重尺', '尺落之处，浪亦低头。', 'red', '⚔️', '', '萧炎', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (18, '八极崩', '斗技', '玄阶', 0, 2, '以斗气震荡八方的近身斗技，刚猛霸道，萧炎早期成名技。', '', '萧炎', '近身斗气', '八方皆崩，退无可退。', 'gold', '💥', '', '萧炎', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (19, '吸掌', '斗技', '黄阶', 0, 1, '入门斗技，隔空吸物，萧炎少年所学。', '', '萧炎', '基础斗气', '先学会拿，才学会放。', 'ice', '🌀', '', '萧家', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (20, '九转斗尊强体丹', '丹药', '天阶', 0, 4, '助斗者突破斗尊的极品丹药，药尘亲炼，九转丹纹。', '', '药尘', '炼药术', '丹成九转，肉身如铁。', 'gold', '💊', '', '药尘', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (21, '破厄丹', '丹药', '地阶', 0, 3, '可解开绝大多数斗气封锁与奇毒。', '', '丹塔', '炼药术', '一丹破厄，万毒皆消。', 'green', '💊', '', '丹塔', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (22, '三纹青灵丹', '丹药', '玄阶', 0, 2, '提升斗气修为，丹成三纹为上品。', '', '丹塔', '炼药术', '纹数即品，丹亦有灵。', 'green', '🧪', '', '丹塔', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (23, '聚气散', '丹药', '黄阶', 0, 1, '低阶修炼者常用，聚集天地斗气。', '', '药铺', '基础炼药', '聚沙成塔，聚气成海。', 'blue', '🧂', '', '药铺', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (24, '玄重尺', '法宝', '地阶', 0, 3, '黑铁所铸重尺，蕴含重量压制之力，萧炎随身兵器。', '', '萧炎', '重压之道', '尺重如山，心轻如羽。', 'black', '🗡️', '', '萧炎', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (25, '黑魔鼎', '法宝', '天阶', 0, 4, '药尘遗留的炼药古鼎，炼药成功率大增。', '', '药尘', '炼药术', '鼎中天地，可炼乾坤。', 'black', '⚗️', '', '药尘', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (26, '纳戒', '法宝', '玄阶', 0, 2, '内含空间的低阶储物戒指，行走大陆必备。', '', '萧炎,药尘', '空间之道', '戒中无岁月，纳尽行囊。', 'gold', '💍', '', '坊市', '2026-11-19 21:09:47', 0);
INSERT INTO `t_item` VALUES (27, '魔兽山脉短刃', '法宝', '黄阶', 0, 1, '魔兽山脉流传的普通防身兵器。', '', '佣兵', '基础兵器', '刀钝，也要敢拔。', 'ice', '🔪', '', '魔兽山脉', '2026-11-19 21:09:47', 0);

-- ----------------------------
-- Table structure for t_user
-- ----------------------------
DROP TABLE IF EXISTS `t_user`;
CREATE TABLE `t_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码（明文，按需求不加密）',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '昵称/道号',
  `role` tinyint NOT NULL DEFAULT 1 COMMENT '权限：1=默认权限，0=管理员权限',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=正常，0=禁用',
  `sign_days` int NOT NULL DEFAULT 0 COMMENT '累计签到天数',
  `talent` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '灵魂力天赋（属性·职业）',
  `talent_rank` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '天赋评级',
  `talent_score` int NOT NULL DEFAULT 0 COMMENT '灵魂力强度',
  `last_sign_date` date NULL DEFAULT NULL COMMENT '最近签到日期',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最近登录时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of t_user
-- ----------------------------
INSERT INTO `t_user` VALUES (1, 'admin', '123456', '丹塔长老', 0, 1, 12, '木属性·天生炼药师', '极品', 91, NULL, '2026-11-21 17:08:17', '2026-11-19 21:09:47');
INSERT INTO `t_user` VALUES (2, 'xiaoyan', '123456', '炎帝', 1, 1, 8, '土属性·铸器宗师', '良品', 79, '2026-11-21', '2026-11-22 18:55:19', '2026-11-19 21:09:47');
INSERT INTO `t_user` VALUES (3, 'www', '123456', 'www', 1, 1, 1, '', '', 0, '2026-11-20', '2026-11-22 12:24:10', '2026-11-19 21:55:30');
INSERT INTO `t_user` VALUES (4, 'test_451052', '123456', 'test_451052', 1, 1, 0, '火属性·烈焰丹师', '极品', 93, NULL, '2026-11-20 13:27:31', '2026-11-20 13:27:31');
INSERT INTO `t_user` VALUES (5, 'plain_451087', '123456', 'plain_451087', 1, 1, 0, '', '', 0, NULL, NULL, '2026-11-20 13:27:31');
INSERT INTO `t_user` VALUES (6, 'tp_483173', '123456', 'tp_483173', 1, 1, 0, '火属性·狂暴斗者', '天品', 84, NULL, '2026-11-20 13:28:07', '2026-11-20 13:28:03');
INSERT INTO `t_user` VALUES (7, 'tp_592097', '123456', 'tp_592097', 1, 1, 0, '火属性·狂暴斗者', '天品', 82, NULL, '2026-11-20 13:29:56', '2026-11-20 13:29:52');
INSERT INTO `t_user` VALUES (8, 'tp_648352', '123456', 'tp_648352', 1, 1, 0, '火属性·狂暴斗者', '天品', 82, NULL, '2026-11-20 13:30:52', '2026-11-20 13:30:48');
INSERT INTO `t_user` VALUES (9, 'tp_698647', '123456', 'tp_698647', 1, 1, 0, '火属性·狂暴斗者', '天品', 85, NULL, '2026-11-20 13:31:43', '2026-11-20 13:31:39');

SET FOREIGN_KEY_CHECKS = 1;
