FactoryBot.define do
  factory :campaign do
    creator { nil }
    category { nil }
    title { "MyString" }
    goal_amount { "9.99" }
    status { "MyString" }
  end
end
