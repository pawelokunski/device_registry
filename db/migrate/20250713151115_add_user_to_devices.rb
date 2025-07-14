# frozen_string_literal: true

class AddUserToDevices < ActiveRecord::Migration[7.1]
  def change
    add_reference :devices, :user, foreign_key: true
  end
end
