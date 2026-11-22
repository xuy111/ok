<template>
  <div class="journey-page">
    <TopNav active="journey" />

    <section class="head">
      <h1>人物关系历程图</h1>
      <p class="slogan">原著剧情整理　·　三十年河东 三十年河西 莫欺少年穷</p>
    </section>

    <div class="tabs">
      <button class="tab" :class="{ on: view === 'graph' }" @click="switchView('graph')">◈　人物关系图谱</button>
      <button class="tab" :class="{ on: view === 'time' }" @click="switchView('time')">◈　成长历程时间轴</button>
    </div>

    <!-- ===== 关系图谱 ===== -->
    <section class="panel" v-show="view === 'graph'">
      <div class="bar">
        <span class="hint">点人物看成长历程 · 拖拽平移 · 滚轮缩放 · 点击关系类型可筛选</span>
        <div class="legend">
          <span v-for="(v, k) in REL" :key="k" class="lg" :class="{ off: offRel.includes(k) }"
                @click="toggleRel(k)">
            <i :style="{ borderColor: v.c, borderTopStyle: v.dash ? 'dashed' : 'solid' }"></i>{{ v.n }}
          </span>
        </div>
        <button class="btn" @click="resetGraph">重置视图</button>
      </div>
      <svg ref="svg" class="graph" :viewBox="viewBox" preserveAspectRatio="xMidYMid meet"
           @mousedown="onDown" @wheel.prevent="onWheel" @mouseup="onUp" @mouseleave="onUp">
        <defs>
          <radialGradient id="jglow">
            <stop offset="0%" stop-color="#ff8c42" stop-opacity=".55" />
            <stop offset="100%" stop-color="#ff8c42" stop-opacity="0" />
          </radialGradient>
          <clipPath v-for="c in chars" :key="'clip' + c.id" :id="'clip-' + c.id">
            <circle :cx="c.x" :cy="c.y" :r="c.r - 1" />
          </clipPath>
        </defs>
        <circle cx="600" cy="450" r="230" fill="url(#jglow)" :opacity="light ? .35 : .5" />
        <g v-for="(l, i) in visibleLinks" :key="'e' + i">
          <line :x1="byId[l[0]].x" :y1="byId[l[0]].y" :x2="byId[l[1]].x" :y2="byId[l[1]].y"
                :stroke="REL[l[2]].c" stroke-width="1.3" :opacity="linkDim(l) ? .08 : .7"
                :stroke-dasharray="REL[l[2]].dash" :class="{ hot: linkHot(l) }" />
          <text :x="(byId[l[0]].x + byId[l[1]].x) / 2" :y="(byId[l[0]].y + byId[l[1]].y) / 2 - 4"
                :fill="REL[l[2]].c" text-anchor="middle" class="elabel"
                :opacity="linkDim(l) && sel ? 0 : 1">{{ l[3] }}</text>
        </g>
        <g v-for="c in chars" :key="c.id" class="node" :class="{ dim: nodeDim(c.id) }"
           @click.stop="select(c.id)" @mousemove="showTip($event, c)" @mouseleave="hideTip">
          <circle :cx="c.x" :cy="c.y" :r="c.r + 10" :fill="c.c" :opacity="light ? .07 : .1" />
          <circle :cx="c.x" :cy="c.y" :r="c.r" :fill="c.c"
                  :stroke="c.id === 'yan' ? '#f5d76e' : 'rgba(0,0,0,.5)'"
                  :stroke-width="c.id === 'yan' ? 3 : 2" :style="{ filter: `drop-shadow(0 0 10px ${c.c})` }" />
          <image :href="avatar(c.id)" :x="c.x - c.r + 1" :y="c.y - c.r + 1"
                 :width="(c.r - 1) * 2" :height="(c.r - 1) * 2"
                 :clip-path="`url(#clip-${c.id})`" preserveAspectRatio="xMidYMid slice" />
          <circle :cx="c.x" :cy="c.y" :r="c.r" fill="none"
                  :stroke="c.id === 'yan' ? '#f5d76e' : 'rgba(0,0,0,.5)'"
                  :stroke-width="c.id === 'yan' ? 3 : 2" />
          <text :x="c.x" :y="c.y + c.r + 18" text-anchor="middle"
                :font-size="c.id === 'yan' ? 15 : 12.5" :font-weight="c.id === 'yan' ? 800 : 600"
                :fill="c.id === 'yan' ? '#f5d76e' : ''" class="nname">{{ c.name }}</text>
          <text :x="c.x" :y="c.y + c.r + 32" text-anchor="middle" font-size="9.5" class="nsub">
            {{ c.title.split(' · ')[0] }}
          </text>
        </g>
      </svg>
    </section>

    <!-- ===== 成长时间轴 ===== -->
    <section class="panel" v-show="view === 'time'">
      <div class="bar">
        <span class="hint">横向为原著剧情阶段 · 纵向为人物 · 色块显示当时境界，点击查看详细历程</span>
      </div>
      <div class="filters">
        <span v-for="gp in groups" :key="gp" class="chip" :class="{ on: activeGroups.includes(gp) }"
              @click="toggleGroup(gp)">{{ gp }}</span>
      </div>
      <div class="gridScroll">
        <div class="grid">
          <div class="row head">
            <div class="cellName">人物 / 阶段</div>
            <div class="arcCol" v-for="a in ARCS" :key="a.n">{{ a.n }}<small>{{ a.s }}</small></div>
          </div>
          <div class="row" v-for="c in filteredChars" :key="c.id">
            <div class="cellName">
              <div class="ava" :style="{ boxShadow: `0 0 10px ${c.c}` }">
                <img :src="avatar(c.id)" :alt="c.name" @error="imgFallback($event, c)" />
              </div>
              <div class="nm">{{ c.name }}<small>{{ c.title.split(' · ')[0] }}</small></div>
            </div>
            <div class="arcCol" v-for="(a, ai) in ARCS" :key="a.n">
              <template v-if="milestones(c, ai).length">
                <div class="ms" v-for="(m, mi) in milestones(c, ai)" :key="mi"
                     :style="{ borderLeftColor: TIER[tier(m[1])].c }" @click="select(c.id)">
                  <div class="r" :style="{ color: TIER[tier(m[1])].c }">{{ m[1] }}</div>
                  <div class="e" :title="m[2]">{{ m[2].length > 34 ? m[2].slice(0, 34) + '…' : m[2] }}</div>
                </div>
              </template>
              <div class="empty" v-else></div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <footer>
      内容依据天蚕土豆原著《斗破苍穹》整理；境界节点按原著剧情线归纳，个别年龄为按剧情推演。<br>
      斗气等级：斗之气 → 斗者 → 斗师 → 大斗师 → 斗灵 → 斗王 → 斗皇 → 斗宗 → 斗尊 → 半圣 → 斗圣 → 斗帝
    </footer>

    <div id="jtip" v-show="tip.show" :style="{ left: tip.x + 'px', top: tip.y + 'px' }">
      <b>{{ tip.data.name }}</b><br>{{ tip.data.title }}<br>
      <span :style="{ color: TIER[tier(tip.data.final)].c }">{{ tip.data.final }}</span><br>
      <span style="opacity:.7">点击查看完整成长历程 →</span>
    </div>

    <aside class="detail" :class="{ open: detailOpen }">
      <button class="close" @click="closeDetail">✕</button>
      <template v-if="current">
        <div class="dHead">
          <div class="dAva" :style="{ boxShadow: `0 0 16px ${current.c}` }">
            <img :src="avatar(current.id)" :alt="current.name" @error="imgFallback($event, current)" />
          </div>
          <div>
            <div class="dName">{{ current.name }}</div>
            <div class="dTitle">{{ current.title }}</div>
          </div>
        </div>
        <div class="dMeta">
          <span class="pill">阵营 <b>{{ current.group }}</b></span>
          <span class="pill">最终境界 <b :style="{ color: TIER[tier(current.final)].c }">{{ current.final }}</b></span>
        </div>
        <div class="dSec">人物关系</div>
        <div class="rel" v-for="(r, i) in relationsOf(current.id)" :key="i" @click="select(r.other)">
          <i :style="{ background: REL[r.t].c }"></i>
          <b :style="{ color: byId[r.other].c }">{{ byId[r.other].name }}</b>
          <span>· {{ REL[r.t].n }} · {{ r.label }}</span>
        </div>
        <div class="dSec">成长历程</div>
        <div class="tl">
          <div class="ev" v-for="(e, i) in current.g" :key="i">
            <div class="stage">{{ ARCS[e[0]].n }}</div>
            <span class="realm" :style="{ background: TIER[tier(e[1])].c }">{{ e[1] }}</span>
            <div class="txt">{{ e[2] }}</div>
          </div>
        </div>
      </template>
    </aside>
  </div>
