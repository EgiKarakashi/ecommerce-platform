<template>
  <div id="app">
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
// App-level configuration
useHead({
  title: 'Cart - E-commerce Platform',
  meta: [
    { name: 'description', content: 'Shopping cart and checkout for e-commerce platform' }
  ]
})
</script>
