# frozen_string_literal: true

module DiscourseLotteryV6
  class LotteryParser
    # 定义了 BBCode 中允许的所有属性
    VALID_OPTIONS = %w[
      name
      draw_at
      winner_count
      min_participants
      status
      backup_strategy
      specified_winners
      prize_image_url
      notes
    ]

    def self.extract(post)
      # 使用 Discourse 的 PrettyText 来获取一个安全的、已解析的 HTML
      cooked = PrettyText.cook(post.raw, topic_id: post.topic_id, user_id: post.user_id)

      # 使用 Nokogiri 解析 HTML 并找到我们的抽奖 div
      Nokogiri
        .HTML(cooked)
        .css("div.discourse-lottery")
        .map do |lottery_node|
          lottery_data = {}
          lottery_node.attributes.each do |key, attr|
            # 将 data-* 属性转换为符号键
            if key.start_with?("data-")
              option_name = key.sub("data-", "").to_sym
              # 只有在白名单内的属性才会被接受
              if VALID_OPTIONS.include?(option_name.to_s)
                lottery_data[option_name] = CGI.escapeHTML(attr.value || "")
              end
            end
          end
          lottery_data
        end
    end
  end
end
