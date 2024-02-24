<template>
  <router-view />
  <div id="cesiumContainer"></div>
</template>

<script setup>
import * as Cesium from "cesium";
import { onMounted,provide } from "vue";
import { load3dtiles, update3dtiles } from "./tool/load3D";
import CesiumZh from './tool/cesiumToZh'
onMounted(() => {
  Cesium.Ion.defaultAccessToken =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI4Y2ExYTgwMy1jNmJhLTRjZDEtYjYyYy0xMmMxMTRhMjQ1MWYiLCJpZCI6MTY4OTk3LCJpYXQiOjE2OTU4NjQzNjR9.BXFY_pnDehpEk5TbhtO0sGyr3FI57Hrh38kfK2ntQnc";
  const viewer = new Cesium.Viewer("cesiumContainer", {
    timeline: false,
    animation: false,
    baseLayerPicker:false,
    geocoder:false,
    homeButton:false,
    sceneModePicker:false,
    navigationHelpButton:false,
    fullscreenButton:false,
    infoBox:false,
    selectionIndicator:false,
  });
  CesiumZh.load()
  provide('viewer',viewer)
  load3dtiles(viewer, "/src/assets/b3dm/保利b3dm/tileset.json", (tileset) => {
    viewer.zoomTo(tileset);
    update3dtiles(tileset);
  });
});
</script>

<style lang="scss">
#cesiumContainer {
  width: 100vw;
  height: 100vh;
  overflow: hidden;
}
::v-deep .cesium-viewer-bottom{
  display: none;
}
</style>
