/**
 * 灵魂力天赋测试 · 题库与判定
 *
 * 设计思路：不做「答对答错」，而是 5 道情境题各自给 4 个选项，
 * 每个选项偷偷加分到若干维度。最终按主维度取「属性」，按次维度取「道途」，
 * 拼成斗气大陆身份证上的天赋称号（例：木属性·天生炼药师）。
 */

/** 四个打分维度：五行属性偏向 + 行事风格 */
export const AXES = {
  fire:  { name: '火', full: '火属性', tone: '#ff6a3d' },
  wood:  { name: '木', full: '木属性', tone: '#5fbf7a' },
  metal: { name: '金', full: '金属性', tone: '#d8d2c4' },
  water: { name: '水', full: '水属性', tone: '#4aa8d8' },
  earth: { name: '土', full: '土属性', tone: '#b98a52' }
}

/**
 * 风格维度：决定「道途」后缀
 * - rage  狂暴    → 战斗型
 * - calm  沉稳    → 守望型
 * - craft 匠心    → 炼制型
 * - wit   机变    → 谋略型
 */
export const STYLES = {
  rage:  'rage',
  calm:  'calm',
  craft: 'craft',
  wit:   'wit'
}

/**
 * 5 道情境题。每个选项 a = { scores: { 维度: 分值 } }
 * 分值按 0.5 粒度设计，单题最多 3 点，方便差异化
 */
export const QUESTIONS = [
  {
    id: 'q1',
    scene: '荒漠边缘，你撞上一头三星斗灵级别的飞行魔兽。',
    hint: '它已经锁定了你，退路只有三十丈。',
    options: [
      { key: 'A', label: '直接莽', desc: '斗气全开，抢在它俯冲前贴身打', scores: { fire: 3, rage: 2 } },
      { key: 'B', label: '苟住发育', desc: '沉入沙下收敛气息，等它飞远', scores: { earth: 2, water: 1, calm: 2 } },
      { key: 'C', label: '摇人', desc: '放出信号玉简，呼叫附近同门', scores: { metal: 2, wit: 2 } },
      { key: 'D', label: '布阵取巧', desc: '撒出药粉引它撞进流沙陷坑', scores: { wood: 2, craft: 1, wit: 1 } }
    ]
  },
  {
    id: 'q2',
    scene: '拍卖行里，一卷残破的功法玉简被压到最低价。',
    hint: '残卷看不出品阶，摊主只肯打包出售。',
    options: [
      { key: 'A', label: '当场砸下全部身家', desc: '残卷必有大机缘，赌了', scores: { fire: 2, rage: 2 } },
      { key: 'B', label: '先摸清底细', desc: '花三天打听摊主来路再决定', scores: { water: 2, calm: 2 } },
      { key: 'C', label: '买回来慢慢拼', desc: '药鼎就是最好的实验室', scores: { wood: 2, craft: 3 } },
      { key: 'D', label: '联合几人合资', desc: '风险共担，情报共享', scores: { metal: 2, wit: 2 } }
    ]
  },
  {
    id: 'q3',
    scene: '你在药庐里守了三天三夜，丹炉开始不稳。',
    hint: '这一炉是给族中重伤长老救命的。',
    options: [
      { key: 'A', label: '强行提火', desc: '搏一把，成丹就成，炸就炸', scores: { fire: 3, rage: 2 } },
      { key: 'B', label: '压低火候', desc: '宁肯药效打折，也要保住这炉', scores: { wood: 2, water: 2, calm: 2 } },
      { key: 'C', label: '逐味调整药材', desc: '重新配平药性，找最小副作用的路', scores: { wood: 3, craft: 2 } },
      { key: 'D', label: '换一口老鼎', desc: '用家传的稳压炉重来一遍', scores: { earth: 2, metal: 1, craft: 1 } }
    ]
  },
  {
    id: 'q4',
    scene: '同门比试，你的对手是个擅长硬桥硬马的斗者。',
    hint: '台下长老正在看，输赢影响你的资源分配。',
    options: [
      { key: 'A', label: '正面硬刚', desc: '斗气碰撞，看谁先撑不住', scores: { fire: 2, metal: 2, rage: 1 } },
      { key: 'B', label: '游走消耗', desc: '借地形绕他，磨到他自己乱', scores: { water: 2, wit: 2 } },
      { key: 'C', label: '以柔卸力', desc: '顺着他力道反送回去', scores: { wood: 2, calm: 2 } },
      { key: 'D', label: '设伏一击', desc: '前面全是虚招，最后一击定胜负', scores: { metal: 2, wit: 2 } }
    ]
  },
  {
    id: 'q5',
    scene: '如果给你一种能力，你最想要什么？',
    hint: '别想太多，凭第一感觉。',
    options: [
      { key: 'A', label: '越打越强的肉身', desc: '拳拳到肉，谁也别想拦我', scores: { fire: 3, metal: 2, rage: 2 } },
      { key: 'B', label: '看透一切的眼睛', desc: '先看清，再出手', scores: { water: 2, wit: 3 } },
      { key: 'C', label: '让枯木回春的手', desc: '炼丹救人，长长久久', scores: { wood: 3, craft: 3 } },
      { key: 'D', label: '千百年不倒的根基', desc: '慢慢修，稳稳走', scores: { earth: 3, calm: 3 } }
    ]
  }
]

