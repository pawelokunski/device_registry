# frozen_string_literal: true

class Device < ApplicationRecord
  belongs_to :user, optional: true
  has_many :device_assignments
end
