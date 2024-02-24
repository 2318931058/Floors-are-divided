<template>
  <el-card class="setinfo">
    <template #header>
      <div class="card-header">
        <span style="font-weight: 600; font-size: 18px">编辑房户信息</span>
        <el-select
          style="float: right"
          @change="changeBuild"
          v-model="data.pickBuild"
          placeholder="请选择楼栋"
        >
          <el-option
            v-for="item in data.buildList"
            :key="item.id"
            :label="item.name"
            :value="item"
          />
        </el-select>
      </div>
    </template>
    
    <div>
      <el-table
        @row-click="clickTable"
        :data="data.houseList"
        border
        style="width: 100%"
      >
        <el-table-column label="门牌号">
          <template #default="scope">
            <el-tag
              >{{ scope.row.floorNum
              }}{{
                scope.row.number > 9 ? scope.row.number : "0" + scope.row.number
              }}</el-tag
            >
          </template>
        </el-table-column>
        <el-table-column label="单元号">
          <template #default="scope">
            <el-tag type="success">{{ scope.row.number }}单元</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="楼层">
          <template #default="scope">
            <el-tag type="info">{{ scope.row.floorNum }}楼</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作">
          <template #default="scope">
            <el-button
              @click="editInfo(scope.row)"
              link
              type="primary"
              size="small"
              >编辑信息</el-button
            >
          </template>
        </el-table-column>
      </el-table>
      <div>
        <el-pagination
          style="float: right"
          layout="prev, pager, next"
          :page-size="10"
          :total="data.count"
          @current-change="changePage"
        />
      </div>
    </div>
  </el-card>
  <el-dialog
    :close-on-click-modal="false"
    :close-on-press-escape="false"
    @close="data.dialogVisible = false"
    v-model="data.dialogVisible"
    title="编辑信息"
    width="40%"
  >
    <el-form
      :inline="true"
      label-position="right"
      label-width="100px"
      :model="data.houseInfo"
    >
      <h3 style="text-align: center; margin-bottom: 20px">业主信息</h3>
      <el-form-item style="width: 45%" label="业主姓名">
        <el-input v-model="data.houseInfo.ownerName" />
      </el-form-item>
      <el-form-item style="width: 45%" label="业主性别">
        <el-select
          style="width: 100%"
          v-model="data.houseInfo.ownerSex"
          placeholder="请选择性别"
        >
          <el-option label="男" value="1" />
          <el-option label="女" value="2" />
        </el-select>
      </el-form-item>
      <el-form-item style="width: 45%" label="身份证号">
        <el-input v-model="data.houseInfo.idCard" />
      </el-form-item>
      <el-form-item style="width: 45%" label="手机号码">
        <el-input v-model="data.houseInfo.phoneNum" />
      </el-form-item>
      <el-form-item style="width: 94.5%" label="业主住址">
        <el-input v-model="data.houseInfo.nativePlace" />
      </el-form-item>
      <el-form-item style="width: 94.5%" label="业主头像">
        <span v-if="data.houseInfo.ownerImg">
          <el-image
            style="height: 37px; margin-right: 14px"
            :src="'http://127.0.0.1:8090/' + data.houseInfo.ownerImg"
            :preview-src-list="[
              'http://127.0.0.1:8090/' + data.houseInfo.ownerImg,
            ]"
            fit="cover"
          />
        </span>
        <el-upload
          :multiple="false"
          action="http://127.0.0.1:8090/api/v1/upload"
          :on-success="successOwner"
        >
          <el-button size="small" type="info">{{
            data.houseInfo.ownerImg ? "重新上传" : "头像上传"
          }}</el-button>
        </el-upload>
      </el-form-item>
      <h3 style="text-align: center; margin-bottom: 20px">房屋信息</h3>
      <el-form-item style="width: 45%" label="房屋类型">
        <el-input v-model="data.houseInfo.houseType" />
      </el-form-item>
      <el-form-item style="width: 45%" label="房屋面积">
        <el-input type="" v-model="data.houseInfo.builtArea">
          <template #append>m²</template>
        </el-input>
      </el-form-item>
      <el-form-item style="width: 45%" label="房屋朝向">
        <el-input v-model="data.houseInfo.orientation" />
      </el-form-item>
      <el-form-item style="width: 45%" label="物业类型">
        <el-select
          style="width: 100%"
          v-model="data.houseInfo.propertyType"
          placeholder="请选择物业类型"
        >
          <el-option label="居民物业" value="1" />
          <el-option label="商业物业" value="2" />
          <el-option label="工业物业" value="3" />
          <el-option label="其他物业" value="4" />
        </el-select>
      </el-form-item>
      <el-form-item style="width: 94.5%" label="房屋号码">
        <el-input v-model="data.houseInfo.houseAddress" disabled />
      </el-form-item>
      <el-form-item style="width: 94.5%" label="户型图">
        <span v-if="data.houseInfo.houseImg">
          <el-image
            style="height: 37px; margin-right: 14px"
            :src="'http://127.0.0.1:8090/' + data.houseInfo.houseImg"
            :preview-src-list="[
              'http://127.0.0.1:8090/' + data.houseInfo.houseImg,
            ]"
            fit="cover"
          />
        </span>
        <el-upload
          action="http://127.0.0.1:8090/api/v1/upload"
          multiple
          :on-success="successHouse"
        >
          <el-button size="small" type="info">{{
            data.houseInfo.houseImg ? "重新上传" : "图片上传"
          }}</el-button>
        </el-upload>
      </el-form-item>
    </el-form>
    <div style="height: 30px">
      <el-button
        @click="toUpdateInfo"
        style="float: right; margin-right: 5%"
        type="primary"
        >提交</el-button
      >
    </div>
  </el-dialog>
