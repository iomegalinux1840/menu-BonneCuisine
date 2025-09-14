FactoryBot.define do
  factory :admin do
    sequence(:email) { |n| "admin#{n}@labonnecuisine.fr" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end