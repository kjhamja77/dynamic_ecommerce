# Payment APIs - Complete Documentation

## Overview
This document provides a comprehensive overview of all payment-related APIs found in the bazr modules, including general payment methods and Al Qaseh payment gateway integration.

---

## General Payment APIs

### 1. `/ecom/get/PaymentMethods` (GET)
**Location**: `bs_dynamic_ecommerce/controllers/payment_controllers.py`

**Purpose**: Retrieve all available payment methods for the e-commerce platform

**Authentication**: Required (via Authorization header)

**Request**:
- Method: `GET`
- Headers: `Authorization: Bearer <token>`
- Query Parameters: None

**Response**:
```json
{
  "status": "success",
  "code": "PAYMENT_METHOD_RETRIEVED",
  "success": 1,
  "status_code": 200,
  "message": "Payment Method retrieved successfully",
  "data": {
    "payment_method": [
      {
        "id": 1,
        "name": "Cash on Delivery",
        "cod": true,
        "journal_id": 5,
        "url": null
      },
      {
        "id": 2,
        "name": "Al Qaseh",
        "cod": false,
        "journal_id": null,
        "url": "https://base-url/api/alqaseh/create_payment"
      }
    ]
  }
}
```

**Response Fields**:
- `id`: Payment method ID
- `name`: Payment method name (localized)
- `cod`: Boolean indicating if it's Cash on Delivery (true if journal type is 'cash')
- `journal_id`: Account journal ID (for COD methods)
- `url`: Payment URL for gateway methods (e.g., Al Qaseh). This URL should be called with `order_id` parameter

**Notes**:
- Returns only active payment methods (`state != 'disabled'` and `active = True`)
- Results are localized based on user's language preference
- Al Qaseh payment methods include a `url` field pointing to the payment creation endpoint
- For COD methods, `cod` is `true` and `journal_id` is provided

---

### 2. `/ecom/apply/PaymentMethod` (POST)
**Location**: `bs_dynamic_ecommerce/controllers/payment_controllers.py`

**Purpose**: Apply a payment method to a sale order

**Authentication**: Required (via Authorization header)

**Request**:
- Method: `POST`
- Content-Type: `application/json`
- Headers: `Authorization: Bearer <token>`
- Body:
```json
{
  "order_id": 123,
  "payment_method_id": 2
}
```

**Request Parameters**:
- `order_id` (required): The sale order ID to apply the payment method to
- `payment_method_id` (required): The payment method ID to apply

**Response**:
```json
{
  "status": "success",
  "code": "PAYMENT_METHOD_APPLIED",
  "success": 1,
  "status_code": 200,
  "message": "Payment method applied successfully",
  "data": {}
}
```

**Error Responses**:
- `MISSING_ORDER_ID` (400): Order ID is required
- `MISSING_PAYMENT_METHOD_ID` (400): Payment method ID is required
- `ORDER_NOT_FOUND` (404): Order not found
- `INTERNAL_SERVER_ERROR` (500): Unexpected error occurred

**Notes**:
- Sets the `payment_method_id` field on the sale order
- Order must exist and be accessible by the authenticated user
- This should be called before placing the order

---

## Al Qaseh Payment Gateway APIs

### 3. `/api/alqaseh/create_payment` (POST)
**Location**: `bs_payment_alqaseh/controllers/alqaseh.py`

**Purpose**: Create a payment link for Al Qaseh payment gateway

**Authentication**: Public (no authentication required)

**Request**:
- Method: `POST`
- Content-Type: `application/json`
- Body:
```json
{
  "order_id": 123
}
```
OR
```json
{
  "order_name": "SO001"
}
```

**Request Parameters**:
- `order_id` (optional): Sale order database ID (integer)
- `order_name` (optional): Sale order name/reference (string)
- Note: Either `order_id` or `order_name` must be provided

**Response**:
```json
{
  "payment_url": "https://pay-test.alqaseh.com/pay/abc123token",
  "payment_id": "pay_123456789",
  "token": "abc123token"
}
```

**Error Responses**:
- `{"error": "order_not_found"}`: Order not found
- `{"error": "create_failed", "message": "error details"}`: Payment creation failed

**Implementation Details**:
1. Finds the sale order by ID or name
2. Calls `order.action_pay_with_alqaseh()` which:
   - Gets the Al Qaseh payment provider configuration
   - Generates payment signature (`p_sign`) using HMAC SHA256
   - Creates payment request to Al Qaseh API with:
     - `amount`: Order total amount
     - `currency`: Order currency (defaults to 'AED')
     - `description`: "Odoo Order {order_name}"
     - `order_id`: Sale order name
     - `redirect_url`: `{base_url}/payment/alqaseh/return`
     - `webhook_url`: `{base_url}/payment/alqaseh/webhook`
     - `country`: Customer country code
     - `email`: Customer email
     - `transaction_type`: "Retail"
     - `custom_data`: {"source": "odoo"}
     - `p_sing`: Generated signature
     - `nonce`: Order name