</template>
<script setup>
import { onMounted, inject, reactive, onUnmounted } from "vue";
import * as Cesium from "cesium";
import * as turf from "@turf/turf";
import { getHouse, getOneHouseInfo, updateInfo } from "../api/houseApi";
import { getBuild } from "../api/buildApi";
import { ElMessage } from "element-plus";

const viewer = inject('viewer')
const data = reactive({
  buildList: [],
  pickBuild: "",
  houseList: [],
  count: 0,
  query: {
    pageIndex: 1,
    pageNum: 10,
  },
  dialogVisible: false,
  houseInfo: {},
});
let primitiveHouse;
const successOwner = (file) => {
  data.houseInfo.ownerImg = file.data;
};
const successHouse = (file) => {
  data.houseInfo.houseImg = file.data;
};

const toUpdateInfo = () => {
  updateInfo(data.houseInfo).then((res) => {
    if (res.code == 200) {
      ElMessage.success("编辑成功!");
      data.dialogVisible = false;
    }
  });
};

const editInfo = (house) => {
  getOneHouseInfo({ id: house.id }).then((res) => {
    if (res.code == 200) {
      data.houseInfo = res.data;
      let houseNum = house.number > 9 ? house.number : "0" + house.number;
      data.houseInfo.houseAddress =
        house.number + "单元" + house.floorNum + houseNum;
      data.dialogVisible = true;
    }
  });
};

const clickTable = (item) => {
  primitiveHouse && viewer.scene.primitives.remove(primitiveHouse);
  let arr = item.polygon.coordinates[0].flat();
  primitiveHouse = new Cesium.ClassificationPrimitive({
    geometryInstances: new Cesium.GeometryInstance({
      geometry: new Cesium.PolygonGeometry({
        polygonHierarchy: new Cesium.PolygonHierarchy(
          Cesium.Cartesian3.fromDegreesArray(arr)
        ),
        height: item.minHeight,
        extrudedHeight: item.maxHeight,
      }),
      attributes: {
        color: Cesium.ColorGeometryInstanceAttribute.fromColor(
          Cesium.Color.YELLOW.withAlpha(0.8)
        ),
      },
    }),
    classificationType: Cesium.ClassificationType.CESIUM_3D_TILE,
  });
  viewer.scene.primitives.add(primitiveHouse);
};

const changePage = (e) => {
  data.query.pageIndex = e;
  getHouseData();
};

const changeBuild = (build) => {
  primitiveHouse && viewer.scene.primitives.remove(primitiveHouse);
  primitiveHouse = null;
  data.pickBuild = build.name;
  const center = turf.center(build.polygon);
  viewer.camera.flyTo({
    destination: Cesium.Cartesian3.fromDegrees(
      ...center.geometry.coordinates,
      200
    ),
  });
  data.query.id = build.id;
  data.query.pageIndex = 1;
  getHouseData();
};

const getHouseData = () => {
  getHouse(data.query).then((res) => {
    if (res.code == 200) {
      data.houseList = res.data.list;
      data.count = res.data.total;
    }
  });
};

onUnmounted(() => {
  primitiveHouse && viewer.scene.primitives.remove(primitiveHouse);
  primitiveHouse = null;
});

onMounted(() => {
  getBuild().then((res) => {
    if (res.code == 200) {
      data.buildList = res.data;
    }
  });
});
</script>
<style lang="scss">
.setinfo {
  width: 25%;
  position: absolute;
  top: 4%;
  left: 4%;
  z-index: 999;

  .el-card__body {
    .el-table {
      td {
        text-align: center !important;
      }

      th {
        text-align: center !important;
      }
    }
  }
}

.el-upload-list {
  display: none !important;
}
</style>
