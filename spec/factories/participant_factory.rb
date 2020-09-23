FactoryBot.define do
  factory :participant do
    slack_user_id { Faker::Alphanumeric.unique.alphanumeric }
  end
end
