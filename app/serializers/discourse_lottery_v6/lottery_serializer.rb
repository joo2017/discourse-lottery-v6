# frozen_string_literal: true

# 路径: discourse-lottery-v6/app/serializers/discourse_lottery_v6/lottery_serializer.rb

module DiscourseLotteryV6
  class LotterySerializer < ApplicationSerializer
    attributes(
      :id,
      :post_id,
      :name,
      :description,
      :prize_image_url,
      :notes,
      :draw_at,
      :draw_type,
      :winner_count,
      :specified_winners,
      :status,
      :min_participants,
      :backup_strategy,
      :participants_count,
      :winners,
    )

    def participants_count
      # TODO: 将在后续步骤中实现真实的用户计数
      object.participants.count
    end

    def winners
      # TODO: 将在后续步骤中返回中奖者信息
      []
    end
  end
end
