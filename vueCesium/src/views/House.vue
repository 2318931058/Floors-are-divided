<template>
  <el-card class="house">
    <template #header>
      <div class="card-header">
        <span style="font-weight: 600; font-size: 18px">查看房户信息</span>
        <el-select style="float:right" @change="changeBuild" v-model="data.pickBuild" placeholder="请选择楼栋">
          <el-option v-for="item in data.buildList" :key="item.id" :label="item.name" :value="item" />
        </el-select>
      </div>
    </template>
  </el-card>
</template>
<script setup>
import { onMounted, inject, reactive, onUnmounted } from 'vue'
import * as Cesium from 'cesium';
import Bubble from '../tool/bubble'
import * as turf from '@turf/turf'
import { getHouse, getOneHouseInfo } from '../api/houseApi'
import { getBuild } from '../api/buildApi'
const viewer = inject('viewer')
const data = reactive({
  buildList: [],
  pickBuild: ''
})
let houseList = []

const colors = [
  "#99CCCC",
  "#66FF66",
  "#FF6666",
  "#00CCFF",
  "#00FF33",
  "#CC0000",
  "#CC00CC",
  "#CCFF00",
  "#0000FF",
];
let lastPick, bubbles
const changeBuild = (item) => {
  bubbles && bubbles.windowClose()
  bubbles = null
  lastPick = null
  if (houseList.length > 0) {
    houseList.forEach(item => { viewer.scene.primitives.remove(item) })
  }
  houseList = []
  data.pickBuild = item.name
  const center = turf.center(item.polygon)
  viewer.camera.flyTo({
    destination: Cesium.Cartesian3.fromDegrees(...center.geometry.coordinates, 200)
  })
  getAllHouse(item.id)
}

const getAllHouse = (id) => {
  getHouse({ id, noPage: 1 }).then(res => {
    if (res.code == 200) {
      res.data.forEach(item => {
        let arr = item.polygon.coordinates[0].flat()
        let primitive = new Cesium.ClassificationPrimitive({
          geometryInstances: new Cesium.GeometryInstance({
            id: item.id,
            geometry: new Cesium.PolygonGeometry({
              polygonHierarchy: new Cesium.PolygonHierarchy(
                Cesium.Cartesian3.fromDegreesArray(arr)
              ),
              height: item.minHeight,
              extrudedHeight: item.maxHeight,
            }),
            attributes: {
              color: Cesium.ColorGeometryInstanceAttribute.fromColor(
                Cesium.Color.fromCssColorString(colors[item.id % 9]).withAlpha(
                  0.3
                )
              ),
            },
          }),
          classificationType: Cesium.ClassificationType.CESIUM_3D_TILE,
        });
        houseList.push(primitive)
        viewer.scene.primitives.add(primitive);
      })
    }
  })
}

const initHandle = () => {
  let handler = new Cesium.ScreenSpaceEventHandler(viewer.scene.canvas);
  handler.setInputAction((event) => {
    let position = viewer.scene.pickPosition(event.position);
    let pick = viewer.scene.pick(event.position)
    if (position && pick && pick.id) {
      if (lastPick && lastPick.id != pick.id) {
        const lastAttributes = lastPick.primitive.getGeometryInstanceAttributes(lastPick.id)
        lastAttributes.color = Cesium.ColorGeometryInstanceAttribute.toValue(
          Cesium.Color.fromCssColorString(colors[lastPick.id % 9]).withAlpha(0.3)
        )
      }
      const attributes = pick.primitive.getGeometryInstanceAttributes(pick.id)
      attributes.color = Cesium.ColorGeometryInstanceAttribute.toValue(Cesium.Color.YELLOW.withAlpha(0.88));
      lastPick = pick
      getOneHouseInfo({ id: pick.id }).then(res => {
        if (res.code == 200) {
          let houseInfo = res.data
          bubbles && bubbles.windowClose()
          bubbles = new Bubble({
            position,
            viewer: viewer,
            houseInfo
          })
        }
      })
    }
  }, Cesium.ScreenSpaceEventType.LEFT_CLICK);
}

onUnmounted(() => {
  bubbles && bubbles.windowClose()
  if (houseList.length > 0) {
    houseList.forEach(item => { viewer.scene.primitives.remove(item) })
  }
  houseList = []
})

onMounted(() => {
  getBuild().then(res => {
    if (res.code == 200) {
      data.buildList = res.data
    }
  })
  initHandle()
})
</script>
<style lang="scss">
.house {
  width: 25%;
  position: absolute;
  top: 4%;
  left: 4%;
  z-index: 999;
}
</style>