</template>

<script>
import TopNav from '../components/TopNav.vue'

const TIER = {
  emperor: { c: '#ffd45e', n: '斗帝' }, saint: { c: '#e2542a', n: '斗圣' },
  demi: { c: '#ef7d4f', n: '半圣' }, vener: { c: '#e08a3c', n: '斗尊' },
  master: { c: '#a06fd6', n: '斗宗' }, king: { c: '#4aa3c7', n: '斗皇/斗王' },
  spirit: { c: '#5fb37a', n: '斗灵' }, grand: { c: '#8fa36b', n: '斗师' },
  fighter: { c: '#9b8c6b', n: '斗者' }, none: { c: '#6b5c44', n: '—' }
}
function tier(s) {
  if (/斗帝|炎帝|帝炎/.test(s)) return 'emperor'
  if (/斗圣/.test(s)) return 'saint'
  if (/半圣/.test(s)) return 'demi'
  if (/斗尊/.test(s)) return 'vener'
  if (/斗宗/.test(s)) return 'master'
  if (/斗皇|斗王/.test(s)) return 'king'
  if (/斗灵/.test(s)) return 'spirit'
  if (/大斗师|斗师/.test(s)) return 'grand'
  if (/斗者|斗之气/.test(s)) return 'fighter'
  return 'none'
}
const REL = {
  master: { c: '#f5d76e', n: '师徒', dash: '' }, spouse: { c: '#ff6b8a', n: '眷属', dash: '' },
  love: { c: '#ff9a5c', n: '红颜', dash: '4 4' }, family: { c: '#b18cff', n: '血亲', dash: '' },
  ally: { c: '#4ec9b0', n: '盟友', dash: '' }, rival: { c: '#c9a227', n: '宿敌', dash: '7 5' },
  enemy: { c: '#ff5a4e', n: '敌对', dash: '7 5' }
}
const ARCS = [
  { n: '乌坦城', s: '天才陨落 · 退婚之耻' }, { n: '魔兽山脉', s: '历练 · 结识红颜' },
  { n: '塔戈尔沙漠', s: '青莲地心火 · 蛇人族' }, { n: '三年之约', s: '云岚宗决战' },
  { n: '迦南学院', s: '磐门 · 陨落心炎' }, { n: '炎盟风云', s: '建炎盟 · 药老被掳' },
  { n: '中州', s: '丹会 · 三千焱炎火' }, { n: '天墓与古界', s: '换血 · 族纹' },
  { n: '天府联盟', s: '净莲妖火 · 抗魂殿' }, { n: '双帝之战', s: '成帝 · 封印魂天帝' },
  { n: '大千世界', s: '无尽火域' }
]
const C = [
  { id:'yan',name:'萧炎',title:'主角 · 炎帝 · 无尽火域域主',group:'主角',x:600,y:450,r:34,c:'#ff8c42',
   final:'斗帝 · 炎帝（22种异火融合为帝炎）',
   g:[[0,'斗者→斗之气三段','11岁成萧家最年轻斗者；12岁斗气尽失跌至三段，15岁被纳兰嫣然退婚'],
      [0,'斗者','药老现身拜师，修焚诀，一年重凝斗之气旋'],
      [1,'斗师','魔兽山脉历练，结识小医仙与"云芝"；得紫云翼'],
      [2,'大斗师','塔戈尔沙漠夺青莲地心火，成二品炼药师；与美杜莎结缘'],
      [3,'斗灵·斗王','三年之约击败纳兰嫣然；云岚宗之乱，父亲被掳，药老附身退敌'],
      [4,'九星斗王','入迦南学院建磐门，收陨落心炎，击败韩枫'],
      [5,'斗皇','三上云岚宗杀云山，整合加玛建炎盟；药老被魂殿掳走'],
      [6,'斗宗→斗尊','赴中州，丹会夺冠收三千焱炎火；救回药老，任星陨阁少阁主'],
      [7,'斗尊','天墓得萧玄本源换血、激活族纹；收骨灵冷火、海心焰'],
      [8,'斗尊→斗圣','创建天府联盟抗魂殿，收服净莲妖火'],
      [9,'斗帝 · 炎帝','得陀舍古帝传承，融22种异火成帝炎，异火恒古尺封印魂天帝'],
      [10,'斗帝','赴大千世界，于极北之域创立无尽火域']]},
  { id:'yao',name:'药尘',title:'药老 · 药尊者 · 药圣 · 星陨阁阁主',group:'星陨阁·炼药',x:330,y:225,r:26,c:'#f5d76e',
   final:'一星斗圣 · 药圣（九品炼药宗师）',
   g:[[0,'九转斗尊巅峰','遭弟子韩枫背叛，灵魂寄于黑戒，辗转落入萧炎之手'],
      [0,'灵魂体','吸收萧炎三年斗气后苏醒，收其为徒'],
      [4,'灵魂体','授焚诀、八极崩、焰分噬浪尺，多次救萧炎于危难'],
      [6,'半圣','被魂殿掳走；萧炎以斗尊骨骸与造化圣者手臂骨为其炼体复活'],
      [6,'一星斗圣','服黄泉妖圣精血晋阶，重掌星陨阁'],
      [8,'一星斗圣','促成远古八族组成天府联盟'],
      [10,'斗圣','著《炎帝药典》传世，后随萧炎赴大千世界']]},
  { id:'xuner',name:'萧薰儿',title:'古薰儿 · 古族神品血脉 · 炎帝之妻',group:'古族',x:570,y:105,r:26,c:'#ff6b8a',
   final:'斗圣巅峰 · 金帝焚天炎',
   g:[[0,'斗之气','古族大小姐，自幼寄养萧家；萧炎落魄三年始终不离不弃'],
      [4,'斗宗','在迦南学院等萧炎两年，后为护萧炎返回古界'],
      [6,'斗尊','中州救萧炎于冰河谷、青海尊者之手'],
      [7,'斗尊','与萧炎同入天墓得萧玄相助；成人礼萧炎提亲，授五印帝印决'],
      [9,'斗圣巅峰','神品血脉觉醒金帝焚天炎；双帝战后与萧炎大婚'],
      [10,'斗圣','成无尽火域主母，后掌古族']]},
  { id:'cai',name:'彩鳞',title:'美杜莎女王 · 七彩/九彩吞天蟒 · 炎帝之妻',group:'蛇人族',x:920,y:250,r:26,c:'#ff6b8a',
   final:'斗帝 · 九彩吞天蟒（大千世界时期）',
   g:[[2,'斗宗','蛇人族女王，争夺青莲地心火时进化七彩吞天蟒，与萧炎结缘'],
      [3,'斗宗','三年之约现身惊退云山，常为萧炎保命符'],
      [4,'斗宗','陨落心炎煅烧，与吞天蟒灵魂融为一体'],
      [5,'斗宗','生下女儿萧潇；独坐镇炎盟，抗魂殿入侵'],
      [8,'五星斗尊→斗尊巅峰','服菩提大还丹与黄泉妖圣精血，九幽黄泉得吞天蟒传承'],
      [9,'四星斗圣','突破九彩吞天蟒，与萧炎、薰儿同办盛大婚礼'],
      [10,'斗帝','随萧炎赴大千世界，镇守无尽火域']]},
  { id:'xiaoyi',name:'小医仙',title:'毒宗宗主 · 天毒女 · 萧炎红颜知己',group:'主角团',x:810,y:700,r:22,c:'#4ec9b0',
   final:'一星斗圣 · 厄难毒体（已彻底炼化）',
   g:[[1,'斗者','青山镇结识萧炎，身具厄难毒体，修《七彩毒经》'],
      [5,'四星斗宗','成为毒宗宗主"天毒女"，受魂殿指示围攻加玛，后助萧炎化解危机'],
      [6,'六星斗宗','遭冰河谷追杀，落神涧被萧炎救下'],
      [6,'二星斗尊','凝练毒丹，初步控制厄难毒体'],
      [7,'七星斗尊','得前辈墓府功法，彻底炼化毒体'],
      [8,'一星斗圣','服黄泉妖圣精血晋阶，成萧炎一大助力'],
      [9,'一星斗圣','与彩鳞、青鳞联手拦下魂殿三天尊'],
      [10,'斗圣','回青山镇行医，后被萧炎邀回乌坦城']]},
  { id:'yunyun',name:'云韵',title:'云岚宗前宗主 · 花宗宗主 · 萧炎红颜知己',group:'主角团',x:960,y:540,r:22,c:'#4ec9b0',
   final:'八星斗尊',
   g:[[1,'三星斗皇','以"云芝"身份于魔兽山洞结识萧炎，是其认识的第一位斗皇'],
      [3,'斗皇','云岚宗宗主；云山将其许配古河，萧炎杀上云岚宗，云岚宗解散'],
      [6,'斗尊','中州得花婆婆传承，遭花锦迫害，萧炎助其夺回花宗宗主之位'],
      [8,'八星斗尊','率花宗加入天府联盟，共抗魂殿'],
      [9,'八星斗尊','大结局受萧炎邀请回加玛帝国，与萧炎保持故交']]},
  { id:'nalan',name:'纳兰嫣然',title:'纳兰家大小姐 · 云岚宗少宗主',group:'主角团',x:1080,y:120,r:18,c:'#c9a227',
   final:'高阶斗宗',
   g:[[0,'斗之气','15岁在云韵支持下瞒着家族前往萧家退婚，萧炎立下三年之约'],
      [3,'斗师','炼药师大会对化名"岩枭"的萧炎萌生情愫；三年之约一战落败'],
      [4,'斗灵','云岚宗覆灭后随云韵离开加玛，后加入花宗'],
      [7,'斗宗','天目山脉与萧炎重逢，过鼠潮音波阵得天山血潭洗礼'],
      [9,'高阶斗宗','随云韵回加玛，与萧炎化解旧怨']]},
  { id:'ziyan',name:'紫妍',title:'太虚古龙龙皇之女 · 新一代龙凰',group:'太虚古龙',x:610,y:760,r:22,c:'#4ec9b0',
   final:'四星斗圣后期 · 龙凰',
   g:[[4,'斗王','迦南学院内院强榜第一"蛮力王"，本体太虚古龙，与萧炎亲近'],
      [6,'斗尊','中州丹界助萧炎得三千焱炎火，参与营救药老'],
      [7,'斗尊','得龙凰本源果成晶体人，被萧炎异火救回；王族血脉大成'],
      [8,'四星斗圣后期','败北岛龙王，统一太虚古龙族'],
      [9,'斗圣','率古龙族支援天府联盟，与父亲烛坤相认']]},
  { id:'qinglin',name:'青鳞',title:'碧蛇三花瞳 · 萧炎追随者',group:'蛇人族',x:265,y:635,r:18,c:'#4ec9b0',
   final:'一星斗圣',
   g:[[2,'斗之气','漠铁佣兵团小侍女，碧蛇三花瞳，助萧炎找到青莲地心火莲座'],
      [2,'—','被墨家大长老觊觎劫走，天蛇府绿蛮等将其带走培养'],
      [7,'斗尊','远古遗址重逢，控十余位九幽地冥蟒强者；龙墓炼化九头天蛇晋六星斗尊'],
      [8,'一星斗圣','服黄泉妖圣精血晋阶，成为萧炎一大助力']]},
  { id:'yafei',name:'雅妃',title:'米特尔首席拍卖师 · 金之女皇',group:'主角团',x:120,y:510,r:18,c:'#4ec9b0',
   final:'斗皇 · 金之女皇',
   g:[[0,'—','米特尔拍卖行首席拍卖师，对萧炎心生好感，多次相助'],
      [4,'斗皇','萧炎被云岚宗追杀时冒死出手；海波东扶持其成米特尔掌权人'],
      [9,'斗皇','成西北地域首屈一指的产业大亨，服炎盟丹药达斗皇']]},
  { id:'xiaozhan',name:'萧战',title:'萧炎之父 · 萧家族长',group:'主角团',x:165,y:320,r:20,c:'#b18cff',
   final:'修为尽废（原著结局）',
   g:[[0,'大斗师','萧炎被视为废物的三年里始终给予鼓励'],
      [3,'—','云岚宗袭击萧家时被掳走，下落不明（实为魂殿带走）'],
      [8,'斗皇','被魂族以丹药提升至斗皇，萧炎以陀舍古帝玉交换救回'],
      [9,'修为尽废','获救后隐居加玛帝国']]},
  { id:'xiaoding',name:'萧鼎',title:'萧炎大哥 · 前漠铁佣兵团团长',group:'主角团',x:360,y:55,r:16,c:'#b18cff',
   final:'斗皇（原著中后期的炎盟核心）',
   g:[[0,'斗师','萧家长子，木属斗气，照顾弟妹'],
      [5,'斗皇','与萧厉共同主持炎盟，并与彩鳞完成萧家简单婚礼'],
      [9,'斗皇','坐镇加玛，守护萧家与炎盟']]},
  { id:'haibo',name:'海波东',title:'冰皇 · 米特尔家族守护者',group:'主角团',x:105,y:700,r:18,c:'#4ec9b0',
   final:'斗皇',
   g:[[2,'斗皇','被封印的斗皇，萧炎助其恢复实力，从此护道左右'],
      [3,'斗皇','三年之约时为萧炎护法；扶持雅妃掌米特尔家族'],
      [5,'斗皇','炎盟元老，守护加玛帝国']]},
  { id:'guyuan',name:'古元',title:'古族族长 · 薰儿之父',group:'古族',x:830,y:100,r:20,c:'#b18cff',
   final:'九星斗圣巅峰',
   g:[[6,'九星斗圣','起初因血脉之故反对萧炎与薰儿婚事'],
      [7,'九星斗圣','天墓后默许二人；率古族参与对抗魂族'],
      [9,'九星斗圣巅峰','双帝之战中参战；后随萧炎赴大千世界']]},
  { id:'zhukun',name:'烛坤',title:'太虚古龙族老龙皇 · 紫妍之父',group:'太虚古龙',x:405,y:745,r:18,c:'#b18cff',
   final:'九星斗圣巅峰',
   g:[[8,'九星斗圣巅峰','被困古帝洞府，为萧炎指明陀舍古帝传承之地'],
      [9,'九星斗圣巅峰','助萧炎获古帝传承，与紫妍父女相认'],
      [10,'斗圣','随萧炎赴大千世界']]},
  { id:'hanfeng',name:'韩枫',title:'药老叛徒 · 黑角域炼药师',group:'敌对阵营',x:150,y:110,r:16,c:'#ff5a4e',
   final:'斗宗（已亡于萧炎）',
   g:[[0,'斗宗','背叛恩师药尘，致其沦为灵魂体'],
      [4,'斗宗','黑角域与萧炎为敌，被萧炎击败击杀，灵魂被擒']]},
  { id:'hun',name:'魂天帝',title:'魂族族长 · 终极宿敌 · 血帝',group:'敌对阵营',x:1075,y:720,r:24,c:'#ff5a4e',
   final:'斗帝 · 血帝（被萧炎封印）',
   g:[[5,'斗圣','魂殿幕后黑手，掳走药老，图谋萧家陀舍古帝玉'],
      [8,'斗圣巅峰','屠灭灵族、药族等远古八族'],
      [9,'斗帝 · 血帝','集齐八玉开启古帝洞府，炼化帝品雏丹成就斗帝'],
      [9,'斗帝','双帝之战中被萧炎以帝炎、异火恒古尺封印于异火广场']]},
  { id:'xiaoxiao',name:'萧潇',title:'萧炎与彩鳞之女',group:'主角',x:1080,y:390,r:18,c:'#ffd45e',
   final:'八星斗圣（萧炎成帝时）',
   g:[[5,'出生即斗宗','萧炎与彩鳞之女，天赋惊才绝艳'],
      [9,'八星斗圣','萧炎晋升斗帝之时已达八星斗圣'],
      [10,'—','《大主宰》中与牧尘相遇']]}
]
const E = [
  ['yao','yan','master','授业恩师'],['xuner','yan','spouse','青梅 · 妻'],['cai','yan','spouse','妻 · 炎盟'],
  ['xiaoyi','yan','love','红颜知己'],['yunyun','yan','love','红颜 · 纠葛'],['yafei','yan','love','红颜 · 相护'],
  ['nalan','yan','rival','退婚 · 三年之约'],['ziyan','yan','ally','挚友 · 龙凰'],['qinglin','yan','ally','侍女 · 追随'],
  ['haibo','yan','ally','冰皇 · 护道'],['xiaozhan','yan','family','父亲'],['xiaoding','yan','family','大哥'],
  ['xiaoxiao','yan','family','女儿'],['hanfeng','yan','enemy','叛徒来袭'],['hun','yan','enemy','终极宿敌'],
  ['guyuan','xuner','family','父女'],['zhukun','ziyan','family','父女'],['cai','xiaoxiao','family','母女'],
  ['yao','hanfeng','master','师徒 · 背叛'],['yunyun','nalan','master','师徒']
]

