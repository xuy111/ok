<template>
  <div class="cg-page">
    <TopNav active="cg" />
    <header class="cg-head">
      <div class="cg-eyebrow"><i></i> MOTION ARCHIVE · 动态典藏</div>
      <h1>名场面 <em>CG</em></h1>
      <p class="cg-sub">那些只在动起来时才真正炸开的瞬间——炎帝的尺、女王的蟒、药尊者的火。<br />点选右侧片段，播放器来自抖音官方。</p>
      <div class="cg-note">
        <span class="dot"></span>
        视频由抖音官方播放器提供，本站不转存文件。当前为<strong>通道演示源</strong>，替换视频 ID 即为对应 CG。
      </div>
    </header>

    <div class="cg-layout">
      <!-- 选片列表 -->
      <aside class="cg-list">
        <div class="cg-list-title">片段 <span>{{ VIDEOS.length }}</span></div>
        <button
          v-for="(v, i) in VIDEOS"
          :key="v.id"
          class="cg-item"
          :class="{ on: cur.id === v.id }"
          :style="{ '--c': CHAR_COLOR[v.char] }"
          @click="pick(v)"
        >
          <span class="ci-thumb">
            <img :src="v.cover" :alt="v.title" />
            <i v-if="v.demo" class="ci-demo">演示</i>
          </span>
          <span class="ci-body">
            <span class="ci-top"><b>{{ String(i + 1).padStart(2, '0') }}</b>{{ CHAR_NAME[v.char] }}</span>
            <strong>{{ v.title }}</strong>
            <em>{{ v.tag }}</em>
          </span>
        </button>

        <div class="cg-how">
          <b>换成你的斗破 CG</b>
          <p>抖音里挑好视频 → 分享复制链接 → 发我视频 ID，我填进 <code>cg.js</code>。或直接用下方粘贴框即时预览。</p>
          <input v-model.trim="inputId" @keyup.enter="applyId" placeholder="粘贴抖音链接 / 视频 ID" />
          <button @click="applyId">载入预览</button>
          <span v-if="msg" class="cg-msg" :class="{ bad: !msgOk }">{{ msg }}</span>
        </div>
      </aside>

      <!-- 播放器 -->
      <section class="cg-stage">
        <div class="stage-bar">
          <span class="sb-live"><i></i> NOW PLAYING</span>
          <span class="sb-title">{{ cur.title }}</span>
          <a class="sb-open" :href="douyinLink" target="_blank" rel="noopener" title="在抖音打开原视频">在抖音打开 ↗</a>
        </div>

        <div class="stage-frame" :style="{ '--c': CHAR_COLOR[cur.char] }">
          <iframe
            :key="frameKey"
            :src="src"
            frameborder="0"
            scrolling="no"
            allowfullscreen="true"
            referrerpolicy="unsafe-url"
            allow="autoplay; fullscreen; encrypted-media"
          ></iframe>
        </div>

        <div class="stage-foot">
          <div class="sf-who">
            <img :src="'/characters/' + cur.char + '_avatar.jpg'" :alt="CHAR_NAME[cur.char]" />
            <div>
              <b>{{ CHAR_NAME[cur.char] }}</b>
              <span>{{ cur.tag }}</span>
            </div>
          </div>
          <p class="sf-desc">{{ cur.desc }}</p>
        </div>
      </section>
    </div>

    <footer class="cg-footer">
      视频版权归原作者及平台所有，本站通过官方播放器嵌入展示，未做下载或转存。
    </footer>
  </div>
</template>

<script>
import { VIDEOS, CHAR_COLOR, CHAR_NAME, playerUrl, parseDouyinId } from '../cg'
import TopNav from '../components/TopNav.vue'

