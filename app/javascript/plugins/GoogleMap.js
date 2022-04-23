const GoogleMap = {
  install(app) {
    console.log(app);
  },
};
export default GoogleMap;


const showMap = (canvas, myLatLng) => {
  const map = new window.google.maps.Map(canvas, {
    center: myLatLng,
    zoom: 15,
  });
  new window.google.maps.Marker({ position: myLatLng, map });
};

app.config.globalProperties.$showMap = (canvas, myLatLng) => {
  if (mapLoaded) {
    showMap(canvas, myLatLng);
  }
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



const GoogleMap = {
  install(app) {
    let mapLoaded = false;
    const loadScript = () => {
      let script = document.createElement('script');
      script.src =
        'https://maps.googleapis.com/maps/api/js?key=AIzaSyBFbEUWqwVYWapRl2AZJ8X-9_vibRDvpao&callback=initMap';
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
  },
}
