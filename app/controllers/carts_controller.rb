class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :add_product, :update_quantity, :remove_product]
  before_action :find_product, only: [:add_product]
  before_action :find_cart_item, only: [:update_quantity, :remove_product]

  def create
    @cart = Cart.create!(total_price: 0.0)
    session[:cart_id] = @cart.id
  
    if params[:product_id].present? && params[:quantity].present?
      @product = Product.find_by(id: params[:product_id])
  
      if @product
        CartService.new(@cart).add_product(@product, params[:quantity].to_i)
        render_cart(@cart, status: :created)
      else
        render json: { error: "Produto não encontrado" }, status: :not_found
      end
    else
      render_cart(@cart, status: :created) 
    end
  end

  def show
    render_cart(@cart)
  end

  def add_product
    update_cart { CartService.new(@cart).add_product(@product, params[:quantity].to_i) }
  end

  def update_quantity
    update_cart { CartService.new(@cart).update_item_quantity(@cart_item, params[:quantity].to_i) }
  end

  def remove_product
    update_cart { CartService.new(@cart).remove_product(@cart_item) }
  end

  private

def update_cart
  begin
    updated_cart = yield
    render_cart(updated_cart, status: :ok)
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end
end

  def set_cart
    @cart = Cart.find_by(id: params[:cart_id] || params[:id]) || Cart.find_or_initialize_by(id: session[:cart_id])
    @cart ||= Cart.create!(total_price: 0.0)
    session[:cart_id] ||= @cart.id
  end  

  def find_product
    @product = Product.find_by(id: params[:product_id])
    render json: { error: "Produto não encontrado" }, status: :not_found unless @product
  end

  def find_cart_item
    @cart_item = @cart.cart_items.find_by(product_id: params[:product_id])
    render json: { error: "Produto não encontrado no carrinho" }, status: :not_found unless @cart_item
  end

  def render_cart(cart, status: :ok)
    render json: {
      id: cart.id,
      status: cart.status,
      products: cart.cart_items.map { |item| item_to_json(item) },
      total_price: cart.total_price.to_f
    }, status: status
  end

  def item_to_json(item)
    {
      id: item.product.id,
      name: item.product.name,
      quantity: item.quantity,
      unit_price: item.product.price.to_f,
      total_price: item.total_price.to_f
    }
  end
end
