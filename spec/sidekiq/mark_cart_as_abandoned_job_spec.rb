require 'rails_helper'
RSpec.describe MarkCartAsAbandonedJob, type: :job do
    it 'marks inactive carts as abandoned and deletes old abandoned carts' do
        active_cart = create(:shopping_cart, last_interaction_at: 1.hour.ago)
        inactive_cart = create(:shopping_cart, last_interaction_at: 4.hours.ago)
        recent_abandoned_cart = create(:shopping_cart, status: 'abandoned', updated_at: 1.day.ago)
        old_abandoned_cart = create(:shopping_cart, status: 'abandoned', updated_at: 8.days.ago)

        expect {
            MarkCartAsAbandonedJob.new.perform
        }.to change { Cart.count }.by(-1)
        expect(active_cart.reload.status).to eq('active')
        expect(inactive_cart.reload.status).to eq('abandoned')
        expect(recent_abandoned_cart.reload).to be_present
        expect { old_abandoned_cart.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
end
