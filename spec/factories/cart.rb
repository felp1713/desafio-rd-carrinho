FactoryBot.define do
  factory :cart do
    status { "active" }
    last_interaction_at { Time.current }

    factory :shopping_cart do
    end
  end
end