<template>
  <el-card class="setbuild">
    <template #header>
      <div class="card-header">
        <span style="font-weight: 600; font-size: 18px">楼房分户</span>
        <span @click="reset">
          <Refresh style="width: 25px; float: right; cursor: pointer"></Refresh>
        </span>
      </div>
    </template>

    <div>
      <el-steps :active="active" align-center finish-status="success">
        <el-step title="区域绘制 " />
        <el-step title="户型切分" />
        <el-step title="楼房分层" />
      </el-steps>

      <div style="margin: 30px 10px">
        <div style="height: 40px">
          <span style="margin-right: 20px">绘制户型</span>
          <span class="myIcon" @click="drawPolygon" v-show="active == 0"
            ><FullScreen />绘制图形</span
          >
          <span class="myIcon" @click="drawPolyline" v-show="active == 1"
            ><Scissor />裁切图形</span
          >
          <span class="myIcon" @click="drawPoint" v-show="active == 2"
            ><Histogram />楼层分层</span
          >
          <span class="buildnum" v-show="heightArr.length == 3">
            楼层数：<el-input v-model="floorNum" />
          </span>
        </div>

        <div class="textInput">
          <el-input v-model="inputArr[0]" disabled></el-input>
          <el-input v-model="inputArr[1]" disabled></el-input>
          <el-input
            v-model="inputArr[2]"
            disabled
            style="width: 50%"
          ></el-input>
          <el-input
            v-model="inputArr[3]"
            v-show="active == 1"
            disabled
            style="width: 50%"
          ></el-input>
        </div>

        <div class="textInput" v-for="(item, index) in unitArr" :key="index">
          <el-input v-model="item[0]" disabled></el-input>
          <el-input v-model="buildName"></el-input>
          <el-input v-model="item[1]" style="width: 50%"></el-input>
          <img
            v-show="active == 1"
            @click="toFlash(item[2])"
            src="/src/assets/img/position.png"
          />
        </div>

        <div class="pointList" v-show="heightArr.length == 3">
          最低点：<el-input v-model="heightArr[0]"></el-input> 分割点：<el-input
            v-model="heightArr[1]"
          ></el-input>
          最高点：<el-input v-model="heightArr[2]"></el-input>
        </div>

        <el-button
          v-show="active == 3"
          @click="toAddHouse"
          style="margin: 12px; float: right"
          type="primary"
          >生成数据</el-button
        >
        <el-button
          v-if="active < 2"
          @click="next"
          style="margin: 12px; float: right"
          type="info"
          >下一步</el-button
        >
        <el-button
          v-else
          @click="toLayer"
          style="margin: 12px; float: right"
          type="success"
          >楼房分层</el-button
        >
      </div>
    </div>
  </el-card>
</template>

<script setup>
import * as Cesium from "cesium";
import * as turf from "@turf/turf";
import { ref, inject,onUnmounted } from "vue";
import {
  FullScreen,
  Scissor,
  Histogram,
  Refresh,
} from "@element-plus/icons-vue";
import { ElMessage } from "element-plus";
import { addHouse } from "../api/houseApi";
import { toDraw, endDraw } from "../tool/draw";
import polygonCut from "../tool/polygonCut";
const viewer = inject("viewer");
let active = ref(0);
const next = () => {
  if (active.value == 0) {
    if (!polygonEntity) {
      return ElMessage.error("请先绘制区");
    }
  } else if (active.value == 1) {
    endDraw();
  }
  active.value++;
};

const buildName = "幸福小区10栋";
let polygonEntity, polygonAllGeoJson, geoJsonPolygonArr;
let unitArr = ref([]);
const inputArr = ["分户坐标", "地址前缀", "单位", "定位"];
let heightArr = ref([]);
let floorNum = ref(0);
let houseList = [];

