<script>
export default {
  props: {
    myLatLng: {
      type: Object,
      required: true,
    },
    zoom: {
      type: Number,
      default: 15
    },
  },
  mounted() {
    if (!window.mapLoadStarted) {
      window.mapLoadStarted = true;
      let script = document.createElement('script');
      script.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyAc8ucfbF9aY5Jn9VehhJZ852fopENuQTc&callback=initMap';
      script.async = true;
      document.head.appendChild(script);
    }

    window.initMap = () => {
      window.mapLoaded = true;
    };

    let timer = setInterval(() => {
      if (window.mapLoaded) {
        clearInterval(timer);
        const map = new window.google.maps.Map(this.$refs.map, {
          center: this.myLatLng,
          zoom: this.zoom,
          mapTypeId: 'roadmap'
        });
        new window.google.maps.Marker({ position: this.myLatLng, map });
      }
    }, 500);
  },
  
}
  < template >
  <div ref="map" style="height: 400px; width: 100%;"></div>


