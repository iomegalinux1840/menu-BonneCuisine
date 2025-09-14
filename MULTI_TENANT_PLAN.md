# Multi-Tenant Restaurant Menu Platform - Implementation Plan

## Overview
Transform the single-restaurant La Bonne Cuisine app into a multi-tenant SaaS platform where multiple restaurants can manage and display their menus independently.

## Architecture Decision
- **Approach**: Subdomain-based tenant identification
- **URL Structure**: `{restaurant-slug}.menuplatform.app`
- **Database**: Single database with tenant isolation via foreign keys
- **Admin Access**: `admin.menuplatform.app/{restaurant-slug}`

## Core Requirements
1. Each restaurant has completely isolated data
2. Public menu pages require no authentication (for TV displays, social sharing)
3. Admin areas require authentication scoped to restaurant
4. Support for custom branding per restaurant
5. Real-time updates work per restaurant only
6. Scalable to hundreds of restaurants

## Database Schema Changes

### New Tables Needed
```
restaurants
- id (bigint, primary key)
- name (string, not null)
- slug (string, unique, not null) # URL identifier
- subdomain (string, unique) # optional custom subdomain
- custom_domain (string, unique) # optional fully custom domain
- logo_url (string)
- primary_color (string, default: '#8B4513')
- secondary_color (string, default: '#F5DEB3')
- font_family (string, default: 'Playfair Display')
- timezone (string, default: 'America/Toronto')
- created_at
- updated_at
- deleted_at (soft delete)

restaurant_settings
- id
- restaurant_id (foreign key)
- setting_key (string)
- setting_value (text)
- created_at
- updated_at
```

### Existing Tables Modifications
```
menu_items
- ADD: restaurant_id (bigint, foreign key, not null)
- ADD: image_url (string)
- MODIFY: position to be scoped per restaurant

admins
- ADD: restaurant_id (bigint, foreign key, not null)
- ADD: role (string, default: 'manager') # owner, manager, staff
- ADD: last_login_at (datetime)
```

## Technical Implementation Tasks

### Phase 1: Database & Models (Foundation)
- [ ] Create migration for restaurants table
- [ ] Create Restaurant model with validations
- [ ] Create migration to add restaurant_id to menu_items
- [ ] Create migration to add restaurant_id to admins
- [ ] Update MenuItem model with belongs_to :restaurant
- [ ] Update Admin model with belongs_to :restaurant
- [ ] Add Restaurant has_many associations
- [ ] Create seeds for demo restaurants
- [ ] Add slug generation logic (friendly_id gem?)
- [ ] Add subdomain validation (no reserved words)

### Phase 2: Request Infrastructure
- [ ] Create CurrentTenant concern for controllers
- [ ] Implement subdomain extraction middleware
- [ ] Add before_action to set @current_restaurant
- [ ] Create Subdomain constraint class for routing
- [ ] Handle missing/invalid subdomain (404 or redirect)
- [ ] Add tenant switching for super admin
- [ ] Implement request.host parsing for custom domains

### Phase 3: Routing Restructure
- [ ] Update routes.rb with subdomain constraints
- [ ] Separate public routes (menu display)
- [ ] Separate admin routes with restaurant scope
- [ ] Add landing page route for main domain
- [ ] Add restaurant signup route
- [ ] Update all path helpers to include subdomain
- [ ] Add routes for restaurant settings

### Phase 4: Controllers Update
- [ ] Update MenuItemsController with restaurant scope
- [ ] Update AdminsController with restaurant scope
- [ ] Create PublicMenuController for display
- [ ] Update AdminSessionsController for multi-tenant
- [ ] Create RestaurantsController for management
- [ ] Add restaurant context to ApplicationController
- [ ] Update all queries to use current_restaurant scope
- [ ] Handle cross-tenant access attempts

### Phase 5: Views & Frontend
- [ ] Create restaurant selection page for admin login
- [ ] Update menu display with restaurant branding
- [ ] Add restaurant settings page in admin
- [ ] Update admin navigation with restaurant name
- [ ] Create restaurant onboarding flow
- [ ] Add logo upload functionality
- [ ] Implement theme color customization
- [ ] Update all view paths for multi-tenant

### Phase 6: ActionCable Multi-tenancy
- [ ] Scope menu_channel by restaurant
- [ ] Update channel subscription with restaurant_id
- [ ] Modify broadcast keys to include restaurant
- [ ] Test cross-tenant isolation for broadcasts
- [ ] Update JavaScript to handle restaurant scope

