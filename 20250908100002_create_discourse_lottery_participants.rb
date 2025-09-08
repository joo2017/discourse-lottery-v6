# frozen_string_literal: true

class CreateDiscourseLotteryParticipants < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_lottery_participants do |t|
      t.references :lottery, foreign_key: { to_table: :discourse_lottery_lotteries }, null: false
      t.references :user, foreign_key: true, null: false
      t.integer :post_number, null: false
      t.timestamps
    end
    add_index :discourse_lottery_participants, %i[lottery_id user_id], unique: true
  end
end
