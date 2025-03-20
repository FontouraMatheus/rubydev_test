require 'rails_helper'

RSpec.describe CartService, type: :service do
  let!(:cart) { create(:cart) }
  let!(:product) { create(:product, name: 'Produto Teste', price: 10.0) }
  let!(:second_product) { create(:product, name: 'Produto Teste', price: 10.0) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

  describe '#add_product' do
    it 'add products in cart' do
      service = CartService.new(cart)

      expect {
        service.add_product(second_product, 2)
        service.add_product(product, 2)
        service.add_product(product, 2)
      }.to change { cart.cart_items.count }.by(1)

      expect(cart.cart_items.first.quantity).to eq(5) #create + add + add
    end
  end

  describe '#update_item_quantity' do
    it 'updated quantity' do
      service = CartService.new(cart)

      expect {
        service.update_item_quantity(cart_item, 2)
      }.to change { cart_item.reload.quantity }.by(2)

      expect(cart_item.reload.quantity).to eq(3)
    end
  end

  describe '#remove_product' do
    it 'remove products' do
      service = CartService.new(cart)

      expect {
        service.remove_product(cart_item)
      }.to change { cart.cart_items.count }.by(-1)

      expect(cart.cart_items).to be_empty
    end
  end
end
