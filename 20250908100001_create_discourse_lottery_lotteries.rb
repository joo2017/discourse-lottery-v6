# frozen_string_literal: true

class CreateDiscourseLotteryLotteries < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_lottery_lotteries do |t|
      t.references :post, foreign_key: true, null: false, index: { unique: true }
      t.integer :draw_type, null: false, default: 0
      t.integer :winner_count, null: false
      t.integer :specified_winners, array: true, default: []
      t.integer :status, null: false, default: 0
      t.datetime :draw_at, null: false
      t.integer :min_participants, null: false, default: 1
      t.integer :backup_strategy, null: false, default: 0
      t.string :name
      t.text :description
      t.string :prize_image_url
      t.text :notes
      t.timestamps
    end
  end
end
