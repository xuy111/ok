-- ============================================================
-- 斗破苍穹 · 异火图鉴  数据库脚本  v2
-- MySQL 8.x   数据库：doupo   字符集：utf8mb4
-- 导入：mysql -u root -p123456 --default-character-set=utf8mb4 < doupo.sql
-- 说明：用户密码按需求存明文；role = 1 默认权限，role = 0 管理员权限
-- v2 新增：异火详情字段（榜单排名/收服难度/持有者/功法/台词/形态/主色）、
--          收藏(收服)、评论、抽卡记录，用户增加签到天数
-- ============================================================

CREATE DATABASE IF NOT EXISTS doupo DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE doupo;

-- ------------------------------------------------------------
-- 用户表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_user;
CREATE TABLE t_user (
  id              BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  username        VARCHAR(50)  NOT NULL               COMMENT '用户名',
  password        VARCHAR(100) NOT NULL               COMMENT '密码（明文，按需求不加密）',
  nickname        VARCHAR(50)  DEFAULT ''             COMMENT '昵称/道号',
  role            TINYINT      NOT NULL DEFAULT 1      COMMENT '权限：1=默认权限，0=管理员权限',
  status          TINYINT      NOT NULL DEFAULT 1      COMMENT '状态：1=正常，0=禁用',
  sign_days       INT          NOT NULL DEFAULT 0      COMMENT '累计签到天数',
  talent          VARCHAR(50)  DEFAULT ''             COMMENT '灵魂力天赋（属性·职业，如 木属性·天生炼药师）',
  talent_rank     VARCHAR(20)  DEFAULT ''             COMMENT '天赋评级：凡品/良品/上品/极品/天品',
  talent_score    INT          NOT NULL DEFAULT 0      COMMENT '灵魂力强度 40-99',
  last_sign_date  DATE         DEFAULT NULL            COMMENT '最近签到日期',
  last_login_time DATETIME     DEFAULT NULL            COMMENT '最近登录时间',
  create_time     DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

INSERT INTO t_user (username, password, nickname, role, sign_days) VALUES
('admin',   '123456', '丹塔长老', 0, 12),
('xiaoyan', '123456', '炎帝',     1, 6);

-- ------------------------------------------------------------
-- 图鉴条目表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_item;
CREATE TABLE t_item (
  id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  name        VARCHAR(100) NOT NULL               COMMENT '名称',
  category    VARCHAR(20)  NOT NULL               COMMENT '分类：异火/功法/斗技/丹药/法宝',
  grade       VARCHAR(20)  NOT NULL               COMMENT '品阶：黄阶/玄阶/地阶/天阶',
  rank_no     INT          NOT NULL DEFAULT 0      COMMENT '异火榜排名，0=未上榜',
  difficulty  TINYINT      NOT NULL DEFAULT 3      COMMENT '收服难度 1-5',
  description VARCHAR(500) DEFAULT ''             COMMENT '简介',
  form_desc   VARCHAR(300) DEFAULT ''             COMMENT '异火形态',
  holders     VARCHAR(200) DEFAULT ''             COMMENT '历代持有者（逗号分隔）',
  method      VARCHAR(100) DEFAULT ''             COMMENT '收服功法',
  quote       VARCHAR(300) DEFAULT ''             COMMENT '经典台词',
  color       VARCHAR(20)  DEFAULT 'gold'         COMMENT '主色：gold/black/pink/green/blue/ice/purple/red',
  icon        VARCHAR(50)  DEFAULT ''             COMMENT '图标（emoji）',
  image       VARCHAR(200) DEFAULT ''             COMMENT '异火插图（public 下的相对路径，如 /fire/diyan.jpg）',
  source      VARCHAR(100) DEFAULT ''             COMMENT '出处',
  create_time DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  deleted     TINYINT      NOT NULL DEFAULT 0      COMMENT '逻辑删除：0=正常，1=已删除',
  PRIMARY KEY (id),
  KEY idx_category (category),
  KEY idx_grade (grade),
  KEY idx_rank (rank_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='异火图鉴条目表';

INSERT INTO t_item
(name, category, grade, rank_no, difficulty, description, form_desc, holders, method, quote, color, icon, source) VALUES
('帝炎', '异火', '天阶', 1, 5,
 '异火榜第一，万火之帝。陀舍古帝本体所化，可统御世间一切异火，得之者可窥斗帝之门。',
 '金色帝座之形，焰中隐有帝王虚影，万火朝拜',
 '陀舍古帝,萧炎', '焚决·万火归一',
 '万火之中，我为帝君。', 'gold', '🔥', '异火榜'),

('虚无吞炎', '异火', '天阶', 2, 5,
 '异火榜第二，无形无质，可吞噬万物斗气乃至灵魂，魂族至宝。',
 '漆黑雾焰，无固定形态，靠近时斗气自发溃散',
 '魂天帝,虚无', '魂族秘法·吞天',
 '我看不见，可我能吞下你的一切。', 'black', '🌫️', '异火榜'),

('净莲妖火', '异火', '天阶', 3, 5,
 '异火榜第三，莲花状火焰，可净化一切污秽与异火，妖火本源诞于天地初开。',
 '粉白莲台，层层绽放，花瓣皆为实质火焰',
 '净莲妖圣,萧炎', '焚决·莲华净世',
 '花开一瞬，焚尽执念。', 'pink', '🌸', '异火榜'),

('金帝焚天炎', '异火', '天阶', 4, 5,
 '异火榜第四，金色圣焰，古族镇族异火，可焚天裂地。',
 '炽金日轮，热浪扭曲空间',
 '古元,古族', '古族秘法·焚天',
 '金焰所至，寸草不生。', 'gold', '☀️', '异火榜'),

('生灵之焱', '异火', '天阶', 5, 4,
 '异火榜第五，蕴含磅礴生机，可生死人肉白骨，亦可焚尽生机。',
 '碧绿萤火，明灭如呼吸，所过之处草木疯长',
 '药尘,神农老人', '炼药术·生机引',
 '生与死，不过一缕绿焰。', 'green', '🌿', '异火榜'),

('八荒破灭炎', '异火', '天阶', 6, 4,
 '异火榜第六，传说可焚尽八荒的赤色烈焰。',
 '赤红巨浪，焰尾拖曳如龙',
 '炎族', '炎族秘法·八荒',
 '八荒之内，唯火独尊。', 'red', '🔥', '异火榜'),

('九幽风炎', '异火', '天阶', 7, 4,
 '异火榜第七，生于九幽之风，风助火势，火借风威。',
 '幽紫旋风裹焰，无声无形',
 '风尊者', '风系斗气·御风',
 '风起时，火已至。', 'purple', '🌪️', '异火榜'),

('骨灵冷火', '异火', '天阶', 8, 4,
 '极寒之火，药尘本命异火，火焰之中蕴含极寒之力，可冻结斗气。',
 '森白焰骨，焰心呈骨骼状，触之刺骨',
 '药尘,萧炎', '焚决·寒焰炼骨',
 '冷到极致，也是燃烧。', 'ice', '❄️', '异火榜'),

('三千焱炎火', '异火', '天阶', 9, 4,
 '星域之中诞生的星辰之火，可焚天煮海，星陨之后仍不灭。',
 '紫金星辰碎焰，如银河倾泻',
 '药尘,萧炎', '焚决·星辰引',
 '星落成灰，我自长明。', 'purple', '✨', '异火榜'),

('青莲地心火', '异火', '地阶', 19, 3,
 '生于地心岩浆，青莲形态，萧炎第一道异火，可借莲台之力温养斗气。',
 '青色莲台悬浮，花瓣缓缓开合',
 '萧炎', '焚决·青莲变',
 '从今日起，我也有异火了。', 'green', '🌱', '异火榜'),

('陨落心炎', '异火', '地阶', 14, 3,
 '天焚炼气塔下孕育，可淬炼斗气与灵魂，陨落之焰愈燃愈烈。',
 '幽蓝心形焰，焰心如心脏搏动',
 '萧炎', '焚决·心炎淬体',
 '陨落之地，亦可重生。', 'blue', '💠', '异火榜'),

('海心焰', '异火', '地阶', 16, 3,
 '深海之底孕育的蓝色火焰，水属性异火，遇水不灭反炽。',
 '深蓝水纹焰，流动如水',
 '海波东', '水系斗气·驭海',
 '海再深，也压不住一团火。', 'blue', '🌊', '异火榜'),

('焚决', '功法', '天阶', 0, 5,
 '萧炎核心功法，可吞噬异火不断进化，是通往斗帝之路的钥匙。',
 '', '萧炎', '自创',
 '吞尽天下异火，方成我道。', 'red', '📜', '萧炎'),

('天火三玄变', '功法', '地阶', 0, 3,
 '焚决配套秘法，以异火为引，短时间爆发数倍战力。',
 '', '萧厉,萧炎', '焚决衍生',
 '三变更迭，战力翻涌。', 'gold', '📜', '萧厉'),

('青木诀', '功法', '黄阶', 0, 1,
 '木属性基础功法，修炼缓慢但根基稳固，萧炎少年所修。',
 '', '萧炎', '迦南学院',
 '慢一点，也总能到。', 'green', '📗', '迦南学院'),

('大天造化掌', '斗技', '天阶', 0, 5,
 '造化圣者所创，一掌之下可碎山河，蕴含造化之力。',
 '', '造化圣者', '造化之力',
 '一掌之间，自成天地。', 'gold', '🖐️', '造化圣者'),

('焰分噬浪尺', '斗技', '地阶', 0, 3,
 '玄重尺配合斗气施展，一尺劈开浪潮，重压如山。',
 '', '萧炎', '玄重尺',
 '尺落之处，浪亦低头。', 'red', '⚔️', '萧炎'),

('八极崩', '斗技', '玄阶', 0, 2,
 '以斗气震荡八方的近身斗技，刚猛霸道，萧炎早期成名技。',
 '', '萧炎', '近身斗气',
 '八方皆崩，退无可退。', 'gold', '💥', '萧炎'),

('吸掌', '斗技', '黄阶', 0, 1,
 '入门斗技，隔空吸物，萧炎少年所学。',
 '', '萧炎', '基础斗气',
 '先学会拿，才学会放。', 'ice', '🌀', '萧家'),

('九转斗尊强体丹', '丹药', '天阶', 0, 4,
 '助斗者突破斗尊的极品丹药，药尘亲炼，九转丹纹。',
 '', '药尘', '炼药术',
 '丹成九转，肉身如铁。', 'gold', '💊', '药尘'),

('破厄丹', '丹药', '地阶', 0, 3,
 '可解开绝大多数斗气封锁与奇毒。',
 '', '丹塔', '炼药术',
 '一丹破厄，万毒皆消。', 'green', '💊', '丹塔'),

('三纹青灵丹', '丹药', '玄阶', 0, 2,
 '提升斗气修为，丹成三纹为上品。',
 '', '丹塔', '炼药术',
 '纹数即品，丹亦有灵。', 'green', '🧪', '丹塔'),

('聚气散', '丹药', '黄阶', 0, 1,
 '低阶修炼者常用，聚集天地斗气。',
 '', '药铺', '基础炼药',
 '聚沙成塔，聚气成海。', 'blue', '🧂', '药铺'),

('玄重尺', '法宝', '地阶', 0, 3,
 '黑铁所铸重尺，蕴含重量压制之力，萧炎随身兵器。',
 '', '萧炎', '重压之道',
 '尺重如山，心轻如羽。', 'black', '🗡️', '萧炎'),

('黑魔鼎', '法宝', '天阶', 0, 4,
 '药尘遗留的炼药古鼎，炼药成功率大增。',
 '', '药尘', '炼药术',
 '鼎中天地，可炼乾坤。', 'black', '⚗️', '药尘'),

('纳戒', '法宝', '玄阶', 0, 2,
 '内含空间的低阶储物戒指，行走大陆必备。',
 '', '萧炎,药尘', '空间之道',
 '戒中无岁月，纳尽行囊。', 'gold', '💍', '坊市'),

('魔兽山脉短刃', '法宝', '黄阶', 0, 1,
 '魔兽山脉流传的普通防身兵器。',
 '', '佣兵', '基础兵器',
 '刀钝，也要敢拔。', 'ice', '🔪', '魔兽山脉');

-- ------------------------------------------------------------
-- 异火插图（按原著形态绘制，文件在 doupo-frontend/public/fire/）
-- ------------------------------------------------------------
UPDATE t_item SET image = '/fire/diyan.jpg'    WHERE name = '帝炎'       AND category = '异火';
UPDATE t_item SET image = '/fire/xuwu.jpg'     WHERE name = '虚无吞炎'   AND category = '异火';
UPDATE t_item SET image = '/fire/jinglian.jpg' WHERE name = '净莲妖火'   AND category = '异火';
UPDATE t_item SET image = '/fire/jindi.jpg'    WHERE name = '金帝焚天炎' AND category = '异火';
UPDATE t_item SET image = '/fire/shengling.jpg' WHERE name = '生灵之焱'  AND category = '异火';
UPDATE t_item SET image = '/fire/bahuang.jpg'  WHERE name = '八荒破灭炎' AND category = '异火';
UPDATE t_item SET image = '/fire/jiuyou.jpg'   WHERE name = '九幽风炎'   AND category = '异火';
UPDATE t_item SET image = '/fire/guling.jpg'   WHERE name = '骨灵冷火'   AND category = '异火';
UPDATE t_item SET image = '/fire/sanqian.jpg'  WHERE name = '三千焱炎火' AND category = '异火';
UPDATE t_item SET image = '/fire/qinglian.jpg' WHERE name = '青莲地心火' AND category = '异火';
UPDATE t_item SET image = '/fire/yunluo.jpg'   WHERE name = '陨落心炎'   AND category = '异火';
UPDATE t_item SET image = '/fire/haixin.jpg'   WHERE name = '海心焰'     AND category = '异火';

-- ------------------------------------------------------------
-- 道具插图（功法 / 斗技 / 丹药 / 法宝，文件在 doupo-frontend/public/item/）
-- ------------------------------------------------------------
UPDATE t_item SET image = '/item/fenjue.jpg'       WHERE name = '焚决'       AND category = '功法';
UPDATE t_item SET image = '/item/tianhuo.jpg'      WHERE name = '天火三玄变' AND category = '功法';
UPDATE t_item SET image = '/item/qingmu.jpg'       WHERE name = '青木诀'     AND category = '功法';
UPDATE t_item SET image = '/item/datian.jpg'       WHERE name = '大天造化掌' AND category = '斗技';
UPDATE t_item SET image = '/item/yanfen.jpg'       WHERE name = '焰分噬浪尺' AND category = '斗技';
UPDATE t_item SET image = '/item/bajibeng.jpg'     WHERE name = '八极崩'     AND category = '斗技';
UPDATE t_item SET image = '/item/xizhang.jpg'      WHERE name = '吸掌'       AND category = '斗技';
UPDATE t_item SET image = '/item/jiuzhuan.jpg'     WHERE name = '九转斗尊强体丹' AND category = '丹药';
UPDATE t_item SET image = '/item/poedan.jpg'       WHERE name = '破厄丹'     AND category = '丹药';
UPDATE t_item SET image = '/item/sanwen.jpg'       WHERE name = '三纹青灵丹' AND category = '丹药';
UPDATE t_item SET image = '/item/juqisan.jpg'      WHERE name = '聚气散'     AND category = '丹药';
UPDATE t_item SET image = '/item/xuanchongchi.jpg' WHERE name = '玄重尺'     AND category = '法宝';
UPDATE t_item SET image = '/item/heimoding.jpg'    WHERE name = '黑魔鼎'     AND category = '法宝';
UPDATE t_item SET image = '/item/najie.jpg'        WHERE name = '纳戒'       AND category = '法宝';
UPDATE t_item SET image = '/item/duanren.jpg'      WHERE name = '魔兽山脉短刃' AND category = '法宝';

-- ------------------------------------------------------------
-- 收藏（收服）表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_collect;
CREATE TABLE t_collect (
  id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  user_id     BIGINT       NOT NULL               COMMENT '用户',
  item_id     BIGINT       NOT NULL               COMMENT '图鉴条目',
  note        VARCHAR(300) DEFAULT ''             COMMENT '私人笔记',
  create_time DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '收服时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_item (user_id, item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏/收服记录';

-- ------------------------------------------------------------
-- 评论表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_comment;
CREATE TABLE t_comment (
  id          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
  item_id     BIGINT       NOT NULL               COMMENT '图鉴条目',
  user_id     BIGINT       NOT NULL               COMMENT '用户',
  nickname    VARCHAR(50)  DEFAULT ''             COMMENT '昵称快照',
  content     VARCHAR(300) NOT NULL               COMMENT '评论内容',
  create_time DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
  deleted     TINYINT      NOT NULL DEFAULT 0      COMMENT '逻辑删除',
  PRIMARY KEY (id),
  KEY idx_item (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='异火评论';

INSERT INTO t_comment (item_id, user_id, nickname, content) VALUES
(1, 2, '炎帝', '异火榜第一，名副其实。'),
(1, 1, '丹塔长老', '陀舍古帝留下的东西，不是谁都能碰的。'),
(4, 2, '炎帝', '我的第一道异火，感情最深。'),
(8, 1, '丹塔长老', '老师当年就是靠它撑着灵魂。');

-- ------------------------------------------------------------
-- 抽卡记录表
-- ------------------------------------------------------------
DROP TABLE IF EXISTS t_draw;
CREATE TABLE t_draw (
  id          BIGINT   NOT NULL AUTO_INCREMENT COMMENT '主键',
  user_id     BIGINT   NOT NULL               COMMENT '用户',
  item_id     BIGINT   NOT NULL               COMMENT '抽到的条目',
  draw_date   DATE     NOT NULL               COMMENT '抽卡日期（用于每日次数限制）',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '时间',
  PRIMARY KEY (id),
  KEY idx_user_date (user_id, draw_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='异火降临抽卡记录';

-- ------------------------------------------------------------
-- 给演示账号预置一些收藏，让「我的异火」和境界有内容
-- ------------------------------------------------------------
INSERT INTO t_collect (user_id, item_id) VALUES
(2, 1), (2, 4), (2, 8), (2, 9), (2, 11);
INSERT INTO t_collect (user_id, item_id, note) VALUES
(2, 13, '焚决一定要练成第三步');
