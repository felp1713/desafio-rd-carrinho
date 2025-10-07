class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def total_price
    cart_items.includes(:product).sum(&:total_price)
  end
  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
