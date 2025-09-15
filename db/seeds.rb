# Clear existing data
MenuItem.destroy_all
Admin.destroy_all
Restaurant.destroy_all

# Create the restaurant first
restaurant = Restaurant.create!(
  name: 'La Bonne Cuisine',
  slug: 'la-bonne-cuisine',
  subdomain: 'labonnecuisine',
  primary_color: '#8B4513',
  secondary_color: '#F5DEB3',
  font_family: 'Playfair Display',
  timezone: 'America/Toronto'
)

puts "Restaurant créé: #{restaurant.name} (slug: #{restaurant.slug})"

# Create admin user
admin = Admin.create!(
  email: 'admin@labonnecuisine.ca',
  password: 'password123',
  password_confirmation: 'password123',
  restaurant: restaurant,
  role: 'owner'
)

puts "Admin créé: #{admin.email}"

# Create French Canadian fast food menu items
menu_items = [
  {
    name: 'Poutine Classique',
    description: 'Frites fraîches, sauce brune maison et fromage en grains qui fait "squick squick"',
    price: 12.99,
    comment: 'Notre spécialité depuis 1985 • Végétarien',
    available: true,
    position: 1
  },
  {
    name: 'Poutine au Smoked Meat',
    description: 'Notre poutine classique garnie de généreux morceaux de smoked meat de Montréal',
    price: 18.99,
    comment: 'Best-seller • Contient: gluten',
    available: true,
    position: 2
  },
  {
    name: 'Hot-Dog Steamé All-Dressed',
    description: 'Deux saucisses steamées, chou, oignons, moutarde et relish dans un pain vapeur',
    price: 8.99,
    comment: 'Style cabane à sucre • Contient: gluten, moutarde',
    available: true,
    position: 3
  },
  {
    name: 'Burger Le Bûcheron',
    description: 'Double bœuf Angus, bacon, fromage cheddar fort, oignons caramélisés, sauce BBQ érable',
    price: 16.99,
    comment: 'Bœuf local • Contient: gluten, lactose',
    available: true,
    position: 4
  },
  {
    name: 'Club Sandwich Québécois',
    description: 'Triple étage avec poulet grillé, bacon croustillant, tomates, laitue, mayo maison',
    price: 14.99,
    comment: 'Servi avec frites et salade de chou • Contient: gluten, œufs',
    available: true,
    position: 5
  },
  {
    name: 'Guédille aux Crevettes',
    description: 'Pain hot-dog grillé rempli de crevettes nordiques, mayo citronnée et ciboulette',
    price: 15.99,
    comment: 'Crevettes de Matane • Contient: crustacés, gluten',
    available: true,
    position: 6
  },
  {
    name: 'Tourtière du Lac',
    description: 'Pâté à la viande traditionnel servi avec ketchup aux fruits maison et salade verte',
    price: 13.99,
    comment: 'Recette de grand-maman • Contient: gluten',
    available: true,
    position: 7
  },
  {
    name: 'Rondelles d\'Oignon Géantes',
    description: 'Oignons panés croustillants servis avec sauce ranch épicée',
    price: 9.99,
    comment: 'À partager • Végétarien',
    available: true,
    position: 8
  },
  {
    name: 'Pouding Chômeur',
    description: 'Gâteau éponge nappé de sirop d\'érable, servi chaud avec crème glacée vanille',
    price: 7.99,
    comment: 'Dessert réconfortant • Contient: gluten, lactose',
    available: true,
    position: 9
  },
  {
    name: 'Queue de Castor',
    description: 'Pâte frite étirée, cannelle et sucre, avec option Nutella ou sirop d\'érable',
    price: 6.99,
    comment: 'Chaud et croustillant • Contient: gluten',
    available: true,
    position: 10
  },
  {
    name: 'Tarte au Sucre',
    description: 'Tarte traditionnelle au sucre brun et crème, servie avec crème fouettée',
    price: 5.99,
    comment: 'Fait maison • Contient: gluten, lactose',
    available: true,
    position: 11
  },
  {
    name: 'Flotteur à la Bière d\'Épinette',
    description: 'Bière d\'épinette Bec Cola avec boule de crème glacée vanille',
    price: 4.99,
    comment: 'Rafraîchissant et nostalgique • Sans alcool',
    available: true,
    position: 12
  }
]

menu_items.each do |item|
  menu_item = restaurant.menu_items.create!(item)
  puts "Plat créé: #{menu_item.name} - #{menu_item.price}$"
end

puts "\n✨ Base de données initialisée avec succès!"
puts "📧 Admin: #{admin.email}"
puts "🔑 Mot de passe: password123"
puts "🍟 #{MenuItem.count} plats créés"