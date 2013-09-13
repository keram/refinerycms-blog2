user = FactoryGirl.create(:user)

FactoryGirl.define do
  factory :post, class: Refinery::Blog::Post do
    sequence(:title) { |n| "refinery#{n}" }
    published_at Time.now
    authors [user]
  end
end

