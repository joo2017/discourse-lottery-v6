# frozen_string_literal: true

module DiscourseLotteryV6
  module PostExtension
    extend ActiveSupport::Concern

    prepended do
      has_one :lottery,
              class_name: "DiscourseLotteryV6::Lottery",
              foreign_key: :post_id,
              dependent: :destroy

      validate :validate_lottery, if: :raw_changed?
    end

    private

    def validate_lottery
      # 仅在首帖进行验证
      return unless self.is_first_post?
      validator = DiscourseLotteryV6::LotteryValidator.new(self)
      validator.validate
    end
  end
end
