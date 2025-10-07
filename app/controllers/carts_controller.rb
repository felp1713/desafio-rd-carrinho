class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: formatted_cart(@cart)
  end

  def add_item
    product = Product.find(add_item_params[:product_id])
    quantity = add_item_params[:quantity].to_i
    cart_item = @cart.cart_items.find_by(product_id: product.id)

    if cart_item
      cart_item.increment!(:quantity, quantity)
    else
      @cart.cart_items.create!(product: product, quantity: quantity)
    end

    @cart.touch(:last_interaction_at)
    render json: formatted_cart(@cart)
  end

  def destroy_item
    cart_item = @cart.cart_items.find_by(product_id: params[:product_id])

    if cart_item
      cart_item.destroy
      @cart.touch(:last_interaction_at)
      render json: formatted_cart(@cart)
    else
      render json: { error: 'Product not found in cart' }, status: :not_found
    end
  end

  private

  def set_cart
    if session[:cart_id]
      @cart = Cart.find_by(id: session[:cart_id])
    end

    if @cart.nil?
      @cart = Cart.create!
      session[:cart_id] = @cart.id
    end
  end

  def add_item_params
    params.permit(:product_id, :quantity)
  end

  def formatted_cart(cart)
    items = cart.cart_items.includes(:product)

    {
      id: cart.id,
      products: items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price.to_s,
          total_price: item.total_price.to_s
        }
      end,
      total_price: cart.total_price.to_s
    }
  end
end
