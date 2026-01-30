# Moyasar Payment Integration Guide

## Overview
This guide explains how to implement Moyasar payment processing in your Flutter app. Moyasar is a Saudi-based payment gateway that supports card payments, Apple Pay, and Google Pay.

## Setup Steps

### 1. Create Moyasar Account
1. Visit [https://dashboard.moyasar.com](https://dashboard.moyasar.com)
2. Sign up and complete verification
3. Navigate to Settings → API Keys
4. Copy your **API Key** (Keep this secret!)

### 2. Update Service Configuration
Open [lib/services/moyasar_service.dart](../lib/services/moyasar_service.dart) and replace:
```dart
static const String apiKey = 'YOUR_MOYASAR_API_KEY';
```
With your actual API key from the dashboard.

### 3. Payment Flow

The payment flow works as follows:

```
User → PaymentDialog → Card Input → MoyasarService.createPayment()
                                    ↓
                          Backend/Moyasar API
                                    ↓
                    Payment Processed → Status Check
                                    ↓
                         Success/Failure Callback
```

### 4. Using the Payment Dialog

In your page where you need to accept payments:

```dart
showDialog(
  context: context,
  builder: (context) => PaymentDialog(
    amount: 75.0, // Amount in SAR
    description: 'Driver booking',
    userId: currentUserId,
    bookingId: bookingId,
    onSuccess: () {
      // Handle successful payment
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
    },
    onError: (error) {
      // Handle payment error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $error')),
      );
    },
  ),
);
```

## Important: Production Implementation

The current implementation includes a basic card input dialog for demonstration. For production, you MUST implement proper card tokenization:

### Option A: Moyasar Hosted Payment Page (Recommended)
```dart
// Redirect to Moyasar hosted page
final paymentUrl = 'https://pay.moyasar.com/?key=YOUR_KEY&amount=7500&currency=sar';
// Use web_view or url_launcher to open the page
```

### Option B: Moyasar Mobile SDK
```dart
// When available, use Moyasar's mobile SDK for secure card tokenization
// Similar to how Stripe works with flutter_stripe
```

### Option C: Backend Tokenization
Send card details to your backend, which tokenizes them using Moyasar's API:
```javascript
// backend/payments.js
router.post('/tokenize-card', async (req, res) => {
  const { cardNumber, expiryDate, cvc } = req.body;
  
  // Tokenize using Moyasar API
  const token = await moyasar.cards.tokenize({
    number: cardNumber,
    month: expiryDate.split('/')[0],
    year: expiryDate.split('/')[1],
    cvc: cvc,
  });
  
  res.json({ token: token });
});
```

## API Reference

### createPayment()
Creates a payment with card token.

```dart
final paymentId = await MoyasarService.createPayment(
  amount: 75.0,        // Amount in SAR
  currency: 'sar',     // Currency code
  description: 'Booking payment',
  userId: 'user123',
  bookingId: 'booking456',
  cardToken: 'tok_xxx', // From tokenization
);
```

**Parameters:**
- `amount` (double): Amount in SAR
- `currency` (string): Currency code (default: 'sar')
- `description` (string): Payment description
- `userId` (string): User identifier
- `bookingId` (string): Booking identifier
- `cardToken` (string): Tokenized card from Moyasar

**Returns:** Payment ID on success, null on failure

### getPaymentStatus()
Retrieves payment details and status.

```dart
final payment = await MoyasarService.getPaymentStatus(paymentId);

// Check payment status
if (payment['status'] == 'paid') {
  // Payment successful
} else if (payment['status'] == 'pending') {
  // Payment pending
} else if (payment['status'] == 'failed') {
  // Payment failed
}
```

### refundPayment()
Refunds a payment (partial or full).

```dart
final success = await MoyasarService.refundPayment(
  paymentId: 'payment_id',
  amount: 75.0, // SAR amount
);
```

### listPayments()
Lists all payments with optional filters.

```dart
final payments = await MoyasarService.listPayments(
  limit: 50,
  accountId: 'account_id', // Optional
);
```

## Webhook Setup

To handle payment status updates in real-time:

1. **Create webhook endpoint** in your backend:
```javascript
// backend/routes/payments.js
router.post('/webhook/moyasar', (req, res) => {
  const { type, data } = req.body;
  
  switch(type) {
    case 'payment.paid':
      // Mark booking as paid in database
      updateBookingStatus(data.booking_id, 'paid');
      break;
    case 'payment.failed':
      // Mark booking as failed
      updateBookingStatus(data.booking_id, 'failed');
      break;
  }
  
  res.json({ ok: true });
});
```

2. **Register webhook** in Moyasar Dashboard:
   - Settings → Webhooks
   - Add endpoint: `https://your-backend.com/webhook/moyasar`
   - Subscribe to events: `payment.paid`, `payment.failed`

## Environment Variables

Create a `.env` file or use your backend for storing sensitive keys:

```
MOYASAR_API_KEY=pk_test_your_key_here
MOYASAR_BASE_URL=https://api.moyasar.com/v1
```

## Error Handling

Common error cases and how to handle them:

```dart
try {
  final paymentId = await MoyasarService.createPayment(...);
} catch (e) {
  if (e.toString().contains('Invalid amount')) {
    // Handle invalid amount
  } else if (e.toString().contains('Card declined')) {
    // Handle card decline
  } else if (e.toString().contains('Connection error')) {
    // Handle network error
  }
}
```

## Testing

### Test Cards (Moyasar provides test cards)
- Visa: 4111 1111 1111 1111
- MasterCard: 5555 5555 5555 4444
- Expiry: Any future date
- CVC: Any 3 digits

Use these cards in the payment dialog to test integration.

## Security Checklist

- [ ] Never hardcode API keys in Flutter code
- [ ] Always use HTTPS for API calls
- [ ] Implement proper card tokenization (not raw card data)
- [ ] Validate amount on both client and backend
- [ ] Log payment attempts (without sensitive data)
- [ ] Implement rate limiting on payment endpoints
- [ ] Use webhook signatures to verify authenticity
- [ ] Store payment records securely in database
- [ ] Implement proper error handling without exposing sensitive info

## Troubleshooting

### Payment Creation Fails
- Check API key is correct
- Verify amount is in correct format (SAR)
- Ensure card token is valid

### Webhook Not Triggering
- Verify webhook endpoint is publicly accessible
- Check webhook URL in Moyasar dashboard
- Look for webhook logs in Moyasar dashboard

### Authentication Error
- API key might be incorrect
- Ensure base64 encoding of credentials
- Check Authorization header format

## Support

- Moyasar Documentation: https://moyasar.com/docs
- Moyasar Support: support@moyasar.com
- Dashboard: https://dashboard.moyasar.com

## Next Steps

1. ✅ Integrate Moyasar payment service
2. ⏳ Implement proper card tokenization (use hosted page or SDK)
3. ⏳ Setup webhooks for payment confirmations
4. ⏳ Add database support for payment tracking
5. ⏳ Implement refund functionality
6. ⏳ Add payment history/receipts
7. ⏳ Setup error notifications to admin
