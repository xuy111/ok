-- ============================================================
-- One Piece 航海图鉴系统 · 完整数据库初始化脚本
-- 数据库: onepiece
-- 表: user(用户) / content(航海图鉴) / timeline(航海日志) / favorite(收藏)
-- 后端: springBootTest (Spring Boot 3.4.5 + MyBatis-Plus + MySQL 8.x)
-- 密码: SHA-256 摘要存储，种子账号密码均为 123456
-- 使用: mysql -uroot -p123456 < onepiece.sql
-- ============================================================

DROP DATABASE IF EXISTS `onepiece`;
CREATE DATABASE `onepiece` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `onepiece`;

-- ------------------------------------------------------------
-- 用户表（船员名册）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `username`    VARCHAR(50) NOT NULL COMMENT '用户名(船长之名)',
    `password`    VARCHAR(64) NOT NULL COMMENT '密码(SHA-256摘要)',
    `crew`        VARCHAR(20) NOT NULL DEFAULT 'straw' COMMENT '海贼团',
    `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='船员名册';

INSERT INTO `user` (`username`, `password`, `crew`) VALUES
('luffy','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','straw'),
('zoro','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','straw'),
('shanks','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','redhair'),
('teach','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','blackbeard'),
('newgate','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','whitebeard');

-- ------------------------------------------------------------
-- 航海图鉴表（首页搜索/展示/船员/岛屿/悬赏数据源）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `content`;
CREATE TABLE `content` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `category`     VARCHAR(50)  NOT NULL COMMENT '大类: island/character/fruit/org/item/event',
    `subcategory`  VARCHAR(50)  DEFAULT NULL COMMENT '子类(细分分类)',
    `region`       VARCHAR(50)  DEFAULT NULL COMMENT '海域: 东海/西海/南海/北海/伟大航道/新世界/剧场版',
    `crew`         VARCHAR(30)  DEFAULT NULL COMMENT '所属海贼团: straw/redhair/blackbeard/whitebeard/bigmom/kaido/roger/other',
    `name`         VARCHAR(200) NOT NULL COMMENT '名称',
    `description`  VARCHAR(500) DEFAULT NULL COMMENT '描述',
    `detail`       TEXT         DEFAULT NULL COMMENT '详细解析(长篇剧情)',
    `bounty`       VARCHAR(50)  DEFAULT NULL COMMENT '悬赏金额文本(如 30亿贝里)',
    `bounty_value` BIGINT       DEFAULT NULL COMMENT '悬赏数值(贝里,用于排序)',
    `sort`         INT          NOT NULL DEFAULT 0 COMMENT '排序权重,越大越靠前',
    `position`     VARCHAR(50)  DEFAULT NULL COMMENT '船上职位',
    `epithet`      VARCHAR(100) DEFAULT NULL COMMENT '称号',
    `ability`      VARCHAR(200) DEFAULT NULL COMMENT '果实/能力',
    `power`        VARCHAR(30)  DEFAULT NULL COMMENT '实力评级 S/A/B/C',
    `create_time`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_category` (`category`),
    KEY `idx_subcategory` (`subcategory`),
    KEY `idx_region` (`region`),
    KEY `idx_crew` (`crew`),
    KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='航海图鉴(首页搜索/展示)';

