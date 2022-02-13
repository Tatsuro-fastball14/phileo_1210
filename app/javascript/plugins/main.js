import { createApp } from 'vue';
import App from './App.vue';
import GoogleMap from './plugins/GoogleMap';

const app = createApp(App);
app.use(GoogleMap);
app.mount('#app');

app.config.globalProperties.$showMap = (canvas, myLatLng) => {
  console.log(mapLoaded);
  if (mapLoaded) {
    showMap(canvas, myLatLng);
  }
};

const GoogleMap = {
  install(app) {
    let mapLoaded = false;
    const loadScript = () => {
      let script = document.createElement('script');
      script.src =
      'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpixta.jp%2Fillustration%2F12767983&psig=AOvVaw0JcQTIocWdS2K6xFdU8EYV&ust=1638779689532000&source=images&cd=vfe&ved=0CAsQjRxqFwoTCJjvx5ygzPQCFQAAAAAdAAAAABAO' 
      script.async = true;
      document.head.appendChild(script);
    };

    loadScript();

    window.initMap = () => {
      mapLoaded = true;
      console.log(mapLoaded);
    };

    const showMap = (canvas, myLatLng) => {
      const map = new window.google.maps.Map(canvas, {
        center: myLatLng,
        zoom: 4,
      });
      new window.google.maps.Marker({ position: myLatLng, map });
    };

    app.config.globalProperties.$showMap = (canvas, myLatLng) => {
      console.log(mapLoaded);
      if (mapLoaded) {
        showMap(canvas, myLatLng);
      } else {
        let timer = setInterval(() => {
          if (mapLoaded) {
            clearInterval(timer);
            showMap(canvas, myLatLng);
          }
        }, 500);
      }
    };
  },
};
export default GoogleMap;









