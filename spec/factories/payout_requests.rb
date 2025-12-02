FactoryBot.define do
  factory :payout_request do
    campaign { nil }
    requestor { nil }
    amount { "9.99" }
    status { "MyString" }
    disbursement_reference { "MyString" }
    requested_at { "2025-12-02 10:56:31" }
    processed_at { "2025-12-02 10:56:31" }
    completed_at { "2025-12-02 10:56:31" }
  end
end
