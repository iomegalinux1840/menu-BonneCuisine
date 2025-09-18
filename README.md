# La Bonne Cuisine - Menu Application

Une application Ruby on Rails pour la gestion du menu du restaurant français "La Bonne Cuisine".

## Fonctionnalités

- **Menu public** : Affichage du menu en temps réel pour les clients
- **Administration** : Interface d'administration pour la gestion du menu
- **Mises à jour en temps réel** : ActionCable pour les changements instantanés
- **Design responsive** : Optimisé pour desktop et tablette
- **Interface française** : Entièrement localisée en français

## Prérequis

- Ruby 3.2.0+
- Rails 7.0+
- PostgreSQL
- Node.js (pour les assets JavaScript)

## Installation

1. **Cloner le projet** (ou utiliser les fichiers existants)

2. **Installer les dépendances Ruby** :
   ```bash
   bundle install
   ```

3. **Configurer la base de données** :
   ```bash
   # Créer la base de données
   rails db:create

   # Exécuter les migrations
   rails db:migrate

   # Charger les données initiales
   rails db:seed
   ```

4. **Démarrer le serveur** :
   ```bash
   rails server
   ```

5. **Accéder à l'application** :
   - Menu public : http://localhost:3000
   - Administration : http://localhost:3000/admin/login

## Comptes d'administration

**Email** : admin@labonnecuisine.fr
**Mot de passe** : password123

## Structure du projet

### Modèles
- **Admin** : Gestion des administrateurs avec authentification
- **MenuItem** : Gestion des plats du menu

### Contrôleurs
- **MenuItemsController** : Affichage public du menu
- **Admin::SessionsController** : Authentification admin
- **Admin::MenuItemsController** : Gestion CRUD du menu

### Vues
- **Menu public** : Affichage en grille des plats disponibles
- **Administration** : Interface de gestion complète

### ActionCable
- **MenuChannel** : Diffusion des changements en temps réel

## Base de données

### Table `admins`
- `email` : Email unique de l'administrateur
- `password_digest` : Mot de passe crypté

### Table `menu_items`
- `name` : Nom du plat (obligatoire)
- `description` : Description du plat
- `price` : Prix (decimal 8,2)
- `comment` : Commentaire (allergies, suggestions)
- `available` : Disponibilité (boolean, défaut: true)
- `position` : Position dans l'affichage (integer)

## Configuration ActionCable

L'application utilise ActionCable pour les mises à jour en temps réel :
- **Développement** : ws://localhost:3000/cable
- **Production** : Configuration à adapter selon l'environnement

## Données de démonstration

Le fichier `db/seeds.rb` contient :
- 1 compte administrateur
- 12 plats français authentiques (entrées, plats, desserts)

## Styling et Design

- **Couleur principale** : Bleu (#2B5797) en accord avec le logo
- **Typographie** : Playfair Display (titres) + Source Sans Pro (texte)
- **Layout** : Grille CSS pour l'affichage des plats
- **Responsive** : Optimisé pour desktop et tablette

## Déploiement

### Variables d'environnement de production
```bash
DATABASE_URL=postgresql://...
RAILS_MASTER_KEY=...
STRIPE_SECRET_KEY=sk_live...
STRIPE_PUBLISHABLE_KEY=pk_live...
STRIPE_PRICE_ID=price_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PRICING_TABLE_ID=prctbl_...
STRIPE_TRIAL_DAYS=14
```

### Paiements Stripe

- Ajoutez vos clés Stripe (`STRIPE_SECRET_KEY` et `STRIPE_PUBLISHABLE_KEY`) dans les variables d'environnement (Railway, Render, etc.).
- Définissez `STRIPE_PRICE_ID` avec l'identifiant du prix de l'abonnement (utilisé pour le bouton Stripe Checkout si aucune table de prix n'est fournie).
- Ajoutez `STRIPE_PRICING_TABLE_ID` si vous souhaitez intégrer directement la table de prix Stripe.
- `STRIPE_TRIAL_DAYS` (optionnel) permet d'ajuster la durée de l'essai pour les nouveaux restaurants (14 jours par défaut).
- L'accueil (`/`) agit maintenant comme page de présentation avec un appel à l'action vers `/restaurants/new` pour créer un restaurant, un administrateur propriétaire et déclencher automatiquement l'essai Stripe.
- Créez un endpoint webhook dans le dashboard Stripe pointant vers `/stripe/webhooks` et copiez le secret (`STRIPE_WEBHOOK_SECRET`).
- En local, vous pouvez créer un fichier `.env` (à partir de `.env.example`) pour charger ces valeurs en développement.
- Relancez `rails db:migrate` après déploiement pour créer les tables de souscriptions.

### ActionCable en production
Modifier dans `config/environments/production.rb` :
```ruby
config.action_cable.url = 'wss://votre-domaine.com/cable'
config.action_cable.allowed_request_origins = ['https://votre-domaine.com']
```

## Tests

```bash
# Installation des gems de test
bundle install

# Exécuter les tests
rails test
```

## Fonctionnalités détaillées

### Menu public
- Affichage de 12 plats maximum
- Mise à jour automatique sans rechargement
- Design élégant avec cartes et ombres
- Affichage des prix en euros
- Commentaires pour allergies/suggestions

### Administration
- Authentification sécurisée
- CRUD complet sur les plats
- Toggle de disponibilité en un clic
- Gestion des positions dans le menu
- Interface responsive

### Real-time
- Diffusion automatique des changements
- Mise à jour du DOM sans rechargement
- Délai de 2-3 secondes maximum
- Compatible avec tous les navigateurs modernes

## Support

Pour toute question sur l'installation ou l'utilisation, veuillez consulter la documentation Rails officielle ou créer une issue.

---

© 2024 La Bonne Cuisine - Application développée avec Ruby on Rails