INSERT INTO `content` (`category`,`subcategory`,`region`,`crew`,`name`,`description`,`detail`,`bounty`,`bounty_value`,`sort`,`position`,`epithet`,`ability`,`power`) VALUES
('island','东海','东海',NULL,'风车村','路飞的故乡，红发香克斯曾在此驻足','草帽海贼团船长蒙奇·D·路飞的故乡，位于东海哥亚王国境内的一个小渔村。十年前，红发香克斯在此停留一年，路飞因误食橡胶果实（后揭示为人人果实·幻兽种·尼卡形态）并立下成为海贼王的誓言，香克斯将心爱的草帽托付给他。这里是整个故事梦想的起点。',NULL,NULL,60,NULL,NULL,NULL,NULL),
('island','东海','东海',NULL,'罗格镇','海贼王罗杰的出生地与被处刑之地','位于东海，被称为"开始与结束之镇"。海贼王哥尔·D·罗杰在此出生，也在此被处刑。临刑前罗杰留下"想要我的财宝吗？去找吧！我把一切都放在那里了"的遗言，直接开启了大海贼时代。路飞在此被小丑巴基处刑，被父亲蒙奇·D·龙所救。',NULL,NULL,50,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'阿拉巴斯坦','沙漠王国，克洛克达尔曾企图窃国','伟大航道前半段的沙漠王国，克洛克达尔为夺取古代兵器冥王而长期暗中操控。公主薇薇卧底巴洛克工作社，路飞一行揭穿阴谋，击败克洛克达尔。是阿拉巴斯坦篇的主舞台，也是妮可·罗宾入伙之地。',NULL,NULL,70,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'水之都·七水之城','造船业中心，冥王设计图藏匿之处','伟大航道上的造船业中心，别名"七水之城"。世界第一船匠汤姆的徒弟冰山担任市长，弗兰奇在此建造了草帽团的第二艘海贼船"万里阳光号"。冥王设计图长期藏于此，海军CP9曾在此潜伏，司法岛篇的导火索。',NULL,NULL,75,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'司法岛','不夜之岛，世界政府三大司法机构之一','世界政府三大司法机构之一，因终年白昼而被称为"不夜之岛"。草帽团为救回罗宾强攻司法岛，路飞觉醒二档与三档，全员与CP9展开激战，最终烧毁世界政府旗帜宣战。路飞正是在此被认定超越"司法岛事件"，赏金大幅飙升。',NULL,NULL,55,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'空岛·斯凯皮亚','云端上的黄金之乡，历史正文之谜','位于一万米高空的空岛，由白海与白白海构成，黄金之乡香多拉的所在地。路飞一行乘冲天海流抵达，卷入神·艾尼路与山迪亚人的纷争，路飞因橡胶体质免疫雷电而击败艾尼路。历史正文与黄金钟在此揭示罗杰的留言。',NULL,NULL,65,NULL,NULL,NULL,NULL),
('island','新世界','新世界',NULL,'香波地群岛','前往鱼人岛的必经之地，天龙人领地','新世界入口附近的群岛，由79棵亚尔奇曼红树组成，每棵树是一个编号岛。天龙人的领地，奴隶交易市场与拍卖会盛行。路飞在此拳打天龙人，引发大将黄猿与和平主义者围攻，最终由雷利与熊救场，草帽团在此被迫分离。',NULL,NULL,68,NULL,NULL,NULL,NULL),
('island','新世界','新世界',NULL,'德雷斯罗萨','爱与热情之国，堂吉诃德家族的阴谋','新世界"爱与热情之国"，堂吉诃德·多弗朗明哥以"德雷斯罗萨王"身份统治十年。竞技场的格斗比赛、人造恶魔果实SMILE工厂、鸟笼大屠杀皆在此上演。路飞联合罗等击败明哥，首次觉醒四档，草帽大船团在此成立。',NULL,NULL,72,NULL,NULL,NULL,NULL),
('island','新世界','新世界',NULL,'蛋糕岛','四皇 BIG MOM 的领地','四皇夏洛特·玲玲(BIG MOM)的领地，位于万国群岛。山治被强行带至此与三眼族普琳政治联姻，路飞为救山治闯入，与卡塔库栗展开史诗级对决，觉醒"预见未来"的见闻色霸气，最终以蛇人形态取胜，赏金飙升至15亿。',NULL,NULL,66,NULL,NULL,NULL,NULL),
('island','新世界','新世界',NULL,'和之国','武士之国，凯多的根据地','新世界武士之国，四皇凯多的根据地，和之国的闭关锁国与SMILE果实污染交织。路飞为报恩立誓开国，联合武士、毛皮族与超新星讨伐凯多与BIG MOM。路飞在此觉醒果实"尼卡形态"击败凯多，被封为四皇之一。',NULL,NULL,80,NULL,NULL,NULL,NULL),
('island','新世界','新世界',NULL,'拉夫德鲁','伟大航道的终点，ONE PIECE 所在之地','伟大航道的终点，传说之岛，只有集齐四块历史正文坐标才能抵达。海贼王罗杰在此找到了 ONE PIECE 大笑不止，故又称"笑之岛"。当前无人抵达，是整部作品的核心谜题与最终目标。',NULL,NULL,100,NULL,NULL,NULL,NULL),
('character','海贼王',NULL,'other','哥尔·D·罗杰','海贼王，开启大海贼时代之人',NULL,'55亿贝里',5500000000,100,'船长','海贼王','无果实（倾听万物之声）','S'),
('character','四皇',NULL,'redhair','红发香克斯','四皇之一，路飞的引路人',NULL,'40亿4890万贝里',4048900000,95,'船长','红发','无果实（霸王色霸气·剑术）','S'),
('character','四皇',NULL,'blackbeard','黑胡子蒂奇','四皇之一，暗暗果实与震震果实双能力者',NULL,'39亿9600万贝里',3996000000,90,'提督','黑胡子','暗暗果实+震震果实（双果实能力者）','S'),
('character','四皇',NULL,'whitebeard','白胡子纽盖特','四皇之一，被誉为世界最强的男人',NULL,'50亿4600万贝里',5046000000,92,'船长','白胡子','震震果实','S'),
('character','四皇',NULL,NULL,'大妈夏洛特·玲玲','四皇之一，万国女王',NULL,'43亿8800万贝里',4388000000,88,NULL,NULL,NULL,NULL),
('character','草帽团',NULL,'straw','蒙奇·D·路飞','草帽海贼团船长，人人果实·尼卡形态能力者',NULL,'30亿贝里',3000000000,98,'船长','草帽小子','人人果实·幻兽种·尼卡形态（橡胶果实觉醒）','S'),
('character','草帽团',NULL,'straw','罗罗诺亚·索隆','三刀流剑士，目标成为世界第一大剑豪',NULL,'11亿1100万贝里',1111000000,85,'战斗员·剑士','海贼猎人','无果实（三刀流剑术、霸王色霸气）','S'),
('character','草帽团',NULL,'straw','山治','黑足厨师，文斯莫克家族之子',NULL,'10亿3200万贝里',1032000000,80,'厨师','黑足','无果实（杰尔马改造人·隐形黑战斗服）','A'),
('character','草帽团',NULL,'straw','娜美','航海士，气候棒使用者',NULL,'3亿6600万贝里',366000000,70,'航海士','小偷猫','无果实（天候棒·气象知识）','B'),
('character','草帽团',NULL,'straw','乔巴','船医，人人果实能力者',NULL,'1000贝里',1000,65,'船医','最爱棉花糖','人人果实（动物系·蓝波球）','B'),
('character','草帽团',NULL,'straw','妮可·罗宾','考古学家，花花果实能力者，寻找历史正文',NULL,'9亿3000万贝里',930000000,75,'考古学家','恶魔之子','花花果实','A'),
('character','七武海',NULL,NULL,'鹰眼米霍克','世界第一大剑豪，原七武海',NULL,NULL,NULL,78,NULL,NULL,NULL,NULL),
('character','七武海',NULL,NULL,'多弗朗明哥','线线果实能力者，德雷斯罗萨原国王',NULL,'3亿4000万贝里',340000000,74,NULL,NULL,NULL,NULL),
('character','超新星',NULL,NULL,'特拉法尔加·罗','手术果实能力者，红心海贼团船长',NULL,'30亿贝里',3000000000,76,NULL,NULL,NULL,NULL),
('character','海军',NULL,NULL,'蒙奇·D·卡普','海军英雄，路飞与龙的父亲',NULL,NULL,NULL,82,NULL,NULL,NULL,NULL),
('fruit','超人系',NULL,NULL,'橡胶果实（尼卡形态）','传说级果实，觉醒为太阳神尼卡',NULL,NULL,NULL,95,NULL,NULL,NULL,NULL),
('fruit','超人系',NULL,NULL,'震震果实','白胡子的能力，能引发地震与海啸',NULL,NULL,NULL,88,NULL,NULL,NULL,NULL),
('fruit','自然系',NULL,NULL,'暗暗果实','黑胡子的能力，可吞噬一切',NULL,NULL,NULL,90,NULL,NULL,NULL,NULL),
('fruit','自然系',NULL,NULL,'烧烧果实','艾斯的能力，火之能力',NULL,NULL,NULL,82,NULL,NULL,NULL,NULL),
('fruit','动物系',NULL,NULL,'人人果实·幻兽种·尼卡','乔巴误食的果实',NULL,NULL,NULL,70,NULL,NULL,NULL,NULL),
('fruit','动物系',NULL,NULL,'青龙果实','凯多的能力，可化身为龙',NULL,NULL,NULL,86,NULL,NULL,NULL,NULL),
('org','海军',NULL,NULL,'海军本部','世界政府直属，维护大海秩序',NULL,NULL,NULL,70,NULL,NULL,NULL,NULL),
('org','革命军',NULL,NULL,'革命军','蒙奇·D·龙领导的反抗组织',NULL,NULL,NULL,65,NULL,NULL,NULL,NULL),
('org','王下七武海',NULL,NULL,'王下七武海','世界政府认可的海贼',NULL,NULL,NULL,60,NULL,NULL,NULL,NULL),
('item','宝物',NULL,NULL,'ONE PIECE','哥尔·D·罗杰留下的大秘宝',NULL,NULL,NULL,100,NULL,NULL,NULL,NULL),
('item','武器',NULL,NULL,'冥王','古代兵器之一，最强战舰',NULL,NULL,NULL,80,NULL,NULL,NULL,NULL),
('event','大事件',NULL,NULL,'顶上战争','白胡子海贼团 vs 海军本部',NULL,NULL,NULL,85,NULL,NULL,NULL,NULL),
('character','草帽团',NULL,'straw','乌索普','狙击手，草帽团的大发明家与胆小鬼',NULL,'5亿贝里',500000000,68,'狙击手','狙击王','无果实（弹弓狙击·见闻色霸气）','B'),
('character','草帽团',NULL,'straw','弗兰奇','船匠，万里阳光号建造者',NULL,'3亿9400万贝里',394000000,66,'船匠','铁人','无果实（改造人·激光炮）','B'),
('character','草帽团',NULL,'straw','布鲁克','音乐家，黄泉果实能力者',NULL,'3亿8300万贝里',383000000,64,'音乐家','灵魂之王','黄泉果实（灵魂出窍·剑术）','B'),
('character','草帽团',NULL,'straw','甚平','舵手，原王下七武海',NULL,'11亿贝里',1100000000,72,'舵手','海侠','无果实（鱼人空手道·海水操控）','A'),
('character','四皇',NULL,'redhair','本·贝克曼','红发团副船长，实力与红发齐名的参谋',NULL,'不详',NULL,80,'副船长','无敌的贝克曼','无果实（枪术·见闻色霸气）','A'),
('character','四皇',NULL,'redhair','拉基·路','红发团战斗员，常伴红发左右的圆脸战士',NULL,'不详',NULL,70,'战斗员','吃肉的路','无果实（体术·枪术）','B'),
('character','四皇',NULL,'redhair','耶稣布','红发团狙击手，乌索普的父亲',NULL,'不详',NULL,68,'狙击手','追击者','无果实（狙击·见闻色霸气）','B'),
('character','四皇',NULL,'blackbeard','希留','黑胡子团二号船长，原推进城看守长',NULL,'不详',NULL,72,'二号船长','雨之希留','无果实（剑术·透明果实？）','A'),
('character','四皇',NULL,'blackbeard','卡特琳娜·戴彭','黑胡子团六号船长',NULL,'不详',NULL,60,'六号船长','月牙猎人','犬犬果实·幻兽种·九尾狐形态','A'),
('character','四皇',NULL,'blackbeard','巴杰斯','黑胡子团一号船长，格斗冠军',NULL,'不详',NULL,58,'一号船长','冠军','无果实（格斗）','B'),
('character','四皇',NULL,'whitebeard','马尔科','白胡子团一番队队长，不死鸟',NULL,'13亿7400万贝里',1374000000,78,'一番队队长','不死鸟','鸟鸟果实·幻兽种·不死鸟形态（再生）','A'),
('character','四皇',NULL,'whitebeard','艾斯','白胡子团二番队队长，路飞的义兄',NULL,'5亿5000万贝里',550000000,76,'二番队队长','火拳','烧烧果实','A'),
('character','四皇',NULL,'whitebeard','乔兹','白胡子团三番队队长，钻石乔兹',NULL,'不详',NULL,62,'三番队队长','钻石','闪闪果实（钻石硬化）','B'),
('character','四皇',NULL,'whitebeard','萨奇','白胡子团四番队队长，厨师',NULL,'不详',NULL,55,'四番队队长','厨师长','无果实','B'),
('island','东海','东海',NULL,'谢尔兹镇','海军第153支部所在地，亚尔丽塔的据点','东海篇的第一个海军基地，蒙卡上校以暴政统治。路飞在此救出克比，并击败蒙卡，收服第一份通缉令。克比也因此加入海军，成为路飞海军的"对照"。',NULL,NULL,40,NULL,NULL,NULL,NULL),
('island','东海','东海',NULL,'橘子镇','小丑巴基的据点，娜美登场','小丑巴基海贼团占据的小镇，路飞在此遇到小偷娜美（尚未入伙），并初次与巴基交手。是路飞首次接触恶魔果实能力者的战斗，也埋下巴基与红发恩怨的伏笔。',NULL,NULL,42,NULL,NULL,NULL,NULL),
('island','东海','东海',NULL,'西罗布村','乌索普的故乡','乌索普的家乡，管家克拉巴特尔（黑猫海贼团船长克洛）密谋夺取财产。乌索普与路飞等人联手识破阴谋，乌索普以"狙击王"之姿首次登上梅丽号，成为草帽团狙击手。',NULL,NULL,45,NULL,NULL,NULL,NULL),
('island','东海','东海',NULL,'海上餐厅巴拉蒂','山治工作的海上餐厅','伟大的海上餐厅，红脚哲夫经营。山治在此展现厨师与战斗天赋，与路飞对抗克里克海贼团，并与鹰眼米霍克、红发团本·贝克曼等角色交集。山治在此正式入伙，追随哲夫的"找到ALL BLUE"之梦。',NULL,NULL,50,NULL,NULL,NULL,NULL),
('island','东海','东海',NULL,'可可亚西村','娜美的故乡','娜美与养姐诺琪高的故乡，阿龙海贼团在此盘踞八年。娜美为赎回村庄暗中偷钱，路飞在娜美崩溃时出手，击败恶龙。阿龙篇是路飞第一次认真战斗，娜美正式入伙，也奠定草帽团"为伙伴而战"的信念。',NULL,NULL,48,NULL,NULL,NULL,NULL),
('island','东海','东海',NULL,'哥亚王国','路飞出身的王国，萨博的故乡','风车村所在的王国，以垃圾山与贵族区两极分化。路飞与艾斯、萨博在此结为兄弟（ASL），饮下结拜酒。萨博在此"遇难"（实为被龙所救），为后续革命军剧情埋下伏笔。',NULL,NULL,38,NULL,NULL,NULL,NULL),
('island','西海','西海',NULL,'奥哈拉','妮可·罗宾的故乡，考古学圣地','西海著名的考古学之岛，世界最大的图书馆"全知之树"所在地。罗宾童年在此研究历史正文，因触碰"空白的一百年"被世界政府发动屠魔令毁灭。罗宾是唯一幸存者，背负"恶魔之子"之名。',NULL,NULL,60,NULL,NULL,NULL,NULL),
('island','北海','北海',NULL,'杰尔马王国','山治的故乡，科学战斗部队','北海的海上王国，文斯莫克家族的领地，以杰尔马66科学战斗部队闻名。山治的父兄（文斯莫克·加治与四兄弟）在此。山治自幼受父兄欺凌，逃离家庭，成年后在蛋糕岛篇与家族重逢并和解。',NULL,NULL,55,NULL,NULL,NULL,NULL),
('island','北海','北海',NULL,'罗格镇北的卡提·弗拉姆','（略）','北海相关岛屿，剧情涉及较少。',NULL,NULL,20,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'威士忌山峰','伟大航道入口的赏金猎人小镇','进入伟大航道后的第一站，巴洛克工作社的赏金猎人聚集地。草帽团在此揭穿骗局，结识阿拉巴斯坦公主薇薇，正式卷入克洛克达尔的阴谋。',NULL,NULL,52,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'小花园','太古之岛，恐龙时代遗迹','保留恐龙生态的太古之岛，巨人族东利与布洛基在此决斗百年。路飞与索隆分别助两人，娜美感染太古岛病毒。是路飞第一次接触巨人族，也为德雷斯罗萨篇巨人族伏笔。',NULL,NULL,50,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'磁鼓岛（樱花王国）','乔巴的故乡，冬岛','终年寒冬的冬岛，乔巴的家乡。路飞为救娜美攀上雪山，遇到乔巴与希鲁鲁克医生、库蕾哈医生。乔巴在此领悟医生的意义，正式入伙成为船医。樱花王的意志传承至此。',NULL,NULL,54,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'加雅岛','空岛篇的起点','伟大航道上的岛屿，路飞在此被贝拉米嘲笑"梦想无用"，一拳击溃。也是黑胡子蒂奇与路飞首次相遇、蒙布朗·库利凯特故事发生之地，空岛篇的重要前奏。',NULL,NULL,46,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'长环长岛','伟大航道的长岛','草帽团在此遭遇福克西海贼团的"海贼游戏"戴维贝克，草帽团被迫比赛，路飞与福克西单挑，最终夺回船员。轻松搞笑篇，也引出路飞二档。',NULL,NULL,44,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'恐怖三桅帆船','月光·莫利亚的鬼船','巨大海贼船，月光·莫利亚与佩罗娜的据点。布鲁克在此登场（黄泉果实），草帽团为夺回影子与莫利亚、奥兹战斗，最终击败莫利亚。布鲁克正式入伙成为音乐家。',NULL,NULL,58,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'亚马逊·百合','女儿岛，汉库克的故乡','女儿岛（九蛇），女性战士的国度，女帝波雅·汉库克的故乡。路飞被熊拍飞至此，与汉库克相遇，参加格斗大赛，得知艾斯将被处刑。汉库克因此爱上路飞，是顶上战争前的重要篇章。',NULL,NULL,56,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'因佩尔监狱','世界第一大监狱','位于海底的世界最大监狱，推进城。路飞为救艾斯潜入，大闹监狱，与巴洛克工作社、麦哲伦、黑胡子等多方势力交锋，最终突破到第五层，开启顶上战争。',NULL,NULL,70,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'马林梵多','海军本部，顶上战争战场','海军本部所在地，顶上战争的决战舞台。白胡子海贼团与海军本部在此全面开战，艾斯与白胡子战死，路飞见证惨烈战争。战后海军本部迁移，是整部作品的分水岭。',NULL,NULL,75,NULL,NULL,NULL,NULL),
('island','新世界','新世界',NULL,'鱼人岛','海底一万米的龙宫王国','位于海底一万米的龙宫王国，人鱼与鱼人的国度。草帽团潜水抵达，卷入范德·戴肯九世与霍迪·琼斯的叛乱，路飞在此展现霸气的进步。是连接乐园与新世界的枢纽，也是白星公主（古代兵器波塞冬）所在地。',NULL,NULL,68,NULL,NULL,NULL,NULL),
('island','新世界','新世界',NULL,'庞克哈萨德','科学实验岛','新世界的科研岛，凯撒·库朗的SAD工厂所在地。路飞与罗结盟，首次联手对抗凯撒，解救被实验的孩子们。草帽团在此与多弗朗明哥势力全面冲突，是德雷斯罗萨篇的前奏。',NULL,NULL,66,NULL,NULL,NULL,NULL),
('island','新世界','新世界',NULL,'佐乌','毛皮族的故乡，象主背上的国度','象主背上的移动岛屿，毛皮族的家园。草帽团在此与犬岚、猫蝮蛇等毛皮族结盟，得知和之国与历史正文的线索，雷藏在此登场。是通往和之国篇的关键中转站。',NULL,NULL,70,NULL,NULL,NULL,NULL),
('island','新世界','新世界',NULL,'万国（托特兰）','BIG MOM 海贼团的领地','四皇BIG MOM的领地，由多座岛屿组成的群岛，每座岛代表一种甜点。蛋糕岛是其中主岛，山治在此被扣留，路飞为救山治闯入。万国的结构是BIG MOM野心的体现。',NULL,NULL,72,NULL,NULL,NULL,NULL),
('island','新世界','新世界',NULL,'艾尔巴夫','巨人族的故乡','传说中的巨人王国，巨人族的家园。香克斯与东利、布洛基等巨人族皆与此有关。乌索普梦想中的"勇敢的海上战士"圣地，也是后续剧情的重要目标。',NULL,NULL,65,NULL,NULL,NULL,NULL),
('character','四皇',NULL,'bigmom','夏洛特·玲玲','万国托特兰的女王，四皇之一，能夺取灵魂并赋予万物生命',NULL,'43亿8800万贝里',4388000000,90,'船长','BIG MOM','魂魂果实','S'),
('character','四皇',NULL,'bigmom','卡塔库栗','三将星之首，预见未来的见闻色霸气，悬赏最高干部',NULL,'10亿5700万贝里',1057000000,80,'甜点三将星·首将','卡塔库栗','糯糯果实（特殊超人系）','S'),
('character','四皇',NULL,'bigmom','斯慕吉','三将星之一，长腿族，能榨取水分强化自身',NULL,'9亿3200万贝里',932000000,72,'甜点三将星','斯慕吉','榨榨果实','A'),
('character','四皇',NULL,'bigmom','克力架','三将星之一，能无限制造饼干士兵',NULL,'8亿6000万贝里',860000000,70,'甜点三将星','克力架','饼干果实','A'),
('character','四皇',NULL,'bigmom','夏洛特·佩罗斯佩罗','大妈长子，万国糖果大臣',NULL,'7亿贝里',700000000,65,'长子','佩罗斯佩罗','舔舔果实','B'),
('character','四皇',NULL,'kaido','凯多','百兽海贼团总督，四皇之一，号称「世界最强生物」',NULL,'46亿1110万贝里',4611100000,92,'总督','凯多','鱼鱼果实·幻兽种·青龙形态','S'),
('character','四皇',NULL,'kaido','烬','百兽团二号人物，露娜利亚族幸存者，火之能力',NULL,'13亿9000万贝里',1390000000,78,'大看板·炎灾','烬','龙龙果实·古代种·无齿翼龙形态','S'),
('character','四皇',NULL,'kaido','奎因','百兽团三号，科学家，改造人',NULL,'13亿2000万贝里',1320000000,75,'大看板·疫灾','奎因','龙龙果实·古代种·腕龙形态','A'),
('character','四皇',NULL,'kaido','杰克','百兽团四号，鱼人，悬赏最高猛将之一',NULL,'10亿贝里',1000000000,73,'大看板·旱灾','杰克','象象果实·古代种·猛犸象形态','A'),
('character','海贼王',NULL,'roger','西尔巴兹·雷利','罗杰海贼团副船长，隐居香波地的镀膜匠，路飞的师父',NULL,NULL,NULL,88,'副船长','冥王','无果实（顶级剑术·三色霸气）','S'),
('character','海贼王',NULL,'roger','香克斯（青年）','罗杰团见习船员时期，后成为四皇',NULL,NULL,NULL,70,'船员','红发','无果实（剑术·霸王色）','A'),
('island','剧场版','新世界',NULL,'黄金城·格兰·泰佐罗','被吉尔德·泰佐罗用黄金果实支配的娱乐都市','剧场版《GOLD》的舞台。世界最大娱乐城市，整座岛都由黄金构成，实为泰佐罗（黄金果实能力者）用能力与庞大的财富建立起来的独立王国，天龙人默许其存在。泰佐罗曾是明哥的合作伙伴，最终被路飞击败，黄金城随之崩塌。',NULL,NULL,60,NULL,NULL,NULL,NULL),
('island','剧场版','新世界',NULL,'安布尔山岛','萨博相关，剧场版登场的冬岛','剧场版《航海王之黄金罗盘》等衍生作品中登场的岛屿，设定上为气候严寒的冬岛。',NULL,NULL,40,NULL,NULL,NULL,NULL),
('island','伟大航道','伟大航道',NULL,'磁鼓岛','乔巴故乡，冬岛，医生王国','乔巴的故乡，冬岛。曾由暴君瓦波尔统治，医生希鲁鲁克与库蕾哈在此行医。乔巴在此继承希鲁鲁克的意志，吃下人人果实，最终与库蕾哈一同成为医生。瓦波尔倒台后成为和平的医生王国。',NULL,NULL,58,NULL,NULL,NULL,NULL),
('character','超新星',NULL,'other','尤斯塔斯·基德','超新星之一，磁磁果实能力者，与路飞、罗组成同盟',NULL,'30亿贝里',3000000000,74,'船长','船长','磁磁果实','A'),
('character','超新星',NULL,'other','巴兹尔·霍金斯','超新星之一，占卜师，稻草果实能力者',NULL,'3亿2000万贝里',320000000,60,'船长','杀人机器','稻草果实','B'),
('character','超新星',NULL,'other','乌尔基','超新星之一，空岛出身，怪僧乌尔基',NULL,'1亿800万贝里',108000000,58,'船长','怪僧','因果果实','B'),
('character','七武海',NULL,'other','甚平','原七武海，鱼人族，后加入草帽海贼团任舵手',NULL,'4亿3800万贝里',438000000,76,'七武海','海侠','无果实（鱼人空手道）','A'),
('character','七武海',NULL,'other','克洛克达尔','原七武海，沙沙果实能力者，巴洛克工作社社长',NULL,'8100万贝里',81000000,68,'七武海','沙鳄','沙沙果实','A'),
('character','海军',NULL,'other','库赞','原海军大将，冰冻果实能力者，后退出海军',NULL,'30亿贝里',3000000000,82,'大将','青雉','冰冻果实','S'),
('character','海军',NULL,'other','萨卡斯基','海军元帅，岩浆果实能力者，顶上战争击杀艾斯',NULL,NULL,NULL,84,'大将','赤犬','岩浆果实','S'),
('character','海军',NULL,'other','波鲁萨利诺','海军大将，闪闪果实能力者，光速移动',NULL,NULL,NULL,80,'大将','黄猿','闪闪果实','S'),
('character','革命军',NULL,'other','蒙奇·D·龙','革命军首领，路飞之父，被世界政府视为最凶恶罪犯',NULL,NULL,NULL,86,'首领','革命家','未知','S'),
('character','革命军',NULL,'other','萨博','革命军参谋总长，路飞与艾斯的结义兄弟，烧烧果实继承人',NULL,'6亿200万贝里',602000000,78,'参谋总长','炎帝','烧烧果实','S');

