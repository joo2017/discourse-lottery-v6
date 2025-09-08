# frozen_string_literal: true

Discourse::Markdown.register_bbcode("lottery", "div") do |bbcode|
  attrs =
    [
      "name",
      "draw_at",
      "winner_count",
      "min_participants",
      "status",
      "backup_strategy",
      "specified_winners",
      "prize_image_url",
      "notes"
    ].map { |key| "data-#{key.dasherize}='#{bbcode.attrs[key]}'" if bbcode.attrs[key] }.compact.join(" ")

  "<div class='discourse-lottery' #{attrs}></div>"
end
