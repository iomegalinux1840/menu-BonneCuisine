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
      menu_items = page.all('.menu-item h3').map(&:text)
      expect(menu_items).to eq(["Soupe à l'oignon", "Coq au vin"])
    end

    it "has responsive grid layout" do
      visit root_path
      expect(page).to have_css('.menu-grid')
      expect(page).to have_css('.menu-item', count: 2)
    end

    it "displays items with proper styling" do
      visit root_path
      within first('.menu-item') do
        expect(page).to have_css('h3')
        expect(page).to have_css('.description')
        expect(page).to have_css('.price')
      end
    end
  end
end