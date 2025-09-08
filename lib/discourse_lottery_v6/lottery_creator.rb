# frozen_string_literal: true

module DiscourseLotteryV6
  class LotteryCreator
    def initialize(post)
      @post = post
      @lotteries_data = LotteryParser.extract(post)
    end

    def create_or_update
      if @lotteries_data.empty?
        @post.lottery&.destroy
        return
      end

      lottery_data = @lotteries_data.first
      lottery = @post.lottery || @post.build_lottery

      if lottery_data[:specified_winners].present?
        lottery.draw_type = :specified
        winner_floors = lottery_data[:specified_winners].to_s.split(",").map(&:to_i).reject(&:zero?)
        lottery.winner_count = winner_floors.size
        lottery.specified_winners = winner_floors
      else
        lottery.draw_type = :random
        lottery.winner_count = lottery_data[:winner_count].to_i
        lottery.specified_winners = []
      end

      lottery.draw_at = Time.zone.parse(lottery_data[:draw_at].to_s) rescue nil
      lottery.min_participants = lottery_data[:min_participants].to_i
      lottery.backup_strategy = lottery_data[:backup_strategy] || :proceed
      lottery.name = lottery_data[:name]
      lottery.description = lottery_data[:description]
      lottery.prize_image_url = lottery_data[:prize_image_url]
      lottery.notes = lottery_data[:notes]
      lottery.status = :running

      if lottery.save
        # schedule_jobs(lottery) # 暂时注释
      else
        Rails.logger.error("[DiscourseLotteryV6] Lottery save failed for post #{@post.id}: #{lottery.errors.full_messages.join(", ")}")
      end
    end
  end
end
