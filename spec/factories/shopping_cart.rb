# spec/factories/shopping_carts.rb
FactoryBot.define do
    factory :shopping_cart, class: 'Cart' do
      total_price { 0.0 }
      status { "active" }
      last_interaction_at { 7.days.ago }
    end
  end

  