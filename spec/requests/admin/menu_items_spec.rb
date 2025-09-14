require 'rails_helper'

RSpec.describe "Admin::MenuItems", type: :request do
  let(:admin) { create(:admin) }
  let!(:menu_item) { create(:menu_item, name: "Test Plat", price: 25.00) }

  before do
    post admin_login_path, params: { email: admin.email, password: 'password123' }
  end

  describe "GET /admin/menu_items" do
    context "when logged in" do
      it "returns http success" do
        get admin_menu_items_path
        expect(response).to have_http_status(:success)
      end

      it "displays all menu items" do
        available_item = create(:menu_item, name: "Available Item", available: true)
        unavailable_item = create(:menu_item, name: "Unavailable Item", available: false)

        get admin_menu_items_path
        expect(response.body).to include("Available Item")
        expect(response.body).to include("Unavailable Item")
        expect(response.body).to include("Test Plat")
      end

      it "displays action buttons" do
        get admin_menu_items_path
        expect(response.body).to include("Modifier")
        expect(response.body).to include("Supprimer")
        expect(response.body).to include("Nouveau Plat")
      end
    end

    context "when not logged in" do
      before { delete admin_logout_path }

      it "redirects to login" do
        get admin_menu_items_path
        expect(response).to redirect_to(admin_login_path)
      end
    end
  end

  describe "GET /admin/menu_items/new" do
    it "returns http success" do
      get new_admin_menu_item_path
      expect(response).to have_http_status(:success)
    end

    it "displays form fields" do
      get new_admin_menu_item_path
      expect(response.body).to include("Nom du plat")
      expect(response.body).to include("Description")
      expect(response.body).to include("Prix")
      expect(response.body).to include("Commentaire")
      expect(response.body).to include("Position")
    end
  end

  describe "POST /admin/menu_items" do
    context "with valid params" do
      let(:valid_params) do
        {
          menu_item: {
            name: "Nouveau Plat",
            description: "Délicieux plat",
            price: 30.00,
            comment: "Sans gluten",
            available: true,
            position: 5
          }
        }
      end

      it "creates a new menu item" do
        expect {
          post admin_menu_items_path, params: valid_params
        }.to change(MenuItem, :count).by(1)
      end

      it "redirects to menu items list" do
        post admin_menu_items_path, params: valid_params
        expect(response).to redirect_to(admin_menu_items_path)
      end

      it "shows success message" do
        post admin_menu_items_path, params: valid_params
        follow_redirect!
        expect(response.body).to include("Plat créé avec succès")
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          menu_item: {
            name: "",
            price: nil
          }
        }
      end

      it "does not create a menu item" do
        expect {
          post admin_menu_items_path, params: invalid_params
        }.not_to change(MenuItem, :count)
      end

      it "renders new template" do
        post admin_menu_items_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /admin/menu_items/:id/edit" do
    it "returns http success" do
      get edit_admin_menu_item_path(menu_item)
      expect(response).to have_http_status(:success)
    end

    it "displays current values" do
      get edit_admin_menu_item_path(menu_item)
      expect(response.body).to include("Test Plat")
      expect(response.body).to include("25")
    end
  end

  describe "PATCH /admin/menu_items/:id" do
    context "with valid params" do
      let(:update_params) do
        {
          menu_item: {
            name: "Updated Plat",
            price: 35.00
          }
        }
      end

      it "updates the menu item" do
        patch admin_menu_item_path(menu_item), params: update_params
        menu_item.reload
        expect(menu_item.name).to eq("Updated Plat")
        expect(menu_item.price).to eq(35.00)
      end

      it "redirects to menu items list" do
        patch admin_menu_item_path(menu_item), params: update_params
        expect(response).to redirect_to(admin_menu_items_path)
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          menu_item: {
            name: "",
            price: -5
          }
        }
      end

      it "does not update the menu item" do
        patch admin_menu_item_path(menu_item), params: invalid_params
        menu_item.reload
        expect(menu_item.name).to eq("Test Plat")
      end

      it "renders edit template" do
        patch admin_menu_item_path(menu_item), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /admin/menu_items/:id" do
    it "destroys the menu item" do
      expect {
        delete admin_menu_item_path(menu_item)
      }.to change(MenuItem, :count).by(-1)
    end

    it "redirects to menu items list" do
      delete admin_menu_item_path(menu_item)
      expect(response).to redirect_to(admin_menu_items_path)
    end

    it "shows success message" do
      delete admin_menu_item_path(menu_item)
      follow_redirect!
      expect(response.body).to include("Plat supprimé avec succès")
    end
  end

  describe "PATCH /admin/menu_items/:id/toggle_availability" do
    it "toggles availability from true to false" do
      menu_item.update(available: true)
      patch toggle_availability_admin_menu_item_path(menu_item)
      menu_item.reload
      expect(menu_item.available).to be_falsey
    end

    it "toggles availability from false to true" do
      menu_item.update(available: false)
      patch toggle_availability_admin_menu_item_path(menu_item)
      menu_item.reload
      expect(menu_item.available).to be_truthy
    end

    it "redirects to menu items list" do
      patch toggle_availability_admin_menu_item_path(menu_item)
      expect(response).to redirect_to(admin_menu_items_path)
    end
  end
end