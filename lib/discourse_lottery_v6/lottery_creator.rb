# frozen_string_literal: true

module DiscourseLotteryV6
  class LotteryCreator
    def initialize(post)
      @post = post
      @lotteries_data = LotteryParser.extract(post)
    end

    def create_or_update
      # 如果帖子里没有抽奖BBCode，但数据库里有关联的抽奖，就删除它
      if @lotteries_data.empty?
        @post.lottery&.destroy
        return
      end

      lottery_data = @lotteries_data.first
      lottery = @post.lottery || @post.build_lottery

      # 智能判断抽奖方式
      if lottery_data[:specified_winners].present?
        lottery.draw_type = :specified
        winner_floors = lottery_data[:specified_winners].split(",").map(&:to_i).reject(&:zero?)
        lottery.winner_count = winner_floors.size
        lottery.specified_winners = winner_floors
      else
        lottery.draw_type = :random
        lottery.winner_count = lottery_data[:winner_count].to_i
        lottery.specified_winners = []
      end

      # 填充其他属性
      lottery.draw_at = Time.zone.parse(lottery_data[:draw_at])
      lottery.min_participants = lottery_data[:min_participants].to_i
      lottery.backup_strategy = lottery_data[:backup_strategy] || :proceed
      lottery.name = lottery_data[:name]
      lottery.description = lottery_data[:description]
      lottery.prize_image_url = lottery_data[:prize_image_url]
      lottery.notes = lottery_data[:notes]
      lottery.status = :running # 每次编辑都重置为running状态

      if lottery.save
        schedule_jobs(lottery)
      else
        # 如果保存失败，可以在这里处理错误，比如记录日志
        Rails.logger.error("Failed to save lottery for post #{@post.id}: #{lottery.errors.full_messages.join(", ")}")
      end
    end

    private

    def schedule_jobs(lottery)
      # 调度开奖任务
      Jobs.cancel_scheduled_job(:execute_lottery_draw, lottery_id: lottery.id)
      Jobs.enqueue_at(lottery.draw_at, :execute_lottery_draw, lottery_id: lottery.id)

      # 调度锁定帖子任务
      lock_delay = SiteSetting.lottery_post_lock_delay_minutes
      if lock_delay > 0
        Jobs.cancel_scheduled_job(:lock_lottery_post, post_id: @post.id)
        Jobs.enqueue_in(lock_delay.minutes, :lock_lottery_post, post_id: @post.id)
      end
    end
  end
end
