require 'rails_helper'

RSpec.describe "/carts", type: :request do
  let!(:cart) { create(:cart) }
  let!(:product) { create(:product, name: 'Produto Teste', price: 10.0) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

  def json
    JSON.parse(response.body)
  end

  describe "POST /carts" do
    context 'when create a cart' do
      it 'create a cart without item' do
        post '/carts', params: {}, as: :json

        expect(response).to have_http_status(:created)
        expect(json['id']).to be_present
        expect(json['products']).to be_empty
      end

      context 'when create a cart with item' do
        let(:product) { create(:product, name: 'Produto Teste', price: 10.0) }
        
        it 'adding item in cart' do

          post '/carts', params: { product_id: product.id, quantity: 1 }, as: :json

          expect(response).to have_http_status(:created)
          expect(json['products'].size).to eq(1)
          expect(json['products'][0]['name']).to eq('Produto Teste')
          expect(json['products'][0]['quantity']).to eq(2)
        end
      end
    end
  end

  describe "POST /carts/:id/add_product" do
    context 'adding product in cart' do
      it 'adding quantity' do
        post "/carts/#{cart.id}/add_product", params: { product_id: product.id, quantity: 2 }, as: :json

        expect(response).to have_http_status(:ok)
        expect(json['products'][0]['quantity']).to eq(3)
      end
    end
  end

  describe "POST /carts/:id/update_item" do
    context 'when update quantity in a cart' do
      it 'update item quantity' do
        post "/carts/#{cart.id}/update_item", params: { product_id: product.id, quantity: 1 }, as: :json

        expect(response).to have_http_status(:ok)
        expect(json['products'][0]['quantity']).to eq(2)
      end
    end
  end

  describe "DELETE /carts/:id/remove_item/:product_id" do
    context 'when destroy a product in cart' do
      it 'when remove' do
        delete "/carts/#{cart.id}/remove_item/#{product.id}", as: :json

        expect(response).to have_http_status(:ok)
        expect(json['products']).to be_empty
      end
    end
  end

  describe 'POST /carts/:id/add_product' do
    context 'quando o produto já está no carrinho' do
      subject do
        post "/carts/#{cart.id}/add_product", params: { product_id: product.id, quantity: 1 }, as: :json
        post "/carts/#{cart.id}/add_product", params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'atualiza a quantidade do item existente no carrinho' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
