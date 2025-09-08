# frozen_string_literal: true

module DiscourseLotteryV6
  class Lottery < ActiveRecord::Base
    self.table_name = "discourse_lottery_lotteries"

    belongs_to :post, class_name: "Post"
    has_many :participants,
             class_name: "DiscourseLotteryV6::Participant",
             foreign_key: :lottery_id,
             dependent: :destroy

    enum status: { running: 0, finished: 1, cancelled: 2 }
    enum draw_type: { random: 0, specified: 1 }
    enum backup_strategy: { proceed: 0, cancel: 1 }

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
