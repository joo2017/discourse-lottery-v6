# frozen_string_literal: true

module DiscourseLotteryV6
  class LotteryValidator
    def initialize(post)
      @post = post
      @lotteries_data = LotteryParser.extract(post)
    end

    def validate
      # 确保插件已启用
      return false unless SiteSetting.lottery_enabled?

      # 一个帖子只能有一个抽奖
      if @lotteries_data.count > 1
        @post.errors.add(:base, I18n.t("plugins.lottery.errors.multiple_lotteries"))
        return false
      end

      return true if @lotteries_data.empty? # 如果没有抽奖，则跳过验证

      # 抽奖必须在首帖
      unless @post.is_first_post?
        @post.errors.add(:base, I18n.t("plugins.lottery.errors.must_be_in_first_post"))
        return false
      end

      lottery_data = @lotteries_data.first

      # 验证必填项
      unless lottery_data[:draw_at].present? && lottery_data[:winner_count].present? &&
               lottery_data[:min_participants].present?
        @post.errors.add(:base, I18n.t("plugins.lottery.errors.missing_required_fields"))
        return false
      end

      # 验证参与门槛
      min_participants = lottery_data[:min_participants].to_i
      if min_participants < SiteSetting.lottery_min_participants_global
        @post.errors.add(
          :base,
          I18n.t(
            "plugins.lottery.errors.min_participants_too_low",
            min: SiteSetting.lottery_min_participants_global,
          ),
        )
        return false
      end

      true
    end
  end
end
