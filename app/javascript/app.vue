<template>
  <div id="app">
    <p>{{ message }}</p>
    <p>{{ cooks }}</p>
       <div> v-if="number">条件次第で表示</div>
        <ul>
        <li v-for="cook in cooks">{{ cook }}</li>
        </ul>

        </div>
  </div>
</template>

<script>
export default {
  el: app,
  data: function () {
      
    return {
      message: "Hello Vue!",
      cooks: [1,2,3],
      {store: "awamori", lat: 1222.2222, lng: 3737},
      {store: "awamori", lat: 1222.2222, lng: 3737}

    }
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
