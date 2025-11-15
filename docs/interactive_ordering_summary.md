# Interactive Ordering Feature Outline

## Vision
- Allow guests to scan a QR code, pick items (per guest or whole table), specify their table number, and submit orders directly into the POS-lite workflow.
- Provide a kitchen-facing “cook screen” that lists open orders per restaurant with simple state transitions (e.g., `open → in_progress → completed`).
- Keep billing out of scope; owners just need lightweight ticket management tied to their existing menu data.

## Key Building Blocks
- **Data model**: `orders` (restaurant_id, table_number, status, metadata) and `order_items` (menu_item_id, quantity, notes). Optional table presets per venue.
- **Feature flag**: `restaurants.enable_table_ordering` boolean toggled via admin console; all guest/kitchen endpoints respect it.
- **Guest UI**: dedicated controller/action (or SPA) accessible from QR, with menu browsing, quantity controls, and submission confirmation.
- **Kitchen UI**: authenticated admin/kitchen page showing live queue (ActionCable preferred), filters and action buttons to mark orders complete.
- **Notifications**: broadcast new orders and status changes; optionally send admin emails/push if no screen is open.

## Complexity Highlights
- Multi-tenant isolation and security (prevent cross-restaurant access, protect kitchen view behind login).
- Real-time coordination (ActionCable channels, fallbacks for offline clients).
- UX polish for mobile ordering (optimistic UI, validation, handling sold-out items).
- Additional admin settings (enable/disable feature, maybe limit hours, table presets).

## Suggested Implementation Steps
1. **Schema & Models**: add `orders`, `order_items`, status enums, and restaurant flag.
2. **Admin Controls**: expose toggle plus optional table presets/messages.
3. **Guest Ordering Flow**: build QR landing page, menu selection UI, submission endpoint, validations, confirmation screen.
4. **Kitchen Dashboard**: new admin area view with live queue, filtering, completion controls, and broadcast hooks.
5. **QA & Observability**: model/unit specs, system tests for guest/kitchen flows, logging/metrics for order lifecycle.
