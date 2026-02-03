# Backend API Documentation - Complete Summary

## Table of Contents
1. [Authentication APIs](#authentication-apis)
2. [User Profile APIs](#user-profile-apis)
3. [Product APIs](#product-apis)
4. [Cart APIs](#cart-apis)
5. [Checkout APIs](#checkout-apis)
6. [Payment APIs](#payment-apis)
7. [Order APIs](#order-apis)
8. [Category APIs](#category-apis)
9. [Master Data APIs](#master-data-apis)
10. [Wishlist APIs](#wishlist-apis)
11. [Product Filter APIs](#product-filter-apis)
12. [Design & Onboarding APIs](#design--onboarding-apis)
13. [Refund APIs](#refund-apis)
14. [Al Qaseh Payment APIs](#al-qaseh-payment-apis)

---

## Authentication APIs

### 1. `/ecom/portal/register` (POST)
**Purpose**: Register a new portal user

**Request Data**:
- `email` (required): User email
- `password` (required): User password
- `first_name` (required): First name
- `last_name`: Last name
- `phone`: Phone number
- `country_code`: Country code (e.g., "AE")

**Response Data**:
- `user_id`: Created user ID
- `email`: User email
- `api_token`: Generated API token for authentication
- `created_at`: User creation timestamp

**Notes**:
- Creates portal user with `group_portal`
- Generates API token automatically
- Sends email verification
- Returns token immediately (user can use it)

---

### 2. `/ecom/portal/login` (POST)
**Purpose**: Login with email/mobile and password

**Request Data**:
- `email`: Email or mobile number
- `password` (required): User password
- `device_id`: Device identifier
- `device_token`: FCM device token

**Response Data**:
- `user_id`: User ID
- `email`: User email
- `mobile`: Mobile number
- `name`: Full name
- `api_token`: API token for subsequent requests
- `guest`: false
- `country_code`: User's country code
- `mobile_verification`: Boolean - if mobile is verified
- `login_time`: Login timestamp
- `currency`: Currency name
- `currency_id`: Currency ID

**Special Cases**:
- If mobile login and not verified → Returns `MOBILE_VERIFICATION_REQUIRED` with `user_id` and `mobile`
- If email login and not verified → Returns `EMAIL_NOT_VERIFIED` error
- Updates FCM device registration

---

### 3. `/ecom/portal/verify-token` (POST)
**Purpose**: Verify if API token is still valid

**Request Data**:
- `api_token` (required): API token to verify
- `user_id` (required): User ID

**Response Data**:
- `user_id`: User ID
- `email`: User email
- `name`: User name
- `token_verified_at`: Verification timestamp
- `user_status`: "active"

---

### 4. `/ecom/portal/logout` (POST)
**Purpose**: Logout user and invalidate token

**Request Data**:
- `user_id` (required): User ID
- Authorization header: Bearer token

**Response Data**:
- `user_id`: User ID
- `email`: User email
- `logout_time`: Logout timestamp

**Notes**:
- Clears `api_token` from user record

---

### 5. `/ecom/portal/reset/password` (POST)
**Purpose**: Request password reset email

**Request Data**:
- `email`: Email or mobile number

**Response Data**:
- Success message

**Notes**:
- Sends password reset email via Odoo's standard mechanism

---

### 6. `/ecom/portal/resend/mail-verification` (POST)
**Purpose**: Resend email verification

**Request Data**:
- `user_id` (required): User ID

**Response Data**:
- Success message

---

### 7. `/ecom/portal/resend/mobile-verification` (POST)
**Purpose**: Resend mobile verification code

**Request Data**:
- `user_id` (required): User ID

**Response Data**:
- `mobile`: Masked mobile number
- `expiry_minutes`: Code expiry time (10 minutes)

**Notes**:
- Sends 4-digit code via WhatsApp/SMS

---

### 8. `/ecom/portal/verify/mobile-code` (POST)
**Purpose**: Verify mobile verification code

**Request Data**:
- `user_id` (required): User ID
- `verification_code` (required): 4-digit code

**Response Data**:
- `user_id`: User ID
- `email`: User email
- `mobile`: Mobile number
- `name`: Full name
- `api_token`: API token (generated if not exists)
- `country_code`: Country code
- `mobile_verification`: true
- `login_time`: Verification timestamp
- `currency`: Currency name
- `currency_id`: Currency ID
- `mobile_verified`: true

**Notes**:
- Marks mobile as verified
- Clears verification code
- Generates/returns API token (user is logged in)

---

### 9. `/ecom/guest/login` (POST)
**Purpose**: Create/login as guest user

**Request Data**:
- `name`: Guest name (defaults to "Guest")
- `device_id`: Device identifier
- `device_token`: FCM device token
- `country_code`: Country code

**Response Data**:
- `user_id`: Guest user ID
- `email`: Guest email (guest_{device_id}@guest.local)
- `name`: Guest name
- `api_token`: API token
- `guest`: true
- `login_time`: Login timestamp
- `currency`: Currency name
- `currency_id`: Currency ID

**Notes**:
- Reuses existing guest user if device_id matches
- Creates new guest user if not found
- Updates FCM registration

---

### 10. `/ecom/auth/google` (POST)
**Purpose**: Login/Signup with Google OAuth

**Request Data**:
- `id_token` (required): Google ID token
- `device_id`: Device identifier
- `device_token`: FCM device token

**Response Data**:
- `user_id`: User ID
- `email`: User email
- `mobile`: Mobile number
- `name`: Full name
- `api_token`: API token
- `guest`: false
- `login_time`: Login timestamp
- `currency`: Currency name
- `currency_id`: Currency ID

**Notes**:
- Verifies Google token
- Creates user if doesn't exist
- Downloads profile picture if available
- Updates FCM registration

---

## User Profile APIs

### 11. `/ecom/user/profile` (POST)
**Purpose**: Get or update user profile

**Request Data**:
- `action`: "get" (default) or "update"
- For update: `name`, `phone`, `email`, `street`, `street2`, `city`, `zip`, `state_id`, `country_id`, `image` (base64)

**Response Data** (get):
- `user_id`: User ID
- `partner_id`: Partner ID
- `name`: Full name
- `country_code`: Country code
- `phone`: Phone number
- `email`: Email
- `address`: Address object (street, city, zip, state, country)
- `image`: Base64 encoded image

**Response Data** (update):
- Same as get, with updated values

**Notes**:
- Image is base64 string (without data:image prefix)
- Updates partner record

---

### 12. `/ecom/user/address` (POST)
**Purpose**: Manage user addresses (create, update, delete, list)

**Request Data**:
- `action`: "create", "update", "delete", or "list"
- For create: `addresses` (array of address objects)
- For update/delete: `address_id` (required)
- Address fields: `name`, `type`, `phone`, `email`, `street`, `street2`, `city`, `zip`, `state_id`, `country_id`, `default_address`, `province_id`

**Response Data**:
- `total_count`: Total address count
- `addresses`: Array of address objects with:
  - `id`, `name`, `type`, `phone`, `email`
  - `street`, `street2`, `city`, `zip`
  - `province_id`, `state_id`, `state_name`
  - `country_id`, `country_name`
  - `default_address`: Boolean

**Notes**:
- Creates child partners under user's partner
- Returns all addresses including main partner

---

## Product APIs

### 13. `/ecom/get/product` (POST)
**Purpose**: Get product details or list products

**Request Data**:
- `id`: Product ID (template or variant)
- `type`: "template" or "variant" (optional, auto-detected)
- `template_id`: Template ID (for variant requests)
- `only_in_stock`: Boolean (for list)
- `page_size`: Items per page (default 20)
- `page`: Page number (default 0)
- `public_categ_ids`: Category IDs array (for filtering)

**Response Data** (Template):
- `id`: Template ID
- `name`: Product name
- `description`: Full description
- `short_description`: Short description
- `price`: Price (from pricelist)
- `currency`: Currency code
- `category`: Category object
- `brand`: Brand object
- `type`: "template"
- `website_url`: Product URL
- `quantity_available`: Total quantity
- `in_stock`: Boolean
- `total_variants`: Variant count
- `available_variants`: Available variant count
- `variant_attributes`: Array of attribute options
- `variant_combinations`: Array of variant combinations with prices
- `images`: Array of image URLs
- `optional_product_ids`: Related products
- `accessory_product_ids`: Accessory products
- `alternative_product_ids`: Alternative products
- `sku`: SKU code
- `customer_lead_time_days`: Lead time
- `expected_delivery_within`: Expected delivery date
- `favourite`: Boolean (in wishlist)
- `ribbon`: HTML ribbon
- `product_tag_ids`: Product tags

**Response Data** (Variant):
- Similar to template but includes:
- `template`: Parent template data
- `variant_id`: Variant ID
- `variant_attributes`: Selected attributes
- `variant_images`: Variant-specific images

**Response Data** (List):
- `items`: Array of product objects
- `total_count`: Total products
- `limit`, `offset`: Pagination info

**Notes**:
- Uses user's pricelist for pricing
- Respects language context
- Checks wishlist status

---

## Cart APIs

### 14. `/ecom/product/cart` (POST)
**Purpose**: Manage shopping cart

**Request Data**:
- `action`: "add", "update", "remove", "get", or "clear_cart"
- `product_id`: Product ID (required for add/update/remove)
- `quantity`: Quantity (required for add/update)
- `page`: Page number (default 1)
- `page_size`: Items per page (default 10)

**Response Data**:
- `order_id`: Cart/order ID
- `order_name`: Order name
- `state`: Order state ("draft")
- `lines`: Array of cart items with:
  - `line_id`: Line ID
  - `product_id`: Product ID
  - `product_name`: Product name
  - `product_image`: Image URL
  - `quantity`: Quantity
  - `price_unit`: Unit price
  - `price_subtotal`: Subtotal
  - `price_total`: Total with tax
  - `tax_amount`: Tax amount
  - `taxes`: Tax IDs
  - `tax_details`: Tax breakdown
- `subtotal`: Subtotal (amount_untaxed)
- `tax_amount`: Total tax
- `total`: Total amount
- `total_items`: Total item count
- `currency`: Currency code
- `pagination`: Pagination info

**Notes**:
- Creates draft sale order if doesn't exist
- Removes delivery lines before returning cart
- Supports pagination

---

## Checkout APIs

### 15. `/ecom/get/ShippingMethods` (POST)
**Purpose**: Get available shipping methods for order

**Request Data**:
- `order_id` (required): Order ID

**Response Data**:
- `total_count`: Shipping method count
- `shipping_method`: Array of methods with:
  - `name`: Method name
  - `id`: Method ID
  - `description`: Description
  - `price`: Shipping cost

**Notes**:
- Calculates shipping cost based on order and address
- Only returns published carriers

---

### 16. `/ecom/apply/ShippingMethods` (POST)
**Purpose**: Apply shipping method to order

**Request Data**:
- `order_id` (required): Order ID
- `shipping_method_id` (required): Shipping method ID

**Response Data**:
- `order_details`: Complete order object with:
  - `order_id`, `order_name`, `state`
  - `amount_untaxed`, `amount_tax`, `amount_total`
  - `currency_id`, `currency_name`, `currency_symbol`
  - `shipping`: Shipping method details
  - `partner_shipping_id`, `partner_shipping_name`
  - `order_lines`: Order lines array

**Notes**:
- Sets carrier on order
- Creates delivery line with shipping cost
- Recalculates order totals

---

### 17. `/ecom/get/Pricelists` (POST)
**Purpose**: Get available pricelists/promo codes

**Request Data**:
- `order_id` (required): Order ID

**Response Data**:
- `total_count`: Pricelist count
- `pricelists`: Array of pricelists with:
  - `id`: Pricelist ID
  - `name`: Pricelist name
  - `code`: Promo code
  - `currency_id`, `currency_name`, `currency_symbol`
  - `selectable`: Boolean

**Notes**:
- Returns active pricelists with codes

---

### 18. `/ecom/apply/Pricelist` (POST)
**Purpose**: Apply pricelist/promo code to order

**Request Data**:
- `order_id` (required): Order ID
- `pricelist_id` (required): Pricelist ID
- `promo_code`: Promo code (optional, validated)

**Response Data**:
- `order_details`: Complete order object with updated prices

**Notes**:
- Validates promo code matches pricelist
- Updates order prices
- Only works on draft/sent orders

---

## Payment APIs

### 19. `/ecom/get/PaymentMethods` (GET)
**Purpose**: Get available payment methods

**Request Data**: None (uses Authorization header)

**Response Data**:
- `payment_method`: Array of payment methods with:
  - `id`: Payment method ID
  - `name`: Payment method name
  - `cod`: Boolean (cash on delivery)
  - `journal_id`: Journal ID
  - `url`: Payment URL (for Al Qaseh, contains `/api/alqaseh`)

**Notes**:
- Returns active payment methods
- Al Qaseh methods have URL field

---

### 20. `/ecom/apply/PaymentMethod` (POST)
**Purpose**: Apply payment method to order

**Request Data**:
- `order_id` (required): Order ID
- `payment_method_id` (required): Payment method ID

**Response Data**:
- Success message

**Notes**:
- Sets payment_method_id on sale order

---

## Order APIs

### 21. `/ecom/sale/placeOrder` (POST)
**Purpose**: Place/confirm order

**Request Data**:
- `order_id` (required): Order ID
- `address_id` (required): Shipping address ID

**Response Data**:
- Success message
- Empty data object

**Notes**:
- Sets partner, invoice, and shipping addresses
- Confirms order (state changes to "sale")
- Triggers delivery order creation (if delivery module active)

---

### 22. `/ecom/sale/orderHistory` (GET)
**Purpose**: Get user's order history

**Request Data** (query params):
- `limit`: Items per page (default 20)
- `page`: Page number (default 0)

**Response Data**:
- `orders`: Array of orders with:
  - `id`, `name`, `state`, `state_display`
  - `date_order`: Order date
  - `amount_total`, `amount_untaxed`, `amount_tax`
  - `currency`: Currency code
  - `partner_shipping`: Shipping address object
  - `order_lines`: Order line items
  - `shipping_method`: Shipping method details
  - `order_line_count`: Item count
  - `delivery_status`: Delivery status
  - `invoice_status`: Invoice status
  - `validity_date`: Order validity date
- `total_count`: Total order count
- `limit`, `offset`, `page`: Pagination info

**Notes**:
- Excludes draft orders
- Only returns application orders
- Ordered by creation date (newest first)

---

### 23. `/ecom/sale/orderDetails` (POST)
**Purpose**: Get detailed order information

**Request Data**:
- `order_id` (required): Order ID

**Response Data**:
- Complete order object with:
  - All fields from orderHistory
  - `partner`: Customer details
  - `invoices`: Array of invoice objects
  - `deliveries`: Array of delivery/picking objects
  - `payment_term`: Payment terms
  - `pricelist`: Applied pricelist
  - Detailed order lines with:
    - `qty_delivered`, `qty_invoiced`
    - `discount`
    - `tax_id`: Tax details array

**Notes**:
- Returns full order details including invoices and deliveries
- Only accessible by order owner

---

## Category APIs

### 24. `/ecom/get/product-category` (POST)
**Purpose**: Get product categories with hierarchy

**Request Data**:
- `parent_id`: Parent category ID (optional, defaults to root)
- `max_depth`: Maximum depth (0 = unlimited)
- `page_size`: Items per page (default 50)
- `page`: Page number (default 0)

**Response Data**:
- `items`: Array of categories with:
  - `id`: Category ID
  - `name`: Category name
  - `parent_id`: Parent category ID
  - `complete_name`: Full category path
  - `sequence`: Sort order
  - `image`: Category image URL
  - `product_count`: Product count
  - `hasChildren`: Boolean
  - `children`: Nested children array
- `total_count`: Total category count
- `limit`, `offset`: Pagination info

**Notes**:
- Recursive structure
- Respects max_depth parameter
- Counts published products only

---

### 25. `/ecom/get/product/categories` (GET)
**Purpose**: Get product categories (flat list)

**Request Data** (query params):
- `page`: Page number (default 1)
- `limit`: Items per page (default 50)
- `parent_id`: Parent category ID

**Response Data**:
- `items`: Array of categories (flat)
- `total_count`: Total count
- `limit`, `offset`, `current_page`
- `total_pages`, `has_next`, `has_previous`
- `next_page`, `previous_page`

**Notes**:
- Similar to POST version but flat structure
- Better pagination info

---

## Master Data APIs

### 26. `/ecom/get/country-list` (POST)
**Purpose**: Get list of countries

**Request Data**: None (uses Authorization header)

**Response Data**:
- `total_count`: Country count
- `countries`: Array of countries with:
  - `id`: Country ID
  - `name`: Country name
  - `code`: Country code (ISO)

**Notes**:
- Returns all countries
- Ordered alphabetically

---

### 27. `/ecom/get/state-list` (POST)
**Purpose**: Get states/provinces for a country

**Request Data**:
- `country_id` (required): Country ID

**Response Data**:
- `total_count`: State count
- `states`: Array of states with:
  - `id`: State ID
  - `name`: State name
  - `code`: State code
  - `country_id`: Country ID

**Notes**:
- Returns states for specified country
- Ordered alphabetically

---

### 28. `/ecom/get/iq_provice-list` (GET)
**Purpose**: Get Iraqi provinces

**Request Data**: None (uses Authorization header)

**Response Data**:
- `total_count`: Province count
- `provinces`: Array of provinces with:
  - `id`: Province ID
  - `name`: Province name
  - `code`: Province code

**Notes**:
- Specific to Iraq
- Uses custom `iq.provice` model

---

### 29. `/ecom/get/language-list` (GET)
**Purpose**: Get available languages

**Request Data**: None

**Response Data**:
- `total_count`: Language count
- `languages`: Array of languages with:
  - `id`: Language ID
  - `name`: Language name
  - `code`: Language code (e.g., "en_US", "ar_SA")
  - `iso_code`: ISO code

**Notes**:
- Public endpoint (no auth required)
- But internally calls authenticate_user() (may need token)

---

### 30. `/ecom/get/product/attributes` (GET)
**Purpose**: Get product attributes (colors, sizes, etc.)

**Request Data** (query params):
- `page`: Page number (default 1)
- `limit`: Items per page (default 50)

**Response Data**:
- `items`: Array of attributes with:
  - `id`: Attribute ID
  - `name`: Attribute name
  - `display_type`: Display type
  - `values`: Array of attribute values with:
    - `id`: Value ID
    - `name`: Value name
    - `product_count`: Products with this value
- `total_count`: Total attribute count
- Pagination info

**Notes**:
- Used for filtering products
- Includes product counts per value

---

## Wishlist APIs

### 31. `/ecom/product/wish-list` (POST)
**Purpose**: Manage product wishlist

**Request Data**:
- `action`: "add", "remove", or "list"
- `product_id`: Product ID (required for add/remove)
- `page_size`: Items per page (default 20)
- `page`: Page number (default 0)

**Response Data** (list):
- `items`: Array of wishlist items with:
  - `id`: Wishlist item ID
  - `product_id`: Product ID
  - `product_name`: Product name
  - `product_image`: Image URL
  - `price`: Product price
  - `currency`: Currency code
  - `added_date`: Date added
- `total_count`: Total wishlist items
- Pagination info

**Response Data** (add/remove):
- Success message
- Updated wishlist data

**Notes**:
- Prevents duplicates on add
- Uses `bs.ecom.product.wishlist` model

---

## Product Filter APIs

### 32. `/ecom/get/product/brands` (GET)
**Purpose**: Get product brands

**Request Data** (query params):
- `page`: Page number (default 1)
- `limit`: Items per page (default 50)

**Response Data**:
- `items`: Array of brands with:
  - `id`: Brand ID
  - `name`: Brand name
- `total_count`: Total brand count
- Pagination info

**Notes**:
- Uses `bs.ecom.product.brand` model
- Returns empty if brand module not installed

---

### 33. `/ecom/get/product/filter-options` (GET)
**Purpose**: Get filter options (price range, stock, sorting)

**Request Data**: None (uses Authorization header)

**Response Data**:
- `price_range`: Min and max prices
- `stock_options`: Array of stock filter options
- `sorting_options`: Array of sorting options with:
  - `id`: Sort option ID
  - `name`: Display name
  - `field`: Database field
  - `order`: "asc" or "desc"

**Notes**:
- Calculates price range from all published products
- Provides predefined stock and sorting options

---

### 34. `/ecom/get/product/filter-search` (POST)
**Purpose**: Search products with filters

**Request Data**:
- `search`: Search query (optional)
- `category_ids`: Category IDs array
- `brand_ids`: Brand IDs array
- `attribute_value_ids`: Attribute value IDs array
- `min_price`: Minimum price
- `max_price`: Maximum price
- `in_stock`: Boolean (filter by stock)
- `sort_by`: Sort field
- `sort_order`: "asc" or "desc"
- `page`: Page number
- `page_size`: Items per page

**Response Data**:
- `items`: Array of filtered products
- `total_count`: Total matching products
- Pagination info

**Notes**:
- Applies multiple filters simultaneously
- Supports text search
- Respects pricelist pricing

---

## Design & Onboarding APIs

### 35. `/ecom/get/pages` (POST)
**Purpose**: Get app pages configuration

**Request Data**: None (uses Authorization header)

**Response Data**:
- `total_count`: Page count
- `pages`: Array of pages with:
  - `id`: Page ID
  - `name`: Page name
  - `sequence`: Sort order
  - `description`: Page description

**Notes**:
- Marks user onboarding as done
- Returns pages from active template
- Only returns running pages

---

### 36. `/ecom/get/onboarding` (POST)
**Purpose**: Get onboarding screens

**Request Data**: None

**Response Data**:
- `total_count`: Onboarding screen count
- `onboarding`: Array of screens with:
  - `id`: Screen ID
  - `sequence`: Sort order
  - `name`: Screen name
  - `description`: Screen description
  - `image`: Image URL

**Notes**:
- Public endpoint (no auth required)
- Returns from active template
- Ordered by sequence

---

### 37. `/ecom/get/welcome-message` (POST)
**Purpose**: Get welcome message

**Request Data**: None

**Response Data**:
- `message`: Welcome message text
- `image`: Welcome image URL

**Notes**:
- Public endpoint
- Returns from active template

---

### 38. `/ecom/get/component` (POST)
**Purpose**: Get page component data

**Request Data**:
- `component_id` (required): Component ID
- `page_id`: Page ID (optional)

**Response Data**:
- Component-specific data based on component type

**Notes**:
- Returns dynamic component data
- Used for home page sections

---

## Refund APIs

### 39. `/ecom/sale/checkRefundEligibility` (POST)
**Purpose**: Check if order can be refunded

**Request Data**:
- `order_id` (required): Order ID

**Response Data**:
- `order_id`, `order_name`, `order_state`
- `refund_scenario`: "cancel" or "credit_note"
- `refund_scenario_description`: Description
- `has_paid_invoices`: Boolean
- `has_deliveries`: Boolean
- `refundable_lines`: Array of refundable items with:
  - `line_id`, `product_id`, `product_name`
  - `ordered_qty`, `delivered_qty`, `invoiced_qty`
  - `refunded_qty`, `requested_qty`
  - `available_for_refund_qty`
  - `price_unit`, `price_subtotal`, `price_total`
- `total_refundable_lines`: Count

**Notes**:
- Checks existing refund requests
- Calculates available quantities
- Determines refund scenario

---

### 40. `/ecom/sale/createRefundRequest` (POST)
**Purpose**: Create refund request

**Request Data**:
- `order_id` (required): Order ID
- `refund_lines` (required): Array of {line_id, quantity}
- `reason`: Refund reason

**Response Data**:
- `refund_request_id`: Request ID
- `refund_request_name`: Request name/reference
- `state`: Request state ("pending")
- Success message

**Notes**:
- Creates refund request (needs approval)
- Validates quantities
- Prevents duplicate requests

---

### 41. `/ecom/sale/getRefundRequests` (GET)
**Purpose**: Get user's refund requests

**Request Data** (query params):
- `limit`: Items per page
- `page`: Page number

**Response Data**:
- `refund_requests`: Array of requests with:
  - `id`, `name`, `state`, `state_display`
  - `order_id`, `order_name`
  - `request_date`, `processed_date`
  - `reason`, `total_amount`
  - `refund_lines`: Line items
- `total_count`: Total requests
- Pagination info

---

### 42. `/ecom/sale/getRefundRequestDetails` (POST)
**Purpose**: Get refund request details

**Request Data**:
- `refund_request_id` (required): Request ID

**Response Data**:
- Complete refund request object with:
  - All fields from list
  - `approval_notes`, `rejection_reason`
  - `refund_lines`: Detailed line items
  - `invoices`: Related invoices
  - `credit_notes`: Related credit notes

---

### 43. `/ecom/sale/cancelRefundRequest` (POST)
**Purpose**: Cancel pending refund request

**Request Data**:
- `refund_request_id` (required): Request ID

**Response Data**:
- Success message

**Notes**:
- Only cancels pending requests
- Cannot cancel approved/processed requests

---

## Al Qaseh Payment APIs

### 44. `/api/alqaseh/create_payment` (POST)
**Purpose**: Create Al Qaseh payment link

**Request Data**:
- `order_id` (required): Order ID or order name

**Response Data**:
- `payment_url`: Hosted payment page URL
- `payment_id`: Al Qaseh payment ID
- `token`: Payment token

**Notes**:
- Creates payment context
- Generates payment signature (p_sign)
- Returns hosted checkout URL

---

### 45. `/payment/alqaseh/webhook` (POST)
**Purpose**: Receive payment status updates from Al Qaseh

**Request Data** (from Al Qaseh):
- `payment_status`: Payment status
- `amount`: Payment amount
- `currency`: Currency
- `order_id`: Order reference
- `payment_id`: Payment ID
- `token`: Payment token
- `p_sign`: Payment signature

**Response Data**:
- `status`: "ok"

**Notes**:
- Updates transaction record
- Updates sale order status
- Creates invoice on success
- Called by Al Qaseh server

---

### 46. `/payment/alqaseh/return` (GET)
**Purpose**: Handle customer redirect after payment

**Request Data** (query params):
- `order_id`: Order reference
- `status`: Payment status
- `payment_id`: Payment ID

**Response Data**:
- HTML page with success message

**Notes**:
- Updates order status
- Customer sees confirmation page
- Can close window after payment

---

## Common Response Format

All APIs return responses in this format:

```json
{
  "status": "success" | "error" | "pending",
  "code": "API_SPECIFIC_CODE",
  "success": 1 | 0,
  "status_code": 200 | 400 | 401 | 403 | 404 | 500,
  "message": "Human readable message",
  "data": { ... } | null
}
```

## Authentication

Most APIs require Bearer token authentication:
```
Authorization: Bearer <api_token>
```

Token is obtained from:
- Login endpoints
- Registration endpoint
- Mobile verification endpoint
- Guest login endpoint

## Language Support

All APIs support language via:
- `Accept-Language` header (preferred)
- `lang` query parameter
- Request context

Language affects:
- Product names/descriptions
- Category names
- Country/state names
- Error messages

## Error Codes

Common error codes:
- `MISSING_TOKEN`: No authorization token
- `INVALID_TOKEN`: Token invalid or expired
- `MISSING_REQUIRED_FIELDS`: Required field missing
- `INVALID_CREDENTIALS`: Wrong email/password
- `EMAIL_NOT_VERIFIED`: Email not verified
- `MOBILE_VERIFICATION_REQUIRED`: Mobile verification needed
- `PRODUCT_NOT_FOUND`: Product doesn't exist
- `ORDER_NOT_FOUND`: Order doesn't exist
- `INTERNAL_SERVER_ERROR`: Server error

