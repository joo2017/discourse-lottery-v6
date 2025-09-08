# frozen_string_literal: true

module DiscourseLotteryV6
  class LotteryValidator
    def initialize(post)
      @post = post
      @lotteries_data = LotteryParser.extract(post)
    end

    def validate
      return true unless SiteSetting.lottery_enabled?
      return true if @lotteries_data.empty?

      if @lotteries_data.count > 1
        @post.errors.add(:base, "一个帖子中只能有一个抽奖活动。") # Simplified Chinese for error
        return false
      end

      unless @post.is_first_post?
        @post.errors.add(:base, "抽奖活动必须位于主题的第一个帖子中。")
        return false
      end

      lottery_data = @lotteries_data.first

      unless lottery_data[:draw_at].present? && lottery_data[:winner_count].present? &&
               lottery_data[:min_participants].present?
        @post.errors.add(:base, "抽奖缺少必要参数：开奖时间、获奖人数、参与门槛。")
        return false
      end

      min_participants = lottery_data[:min_participants].to_i
      if min_participants < SiteSetting.lottery_min_participants_global
        @post.errors.add(
          :base,
          "参与门槛不能低于全局设置的最小值 (#{SiteSetting.lottery_min_participants_global})。"
        )
        return false
      end

      true
    end
  end
end
