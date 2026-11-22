/**
 * 异火插图映射
 * 1) 优先用数据库 t_item.image 字段（后台可改）
 * 2) 老库没有 image 字段时，按名称兜底，保证图片不会突然消失
 */
const NAME_ART = {
  '帝炎': '/fire/diyan.jpg',
  '虚无吞炎': '/fire/xuwu.jpg',
  '净莲妖火': '/fire/jinglian.jpg',
  '金帝焚天炎': '/fire/jindi.jpg',
  '生灵之焱': '/fire/shengling.jpg',
  '八荒破灭炎': '/fire/bahuang.jpg',
  '九幽风炎': '/fire/jiuyou.jpg',
  '骨灵冷火': '/fire/guling.jpg',
  '三千焱炎火': '/fire/sanqian.jpg',
  '青莲地心火': '/fire/qinglian.jpg',
  '陨落心炎': '/fire/yunluo.jpg',
  '海心焰': '/fire/haixin.jpg',
  // 功法
  '焚决': '/item/fenjue.jpg',
  '天火三玄变': '/item/tianhuo.jpg',
  '青木诀': '/item/qingmu.jpg',
  // 斗技
  '大天造化掌': '/item/datian.jpg',
  '焰分噬浪尺': '/item/yanfen.jpg',
  '八极崩': '/item/bajibeng.jpg',
  '吸掌': '/item/xizhang.jpg',
  // 丹药
  '九转斗尊强体丹': '/item/jiuzhuan.jpg',
  '破厄丹': '/item/poedan.jpg',
  '三纹青灵丹': '/item/sanwen.jpg',
  '聚气散': '/item/juqisan.jpg',
  // 法宝
  '玄重尺': '/item/xuanchongchi.jpg',
  '黑魔鼎': '/item/heimoding.jpg',
  '纳戒': '/item/najie.jpg',
  '魔兽山脉短刃': '/item/duanren.jpg'
}

/**
 * 取条目插图地址，没有则返回空串（调用方回退到 emoji 图标）。
 * 优先用数据库 image（后台可改）；只要它是空串 / null / 缺失，就按名称兜底。
 * 这样某条数据的 image 被意外清空（新库字段没同步、后台误操作、老接口没返回该字段）时，
 * 原著 12 朵异火的插图也不会「凭空消失」变回 emoji 占位。
 */
export function artOf(item) {
  if (!item) return ''
  if (typeof item.image === 'string' && item.image.trim()) return item.image.trim()
  const name = (item.name || '').trim()
  return NAME_ART[name] || ''
}
