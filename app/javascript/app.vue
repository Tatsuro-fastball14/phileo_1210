<template>
  <div id="app">
    <p>{{ message }}</p>
    <p>@{{ cook.id }}</p>
    <ul>
        <li v-for ="cook in cooks">@{{ cook.id }}</li>
    </ul>


  </div>
</template>

<script>
export default {
  el: "#app",
  data: function () {

    return {    
      message: "Hello Vue!",
      cooks: [
        {store: "awamori", lat: 26.2155658, lng: 127.6691134},
        {store: "awamori", lat: 1222.2222, lng: 3737},
        {store: "awamori", lat: 1222.2222, lng: 3737},
      ]

    },
  },
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>



export default{
  props: {
    myLatLng: {
      type: object,
      required: ture,
    },
    zoom: {
      type: Number,
      required: ture,
    },
  },
  mounted(){
    if (!window.mapLoadStarted) {
      window.mapLoadStarted = true;
      let script = document.createElement('script');
      script.src =
        'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpixta.jp%2Fillustration%2F12767983&psig=AOvVaw0JcQTIocWdS2K6xFdU8EYV&ust=1638779689532000&source=images&cd=vfe&ved=0CAsQjRxqFwoTCJjvx5ygzPQCFQAAAAAdAAAAABAO';
        script.async = true;
        document.head.appendChild(script);
    }

    window.initMap =() => {
      window.mapLoaded = true;
    };
    
    let timer = setInterval(() => {
      if (window. mapLoaded) {
        clearInterval(timer);
        const map = new
    window.google.maps.Map(this.$refs.map, {
          center: this.myLatLng,
          zoom: 15,
          mapTypeId: 'roadmap'


    });
    new window.google.maps.Marker({ position:
    this.myLatLng, map });
      }
    },500);
  },
};

<template>
  <h1>プラグインの作成</h1>
   <google-map />
</template>

<script>
import GoogleMap from './components/GoogleMap.vue';

export default {
  name: 'App',
  components: {
    GoogleMap,
  },
};
</script>


<template>
  <h1>Google Map</h1>
  <div ref="map" style="height: 500px; width: 800px"></div>
</template>

<script>
export default {
  mounted() {
    this.$showMap(this.$refs.map, { lat: 34.344, lng: 136.036 });
  },
};
</script>





