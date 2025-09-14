require 'rails_helper'

RSpec.describe "Admin::Sessions", type: :request do
  let(:admin) { create(:admin, email: 'test@labonnecuisine.fr', password: 'password123') }

  describe "GET /admin/login" do
    it "returns http success" do
      get admin_login_path
      expect(response).to have_http_status(:success)
    end

    it "displays login form" do
      get admin_login_path
      expect(response.body).to include("Connexion Administrateur")
      expect(response.body).to include("Email")
      expect(response.body).to include("Mot de passe")
    end

    it "redirects to admin menu if already logged in" do
      post admin_login_path, params: { email: admin.email, password: 'password123' }
      get admin_login_path
      expect(response).to redirect_to(admin_menu_items_path)
    end
  end

  describe "POST /admin/login" do
    context "with valid credentials" do
      it "logs in the admin" do
        post admin_login_path, params: { email: admin.email, password: 'password123' }
        expect(response).to redirect_to(admin_menu_items_path)
        follow_redirect!
        expect(response.body).to include("Gestion du Menu")
      end

      it "creates a session" do
        post admin_login_path, params: { email: admin.email, password: 'password123' }
        expect(session[:admin_id]).to eq(admin.id)
      end
    end

    context "with invalid credentials" do
      it "does not log in with wrong password" do
        post admin_login_path, params: { email: admin.email, password: 'wrong' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Email ou mot de passe incorrect")
      end

      it "does not log in with non-existent email" do
        post admin_login_path, params: { email: 'wrong@example.com', password: 'password123' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Email ou mot de passe incorrect")
      end

      it "does not create a session" do
        post admin_login_path, params: { email: admin.email, password: 'wrong' }
        expect(session[:admin_id]).to be_nil
      end
    end
  end

  describe "DELETE /admin/logout" do
    before do
      post admin_login_path, params: { email: admin.email, password: 'password123' }
    end

    it "logs out the admin" do
      delete admin_logout_path
      expect(response).to redirect_to(root_path)
      expect(session[:admin_id]).to be_nil
    end

    it "redirects to root path" do
      delete admin_logout_path
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Menu du Jour")
    end
  end
end