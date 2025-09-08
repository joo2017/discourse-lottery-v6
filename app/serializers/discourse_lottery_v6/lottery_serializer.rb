# frozen_string_literal: true

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
      # 暂时返回0，未来会实现真实计数
      0
    end

    def winners
      # 暂时返回空数组，未来会返回中奖者信息
      []
    end
  end
end
