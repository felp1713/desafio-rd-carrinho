class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  scope :to_be_abandoned, -> { where(status: 'active').where('last_interaction_at < ?', 3.hours.ago) }
  scope :to_be_deleted, -> { where(status: 'abandoned').where('updated_at < ?', 7.days.ago) }

  def abandoned?
    status == 'abandoned'
  end

  def mark_as_abandoned
    if last_interaction_at < 3.hours.ago
      update!(status: 'abandoned')
    end
  end

  def remove_if_abandoned
    if abandoned? && updated_at < 7.days.ago
      destroy
    end
  end

  def total_price
    cart_items.includes(:product).sum(&:total_price)
  end
  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