/**
 * 天赋档案库：按「主属性 + 主风格」匹配
 * 每个条目给：称号、身份、一段判词、推荐异火、初始属性
 */
const ARCHIVE = [
  {
    axis: 'wood', style: 'craft',
    title: '木属性·天生炼药师',
    role: '丹塔苗子',
    rank: '极品',
    desc: '你的灵魂力温润绵长，天生对药性敏感。别人靠鼻闻辨药，你靠魂力就能摸出药性之间的相冲。',
    verdict: '药鼎一开，草木皆知春。',
    fire: '生灵之焱',
    stats: { 魂力: 9, 感知: 9, 体魄: 5 }
  },
  {
    axis: 'fire', style: 'rage',
    title: '火属性·狂暴斗者',
    role: '斗气狂徒',
    rank: '天品',
    desc: '你的斗气天生暴躁，一动手就收不住。这种天赋在同阶斗者里是碾压级的，但也很容易把自己烧进去。',
    verdict: '一拳未至，风先裂了。',
    fire: '八荒破灭炎',
    stats: { 魂力: 8, 感知: 4, 体魄: 10 }
  },
  {
    axis: 'metal', style: 'rage',
    title: '金属性·金身斗士',
    role: '战堂打手',
    rank: '上品',
    desc: '你的斗气锋锐且凝实，最擅长正面凿穿对方的防御。缺点是变通不够，一被牵着走就难受。',
    verdict: '刀锋所向，无有坚壁。',
    fire: '金帝焚天炎',
    stats: { 魂力: 6, 感知: 6, 体魄: 9 }
  },
  {
    axis: 'water', style: 'wit',
    title: '水属性·千机谋士',
    role: '族中智囊',
    rank: '上品',
    desc: '你的斗气柔韧绵长，最擅长把局面拖到自己熟悉的水域里。别人跟你打，往往打着打着节奏就乱了。',
    verdict: '水无常形，局无定势。',
    fire: '海心焰',
    stats: { 魂力: 9, 感知: 8, 体魄: 4 }
  },
  {
    axis: 'earth', style: 'calm',
    title: '土属性·厚土守御',
    role: '镇山之人',
    rank: '上品',
    desc: '你的根基扎实得可怕，斗气沉在丹田里几乎不散。你出手慢，但一旦站定，很少有人能把你推走。',
    verdict: '万法压身，我自不移。',
    fire: '陨落心炎',
    stats: { 魂力: 6, 感知: 7, 体魄: 9 }
  },
  {
    axis: 'wood', style: 'calm',
    title: '木属性·药园守人',
    role: '养丹师',
    rank: '良品',
    desc: '你不求速成，偏爱一株一株地养。你的炼丹成丹率未必最高，但药性往往最稳，几乎不留暗伤。',
    verdict: '春来无声，草木自长。',
    fire: '生灵之焱',
    stats: { 魂力: 7, 感知: 8, 体魄: 6 }
  },
  {
    axis: 'fire', style: 'craft',
    title: '火属性·烈焰丹师',
    role: '异火控炉人',
    rank: '上品',
    desc: '你能把最暴烈的火压成最细的火候，别人烧炉你炼心。这是天生的控火天赋，炼丹时最难得的那口气。',
    verdict: '火在我手，不在我身。',
    fire: '骨灵冷火',
    stats: { 魂力: 8, 感知: 8, 体魄: 6 }
  },
  {
    axis: 'water', style: 'calm',
    title: '水属性·静水长老',
    role: '观星者',
    rank: '上品',
    desc: '你的魂力像深潭，外面看不出动静，底下早已把整盘棋算完。你不抢功，但功劳往往绕不开你。',
    verdict: '静水流深，不见其底。',
    fire: '三千焱炎火',
    stats: { 魂力: 9, 感知: 7, 体魄: 4 }
  },
  {
    axis: 'metal', style: 'wit',
    title: '金属性·暗刃刺客',
    role: '游走散修',
    rank: '良品',
    desc: '你的斗气擅长收敛，出手前几乎不露痕迹。你信的是「一击即退」，而不是跟人拼耐力。',
    verdict: '刃出无痕，刃归无影。',
    fire: '虚无吞炎',
    stats: { 魂力: 7, 感知: 9, 体魄: 5 }
  },
  {
    axis: 'earth', style: 'craft',
    title: '土属性·铸器宗师',
    role: '器坊主人',
    rank: '良品',
    desc: '你对材质和结构有种天然的直觉，什么火配什么矿，你上手就清楚。法宝在你手里比在别人手里多半阶。',
    verdict: '千锤之下，顽石成锋。',
    fire: '陨落心炎',
    stats: { 魂力: 7, 感知: 7, 体魄: 8 }
  },
  {
    axis: 'wood', style: 'wit',
    title: '木属性·百草药商',
    role: '坊市行商',
    rank: '良品',
    desc: '你懂药，更懂人。别人卖药你卖方子，一张方子能换三份人情，这在斗气大陆比丹药还值钱。',
    verdict: '药香十里，人情千斤。',
    fire: '生灵之焱',
    stats: { 魂力: 8, 感知: 8, 体魄: 4 }
  },
  {
    axis: 'fire', style: 'wit',
    title: '火属性·焚策书生',
    role: '谋火者',
    rank: '上品',
    desc: '你的火不拿来烧人，拿来烧局。你会算风向、算地形、算对方还剩几分斗气，然后一次性点着。',
    verdict: '不燃其身，先燃其势。',
    fire: '净莲妖火',
    stats: { 魂力: 9, 感知: 8, 体魄: 5 }
  },
  {
    axis: 'water', style: 'rage',
    title: '水属性·怒涛战修',
    role: '浪头前锋',
    rank: '上品',
    desc: '你看着耐性极好，真被逼急了，往往就是一波把对面整段路冲没的狠角色。',
    verdict: '水静时最深，动时最凶。',
    fire: '海心焰',
    stats: { 魂力: 7, 感知: 5, 体魄: 9 }
  },
  {
    axis: 'earth', style: 'rage',
    title: '土属性·撼山斗士',
    role: '山门力士',
    rank: '良品',
    desc: '你不太讲究招式，只讲究这一拳够不够沉。你的对手往往不是被你打退的，是被你压在地上的。',
    verdict: '山不自高，人自低首。',
    fire: '八荒破灭炎',
    stats: { 魂力: 5, 感知: 5, 体魄: 10 }
  },
  {
    axis: 'metal', style: 'calm',
    title: '金属性·执法堂主',
    role: '规矩守护',
    rank: '上品',
    desc: '你的斗气干净利落，最见不得拖泥带水。族里立规矩、断是非的活儿，交给你最稳妥。',
    verdict: '规矩既立，寸步不让。',
    fire: '金帝焚天炎',
    stats: { 魂力: 7, 感知: 7, 体魄: 8 }
  }
]

