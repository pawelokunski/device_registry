# frozen_string_literal: true

FactoryBot.define do
  factory :api_key do
    token { SecureRandom.hex }
    association :bearer, factory: :user
  end
end
