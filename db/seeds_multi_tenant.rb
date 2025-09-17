# Multi-tenant seed data for testing

# Create a second restaurant
pizza_place = Restaurant.find_or_create_by!(slug: "tonys-pizza") do |r|
  r.name = "Tony's Pizza Palace"
  r.subdomain = "tonys"
  r.primary_color = "#D32F2F"
  r.secondary_color = "#FFF3E0"
  r.font_family = "Roboto Slab"
  r.timezone = "America/Toronto"
  r.menu_grid_columns = 5
  r.menu_image_size = 'small'
  r.message_of_the_day = "Pizza du chef : garniture surprise disponible aujourd'hui!"
end

# Create admin for pizza place
Admin.find_or_create_by!(email: "admin@tonyspizza.com", restaurant: pizza_place) do |a|
  a.password = "pizza123"
  a.role = "owner"
end

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
  },
  {
    name: "BBQ Chicken",
    description: "Grilled chicken, BBQ sauce, red onions, cilantro",
    price: 18.99,
    comment: "Contains: gluten",
    available: true,
    position: 3
  },
  {
    name: "Vegetarian Supreme",
    description: "Bell peppers, mushrooms, olives, onions, tomatoes",
    price: 15.99,
    comment: "Vegetarian",
    available: true,
    position: 4
  },
  {
    name: "Hawaiian",
    description: "Ham, pineapple, mozzarella, tomato sauce",
    price: 16.99,
    comment: "Sweet & savory",
    available: true,
    position: 5
  },
  {
    name: "Meat Lovers",
    description: "Pepperoni, sausage, bacon, ham, ground beef",
    price: 20.99,
    comment: "Extra protein",
    available: true,
    position: 6
  }
]

pizza_items.each do |item_attrs|
  pizza_place.menu_items.find_or_create_by!(name: item_attrs[:name]) do |item|
    item_attrs.each { |k, v| item.send("#{k}=", v) }
  end
end

# Create a third restaurant - sushi place
sushi_bar = Restaurant.find_or_create_by!(slug: "sakura-sushi") do |r|
  r.name = "Sakura Sushi Bar"
  r.subdomain = "sakura"
  r.primary_color = "#1976D2"
  r.secondary_color = "#E3F2FD"
  r.font_family = "Noto Sans"
  r.timezone = "America/Toronto"
  r.menu_grid_columns = 3
  r.menu_image_size = 'large'
  r.message_of_the_day = "Assortiment spécial sakura offert pour une durée limitée."
end

# Create admin for sushi bar
Admin.find_or_create_by!(email: "admin@sakurasushi.com", restaurant: sushi_bar) do |a|
  a.password = "sushi123"
  a.role = "owner"
end

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
  },
  {
    name: "Dragon Roll",
    description: "Shrimp tempura, eel, avocado, eel sauce",
    price: 15.99,
    comment: "Chef's special",
    available: true,
    position: 3
  },
  {
    name: "Tuna Nigiri",
    description: "2 pieces of yellowfin tuna over rice",
    price: 7.99,
    comment: "Gluten-free option",
    available: true,
    position: 4
  },
  {
    name: "Vegetable Tempura",
    description: "Assorted vegetables, lightly battered and fried",
    price: 9.99,
    comment: "Vegetarian",
    available: true,
    position: 5
  },
  {
    name: "Chirashi Bowl",
    description: "Assorted sashimi over sushi rice",
    price: 22.99,
    comment: "Contains: raw fish",
    available: true,
    position: 6
  }
]

sushi_items.each do |item_attrs|
  sushi_bar.menu_items.find_or_create_by!(name: item_attrs[:name]) do |item|
    item_attrs.each { |k, v| item.send("#{k}=", v) }
  end
end

puts "Created multi-tenant seed data:"
puts "- Tony's Pizza Palace (subdomain: tonys)"
puts "  Admin: admin@tonyspizza.com / pizza123"
puts "- Sakura Sushi Bar (subdomain: sakura)"
puts "  Admin: admin@sakurasushi.com / sushi123"
puts ""
puts "Access URLs (for local testing):"
puts "- http://tonys.localhost:3000 - Tony's Pizza menu"
puts "- http://sakura.localhost:3000 - Sakura Sushi menu"
puts "- http://localhost:3000/r/tonys-pizza - Path-based access"
puts "- http://localhost:3000/r/sakura-sushi - Path-based access"
