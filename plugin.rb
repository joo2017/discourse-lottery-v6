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
  # --- 所有插件逻辑都从这里开始 ---

  # 1. 加载非自动加载的核心逻辑文件
  require_relative "lib/discourse_markdown/discourse_lottery.rb"
  require_relative "lib/discourse_lottery_v6/lottery_parser.rb"
  require_relative "lib/discourse_lottery_v6/lottery_validator.rb"
  require_relative "lib/discourse_lottery_v6/lottery_creator.rb"
  require_relative "lib/discourse_lottery_v6/post_extension.rb"

  # 2. 设置 BBCode 解析规则
  DiscourseLotteryV6::DiscourseMarkdown.setup(Discourse::Markdown)

  # 3. 允许我们的 div 和 data-* 属性通过 HTML sanitizer
  customize_html_whitelist do |whitelist|
    whitelist[:attributes]["div"].concat(
      %w[
        data-name
        data-draw-at
        data-winner-count
        data-min-participants
        data-status
        data-backup-strategy
        data-specified-winners
        data-prize-image-url
        data-notes
      ],
    )
  end

  # 4. 将我们的扩展应用到 Post 模型
  #    reloadable_patch 确保在开发模式下修改 PostExtension 文件时能自动重载
  reloadable_patch { Post.prepend(DiscourseLotteryV6::PostExtension) }

  # 5. 将 Lottery 数据添加到 Post 序列化器中
  add_to_serializer(
    :post,
    :lottery,
    include_condition: -> { SiteSetting.lottery_enabled? && object.is_first_post? && object.lottery.present? },
  ) do
    DiscourseLotteryV6::LotterySerializer.new(object.lottery, scope: scope, root: false).as_json
  end

  # 6. 监听帖子创建和编辑事件
  on(:post_created) do |post, opts, user|
    if post.is_first_post? && SiteSetting.lottery_enabled?
      DiscourseLotteryV6::LotteryCreator.new(post).create_or_update
    end
  end

  on(:post_edited) do |post, topic_changed, post_revision|
    if post.is_first_post? && SiteSetting.lottery_enabled?
      DiscourseLotteryV6::LotteryCreator.new(post).create_or_update
    end
  end
end
