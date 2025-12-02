FactoryBot.define do
  factory :campaign_comment do
    campaign { nil }
    user { nil }
    content { "MyText" }
    comment_type { "MyString" }
  end
end
