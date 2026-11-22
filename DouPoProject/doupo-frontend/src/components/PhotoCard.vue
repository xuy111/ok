<template>
  <article class="pcard" :style="{ '--rot': rot + 'deg', '--tone': tone }" @click="$emit('open')">
    <span class="pin"></span>

    <div class="frame">
      <div class="shot" :style="{ aspectRatio: ratio }">
        <img :src="scene.img" :alt="scene.title" loading="lazy" decoding="async"
             :style="{ objectPosition: scene.pos || 'center' }" />
        <span class="sheen"></span>
        <span v-if="!scene.official" class="no">{{ scene.no }}</span>
        <span v-if="scene.official" class="chip-off">官方</span>
        <span class="chip-arc">{{ scene.realm }}</span>
        <div class="veil"><span>查看考据 →</span></div>
      </div>

      <div class="cap">
        <b>{{ scene.title }}</b>
        <i>{{ scene.tag }}</i>
      </div>
    </div>
  </article>
</template>

<script>
export default {
  name: 'PhotoCard',
  props: {
    scene: { type: Object, required: true },
    tone: { type: String, default: '#f5d76e' },
    /** 照片区宽高比：名场面是竖构图，官方形象照传 '16 / 9' */
    ratio: { type: String, default: '1024 / 1452' }
  },
  emits: ['open'],
  computed: {
    /** 每张照片手工贴上去的错觉：正负 1.8 度内交替倾斜 */
    rot() {
      return this.scene.rot != null ? this.scene.rot : 0
    }
  }
}
</script>

<style scoped>
.pcard {
  position: relative;
  cursor: pointer;
  transform: rotate(var(--rot));
  transition: transform .38s cubic-bezier(.2, .8, .25, 1), filter .3s;
  will-change: transform;
}
.pcard:hover { transform: rotate(0deg) translateY(-10px) scale(1.025); z-index: 3; }

/* 图钉 */
.pin {
  position: absolute; top: -7px; left: 50%; width: 13px; height: 13px; margin-left: -6.5px;
  border-radius: 50%; z-index: 5;
  background: radial-gradient(circle at 34% 30%, #fff6d8, var(--tone) 42%, #7a5c1a 100%);
  box-shadow: 0 3px 7px rgba(0, 0, 0, .55), 0 0 12px color-mix(in srgb, var(--tone) 55%, transparent);
}
.pin::after {
  content: ""; position: absolute; left: 50%; top: 11px; width: 1px; height: 7px;
  background: linear-gradient(var(--tone), transparent); opacity: .7;
}

/* 相框：泛黄的相纸 */
.frame {
  position: relative; padding: 9px 9px 0; border-radius: 2px;
  background: linear-gradient(168deg, #fffaf0 0%, #f7eeda 52%, #eee0c2 100%);
  box-shadow: 0 22px 40px -18px rgba(0, 0, 0, .85), 0 0 0 1px rgba(255, 255, 255, .07);
  transition: box-shadow .38s;
}
.pcard:hover .frame {
  box-shadow: 0 30px 56px -18px rgba(0, 0, 0, .9),
              0 0 0 1px color-mix(in srgb, var(--tone) 45%, transparent),
              0 0 34px -8px color-mix(in srgb, var(--tone) 40%, transparent);
}

.shot {
  position: relative; overflow: hidden; border-radius: 1px;
  background: #15100c;
}
.shot img {
  width: 100%; height: 100%; object-fit: cover; display: block;
  filter: saturate(1.04) contrast(1.03);
  transition: transform .8s cubic-bezier(.2, .8, .25, 1), filter .5s;
}
.pcard:hover .shot img { transform: scale(1.07); filter: saturate(1.14) contrast(1.06); }

/* 相纸反光 */
.sheen {
  position: absolute; inset: 0; pointer-events: none;
  background: linear-gradient(118deg, rgba(255, 255, 255, .16) 0%, transparent 34%, transparent 66%, rgba(255, 255, 255, .07) 100%);
  mix-blend-mode: screen;
}

.no {
  position: absolute; top: 8px; left: 9px; z-index: 2;
  font-size: 10px; font-weight: 800; letter-spacing: 2px; color: #fff;
  padding: 2px 7px; border-radius: 3px;
  background: rgba(0, 0, 0, .5); backdrop-filter: blur(4px);
  border: 1px solid rgba(255, 255, 255, .22);
}
/* 官方形象照标记：金箔小印 */
.chip-off {
  position: absolute; top: 8px; right: 9px; z-index: 2;
  font-size: 10px; font-weight: 800; letter-spacing: 1.5px; color: #1a1206;
  padding: 2px 8px; border-radius: 3px;
  background: linear-gradient(100deg, #c99a2e, #f5d76e);
  box-shadow: 0 2px 10px rgba(0, 0, 0, .45);
}
.chip-arc {
  position: absolute; bottom: 8px; left: 9px; right: 9px; z-index: 2;
  font-size: 10px; letter-spacing: .5px; color: #ffe8b8;
  opacity: 0; transform: translateY(6px); transition: .35s .04s;
  text-shadow: 0 1px 6px rgba(0, 0, 0, .9);
}
.pcard:hover .chip-arc { opacity: 1; transform: translateY(0); }

.veil {
  position: absolute; inset: 0; z-index: 1;
  display: grid; place-items: center;
  background: linear-gradient(to top, rgba(10, 7, 4, .82) 0%, rgba(10, 7, 4, .18) 46%, transparent 72%);
  opacity: 0; transition: opacity .34s;
}
.pcard:hover .veil { opacity: 1; }
.veil span {
  font-size: 11.5px; letter-spacing: 2px; color: var(--tone);
  padding: 6px 14px; border-radius: 14px;
  border: 1px solid color-mix(in srgb, var(--tone) 55%, transparent);
  background: rgba(0, 0, 0, .45); backdrop-filter: blur(6px);
}

/* 相纸下方的手写留白 */
.cap { padding: 11px 3px 15px; }
.cap b {
  display: block; font-size: 14.5px; letter-spacing: 1.5px; color: #3b2c16;
  font-weight: 800; line-height: 1.3;
}
.cap i {
  display: block; margin-top: 6px; font-size: 10.5px; font-style: normal;
  color: #8a7148; line-height: 1.55; letter-spacing: .3px;
  min-height: 32px;
}

/* 白昼模式下相纸与背景都偏暖，加深相纸边缘区分层次 */
body.light .frame {
  background: linear-gradient(168deg, #fffdf7 0%, #f9f1e1 52%, #f0e3c8 100%);
  box-shadow: 0 18px 30px -16px rgba(120, 92, 45, .5), 0 0 0 1px rgba(170, 132, 44, .18);
}
body.light .pcard:hover .frame {
  box-shadow: 0 26px 44px -16px rgba(120, 92, 45, .55),
              0 0 0 1px color-mix(in srgb, var(--tone) 60%, transparent),
              0 0 30px -10px color-mix(in srgb, var(--tone) 55%, transparent);
}
</style>
