
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
