<script setup>
import Authorize from './components/Authorize.vue';
import { RouterView } from 'vue-router';
</script>

<template>
  <Authorize>
    <RouterView />
  </Authorize>
</template>