3. Creates an `alqaseh.transaction` record with status 'prepared'
4. Updates sale order with `alqaseh_payment_id`, `alqaseh_token`, and `alqaseh_status`
5. Returns payment URL (test or live based on provider environment)

**Payment URL Format**:
- Test: `https://pay-test.alqaseh.com/pay/{token}`
- Live: `https://pay.alqaseh.com/pay/{token}`

**Notes**:
- This endpoint is called by the mobile app after selecting Al Qaseh as payment method
- The returned `payment_url` should be opened in a webview for customer payment
- The `payment_id` and `token` are stored on the order for tracking

---

### 4. `/payment/alqaseh/webhook` (POST)
**Location**: `bs_payment_alqaseh/controllers/alqaseh.py`

**Purpose**: Receive payment status updates from Al Qaseh payment gateway

**Authentication**: Public (called by Al Qaseh servers)

**Request**:
- Method: `POST`
- Content-Type: `application/json`
- Body (from Al Qaseh):
```json
{
  "payment_status": "succeeded",
  "amount": 1000.00,
  "currency": "AED",
  "order_id": "SO001",
  "payment_id": "pay_123456789",
  "token": "abc123token",
  "p_sign": "signature_hash"
}
```

**Request Fields** (from Al Qaseh):
- `payment_status` or `status`: Payment status
- `amount`: Payment amount
- `currency`: Currency code
- `order_id`: Order reference/name
- `payment_id` or `paymentId`: Al Qaseh payment ID
- `token`: Payment token
- `p_sign`: Payment signature (for verification)

**Response**:
```json
{
  "status": "ok"
}
```

**Implementation Details**:
1. Searches for sale order by `order_id` (order name)
2. Updates or creates `alqaseh.transaction` record:
   - Updates existing transaction if found by `payment_id`
   - Creates new transaction if not found
   - Stores full response JSON
   - Sets status to lowercase value
3. Updates sale order `alqaseh_status` field
4. On success status, creates invoice:
   - Calls `order._create_invoices()` to create invoice draft
   - Invoice can be posted and reconciled separately

**Success Status Values**:
The following status values are considered successful:
- `success`
- `succeeded`
- `successed`
- `succeed`
- `successfull`

**Transaction Status Values**:
- `draft`
- `prepared`
- `pending`
- `succeeded`
- `failed`
- `revoked`
- `retried`
- `expired`
- `duplicated`
- `declined`
- `unknown`

**Notes**:
- This endpoint is called by Al Qaseh servers, not by the mobile app
- Always returns 200 OK to prevent retries
- If order not found, still returns OK to avoid webhook retries
- Invoice creation is automatic on successful payment

---

### 5. `/payment/alqaseh/return` (GET)
**Location**: `bs_payment_alqaseh/controllers/alqaseh.py`

**Purpose**: Handle customer redirect after completing payment on Al Qaseh hosted checkout page

**Authentication**: Public (no authentication required)

**Request**:
- Method: `GET`
- Query Parameters:
  - `order_id`: Order reference/name
  - `status` or `payment_status`: Payment status
  - `payment_id`: Payment ID (optional)

**Response**:
- HTML page with message: "Payment processed. You can close this window."

**Implementation Details**:
1. Extracts `order_id` and `status` from query parameters
2. Finds sale order by name
3. Updates order `alqaseh_status` if status provided
4. Returns simple HTML page for user

**Notes**:
- This is the redirect URL configured in Al Qaseh payment creation
- Customer is redirected here after payment completion
- Customer can close the window after seeing the message
- Mobile app should poll order status or listen for webhook updates instead of relying on this redirect

---

## Payment Provider Configuration

### Al Qaseh Payment Provider Fields
**Location**: `bs_payment_alqaseh/models/payment_provider.py`

The Al Qaseh payment provider extends Odoo's `payment.provider` model with:

- `alqaseh_client_id`: Client ID from Al Qaseh
- `alqaseh_client_secret`: Client secret for signature generation
- `alqaseh_environment`: Selection field ('test' or 'live')
- `code`: Payment provider code ('alqaseh')

**Methods**:
- `_alqaseh_api_url()`: Returns API URL based on environment
  - Test: `https://api-test.alqaseh.com/v1`
  - Live: `https://api.alqaseh.com/v1`
