class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    carts = Cart.where("last_interaction_at < ?", 3.hours.ago).where(status: 'active')

    carts.find_each do |cart|
      cart.update!(status: 'abandoned')
    end
  end
end
