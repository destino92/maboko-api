FactoryBot.define do
  factory :contribution do
    campaign { nil }
    contributor { nil }
    amount { "9.99" }
    status { "MyString" }
    payment_reference { "MyString" }
    contributed_at { "2025-12-02 10:46:30" }
  end
end
