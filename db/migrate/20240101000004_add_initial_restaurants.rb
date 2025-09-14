class AddInitialRestaurants < ActiveRecord::Migration[7.0]
  def up
    # Create Tony's Pizza Palace
    pizza_place = Restaurant.create!(
      name: "Tony's Pizza Palace",
      slug: "tonys-pizza",
      subdomain: "tonys",
      primary_color: "#D32F2F",
      secondary_color: "#FFF3E0",
      font_family: "Roboto Slab",
      timezone: "America/Toronto"
    )

    # Create admin for pizza place
    Admin.create!(
      email: "admin@tonyspizza.com",
      password: "pizza123",
      role: "owner",
      restaurant: pizza_place
    )

    # Create menu items for pizza place
    pizza_items = [
      {
        name: "Margherita Classic",
        description: "Fresh mozzarella, tomato sauce, basil leaves",
        price: 14.99,
        comment: "Vegetarian",
        available: true,
        position: 1
      },
      {
        name: "Pepperoni Feast",
        description: "Double pepperoni, mozzarella, tomato sauce",
        price: 16.99,
        comment: "Most popular",
        available: true,
        position: 2
      }
    ]

    pizza_items.each do |item_attrs|
      pizza_place.menu_items.create!(item_attrs)
    end

    # Create Sakura Sushi Bar
    sushi_bar = Restaurant.create!(
      name: "Sakura Sushi Bar",
      slug: "sakura-sushi",
      subdomain: "sakura",
      primary_color: "#1976D2",
      secondary_color: "#E3F2FD",
      font_family: "Noto Sans",
      timezone: "America/Toronto"
    )

    # Create admin for sushi bar
    Admin.create!(
      email: "admin@sakurasushi.com",
      password: "sushi123",
      role: "owner",
      restaurant: sushi_bar
    )

    # Create menu items for sushi bar
    sushi_items = [
      {
        name: "Salmon Sashimi",
        description: "6 pieces of fresh Atlantic salmon",
        price: 12.99,
        comment: "Gluten-free",
        available: true,
        position: 1
      },
      {
        name: "California Roll",
        description: "Crab, avocado, cucumber, sesame seeds",
        price: 8.99,
        comment: "Contains: shellfish",
        available: true,
        position: 2
      }
    ]

    sushi_items.each do |item_attrs|
      sushi_bar.menu_items.create!(item_attrs)
    end
  end

  def down
    Restaurant.where(slug: ["tonys-pizza", "sakura-sushi"]).destroy_all
  end
end