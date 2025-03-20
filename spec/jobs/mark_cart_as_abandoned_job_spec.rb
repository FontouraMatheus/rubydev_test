require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  let!(:active_cart) { create(:cart, status: 'active', last_interaction_at: 4.hours.ago) }
  let!(:non_abandoned_cart) { create(:cart, status: 'active', last_interaction_at: 2.hours.ago) }
  let!(:abandoned_cart) { create(:cart, status: 'abandoned', last_interaction_at: 5.hours.ago) }

  before do
    expect(active_cart.status).to eq('active')
    expect(non_abandoned_cart.status).to eq('active')
    expect(abandoned_cart.status).to eq('abandoned')
  end

  it 'marks a cart as abandoned if last interaction was more than 3 hours ago' do
    expect {
      MarkCartAsAbandonedJob.new.perform
    }.to change { active_cart.reload.status }.from('active').to('abandoned')
  end

  it 'does not mark a cart as abandoned if last interaction was less than 3 hours ago' do
    expect {
      MarkCartAsAbandonedJob.new.perform
    }.to_not change { non_abandoned_cart.reload.status }
  end

  it 'does not mark carts that are already abandoned' do
    expect {
      MarkCartAsAbandonedJob.new.perform
    }.to_not change { abandoned_cart.reload.status }
  end

  it 'does not affect the cart status if no carts are found to be abandoned' do
    Cart.find_each { |cart| cart.cart_items.destroy_all }
    Cart.delete_all

    expect {
      MarkCartAsAbandonedJob.new.perform
    }.to_not change { Cart.count }
  end
end
