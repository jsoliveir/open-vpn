<script setup>
import { ref, useAttrs } from 'vue'
import qrcode from 'qrcode'

const image = ref('')
const attrs = useAttrs();
const imageSize = `max-width: ${ attrs.size }px`
const url = attrs.data
qrcode.toDataURL(url, { width: attrs.size }, (err, img) => {
  image.value = img
})
</script>
<template>
  <div :key="image" class="qrcode" :style="imageSize">
    <a :href="url">
      <img :src="image" :style="imageSize"/>
    </a>
  </div>
</template>

