require 'rails_helper'

RSpec.describe "Admin Management", type: :system do
  before do
    driven_by(:rack_test)

    @admin = create(:admin, email: 'admin@test.fr', password: 'password123')
    @menu_item = create(:menu_item, name: "Test Plat", price: 25.00, available: true)
  end

  describe "admin login" do
    it "allows admin to login with valid credentials" do
      visit admin_login_path

      fill_in "Email", with: @admin.email
      fill_in "Mot de passe", with: "password123"
      click_button "Se connecter"

      expect(page).to have_current_path(admin_menu_items_path)
      expect(page).to have_content("Gestion du Menu")
    end

    it "rejects invalid credentials" do
      visit admin_login_path

      fill_in "Email", with: @admin.email
      fill_in "Mot de passe", with: "wrong"
      click_button "Se connecter"

      expect(page).to have_content("Email ou mot de passe incorrect")
    end
  end

  describe "admin menu management" do
    before do
      visit admin_login_path
      fill_in "Email", with: @admin.email
      fill_in "Mot de passe", with: "password123"
      click_button "Se connecter"
    end

    it "displays all menu items" do
      expect(page).to have_content("Test Plat")
      expect(page).to have_content("25,00€")
      expect(page).to have_css(".badge-success", text: "Disponible")
    end

    it "allows creating a new menu item" do
      click_link "Nouveau Plat"

      fill_in "Nom du plat", with: "Nouveau Plat Test"
      fill_in "Description", with: "Description test"
      fill_in "Prix", with: "30.50"
      fill_in "Commentaire", with: "Sans gluten"
      fill_in "Position", with: "5"
      check "Disponible"

      click_button "Créer le plat"

      expect(page).to have_content("Plat créé avec succès")
      expect(page).to have_content("Nouveau Plat Test")
      expect(page).to have_content("30,50€")
    end

    it "allows editing a menu item" do
      within "#menu_item_#{@menu_item.id}" do
        click_link "Modifier"
      end

      fill_in "Nom du plat", with: "Plat Modifié"
      fill_in "Prix", with: "35.00"
      click_button "Mettre à jour"

      expect(page).to have_content("Plat mis à jour avec succès")
      expect(page).to have_content("Plat Modifié")
      expect(page).to have_content("35,00€")
    end

    it "allows toggling availability" do
      within "#menu_item_#{@menu_item.id}" do
        expect(page).to have_css(".badge-success", text: "Disponible")

        click_button "Rendre indisponible"
      end

      within "#menu_item_#{@menu_item.id}" do
        expect(page).to have_css(".badge-danger", text: "Non disponible")
      end
    end

    it "allows deleting a menu item" do
      within "#menu_item_#{@menu_item.id}" do
        accept_confirm do
          click_link "Supprimer"
        end
      end

      expect(page).to have_content("Plat supprimé avec succès")
      expect(page).not_to have_content("Test Plat")
    end

    it "validates form inputs" do
      click_link "Nouveau Plat"

      fill_in "Nom du plat", with: ""
      fill_in "Prix", with: "-5"
      click_button "Créer le plat"

      expect(page).to have_content("ne peut pas être vide")
      expect(page).to have_content("doit être supérieur à 0")
    end

    it "allows admin to logout" do
      click_link "Déconnexion"

      expect(page).to have_current_path(root_path)
      expect(page).to have_content("Menu du Jour")

      # Try to access admin area
      visit admin_menu_items_path
      expect(page).to have_current_path(admin_login_path)
    end
  end
end