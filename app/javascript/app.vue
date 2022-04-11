<template>
  <div>
    <h1>Google Map</h1>
    <div ref="map" style="height: 500px; width: 800px"></div>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      cooks: [
        {store: "awamori", lat: 26.2155658, lng: 127.6691134},
        {store: "awamori", lat: 26.176827006031758, lng: 127.6751037628797},
        {store: "awamori", lat: 26.18668612463146, lng: 127.66806564613702},
      ]
    }
  },

  methods: {
    fetchCooks() {
      return this.$axios.get('/cooks/9').then(res => {
        this.data.cooks = res.data;    
      })
    }
  },
  mounted() {
    this.fetchCooks();

    if (!window.mapLoadStarted) {
      window.mapLoadStarted = true;
      let script = document.createElement('script');
      script.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyAc8ucfbF9aY5Jn9VehhJZ852fopENuQTc&callback=initMap';
      script.async = true;
      document.head.appendChild(script);
      window.initMap = () => {
      window.mapLoaded = true;
      }
    }
    let timer = setInterval(() => {
      if (window.mapLoaded) {
        clearInterval(timer);
        const map = new window.google.maps.Map(this.$refs.map, {
          center: {lat: this.cooks[0].lat, lng: this.cooks[0].lng },
          zoom: 15,
        });
      
  
    this.cooks.forEach(cook => {
      new window.google.maps.Marker({position: {lat: cook.lat, lng: cook.lng}, map});
        });
      }, 500);
  },
};

  // $(function () {
  //     var markers = [];
  //     var infoWindows = [];
  //     var latlng = new google.maps.LatLng(35.681382, 139.76608399999998); // 東京駅
  //     var latlng2 = new google.maps.LatLng(35.675069, 139.763328);        // 有楽町駅
  
  //     var opts = {
  //         zoom: 15,
  //         center: latlng,
  //         mapTypeId: google.maps.MapTypeId.ROADMAP,
  //     };
  
  //     var map = new google.maps.Map(document.getElementById("map_canvas"), opts);
  
  //     var markerOption1 = {
  //         position: latlng, //位置座標 [LatLngクラスで指定]
  //         map: map, //設置するMapオブジェクト
  //     };
  //     markers[0] = new google.maps.Marker(markerOption1);
  
  //     var infoWindowOption1 = {
  //         content: "東京駅"
  //     }
  //     infoWindows[0] = new google.maps.InfoWindow(infoWindowOption1);
  //     infoWindows[0].open(map, markers[0]);
  
  //     var infoWindowOption2 = {
  //         position: latlng2,
  //         content: "有楽町駅",
  //     };
  //     infoWindows[1] = new google.maps.InfoWindow(infoWindowOption2);
  //     infoWindows[1].open(map);
  
  //     $("#method11").click(function () {
  //         var content;
  //         var latlng;
  //         content = infoWindows[1].getContent()
  //         if (content === "有楽町駅") {
  //             latlng = new google.maps.LatLng(35.682413, 139.77391899999998); // 日本橋駅
  //             infoWindows[1].setPosition(latlng);
  //             infoWindows[1].setContent("日本橋駅");
  //         } else {
  //             latlng = new google.maps.LatLng(35.675069, 139.763328);   // 有楽町駅
  //             infoWindows[1].setPosition(latlng);
  //             infoWindows[1].setContent("有楽町駅");
  //         }
  //       });
  // });
}
</script>


