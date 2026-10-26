<script setup>
import { computed, ref } from 'vue'

const inputRef = ref(null)

const props = defineProps({
  id: { type: String, required: true },
  modelValue: { type: String, default: '' },
  label: { type: String, default: '' },
  placeholder: { type: String, default: '' },
  icon: { type: String, default: 'user' }, // user | lock | key | scroll
  type: { type: String, default: 'text' }, // text | password | toggle
  autocomplete: { type: String, default: 'off' },
  disabled: { type: Boolean, default: false }
})

const emit = defineEmits(['update:modelValue', 'enter'])

const show = ref(false)

const realType = computed(() => {
  if (props.type === 'toggle') return show.value ? 'text' : 'password'
  return props.type
})

function onInput(e) {
  emit('update:modelValue', e.target.value)
}

defineExpose({
  focus: () => inputRef.value?.focus()
})
</script>

<template>
  <div class="field">
    <label :for="id">{{ label }}</label>
    <div class="box">
      <svg
        v-if="icon === 'user'"
        class="ico"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.6"
      >
        <circle cx="12" cy="8" r="3.6" />
        <path d="M4.5 20c1.2-3.8 4-5.6 7.5-5.6s6.3 1.8 7.5 5.6" />
      </svg>

      <svg
        v-else-if="icon === 'lock'"
        class="ico"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.6"
      >
        <rect x="4.5" y="10.5" width="15" height="9" rx="2" />
        <path d="M8 10.5V8a4 4 0 018 0v2.5" />
      </svg>

      <svg
        v-else-if="icon === 'key'"
        class="ico"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.6"
      >
        <circle cx="8" cy="8" r="4" />
        <path d="M11 11l9 9M17 17l2-2M14 14l2-2" />
      </svg>

      <svg
        v-else
        class="ico"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.6"
      >
        <rect x="4" y="4" width="16" height="16" rx="2" />
        <path d="M8 9h8M8 13h8M8 17h5" />
      </svg>

      <input
        ref="inputRef"
        :id="id"
        :type="realType"
        :value="modelValue"
        :placeholder="placeholder"
        :autocomplete="autocomplete"
        :disabled="disabled"
        @input="onInput"
        @keydown.enter="emit('enter')"
      />

      <button
        v-if="type === 'toggle'"
        class="toggle"
        type="button"
        @click="show = !show"
      >
        {{ show ? '隐匿' : '显形' }}
      </button>
    </div>
  </div>
</template>