- `_get_alqaseh_payment_url()`: Returns payment creation endpoint URL
  - Format: `{base_url}/api/alqaseh/create_payment`

---

## Sale Order Payment Fields

**Location**: `bs_payment_alqaseh/models/sale_order.py`

Sale orders extended with Al Qaseh-specific fields:

- `alqaseh_payment_id`: Al Qaseh payment ID (Char)
- `alqaseh_token`: Payment token (Char)
- `alqaseh_status`: Payment status (Selection):
  - `draft`
  - `prepared`
  - `pending`
  - `succeeded`
  - `failed`
  - `revoked`
  - `retried`
  - `expired`
  - `duplicated`
  - `declined`
  - `unknown`

**Methods**:
- `action_pay_with_alqaseh()`: Creates payment with Al Qaseh and returns action dict with payment URL
- `generate_psign(secret_key, data_string)`: Generates HMAC SHA256 signature for payment

**Signature Generation**:
The payment signature (`p_sign`) is generated using:
```python
hmac.new(
    secret_key.encode(),
    data_string.encode(),
    hashlib.sha256
).hexdigest()
```

Where `data_string` = `{order_name}{amount_total}{client_id}`

---

## Payment Flow

### Standard Payment Flow (Cash on Delivery)
1. User selects products and adds to cart
2. User proceeds to checkout
3. User selects shipping address
4. User selects payment method (COD)
5. App calls `/ecom/apply/PaymentMethod` with `order_id` and `payment_method_id`
6. App calls `/ecom/sale/placeOrder` to confirm order
7. Order is confirmed and ready for delivery

### Al Qaseh Payment Flow
1. User selects products and adds to cart
2. User proceeds to checkout
3. User selects shipping address
4. User selects Al Qaseh as payment method
5. App calls `/ecom/apply/PaymentMethod` with `order_id` and `payment_method_id`
6. App calls `/ecom/sale/placeOrder` to confirm order (order is placed but not paid)
7. App calls `/api/alqaseh/create_payment` with `order_id`
8. Backend creates payment with Al Qaseh and returns `payment_url`, `payment_id`, and `token`
9. App opens `payment_url` in webview
10. Customer completes payment on Al Qaseh hosted page
11. Al Qaseh calls `/payment/alqaseh/webhook` with payment status
12. Backend updates order status and creates invoice on success
13. Customer is redirected to `/payment/alqaseh/return`
14. App should poll order status or listen for updates to detect payment completion

---

## Error Handling

### Common Error Codes
- `MISSING_ORDER_ID`: Order ID parameter is missing
- `MISSING_PAYMENT_METHOD_ID`: Payment method ID parameter is missing
- `ORDER_NOT_FOUND`: Order does not exist or is not accessible
- `INTERNAL_SERVER_ERROR`: Unexpected server error
- `order_not_found`: Al Qaseh order not found
- `create_failed`: Al Qaseh payment creation failed

### Error Response Format
```json
{
  "status": "error",
  "code": "ERROR_CODE",
  "success": 0,
  "status_code": 400,
  "message": "Error message",
  "data": null
}
```

---

## Security Considerations

1. **Authentication**: Payment method retrieval and application require authentication
2. **Webhook Security**: Al Qaseh webhook endpoint is public but should verify signatures if provided
3. **Payment URLs**: Payment URLs contain tokens that should be kept secure
4. **HTTPS**: All payment endpoints should use HTTPS in production
5. **Signature Verification**: Payment signatures are generated using HMAC SHA256

---

## Testing

### Test Environment
- Al Qaseh test API: `https://api-test.alqaseh.com/v1`
- Al Qaseh test payment page: `https://pay-test.alqaseh.com/pay/{token}`
- Set `alqaseh_environment` to 'test' in payment provider configuration

### Live Environment
- Al Qaseh live API: `https://api.alqaseh.com/v1`
- Al Qaseh live payment page: `https://pay.alqaseh.com/pay/{token}`
- Set `alqaseh_environment` to 'live' in payment provider configuration

---

## Integration Notes

1. **Payment Method Selection**: Always call `/ecom/get/PaymentMethods` first to get available methods
2. **Payment URL**: For Al Qaseh, use the `url` field from payment method response
3. **Order Placement**: Order should be placed before creating payment (for Al Qaseh)
4. **Payment Status**: Poll order status or implement webhook listener to detect payment completion
5. **Error Handling**: Handle all error cases gracefully and show appropriate messages to users
6. **Webview**: Use secure webview for Al Qaseh payment page with proper navigation handling


