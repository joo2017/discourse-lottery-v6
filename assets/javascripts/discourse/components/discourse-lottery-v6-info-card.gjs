import Component from "@glimmer/component";

export default class DiscourseLotteryV6InfoCard extends Component {
  <template>
    <div class="discourse-lottery-info-card">
      <h3>抽奖活动: {{or @lottery.name "无标题"}}</h3>
      <ul>
        <li><strong>状态:</strong> {{@lottery.status}}</li>
        <li><strong>开奖时间:</strong> {{@lottery.draw_at}}</li>
        <li><strong>获奖人数:</strong> {{@lottery.winner_count}}</li>
        <li><strong>参与门槛:</strong> {{@lottery.min_participants}} 人</li>
      </ul>
    </div>
  </template>
}
