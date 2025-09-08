# frozen_string_literal: true

# name: discourse-lottery-v6
# about: A Discourse plugin to create and manage automated lotteries.
# version: 0.1
# authors: [Your Name]
# url: [Your plugin's repository URL]

enabled_site_setting :lottery_enabled

register_asset "stylesheets/common/discourse-lottery-v6.scss"

module ::DiscourseLotteryV6
  PLUGIN_NAME = "discourse-lottery-v6"
end

require_relative "lib/discourse_lottery_v6/engine"

after_initialize do
  # 加载所有库文件
  require_relative "lib/discourse_markdown/discourse_lottery"
  require_relative "lib/discourse_lottery_v6/lottery_parser"
  require_relative "lib/discourse_lottery_v6/lottery_validator"
  require_relative "lib/discourse_lottery_v6/lottery_creator"
  require_relative "lib/discourse_lottery_v6/post_extension"

  # 将我们的扩展应用到 Post 模型
  reloadable_patch { Post.prepend(DiscourseLotteryV6::PostExtension) }

  # 将 Lottery 数据添加到 Post 序列化器中
  add_to_serializer(
    :post,
    :lottery,
    include_condition: -> { SiteSetting.lottery_enabled? && object.is_first_post? && object.lottery.present? },
  ) do
    DiscourseLotteryV6::LotterySerializer.new(object.lottery, scope: scope, root: false).as_json
  end

  # 监听帖子创建和编辑事件
  on(:post_created) do |post, opts, user|
    if post.is_first_post?
      DiscourseLotteryV6::LotteryCreator.new(post).create_or_update
    end
  end

  on(:post_edited) do |post, topic_changed, post_revision|
    if post.is_first_post?
      DiscourseLotteryV6::LotteryCreator.new(post).create_or_update
    end
  end
  
  # 允许我们的div和data-*属性通过HTML sanitizer
  customize_html_whitelist do |whitelist|
    whitelist[:attributes]["div"].concat(%w[
      data-name
      data-draw_at
      data-winner_count
      data-min_participants
      data-status
      data-backup_strategy
      data-specified_winners
      data-prize_image_url
      data-notes
    ])
  end
end