const drawPolygon = () => {
  ElMessage.info("请绘制图形，右键结束绘制");
  viewer.entities.removeAll();
  unitArr.value = [];
  polygonEntity = null;
  toDraw(viewer, "polygon", (res) => {
    let arr = [];
    polygonEntity = res;
    let car3_ps = res._polygon._hierarchy._value.positions;
    for (let i = 0; i < car3_ps.length; i++) {
      let _cartographic = Cesium.Cartographic.fromCartesian(car3_ps[i]);
      let _lat = Cesium.Math.toDegrees(_cartographic.latitude);
      let _lng = Cesium.Math.toDegrees(_cartographic.longitude);
      arr.push([_lng, _lat]);
    }
    arr.push(arr[0]);
    polygonAllGeoJson = turf.polygon([arr]);
    unitArr.value.push([
      polygonAllGeoJson.geometry.coordinates.toString(),
      1,
      res,
    ]);
  });
};
const drawPolyline = () => {
  ElMessage.info("请绘制裁线段，右键结束绘制");
  viewer.entities.removeAll();
  viewer.entities.add(polygonEntity);
  unitArr.value = [];
  unitArr.value.push([
    polygonAllGeoJson.geometry.coordinates.toString(),
    unitArr.value.length + 1,
    polygonEntity,
  ]);
  toDraw(viewer, "line", (res) => {
    let arr = [];
    unitArr.value = [];
    viewer.entities.remove(res);
    let car3_ps = res._polyline.positions._value;
    for (let i = 0; i < car3_ps.length; i++) {
      let _cartographic = Cesium.Cartographic.fromCartesian(car3_ps[i]);
      let _lat = Cesium.Math.toDegrees(_cartographic.latitude);
      let _lng = Cesium.Math.toDegrees(_cartographic.longitude);
      arr.push([_lng, _lat]);
    }
    let lineGeoJson = turf.lineString(arr);
    try {
      geoJsonPolygonArr = polygonCut(polygonAllGeoJson, lineGeoJson);
      if (geoJsonPolygonArr.features.length == 1) {
        ElMessage.error("请切分区域");
        return;
      }
    } catch (error) {
      ElMessage.error(error);
      return;
    }

    let promise = Cesium.GeoJsonDataSource.load(geoJsonPolygonArr, {
      clampToGround: true,
    });
    promise.then((info) => {
      info.entities.values.forEach((item, index) => {
        item.polygon.material = Cesium.Color.fromRandom({ alpha: 0.5 }); // 随机色
        viewer.entities.add(item);
        unitArr.value.push([
          geoJsonPolygonArr.features[index].geometry.coordinates.toString(),
          unitArr.value.length + 1,
          item,
        ]);
      });
    });
  });
};
const toFlash = (item) => {
  if (!item.polygon.material.color._value) return;
  let initColor = item.polygon.material.color._value;
  let x = 1;
  let flog = true;
  item.polygon.material = new Cesium.ColorMaterialProperty(
    new Cesium.CallbackProperty(() => {
      if (flog) {
        x = x - 0.05;
        if (x <= 0) {
          flog = false;
        }
      } else {
        x = x + 0.05;
        if (x >= 1) {
          flog = true;
        }
      }
      return Cesium.Color.RED.withAlpha(x);
    }, false)
  );
  setTimeout(() => {
    item.polygon.material = initColor;
  }, 1500);
};
const drawPoint = () => {
  ElMessage.info("请依次绘制底层、二层以及顶层高度点");
  heightArr.value = [];
  // 获取地图中所有的点实体后遍历删除（坑点：必须倒着删，否则会有一半删除不成功）
  for (let i = viewer.entities.values.length - 1; i >= 0; i--) {
    let item = viewer.entities.values[i];
    item.point && viewer.entities.remove(item);
  }
  toDraw(viewer, "point", (res) => {
    let height = Cesium.Cartographic.fromCartesian(
      res.position._value
    ).height.toFixed(2);
    heightArr.value.push(height);
    if (heightArr.value.length == 3) {
      ElMessage.success("绘制成功，完成绘制");
      endDraw();
      heightArr.value.sort((a, b) => {
        return a - b;
      });
    }
  });
};
const toLayer = () => {
  if (!floorNum.value) {
    ElMessage.info("请设置楼层高度");
  }
  viewer.entities.removeAll();
  if (houseList.length) {
    houseList.forEach((item) => {
      viewer.scene.primitives.remove(item);
    });
    houseList = [];
  }
  let itemHeight =
    (heightArr.value[2] - heightArr.value[1]) / (floorNum.value - 1);
  unitArr.value.forEach((item) => {
    let arr = item[2]._polygon._hierarchy._value.positions;
    for (let i = 0; i < floorNum.value; i++) {
      let height, extrudedHeight;
      if (i == 0) {
        height = Number(heightArr.value[1]);
        extrudedHeight = Number(heightArr.value[1]);
      } else {
        height = Number(heightArr.value[1]) + (i - 1) * itemHeight;
        extrudedHeight = Number(heightArr.value[1]) + i * itemHeight;
      }
      let primitive = new Cesium.ClassificationPrimitive({
        geometryInstances: new Cesium.GeometryInstance({
          geometry: new Cesium.PolygonGeometry({
            polygonHierarchy: new Cesium.PolygonHierarchy(arr),
            height: height,
            extrudedHeight: extrudedHeight,
          }),
          attributes: {
            color: Cesium.ColorGeometryInstanceAttribute.fromColor(
              Cesium.Color.fromRandom({ alpha: 0.3 }) //颜色
            ),
          },
        }),
        classificationType: Cesium.ClassificationType.CESIUM_3D_TILE,
      });
      houseList.push(primitive);
      viewer.scene.primitives.add(primitive);
    }
  });

  active.value = 3;
};
const reset = () => {
  polygonEntity = null;
  polygonAllGeoJson = null;
  geoJsonPolygonArr = null;
  active.value = 0;
  unitArr.value = [];
  heightArr.value = [];
  floorNum.value = 0;
  houseList = [];
  endDraw();
  viewer.entities.removeAll();
};
function toAddHouse(){
  let polygonJson = JSON.stringify(polygonAllGeoJson.geometry);
  let polygonJsonArr = geoJsonPolygonArr
    ? geoJsonPolygonArr.features.map((item) => {
        return JSON.stringify(item.geometry);
      })
    : [];
  let unitArr1 = unitArr.value.map((item) => {
    return Number(item[1]);
  });
  let heightArr1 = heightArr.value.map((item) => {
    return Number(item);
  });
  addHouse({
    polygonJsonArr,
    polygonJson,
    unitArr:unitArr1,
    heightArr:heightArr1,
    name: buildName,
    floorNum: Number(floorNum.value),
  }).then((res) => {
    if (res.code == 200) {
      ElMessage.success("提交成功");
      reset();
      console.log(res)
    }
  });
}
onUnmounted(()=>{
  reset()
})
</script>

<style lang="scss">
.setbuild {
  width: 26%;
  position: absolute;
  top: 4%;
  left: 4%;
  z-index: 999;

  .buildnum {
    float: right;
    width: 40%;

    .el-input {
      width: 50%;
    }
  }

  .myIcon {
    cursor: pointer;

    svg {
      width: 20px;
      position: relative;
      top: 5px;
      margin-right: 3px;
    }
  }

  .textInput {
    display: flex;

    .el-input {
      margin: 5px 1%;

      .el-input__inner {
        text-align: center;
      }
    }

    img {
      margin: 10px 4.6%;
      width: 14%;
      height: 25px;
      cursor: pointer;
    }
  }

  .pointList {
    display: flex;
    font-size: 15px;
    margin: 20px 0;
    line-height: 30px;

    .el-input {
      width: 12%;
      margin-right: 2%;
    }
  }
}
</style>