/** 五行相生：木→火→土→金→水→木（用于副属性说明） */
const GENERATE = { wood: 'fire', fire: 'earth', earth: 'metal', metal: 'water', water: 'wood' }

/**
 * 根据作答（每题选中的 option 对象数组）算出天赋
 * @param {Array} picked 选项对象数组，长度 = QUESTIONS.length
 */
export function evaluate(picked) {
  const axis = { fire: 0, wood: 0, metal: 0, water: 0, earth: 0 }
  const style = { rage: 0, calm: 0, craft: 0, wit: 0 }

  picked.forEach(opt => {
    if (!opt || !opt.scores) return
    Object.keys(opt.scores).forEach(k => {
      const v = opt.scores[k]
      if (k in axis) axis[k] += v
      else if (k in style) style[k] += v
    })
  })

  /** 取分值最高的一项，平手时按固定顺序保证结果稳定 */
  const top = obj => {
    const order = Object.keys(obj)
    let best = order[0]
    order.forEach(k => { if (obj[k] > obj[best]) best = k })
    return best
  }
  /** 取次高项（不同维度） */
  const second = (obj, exclude) => {
    const keys = Object.keys(obj).filter(k => k !== exclude)
    let best = keys[0]
    keys.forEach(k => { if (obj[k] > obj[best]) best = k })
    return best
  }

  const mainAxis = top(axis)
  const mainStyle = top(style)

  // 先精确匹配，匹配不到就用主属性里最接近风格的一条
  let hit = ARCHIVE.find(a => a.axis === mainAxis && a.style === mainStyle)
  if (!hit) {
    hit = ARCHIVE.find(a => a.axis === mainAxis) || ARCHIVE[0]
  }

  const subAxis = second(axis, mainAxis)
  const subStyle = second(style, mainStyle)

  // 灵魂力强度：总分归一 + 一点随机，避免所有人同分
  const total = Object.values(axis).reduce((a, b) => a + b, 0) +
    Object.values(style).reduce((a, b) => a + b, 0)
  const maxish = 34
  const jitter = Math.round((Math.random() - 0.5) * 6)
  const score = Math.max(40, Math.min(99, Math.round(48 + (total / maxish) * 44) + jitter))

  /** 星级：按灵魂力强度给 1~5 颗 */
  const stars = score >= 92 ? 5 : score >= 82 ? 4 : score >= 70 ? 3 : score >= 58 ? 2 : 1

  return {
    ...hit,
    score,
    stars,
    subAxis,
    subStyle,
    subAxisName: AXES[subAxis] ? AXES[subAxis].full : '',
    genAxis: GENERATE[mainAxis] || mainAxis,
    genAxisName: GENERATE[mainAxis] ? AXES[GENERATE[mainAxis]].full : '',
    tone: AXES[mainAxis] ? AXES[mainAxis].tone : '#d4af37',
    axisLabels: Object.keys(axis).map(k => ({
      key: k,
      name: AXES[k].full,
      value: axis[k],
      tone: AXES[k].tone,
      percent: Math.round((axis[k] / Math.max(1, Math.max(...Object.values(axis)))) * 100)
    }))
  }
}

/** 生成身份证编号：DP-年份-4位随机，存本地保证同一次结果不变 */
export function makeCertNo() {
  const y = new Date().getFullYear()
  const n = String(Math.floor(1000 + Math.random() * 9000))
  return `DP-${y}-${n}`
}
