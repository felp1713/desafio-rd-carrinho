require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "GET /show" do
    context "when no cart exists in the session" do
      it "creates a new cart and returns it" do
        session = {}
        allow_any_instance_of(CartsController).to receive(:session).and_return(session)

        get cart_path

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response["id"]).not_to be_nil
        expect(json_response["products"]).to be_empty
        expect(json_response["total_price"]).to eq("0")
        expect(session[:cart_id]).not_to be_nil
      end
    end

    context "when a cart with items exists in the session" do
      let!(:product1) { Product.create!(name: "Produto A", price: 10.00) }
      let!(:product2) { Product.create!(name: "Produto B", price: 20.00) }
      let!(:cart) { Cart.create! }
      let!(:cart_item1) { cart.cart_items.create!(product: product1, quantity: 2) }
      let!(:cart_item2) { cart.cart_items.create!(product: product2, quantity: 1) }

      it "returns the cart with its items and correct totals" do
        session = { cart_id: cart.id }
        allow_any_instance_of(CartsController).to receive(:session).and_return(session)

        get cart_path

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response["id"]).to eq(cart.id)
        expect(json_response["products"].size).to eq(2)
        expect(json_response["total_price"]).to eq("40.0")

        product_a_data = json_response["products"].find { |p| p["id"] == product1.id }
        expect(product_a_data["name"]).to eq("Produto A")
        expect(product_a_data["quantity"]).to eq(2)
        expect(product_a_data["unit_price"]).to eq("10.0")
        expect(product_a_data["total_price"]).to eq("20.0")
      end
    end
  end

  describe "POST /add_items" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }

    before do
      session = { cart_id: cart.id }
      allow_any_instance_of(CartsController).to receive(:session).and_return(session)
    end

    context "when adding a new product to the cart" do
      it "creates a new cart item" do
        expect {
          post '/cart/add_items', params: { product_id: product.id, quantity: 2 }
        }.to change(CartItem, :count).by(1)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the product already is in the cart' do
      let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end

  describe "DELETE /cart/:product_id" do
    let!(:cart) { Cart.create! }
    let!(:product1) { Product.create!(name: "Product A", price: 10.0) }
    let!(:product2) { Product.create!(name: "Product B", price: 20.0) }
    let!(:cart_item1) { cart.cart_items.create!(product: product1, quantity: 1) }
    let!(:cart_item2) { cart.cart_items.create!(product: product2, quantity: 1) }

    before do
      session = { cart_id: cart.id }
      allow_any_instance_of(CartsController).to receive(:session).and_return(session)
    end

    it "removes the specified item from the cart" do
      expect {
        delete destroy_cart_item_path(product_id: product1.id)
      }.to change(CartItem, :count).by(-1)

      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response["products"].size).to eq(1)
      expect(json_response["products"][0]["name"]).to eq("Product B")
      expect(json_response["total_price"]).to eq("20.0")
    end

    it "returns an error if product is not in cart" do
      other_product = Product.create!(name: "Product C", price: 99.0)
      delete destroy_cart_item_path(product_id: other_product.id)
      expect(response).to have_http_status(:not_found)
    end
  end
  # pending "TODO: Escreva os testes de comportamento do controller de carrinho necessários para cobrir a sua implmentação #{__FILE__}"
end
