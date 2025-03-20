require "rails_helper"

RSpec.describe CartsController, type: :routing do
  describe 'routes' do
    it 'routes to #show' do
      expect(get: '/cart').to route_to('carts#show')
    end

    it 'routes to #create' do
      expect(post: '/carts').to route_to('carts#create') 
    end

    it 'routes to #add_item via POST' do
    expect(post: '/cart/add_product').to route_to('carts#add_product')
    end
  end
end 
