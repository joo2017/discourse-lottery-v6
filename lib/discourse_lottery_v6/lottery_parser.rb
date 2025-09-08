# frozen_string_literal: true

module DiscourseLotteryV6
  class LotteryParser
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
      cooked = PrettyText.cook(post.raw, topic_id: post.topic_id, user_id: post.user_id)

      Nokogiri
        .HTML(cooked)
        .css("div.discourse-lottery")
        .map do |lottery_node|
          lottery_data = {}
          lottery_node.attributes.each do |key, attr|
            if key.start_with?("data-")
              option_name = key.sub("data-", "").to_sym
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