export default {
  name: 'CgWall',
  components: { TopNav },
  data() {
    return {
      VIDEOS, CHAR_COLOR, CHAR_NAME,
      cur: VIDEOS[0],
      frameKey: 0,
      inputId: '',
      msg: '',
      msgOk: true,
      custom: null   // 用户临时载入的视频 ID
    }
  },
  computed: {
    src() {
      const vid = this.custom && this.custom.char === this.cur.id ? this.custom.vid : this.cur.vid
      return playerUrl(vid, 1)
    },
    douyinLink() {
      const vid = this.custom && this.custom.char === this.cur.id ? this.custom.vid : this.cur.vid
      return 'https://www.douyin.com/video/' + vid
    }
  },
  methods: {
    pick(v) {
      this.cur = v
      this.frameKey++
      this.msg = ''
    },
    applyId() {
      const id = parseDouyinId(this.inputId)
      if (!id) {
        this.msgOk = false
        this.msg = '没识别出视频 ID。若是 v.douyin.com 短链，请打开后把地址栏的完整链接发我。'
        return
      }
      this.custom = { char: this.cur.id, vid: id }
      this.frameKey++
      this.msgOk = true
      this.msg = '已载入：' + id
    }
  }
}
</script>

<style scoped>
.cg-page {
  min-height: 100vh; padding: 34px clamp(18px, 4vw, 64px) 40px;
  color: var(--text); position: relative;
}
.cg-head { max-width: 1180px; margin: 0 auto 30px; }
.cg-eyebrow {
  display: flex; align-items: center; gap: 9px; font-size: 11px;
  letter-spacing: 3px; color: var(--label);
}
.cg-eyebrow i { width: 22px; height: 1px; background: var(--gold); display: inline-block; }
.cg-head h1 {
  margin: 12px 0 10px; font-size: clamp(38px, 6vw, 64px); font-weight: 800;
  letter-spacing: 8px; color: var(--gold); line-height: 1.05;
  text-shadow: 0 2px 24px rgba(255, 140, 66, .25);
}
.cg-head h1 em {
  font-style: normal; font-family: Georgia, serif; font-size: .82em;
  color: var(--text); letter-spacing: 2px;
}
.cg-sub { font-size: 13px; line-height: 1.9; color: var(--muted); letter-spacing: .5px; }
.cg-note {
  display: inline-flex; align-items: center; gap: 9px; margin-top: 16px;
  padding: 9px 15px; border: 1px solid var(--line); border-radius: 20px;
  font-size: 11px; color: var(--label); background: var(--panel);
}
.cg-note .dot { width: 6px; height: 6px; border-radius: 50%; background: #4aa8d8; box-shadow: 0 0 9px #4aa8d8; }
.cg-note strong { color: var(--gold2); font-weight: 500; }

.cg-layout {
  max-width: 1180px; margin: 0 auto; display: grid;
  grid-template-columns: 320px minmax(0, 1fr); gap: 26px; align-items: start;
}

/* ---- 选片列表 ---- */
.cg-list { display: flex; flex-direction: column; gap: 11px; }
.cg-list-title {
  font-size: 12px; letter-spacing: 3px; color: var(--label);
  padding-bottom: 10px; border-bottom: 1px solid var(--line);
}
.cg-list-title span { color: var(--gold); margin-left: 6px; }
.cg-item {
  display: grid; grid-template-columns: 78px minmax(0, 1fr); gap: 12px;
  align-items: center; text-align: left; cursor: pointer;
  padding: 9px; border: 1px solid var(--line); border-radius: 10px;
  background: var(--panel); color: var(--text); transition: .25s;
}
.cg-item:hover { border-color: var(--c); transform: translateX(3px); }
.cg-item.on {
  border-color: var(--c);
  box-shadow: inset 3px 0 0 var(--c), 0 6px 24px rgba(0, 0, 0, .28);
  background: color-mix(in srgb, var(--c) 8%, var(--panel));
}
.ci-thumb { position: relative; width: 78px; height: 56px; border-radius: 5px; overflow: hidden; background: #15100c; }
.ci-thumb img { width: 100%; height: 100%; object-fit: cover; display: block; }
.ci-demo {
  position: absolute; top: 3px; right: 3px; font-size: 8.5px; font-style: normal;
  padding: 1px 5px; border-radius: 3px; background: rgba(0, 0, 0, .72);
  color: #f5d76e; border: 1px solid rgba(245, 215, 110, .5);
}
.ci-body { min-width: 0; display: flex; flex-direction: column; gap: 3px; }
.ci-top { display: flex; align-items: center; gap: 7px; font-size: 10px; color: var(--label); letter-spacing: 1px; }
.ci-top b { color: var(--c); font-family: Georgia, serif; font-size: 12px; }
.ci-body strong { font-size: 14px; letter-spacing: 2px; color: var(--tone, var(--gold2)); }
.ci-body em {
  font-size: 10.5px; font-style: normal; color: var(--muted);
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}

.cg-how {
  margin-top: 8px; padding: 15px; border: 1px dashed var(--line);
  border-radius: 10px; background: var(--panel);
}
.cg-how b { font-size: 12px; color: var(--gold2); letter-spacing: 1px; }
.cg-how p { font-size: 10.5px; line-height: 1.75; color: var(--muted); margin: 8px 0 11px; }
.cg-how code { color: var(--gold); font-size: 10px; }
.cg-how input {
  width: 100%; box-sizing: border-box; padding: 8px 10px; font-size: 11px;
  color: var(--text); background: var(--bg, #14100c);
  border: 1px solid var(--line); border-radius: 6px; outline: none;
}
.cg-how input:focus { border-color: var(--gold); }
.cg-how button {
  width: 100%; margin-top: 8px; padding: 8px; cursor: pointer; font-size: 11px;
  letter-spacing: 2px; color: #17120c; font-weight: 600;
  background: linear-gradient(135deg, var(--gold), var(--gold2)); border: 0; border-radius: 6px;
}
.cg-msg { display: block; margin-top: 8px; font-size: 10px; color: #6fc9a6; line-height: 1.5; }
.cg-msg.bad { color: #e07b6a; }

/* ---- 播放器 ---- */
.cg-stage {
  border: 1px solid var(--line); border-radius: 14px; overflow: hidden;
  background: var(--panel); box-shadow: 0 18px 60px rgba(0, 0, 0, .35);
}
.stage-bar {
  display: flex; align-items: center; gap: 14px; padding: 13px 18px;
  border-bottom: 1px solid var(--line); background: rgba(0, 0, 0, .16);
}
.sb-live {
  display: inline-flex; align-items: center; gap: 7px; font-size: 10px;
  letter-spacing: 2px; color: var(--label);
}
.sb-live i { width: 7px; height: 7px; border-radius: 50%; background: #e24b4a; box-shadow: 0 0 10px #e24b4a; }
.sb-title { font-size: 13px; letter-spacing: 3px; color: var(--gold2); font-weight: 600; }
.sb-open {
  margin-left: auto; font-size: 10.5px; color: var(--muted);
  text-decoration: none; border: 1px solid var(--line);
  padding: 5px 10px; border-radius: 14px; transition: .2s;
}
.sb-open:hover { color: var(--gold); border-color: var(--gold); }

.stage-frame {
  position: relative; width: 100%; aspect-ratio: 16 / 9;
  background: #080605; border-bottom: 1px solid var(--line);
}
.stage-frame::before {
  content: ''; position: absolute; inset: -1px; z-index: 0; pointer-events: none;
  border: 1px solid color-mix(in srgb, var(--c) 40%, transparent);
}
.stage-frame iframe {
  position: absolute; inset: 0; width: 100%; height: 100%;
  border: 0; display: block; background: #080605;
}

.stage-foot { padding: 16px 18px; display: flex; flex-direction: column; gap: 12px; }
.sf-who { display: flex; align-items: center; gap: 11px; }
.sf-who img {
  width: 40px; height: 40px; border-radius: 50%; object-fit: cover;
  border: 1.5px solid var(--c); flex: none;
}
.sf-who b { display: block; font-size: 13px; color: var(--text); letter-spacing: 2px; }
.sf-who span { display: block; font-size: 10.5px; color: var(--muted); margin-top: 3px; }
.sf-desc {
  margin: 0; font-size: 11.5px; line-height: 1.85; color: var(--muted);
  padding-left: 12px; border-left: 2px solid var(--line);
}

.cg-footer {
  max-width: 1180px; margin: 26px auto 0; padding-top: 16px;
  border-top: 1px solid var(--line); font-size: 10.5px; color: var(--label); text-align: center;
}

@media (max-width: 900px) {
  .cg-layout { grid-template-columns: 1fr; }
  .cg-list { order: 2; }
  .cg-stage { order: 1; }
  .cg-head h1 { letter-spacing: 4px; }
}

/* 无障碍：减少动效 */
@media (prefers-reduced-motion: reduce) {
  .cg-item, .sb-open { transition: none !important; }
}
</style>
