# frozen_string_literal: true

# 路径: discourse-lottery-v6/app/models/discourse_lottery_v6/lottery.rb

module DiscourseLotteryV6
  class Lottery < ActiveRecord::Base
    self.table_name = "discourse_lottery_lotteries"

    # --- 修正开始 ---
    # 在定义关联之前，先定义 enums
    # 明确地将属性名作为第一个参数传递给 enum 方法
    enum :status, { running: 0, finished: 1, cancelled: 2 }
    enum :draw_type, { random: 0, specified: 1 }
    enum :backup_strategy, { proceed: 0, cancel: 1 }
    # --- 修正结束 ---

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
