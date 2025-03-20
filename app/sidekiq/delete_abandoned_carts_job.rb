class DeleteAbandonedCartsJob
  include Sidekiq::Job

  def perform(*args)
    carts = Cart.where("status = ? AND last_interaction_at < ?", "abandoned", 7.days.ago)

    carts.find_each do |cart|
      cart.cart_items.destroy_all
      cart.destroy
    end
  end
end
