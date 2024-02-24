import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

import Icons from "unplugin-icons/vite";
import IconsResolver from "unplugin-icons/resolver";
import Components from "unplugin-vue-components/vite";

import cesium from "vite-plugin-cesium";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    cesium(),
    Components({
      resolvers: [
        // 自动注册图标组件
        IconsResolver(),
      ],
    }),
    Icons(),
  ],
});