export default {
  name: 'Journey',
  components: { TopNav },
  data() {
    return {
      TIER, REL, ARCS, chars: C, links: E,
      byId: Object.fromEntries(C.map(c => [c.id, c])),
      view: 'graph',
      light: document.body.classList.contains('light'),
      offRel: [],
      sel: null,
      detailOpen: false,
      current: null,
      groups: [...new Set(C.map(c => c.group))],
      activeGroups: [...new Set(C.map(c => c.group))],
      tip: { show: false, x: 0, y: 0, data: {} },
      vb: { x: 0, y: 0, w: 1200, h: 900 },
      zoom: 1,
      dragging: false, px: 0, py: 0
    }
  },
  computed: {
    viewBox() { return `${this.vb.x} ${this.vb.y} ${this.vb.w} ${this.vb.h}` },
    visibleLinks() { return this.links.filter(l => !this.offRel.includes(l[2])) },
    filteredChars() { return this.chars.filter(c => this.activeGroups.includes(c.group)) }
  },
  methods: {
    tier,
    avatar(id) { return '/characters/' + id + '_avatar.jpg' },
    imgFallback(e, c) {
      const el = e.target
      el.style.display = 'none'
      const box = el.parentElement
      box.textContent = c.name.slice(-1)
      box.style.background = c.c
      box.style.color = '#0c0a09'
      box.style.display = 'grid'
      box.style.placeItems = 'center'
    },
    switchView(v) { this.view = v; this.closeDetail() },
    toggleRel(k) {
      const i = this.offRel.indexOf(k)
      if (i >= 0) this.offRel.splice(i, 1); else this.offRel.push(k)
    },
    toggleGroup(gp) {
      const i = this.activeGroups.indexOf(gp)
      if (i >= 0) this.activeGroups.splice(i, 1); else this.activeGroups.push(gp)
    },
    milestones(c, ai) { return c.g.filter(x => x[0] === ai) },
    nodeDim(id) {
      if (!this.sel || id === this.sel) return false
      return !this.links.some(([a, b]) => (a === this.sel && b === id) || (b === this.sel && a === id))
    },
    linkDim(l) { return !!this.sel && l[0] !== this.sel && l[1] !== this.sel },
    linkHot(l) { return !!this.sel && (l[0] === this.sel || l[1] === this.sel) },
    showTip(e, c) {
      this.tip.data = c
      this.tip.show = true
      this.tip.x = Math.min(e.clientX + 16, window.innerWidth - 260)
      this.tip.y = Math.min(e.clientY + 16, window.innerHeight - 130)
    },
    hideTip() { this.tip.show = false },
    select(id) {
      this.sel = id
      this.current = this.byId[id]
      this.detailOpen = true
    },
    closeDetail() { this.detailOpen = false; this.sel = null },
    relationsOf(id) {
      return this.links.filter(l => l[0] === id || l[1] === id)
        .map(l => ({ other: l[0] === id ? l[1] : l[0], t: l[2], label: l[3] }))
    },
    resetGraph() { this.vb = { x: 0, y: 0, w: 1200, h: 900 }; this.zoom = 1; this.closeDetail() },
    onDown(e) {
      if (e.target.closest('.node')) return
      this.dragging = true; this.px = e.clientX; this.py = e.clientY
    },
    onMove(e) {
      if (!this.dragging || !this.$refs.svg) return
      const k = this.vb.w / this.$refs.svg.getBoundingClientRect().width
      this.vb.x -= (e.clientX - this.px) * k
      this.vb.y -= (e.clientY - this.py) * k
      this.px = e.clientX; this.py = e.clientY
    },
    onUp() { this.dragging = false },
    onWheel(e) {
      this.zoom = Math.min(2.4, Math.max(.55, this.zoom * (e.deltaY > 0 ? .9 : 1.1)))
      this.vb.w = 1200 / this.zoom
      this.vb.h = 900 / this.zoom
    }
  },
  mounted() {
    window.addEventListener('mousemove', this.onMove)
  },
  beforeUnmount() {
    window.removeEventListener('mousemove', this.onMove)
  }
}
</script>

