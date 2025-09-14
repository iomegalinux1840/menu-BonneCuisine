# Create admin user
admin = Admin.create!(
  email: "admin@labonnecuisine.fr",
  password: "password123",
  password_confirmation: "password123"
)

puts "Admin créé: #{admin.email}"

# Create menu items
menu_items = [
  {
    name: "Soupe à l'oignon gratinée",
    description: "Soupe traditionnelle à l'oignon caramélisé, gratinée au fromage Gruyère et servie avec des croûtons dorés",
    price: 14.50,
    comment: "Spécialité de la maison • Contient: gluten, lactose",
    position: 1
  },
  {
    name: "Escargots de Bourgogne",
    description: "Six escargots préparés au beurre d'ail persillé, accompagnés de pain grillé",
    price: 16.00,
    comment: "Préparation traditionnelle • Contient: gluten, lactose",
    position: 2
  },
  {
    name: "Foie gras poêlé aux figues",
    description: "Escalope de foie gras de canard poêlée, compotée de figues et pain de campagne toasté",
    price: 24.00,
    comment: "Produit d'exception • Contient: gluten",
    position: 3
  },
  {
    name: "Coq au vin de Bourgogne",
    description: "Cuisses de coq mijotées au vin rouge, lardons fumés, champignons de Paris et petits oignons grelots",
    price: 26.00,
    comment: "Recette traditionnelle • Contient: sulfites",
    position: 4
  },
  {
    name: "Bouillabaisse marseillaise",
    description: "Soupe de poissons méditerranéens, rouille safranée, croûtons et fromage râpé",
    price: 32.00,
    comment: "Selon arrivage • Contient: poisson, gluten, lactose",
    position: 5
  },
  {
    name: "Magret de canard aux cerises",
    description: "Magret de canard rosé, sauce aux cerises noires et gratin dauphinois",
    price: 28.00,
    comment: "Cuisson rosée recommandée • Contient: lactose",
    position: 6
  },
  {
    name: "Ratatouille niçoise",
    description: "Légumes du soleil mijotés à l'huile d'olive, herbes de Provence et riz complet",
    price: 20.00,
    comment: "Plat végétarien • Sans gluten",
    position: 7
  },
  {
    name: "Plateau de fromages affinés",
    description: "Sélection de fromages français affinés par notre maître fromager, pain aux noix et confiture de figue",
    price: 18.00,
    comment: "Selon disponibilité • Contient: lactose, gluten, fruits à coque",
    position: 8
  },
  {
    name: "Crème brûlée à la vanille",
    description: "Crème onctueuse à la vanille de Madagascar, caramélisée au sucre roux",
    price: 12.00,
    comment: "Dessert signature • Contient: lactose, œufs",
    position: 9
  },
  {
    name: "Tarte Tatin aux pommes",
    description: "Tarte renversée aux pommes caramélisées, pâte brisée maison et glace vanille",
    price: 14.00,
    comment: "Servie tiède • Contient: gluten, lactose, œufs",
    position: 10
  },
  {
    name: "Mousse au chocolat noir",
    description: "Mousse légère au chocolat noir 70% de Madagascar, chantilly et copeaux de chocolat",
    price: 13.00,
    comment: "Recette grand-mère • Contient: lactose, œufs",
    position: 11
  },
  {
    name: "Café gourmand",
    description: "Expresso accompagné de trois mignardises: macaron, mini éclair et petit-four",
    price: 11.00,
    comment: "Parfait pour finir • Contient: gluten, lactose, œufs, fruits à coque",
    position: 12
  }
]

menu_items.each do |item_attrs|
  item = MenuItem.create!(item_attrs)
  puts "Plat créé: #{item.name} - #{item.price}€"
end

puts "\n✨ Base de données initialisée avec succès!"
puts "📧 Admin: #{admin.email}"
puts "🔑 Mot de passe: password123"
puts "🍽️ #{MenuItem.count} plats créés"