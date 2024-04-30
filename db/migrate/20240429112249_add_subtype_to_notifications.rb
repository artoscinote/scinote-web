# frozen_string_literal: true

class AddSubtypeToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :subtype, :string
    add_index :notifications, :subtype
  end
end
