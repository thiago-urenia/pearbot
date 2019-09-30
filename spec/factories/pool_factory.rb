FactoryBot.define do
  factory :pool do
    slack_channel_id { Faker::Alphanumeric.unique.alphanumeric }
  end
end
