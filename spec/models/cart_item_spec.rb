require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
    it 'belongs to a cart' do
      association = described_class.reflect_on_association(:cart)
      expect(association.macro).to eq :belongs_to
    end

    it 'belongs to a product' do
      association = described_class.reflect_on_association(:product)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe '#total_price' do
    it 'calculates the total price for the cart item' do
      product = Product.new(price: 10.00)
      cart_item = CartItem.new(product: product, quantity: 2)

      expect(cart_item.total_price).to eq(20.00)
    end
  end
end