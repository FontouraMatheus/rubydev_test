class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  def update_total_price!
    update!(total_price: cart_items.joins(:product).sum("cart_items.quantity * products.price"))
  end

  def mark_as_abandoned
    update!(status: 'abandoned') if last_interaction_at < 3.hours.ago
  end

  def remove_if_abandoned
    destroy if abandoned? && last_interaction_at < 7.days.ago
  end

  def abandoned?
    status == 'abandoned'
  end
end
