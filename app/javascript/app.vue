<template>
  <div id="app">
    'test'    
    <ul>
        <li v-for ="cook in cooks">
          {{ cook.id }}
        </li>
    </ul>


  </div>
</template>

<script>
export default {
  el: "#app",
  data: function () {
    return {
      cook:'cook.id',
      cooks: [
        {store: "awamori", lat: 26.2155658, lng: 127.6691134},
        {store: "awamori", lat: 1222.2222, lng: 3737},
        {store: "awamori", lat: 1222.2222, lng: 3737},
      ]
    }
  }


}
</script>

