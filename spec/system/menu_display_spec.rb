require 'rails_helper'

RSpec.describe "Menu Display", type: :system do
  before do
    driven_by(:rack_test)

    # Create menu items
    create(:menu_item, name: "Soupe à l'oignon", description: "Soupe traditionnelle",
           price: 14.50, available: true, position: 1)
    create(:menu_item, name: "Coq au vin", description: "Poulet mijoté",
           price: 26.00, available: true, position: 2)
    create(:menu_item, name: "Crème brûlée", description: "Dessert classique",
           price: 12.00, available: false, position: 3)
  end

  describe "public menu page" do
    def menu_item_selector(page)
      page.has_css?('.showcase-menu-item') ? '.showcase-menu-item' : '.menu-item'
    end

    def menu_grid_selector(page)
      page.has_css?('.showcase-layout__grid') ? '.showcase-layout__grid' : '.menu-grid'
    end

    it "displays the restaurant name" do
      visit root_path
      expect(page).to have_content("La Bonne Cuisine")
      expect(page).to have_content("Menu du Jour")
    end

    it "displays available menu items" do
      visit root_path
      expect(page).to have_content("Soupe à l'oignon")
      expect(page).to have_content("Soupe traditionnelle")
      expect(page).to have_content("14,50€")

      expect(page).to have_content("Coq au vin")
      expect(page).to have_content("Poulet mijoté")
      expect(page).to have_content("26,00€")
    end

    it "does not display unavailable items" do
      visit root_path
      expect(page).not_to have_content("Crème brûlée")
      expect(page).not_to have_content("Dessert classique")
    end

    it "displays items in correct order" do
      visit root_path
      selector = menu_item_selector(page)
      menu_items = page.all(selector).map do |card|
        card.find('h3, .showcase-menu-item__name').text
      end
      expect(menu_items).to eq(["Soupe à l'oignon", "Coq au vin"])
    end

    it "has responsive grid layout" do
      visit root_path
      expect(page).to have_css(menu_grid_selector(page))
      expect(page).to have_css(menu_item_selector(page), count: 2)
    end

    it "displays items with proper styling" do
      visit root_path
      within first(menu_item_selector(page)) do
        expect(page).to have_css('h3, .showcase-menu-item__name')
        expect(page).to have_text("Soupe traditionnelle")
        expect(page).to have_css('.menu-item-price, .showcase-menu-item__price')
      end
    end
  end
end
