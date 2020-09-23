FactoryBot.define do
  factory :exclusion do
    association :excluder, factory: :participant
    association :excluded_participant, factory: :participant
  end
end