### Phase 7: Authentication & Authorization
- [ ] Scope admin login by restaurant
- [ ] Add role-based permissions (owner vs staff)
- [ ] Implement super admin access
- [ ] Add restaurant switching for super admin
- [ ] Update session handling for multi-tenant
- [ ] Add "remember restaurant" functionality

### Phase 8: Custom Domains & SSL
- [ ] Add custom domain verification process
- [ ] Implement CNAME checking
- [ ] Add SSL certificate management logic
- [ ] Create domain configuration UI
- [ ] Handle apex domain vs subdomain
- [ ] Add domain health check endpoint

### Phase 9: Testing
- [ ] Write tests for tenant isolation
- [ ] Test subdomain routing
- [ ] Test data leak prevention
- [ ] Test ActionCable isolation
- [ ] Test custom domain handling
- [ ] Performance test with multiple tenants
- [ ] Security audit for tenant separation

### Phase 10: Deployment Configuration
- [ ] Update Dockerfile for multi-tenant
- [ ] Configure wildcard SSL on Railway
- [ ] Set up DNS for wildcard subdomains
- [ ] Update environment variables
- [ ] Configure Redis namespacing
- [ ] Set up monitoring per tenant
- [ ] Add backup strategy per restaurant

### Phase 11: Migration & Data
- [ ] Create data migration for existing content
- [ ] Assign existing data to default restaurant
- [ ] Create script for bulk restaurant import
- [ ] Add data export per restaurant
- [ ] Implement soft delete for restaurants

### Phase 12: Additional Features
- [ ] QR code generation per restaurant
- [ ] Embeddable widget for external sites
- [ ] Menu scheduling (breakfast/lunch/dinner)
- [ ] Multi-language support structure
- [ ] Analytics dashboard per restaurant
- [ ] Email notifications per restaurant
- [ ] Bulk menu import (CSV/Excel)

## Security Checklist
- [ ] Verify tenant isolation at DB query level
- [ ] Add SQL injection protection for dynamic tenant queries
- [ ] Implement rate limiting per subdomain
- [ ] Add CORS headers for embed functionality
- [ ] Audit all controllers for tenant scoping
- [ ] Test for subdomain takeover vulnerabilities
- [ ] Implement audit logging per tenant
- [ ] Add data encryption for sensitive settings

## Performance Considerations
- [ ] Add database indexes for restaurant_id
- [ ] Implement query caching per tenant
- [ ] Add CDN for restaurant assets
- [ ] Optimize menu queries with includes
- [ ] Add background jobs for heavy operations
- [ ] Monitor database connection pooling

## Business Logic Features
- [ ] Pricing tiers (free, pro, enterprise)
- [ ] Feature flags per pricing tier
- [ ] Usage limits (menu items, admins)
- [ ] Billing integration preparation
- [ ] Terms of service acceptance
- [ ] GDPR compliance per restaurant

## Rollback Plan
- [ ] Keep feature flag to disable multi-tenant
- [ ] Maintain backward compatibility
- [ ] Document rollback procedures
- [ ] Keep database migrations reversible
- [ ] Test rollback scenario

## Open Questions to Resolve
1. How to handle restaurant deletion? (soft delete vs hard delete)
2. Should menu item positions be globally unique or per-restaurant?
3. How many custom domains per restaurant?
4. What happens to subdomain when restaurant is deleted?
5. Should we support restaurant chains (multiple locations)?
6. How to handle menu versioning/history?
7. What analytics to track per restaurant?
8. How to handle different timezones for restaurants?
9. Should we allow custom CSS injection?
10. How to manage storage for uploaded images?

## Success Criteria
- [ ] Can create new restaurant via UI
- [ ] Each restaurant has isolated subdomain
- [ ] Menu updates only affect own restaurant
- [ ] Admin can only see own restaurant data
- [ ] Real-time updates work per restaurant
- [ ] No data leaks between tenants
- [ ] Performance unchanged with 10 restaurants
- [ ] All existing features work per tenant

## Development Phases Timeline
1. **Week 1**: Database & Models (Phase 1-2)
2. **Week 2**: Routing & Controllers (Phase 3-4)
3. **Week 3**: Views & ActionCable (Phase 5-6)
4. **Week 4**: Auth & Testing (Phase 7, 9)
5. **Week 5**: Deployment & Migration (Phase 10-11)
6. **Week 6**: Additional Features & Polish (Phase 12)

## Notes & Decisions Log
- 2025-09-14: Created plan, chose subdomain approach over path-based
- Subdomain approach chosen for cleaner URLs and easier white-labeling
- Single database with FK isolation chosen over separate schemas for simplicity
- PostgreSQL adapter for ActionCable continues to work well for multi-tenant