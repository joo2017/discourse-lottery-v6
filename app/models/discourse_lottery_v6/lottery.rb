# frozen_string_literal: true

# 路径: discourse-lottery-v6/app/models/discourse_lottery_v6/lottery.rb

module DiscourseLotteryV6
  class Lottery < ActiveRecord::Base
    self.table_name = "discourse_lottery_lotteries"

    # --- 关键修正部分 ---
    # 确保你的 enum 定义是这种格式，并且在 belongs_to/has_many 之前
    enum :status, { running: 0, finished: 1, cancelled: 2 }
    enum :draw_type, { random: 0, specified: 1 }
    enum :backup_strategy, { proceed: 0, cancel: 1 }
    # --- 关键修正部分结束 ---

    belongs_to :post, class_name: "Post"
    has_many :participants,
             class_name: "DiscourseLotteryV6::Participant",
             foreign_key: :lottery_id,
             dependent: :destroy

    validates :draw_at, presence: true
    validates :winner_count, presence: true, numericality: { greater_than: 0 }
    validates :min_participants,
              presence: true,
              numericality: {
                greater_than_or_equal_to: 0,
              }

    def topic
      post&.topic
    end
  end
end
