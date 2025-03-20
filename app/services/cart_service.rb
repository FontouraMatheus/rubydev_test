class CartService
  def initialize(cart)
    @cart = cart
  end

  def add_product(product, quantity)
    ActiveRecord::Base.transaction do
      cart_item = @cart.cart_items.find_or_initialize_by(product_id: product.id)
      cart_item.quantity += quantity
      cart_item.save!
      recalculate_total_price
    end
    @cart
  end  

  def update_item_quantity(cart_item, quantity)
    ActiveRecord::Base.transaction do
      cart_item.update!(quantity: cart_item.quantity + quantity)
      recalculate_total_price
    end
    @cart
  end

  def remove_product(cart_item)
    ActiveRecord::Base.transaction do
      cart_item.destroy!
      recalculate_total_price
    end
    @cart
  end

  private

  def recalculate_total_price
    @cart.update!(total_price: @cart.cart_items.joins(:product).sum("cart_items.quantity * products.price"))
  end
end
