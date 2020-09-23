FactoryBot.define do
  factory :pool_entry do
    association :participant
    association :pool
    status { :available }

    trait :available do
      status { :available }
    end

    trait :snoozed do
      status { :snoozed }
    end
  end
end