-- ------------------------------------------------------------
-- 航海日志表（剧情时间线）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `timeline`;
CREATE TABLE `timeline` (
    `id`          BIGINT        NOT NULL AUTO_INCREMENT COMMENT '主键',
    `title`       VARCHAR(200)  NOT NULL COMMENT '事件标题',
    `period`      VARCHAR(50)   DEFAULT NULL COMMENT '所属篇章',
    `stage`       VARCHAR(50)   DEFAULT NULL COMMENT '阶段',
    `summary`     VARCHAR(1000) DEFAULT NULL COMMENT '事件概述',
    `order_no`    INT           NOT NULL DEFAULT 0 COMMENT '时间线顺序',
    `create_time` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_order` (`order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='航海日志(剧情时间线)';

INSERT INTO `timeline` (`title`,`period`,`stage`,`summary`,`order_no`) VALUES
('罗杰处刑，大海贼时代开启','序章','序章','海贼王哥尔·D·罗杰在罗格镇被处刑，临刑遗言"去找吧，我把一切都放在那里了"，直接开启大海贼时代。',10),
('路飞出海，成立草帽海贼团','东海篇','东海','蒙奇·D·路飞从风车村出发，先后招募索隆、娜美、乌索普、山治，乘黄金梅丽号驶向伟大航道。',20),
('击败克洛克达尔，拯救阿拉巴斯坦','阿拉巴斯坦篇','伟大航道','草帽团在阿拉巴斯坦揭穿克洛克达尔窃国阴谋，罗宾加入，成为第七名船员。',30),
('空岛之战，击败神·艾尼路','空岛篇','伟大航道','路飞一行乘冲天海流抵达空岛，路飞凭橡胶体质击败雷电之神艾尼路，敲响黄金钟。',40),
('司法岛事件，烧毁世界政府旗帜','司法岛篇','伟大航道','为救回罗宾，草帽团强攻司法岛，路飞觉醒二档三档，全员击败CP9，向世界政府宣战。',50),
('恐怖三桅帆船，布鲁克入伙','恐怖三桅帆船篇','伟大航道','草帽团击败月光·莫利亚，夺回影子，布鲁克以音乐家身份加入，成为第九名船员。',60),
('香波地群岛，草帽团被迫分离','香波地群岛篇','伟大航道','路飞拳打天龙人，遭大将黄猿与和平主义者围攻，熊将草帽团全员拍飞到世界各地，草帽团分离。',70),
('顶上战争，艾斯与白胡子战死','顶上战争篇','伟大航道','白胡子海贼团与海军本部在马林梵多全面开战，艾斯为保护路飞被赤犬所杀，白胡子战死，大海贼时代进入新纪元。',80),
('两年修行，草帽团再聚香波地','两年后篇','新世界','路飞跟随雷利修行霸气，草帽团各自成长，两年后按约定重聚香波地群岛，换乘万里阳光号再出发。',90),
('鱼人岛篇，龙宫王国之乱','鱼人岛篇','新世界','草帽团抵达海底鱼人岛，平定霍迪·琼斯叛乱，结识白星公主，路飞与甚平并肩作战。',100),
('庞克哈萨德，路飞与罗结盟','庞克哈萨德篇','新世界','草帽团与特拉法尔加·罗结盟，捣毁凯撒·库朗的SAD工厂，为讨伐四皇拉开序幕。',110),
('德雷斯罗萨，草帽大船团成立','德雷斯罗萨篇','新世界','路飞击败多弗朗明哥，首次觉醒四档，各方势力在德雷斯罗萨结盟，草帽大船团正式成立。',120),
('蛋糕岛，路飞单挑卡塔库栗','万国篇','新世界','路飞为救山治闯入四皇BIG MOM领地，与卡塔库栗展开史诗对决，觉醒预见未来的见闻色霸气，赏金飙至15亿。',130),
('和之国，路飞觉醒尼卡击败凯多','和之国篇','新世界','路飞联合武士与超新星讨伐凯多与BIG MOM，觉醒果实尼卡形态，击败凯多，被封为新四皇。',140),
('终局将至，航向拉夫德鲁','最终章','新世界','草帽团继续航行，目标拉夫德鲁与ONE PIECE，伟大航道的终点与最终之谜即将揭晓。',150);

-- ------------------------------------------------------------
-- 收藏表（我的航海日志）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite` (
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `username`    VARCHAR(50) NOT NULL COMMENT '用户名',
    `content_id`  BIGINT      NOT NULL COMMENT '收藏的内容ID',
    `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_content` (`username`, `content_id`),
    KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户收藏(我的航海日志)';

-- ------------------------------------------------------------
-- 后台管理员表（后台管理系统独立鉴权）
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `username`    VARCHAR(50) NOT NULL COMMENT '管理员账号',
    `password`    VARCHAR(64) NOT NULL COMMENT '密码(SHA-256摘要)',
    `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_admin_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='后台管理员';

-- 内置管理员：admin / admin123（SHA-256 摘要存储）
INSERT INTO `admin` (`username`, `password`) VALUES
('admin','240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9');

