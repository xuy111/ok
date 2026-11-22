/**
 * 名场面动态 CG · 数据层
 * ------------------------------------------------------------------
 * 视频通过「抖音官方 iframe 播放器」嵌入，不下载、不转存，无版权转存风险。
 *
 * 【如何换成你想要的斗破 CG】
 *   1. 抖音 App 打开目标视频 → 点分享 → 复制链接
 *   2. 链接形如  https://v.douyin.com/xxxxx/  或  https://www.douyin.com/video/7357934509125389631
 *   3. 把链接发我，我解析出中间的纯数字 video_id，填进下面条目的 vid 字段即可
 *      （也可以直接用官方接口验证：
 *       https://open.douyin.com/api/douyin/v1/video/get_iframe_by_video?video_id=<数字> ）
 *
 * 字段说明：
 *   id       唯一键
 *   title    卡片标题
 *   char     对应角色 id（对应 gallery.js 的 CHARS）
 *   tag      一句话看点
 *   desc     弹层/侧栏 Description
 *   vid      抖音视频 ID（纯数字）
 *   cover    封面图（在换成真实 CG 前，先用照片墙的图占位）
 *   demo     true = 当前只是通道演示源，替换 vid 后即为该名场面 CG
 */
export const CHAR_COLOR = {
  yan: '#ff8c42', xuner: '#ff6b8a', cai: '#a06fd6',
  haibo: '#4aa8d8', yao: '#f5d76e', yunyun: '#5fc9c0'
}

export const CHAR_NAME = {
  yan: '萧炎', xuner: '萧薰儿', cai: '彩鳞',
  haibo: '海波东', yao: '药老', yunyun: '云韵'
}

export const VIDEOS = [
  {
    id: 'cg-yan',
    title: '炎帝临世',
    char: 'yan',
    tag: '二十二火归一，一尺镇乾坤。',
    desc: '抖音「我以炎帝萧炎之名」相关名场面。视频由抖音官方播放器承载，本站不下载、不转存。',
    vid: '7710530048466456420',
    cover: '/gallery/yan-2.jpg',
    demo: false
  },
  {
    id: 'cg-xuner',
    title: '神女归位',
    char: 'xuner',
    tag: '金冠垂翠，古族神女。',
    desc: '抖音「小伊陪看斗破名场面之古薰儿」，聚焦古薰儿的高光片段。视频由抖音官方播放器承载，本站不下载、不转存。',
    vid: '7689044400110011377',
    cover: '/gallery/xuner-2.jpg',
    demo: false
  },
  {
    id: 'cg-cai',
    title: '九彩吞天',
    char: 'cai',
    tag: '女王睁眼，蛇人族万年第二。',
    desc: '抖音「九彩吞天蟒美杜莎」相关名场面。视频由抖音官方播放器承载，本站不下载、不转存。',
    vid: '7667920125937106277',
    cover: '/gallery/cai-2.jpg',
    demo: false
  },
  {
    id: 'cg-yao',
    title: '药尊者归来',
    char: 'yao',
    tag: '白袍胜雪，星陨阁主。',
    desc: '抖音「药老高燃」相关名场面。视频由抖音官方播放器承载，本站不下载、不转存。',
    vid: '7653482226428875761',
    cover: '/gallery/yao-2.jpg',
    demo: false
  }
]

/** 抖音官方播放器地址：video_id 直接拼出，无需申请权限 */
export function playerUrl(vid, autoplay = 1) {
  return `https://open.douyin.com/player/video?vid=${vid}&autoplay=${autoplay}`
}

/** 从抖音分享链接里提取纯数字 video_id */
export function parseDouyinId(text) {
  const s = String(text || '')
  // 直接给了一串数字
  if (/^\d{12,25}$/.test(s.trim())) return s.trim()
  // 视频页 /video/数字 或 modal_id=数字
  let m = s.match(/(?:video\/|modal_id=|vid=)(\d{12,25})/)
  if (m) return m[1]
  // 短链：交给抖音302，这里只提示
  return null
}
