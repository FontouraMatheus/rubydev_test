require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe DeleteAbandonedCartsJob, type: :job do
  let!(:abandoned_cart) { create(:cart, status: 'abandoned', last_interaction_at: 8.days.ago) }
  let!(:recent_abandoned_cart) { create(:cart, status: 'abandoned', last_interaction_at: 6.days.ago) }
  let!(:active_cart) { create(:cart, status: 'active', last_interaction_at: 1.day.ago) }

  before do
    expect(abandoned_cart.status).to eq('abandoned')
    expect(recent_abandoned_cart.status).to eq('abandoned')
    expect(active_cart.status).to eq('active')
  end

  it 'deletes abandoned carts that are older than 7 days' do
    expect {
      DeleteAbandonedCartsJob.new.perform
    }.to change(Cart, :count).by(-1)
  end

  it 'does not delete carts that are still active' do
    expect {
      DeleteAbandonedCartsJob.new.perform
    }.to_not change { active_cart.reload.status }
  end

  it 'does not delete abandoned carts that are less than 7 days old' do
    expect {
      DeleteAbandonedCartsJob.new.perform
    }.to_not change { recent_abandoned_cart.reload.status }
  end

  it 'does not delete any carts if there are no abandoned carts' do
    Cart.find_each { |cart| cart.cart_items.destroy_all }
    Cart.delete_all

    expect {
      DeleteAbandonedCartsJob.new.perform
    }.to_not change(Cart, :count)
  end
end