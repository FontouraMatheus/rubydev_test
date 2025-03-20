class CartItem < ApplicationRecord
    belongs_to :cart
    belongs_to :product
  
    #assumi que produtos gratuitos é um dos casos esperados devido ao arquivo cart.rb original
    validates :quantity, numericality: { greater_than: 0 }
  
    def total_price
      product.price * quantity
    end
  end
  