FactoryBot.define do
  factory :menu_item do
    sequence(:name) { |n| "Plat #{n}" }
    description { "Délicieux plat français traditionnel" }
    price { rand(10.0..35.0).round(2) }
    comment { "Sans gluten disponible" }
    available { true }
    sequence(:position) { |n| n }

    trait :unavailable do
      available { false }
    end

    trait :entree do
      name { "Soupe à l'oignon gratinée" }
      description { "Soupe traditionnelle française avec croûtons et fromage gratiné" }
      price { 14.50 }
    end

    trait :plat do
      name { "Coq au vin de Bourgogne" }
      description { "Poulet mijoté dans le vin rouge avec lardons et champignons" }
      price { 26.00 }
    end

    trait :dessert do
      name { "Crème brûlée à la vanille" }
      description { "Crème onctueuse parfumée à la vanille de Madagascar" }
      price { 12.00 }
    end
  end
end