<style scoped>
.journey-page { min-height: 100vh; padding-bottom: 30px; }
.head { text-align: center; padding: 36px 20px 6px; }
.head h1 { font-size: 30px; letter-spacing: 12px; color: var(--gold2); font-weight: 800;
  text-shadow: 0 0 24px rgba(212,175,55,.4); }
.slogan { margin-top: 9px; font-size: 12.5px; letter-spacing: 3px; color: var(--muted); }

.tabs { display: flex; justify-content: center; gap: 10px; margin: 18px 0; flex-wrap: wrap; padding: 0 20px; }
.tab { padding: 9px 24px; border: 1px solid var(--line); border-radius: 20px;
  background: rgba(0,0,0,.25); color: var(--muted); font-size: 13px; letter-spacing: 2px;
  cursor: pointer; transition: .2s; }
.tab:hover { color: var(--gold2); border-color: var(--gold); }
.tab.on { color: #1a1206; font-weight: 700; border-color: var(--gold2);
  background: linear-gradient(90deg,#c99a2e,#f5d76e,#c99a2e); box-shadow: 0 0 18px rgba(212,175,55,.3); }

.panel { max-width: 1180px; margin: 0 auto; border: 1px solid var(--line); border-radius: 12px;
  background: var(--panel); overflow: hidden; }
.bar { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; padding: 10px 14px;
  border-bottom: 1px solid var(--line); }
.hint { font-size: 11.5px; color: var(--muted); margin-right: auto; }
.legend { display: flex; gap: 13px; flex-wrap: wrap; }
.lg { display: inline-flex; align-items: center; gap: 6px; font-size: 11.5px; color: var(--label); cursor: pointer; user-select: none; }
.lg.off { opacity: .32; }
.lg i { width: 16px; height: 0; border-top: 2px solid; display: inline-block; }
.btn { height: 28px; padding: 0 13px; border-radius: 7px; cursor: pointer; font-size: 12px;
  color: var(--muted); background: transparent; border: 1px solid rgba(212,175,55,.28); }
.btn:hover { color: var(--gold2); border-color: var(--gold); }

.graph { width: 100%; height: 660px; display: block; cursor: grab; }
.graph:active { cursor: grabbing; }
.node { cursor: pointer; }
.nname { fill: var(--text); }
.nsub { fill: var(--label); }
.elabel { pointer-events: none; }
.node.dim { opacity: .16; }

.filters { display: flex; gap: 8px; flex-wrap: wrap; padding: 12px 14px; border-bottom: 1px solid var(--line); }
.chip { padding: 5px 13px; border-radius: 14px; border: 1px solid rgba(212,175,55,.25);
  background: rgba(0,0,0,.25); color: var(--muted); font-size: 11.5px; cursor: pointer; transition: .2s; }
.chip.on { color: #1a1206; background: var(--gold2); border-color: var(--gold2); font-weight: 700; }
.gridScroll { overflow: auto; max-height: 680px; }
.grid { min-width: 2560px; }
.row { display: flex; border-bottom: 1px solid rgba(212,175,55,.08); }
.row.head { position: sticky; top: 0; z-index: 5; background: var(--panel-solid); }
.cellName { width: 150px; min-width: 150px; position: sticky; left: 0; z-index: 4;
  background: var(--panel-solid); padding: 10px 12px; border-right: 1px solid var(--line);
  display: flex; align-items: center; gap: 9px; }
.row.head .cellName { z-index: 7; font-size: 12px; letter-spacing: 2px; color: var(--gold2); }
.ava { width: 30px; height: 30px; border-radius: 50%; flex: none; display: grid; place-items: center;
  font-size: 12px; color: #0c0a09; font-weight: 800; overflow: hidden; border: 1px solid var(--line); }
.ava img { width: 100%; height: 100%; object-fit: cover; display: block; }
.nm { font-size: 12.5px; color: var(--text); line-height: 1.3; }
.nm small { display: block; color: var(--muted); font-size: 10px; margin-top: 2px; }
.arcCol { width: 224px; min-width: 224px; padding: 8px 10px; border-right: 1px solid rgba(212,175,55,.08); }
.row.head .arcCol { font-size: 11.5px; color: var(--gold2); letter-spacing: 1px; font-weight: 600; }
.row.head .arcCol small { display: block; color: var(--label); font-size: 9.5px; letter-spacing: 0; margin-top: 3px; font-weight: 400; }
.ms { border-radius: 8px; padding: 7px 9px; margin: 2px 0; cursor: pointer;
  background: rgba(127,127,127,.07); border: 1px solid var(--line); border-left-width: 3px; transition: .2s; }
.ms:hover { background: rgba(212,175,55,.14); border-color: var(--gold); }
.ms .r { font-size: 11px; font-weight: 700; }
.ms .e { font-size: 10.5px; color: var(--muted); line-height: 1.5; margin-top: 3px; }
.empty { min-height: 52px; }

#jtip { position: fixed; z-index: 60; pointer-events: none; padding: 9px 12px; border-radius: 8px;
  border: 1px solid var(--line); background: var(--panel-solid); box-shadow: var(--shadow);
  font-size: 12px; line-height: 1.7; color: var(--text); max-width: 240px; }
#jtip b { color: var(--gold2); font-size: 13px; }

.detail { position: fixed; top: 0; right: 0; width: 400px; max-width: 92vw; height: 100vh; z-index: 50;
  background: linear-gradient(160deg, var(--panel-solid), var(--panel-solid));
  border-left: 1px solid var(--gold); box-shadow: -18px 0 50px rgba(0,0,0,.7);
  transform: translateX(105%); transition: transform .3s ease; overflow-y: auto; padding: 26px 24px 50px; }
.detail.open { transform: translateX(0); }
.close { position: absolute; top: 16px; right: 18px; width: 30px; height: 30px; border-radius: 50%;
  border: 1px solid var(--line); background: transparent; color: var(--muted); cursor: pointer; font-size: 16px; }
.close:hover { color: var(--gold2); border-color: var(--gold); }
.dHead { display: flex; align-items: center; gap: 14px; margin: 6px 0 14px; padding-right: 34px; }
.dAva { width: 62px; height: 62px; border-radius: 50%; flex: none; display: grid; place-items: center;
  font-size: 24px; color: #0c0a09; font-weight: 800; overflow: hidden; border: 2px solid var(--gold); }
.dAva img { width: 100%; height: 100%; object-fit: cover; display: block; }
.dName { font-size: 23px; color: var(--gold2); letter-spacing: 2px; }
.dTitle { font-size: 11.5px; color: var(--muted); margin-top: 5px; line-height: 1.6; }
.dMeta { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 20px; }
.pill { font-size: 11px; padding: 4px 10px; border-radius: 12px; border: 1px solid var(--line); color: var(--label); }
.pill b { color: var(--gold2); }
.dSec { font-size: 12px; color: var(--gold); letter-spacing: 3px; margin: 22px 0 12px;
  padding-bottom: 7px; border-bottom: 1px solid var(--line); }
.rel { display: flex; align-items: center; gap: 9px; font-size: 11.5px; padding: 6px 0; color: var(--label); cursor: pointer; }
.rel:hover { color: var(--gold2); }
.rel i { width: 7px; height: 7px; border-radius: 50%; flex: none; }
.rel span { color: var(--muted); }
.tl { position: relative; padding-left: 20px; }
.tl::before { content: ""; position: absolute; left: 5px; top: 6px; bottom: 6px; width: 1px; background: var(--line); }
.ev { position: relative; margin-bottom: 15px; }
.ev::before { content: ""; position: absolute; left: -18px; top: 5px; width: 9px; height: 9px; border-radius: 50%;
  background: var(--gold2); box-shadow: 0 0 8px var(--gold2); }
.stage { font-size: 10.5px; color: var(--label); letter-spacing: 1px; }
.realm { display: inline-block; font-size: 11px; font-weight: 700; padding: 2px 8px; border-radius: 10px; margin: 4px 0 5px; color: #0c0a09; }
.txt { font-size: 11.5px; color: var(--label); line-height: 1.65; }
footer { text-align: center; font-size: 11px; color: var(--label); line-height: 1.9; margin-top: 26px; }

body.light .tab { background: rgba(255,255,255,.7); }
@media (max-width: 760px) { .graph { height: 500px; } .hint { display: none; } .detail { width: 100%; } }
</style>
