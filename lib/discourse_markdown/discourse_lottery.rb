# frozen_string_literal: true

# 路径: discourse-lottery-v6/lib/discourse_markdown/discourse_lottery.rb

module DiscourseLotteryV6
  module DiscourseMarkdown
    def self.setup
      Discourse::Markdown.register_bbcode("lottery", "div") do |bbcode|
        attrs =
          %w[
            name
            draw_at
            winner_count
            min_participants
            status
            backup_strategy
            specified_winners
            prize_image_url
            notes
          ].map { |key| "data-#{key.dasherize}='#{bbcode.attrs[key]}'" if bbcode.attrs[key] }
            .compact
            .join(" ")

        "<div class='discourse-lottery' #{attrs}></div>"
      end
    end
  end
end
