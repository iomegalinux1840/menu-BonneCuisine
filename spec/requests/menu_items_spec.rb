require 'rails_helper'

RSpec.describe "MenuItems", type: :request do
  describe "GET /" do
    before do
      create(:menu_item, :entree, available: true, position: 1)
      create(:menu_item, :plat, available: true, position: 2)
      create(:menu_item, :dessert, available: false, position: 3)
    end

    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "displays only available menu items" do
      get root_path
      expect(response.body).to include("Soupe à l'oignon gratinée")
      expect(response.body).to include("Coq au vin de Bourgogne")
      expect(response.body).not_to include("Crème brûlée à la vanille")
    end

    it "displays menu items in correct order" do
      get root_path
      entree_pos = response.body.index("Soupe à l'oignon gratinée")
      plat_pos = response.body.index("Coq au vin de Bourgogne")
      expect(entree_pos).to be < plat_pos
    end

    it "displays restaurant name" do
      get root_path
      expect(response.body).to include("La Bonne Cuisine")
    end

    it "displays prices with euro symbol" do
      get root_path
      expect(response.body).to include("14,50€")
      expect(response.body).to include("26,00€")
    end

    it "includes ActionCable meta tag" do
      get root_path
      expect(response.body).to include("action-cable-url")
    end
  end
end