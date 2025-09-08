import { withPluginApi } from "discourse/lib/plugin-api";
import DiscourseLottery from "../models/discourse-lottery-v6-lottery";
import DiscourseLotteryInfoCard from "../components/discourse-lottery-v6-info-card";

function initializeLottery(api) {
  api.decorateCookedElement(
    (cooked, helper) => {
      const lotteryNode = cooked.querySelector(".discourse-lottery");
      if (!lotteryNode) {
        return;
      }

      const post = helper.getModel();
      let lotteryData;

      if (post && post.lottery) {
        // 模式1: 从后端 PostSerializer 获取完整的抽奖数据
        lotteryData = post.lottery;
      } else {
        // 模式2: 预览模式或数据未加载时，从DOM的data属性中读取基本信息
        // 将 data-draw-at 转换为 draw_at
        lotteryData = Object.keys(lotteryNode.dataset).reduce((acc, key) => {
          const camelCaseKey = key.replace(/-(\w)/g, (match, letter) => letter.toUpperCase());
          acc[camelCaseKey] = lotteryNode.dataset[key];
          return acc;
        }, {});
      }

      const lottery = DiscourseLottery.create(lotteryData);
      const wrapper = document.createElement("div");
      lotteryNode.replaceWith(wrapper); // 替换占位符

      helper.renderGlimmer(
        wrapper,
        <template><DiscourseLotteryInfoCard @lottery={{lottery}} /></template>
      );
    },
    {
      id: "discourse-lottery-v6-decorator",
    }
  );
}

export default {
  name: "discourse-lottery-v6-decorator",

  initialize(container) {
    const siteSettings = container.lookup("service:site-settings");
    if (siteSettings.lottery_enabled) {
      withPluginApi("1.13.0", initializeLottery);
    }
  },
};
