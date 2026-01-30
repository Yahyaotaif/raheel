# Myfatoorah Payment Integration Guide

## Overview
This guide explains how to use Myfatoorah payment processing in your Flutter app. Myfatoorah is a Saudi-based payment gateway that supports card payments, Apple Pay, Google Pay, and more.

## Migration from Moyasar

The migration has been completed with the following changes:

### Files Changed:
1. **Created**: `lib/services/myfatoorah_service.dart` - Complete replacement for Moyasar service
2. **Updated**: `lib/widgets/payment_dialog.dart` - Updated to use MyfatoorahService instead of MoyasarService
3. **Created**: `backend/functions/myfatoorah_webhook.js` - Webhook handler for payment callbacks

### Key Differences from Moyasar:

| Feature | Moyasar | Myfatoorah |
|---------|---------|-----------|
| API Endpoint | `/v1/payments` | `/v2/SendPayment` |
| Authentication | Basic Auth with API Key | Bearer Token |
| Amount Format | Integer (fils) | Decimal (SAR) |
| Status Codes | 'paid', 'pending', 'failed' | 1=Paid, 2=Pending, 3=Failed, 4=Cancelled |
| Webhook Path | `moyasar-webhook` | `myfatoorah-webhook` |

## Setup Steps

### 1. Create Myfatoorah Account
1. Visit [https://dashboard.myfatoorah.com](https://dashboard.myfatoorah.com)
2. Sign up and complete verification
3. Navigate to Settings → API Keys or Developer Settings
4. Copy your **API Key** (Keep this secret!)

### 2. Update Service Configuration

#### In `lib/services/myfatoorah_service.dart`:
```dart
static const String apiKey = 'YOUR_MYFATOORAH_API_KEY';
```

Replace `YOUR_MYFATOORAH_API_KEY` with your actual API key from the dashboard.

#### Test vs Production:
```dart
// For testing (sandbox):
static const String activeUrl = baseUrl; // https://apitest.myfatoorah.com/v2

// For production (live):
static const String activeUrl = productionUrl; // https://api.myfatoorah.com/v2
```

### 3. Update Webhook Endpoint

In your Myfatoorah dashboard, set the webhook URL to:
```
https://mwjjaiqqfzmlaiaamlhu.supabase.co/functions/v1/myfatoorah-webhook
```

Make sure this URL is registered in your Myfatoorah account settings.

### 4. Payment Flow

The payment flow works as follows:

```
User → PaymentDialog → Card Input → MyfatoorahService.createPaymentWithCard()
                                    ↓
                          Backend/Myfatoorah API
                                    ↓
                    Payment Processed → Webhook Notification
                                    ↓
                         Trip Status Updated in Supabase
                                    ↓
                         Success/Failure Response
```

### 5. Using the Payment Dialog

The payment dialog usage remains **exactly the same**:

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

## API Reference

### Available Methods in MyfatoorahService

#### 1. Create Payment with Card
```dart
static Future<String?> createPaymentWithCard({
  required double amount,
  required String currency,
  required String description,
  required String userId,
  required String bookingId,
  required String cardNumber,
  required String month,
  required String year,
  required String cvc,
  required String name,
})
```

#### 2. Create Payment with Token
```dart
static Future<String?> createPaymentWithToken({
  required double amount,
  required String currency,
  required String description,
  required String userId,
  required String bookingId,
  required String cardToken,
})
```

#### 3. Get Payment Status
```dart
static Future<Map<String, dynamic>?> getPaymentStatus(String invoiceId)
```

Returns payment details including status ('Paid', 'Pending', 'Failed', etc.)

#### 4. Refund Payment
```dart
static Future<bool> refundPayment({
  required String invoiceId,
  required double amount,
})
```

#### 5. List Invoices
```dart
static Future<List<Map<String, dynamic>>?> listPayments({
  int? skip,
  int? take,
})
```

## Payment Status Mapping

Myfatoorah payment statuses are mapped as follows:

| Code | Status | Meaning |
|------|--------|---------|
| 1 | Paid | Payment successfully processed |
| 2 | Pending | Payment is pending |
| 3 | Failed | Payment failed |
| 4 | Cancelled | Payment was cancelled |

## Webhook Response

The webhook handler (`myfatoorah_webhook.js`) automatically:
1. Receives payment notifications from Myfatoorah
2. Extracts invoice ID and payment status
3. Updates the trip record in Supabase with:
   - `payment_status`: 'paid', 'pending', 'failed', or 'cancelled'
   - `status`: Trip status based on payment outcome
   - `payment_id`: Invoice ID from Myfatoorah
   - `updated_at`: Timestamp of update

## Error Handling

The service includes comprehensive error handling:
- Card validation (length, Luhn algorithm)
- Amount validation
- Expiry date validation (month 01-12, year YY format)
- CVC validation (3-4 digits)
- API error parsing and user-friendly Arabic error messages

All errors are logged and returned with Arabic descriptions for user display.

## Important Notes

### Security
- Store API keys in environment variables, not in code
- Never log card details (service masks sensitive info)
- Use HTTPS for all API calls
- Validate webhook requests if needed (add signature verification)

### Testing
1. Use test API key and sandbox URL for testing
2. Use test card numbers provided by Myfatoorah
3. Verify webhook delivery in Myfatoorah dashboard logs
4. Check Supabase for updated trip records

### Production
1. Switch to production API key
2. Update `activeUrl` to `productionUrl`
3. Test end-to-end with small amounts first
4. Monitor webhook logs for failures
5. Set up monitoring and alerting for payment failures

## Troubleshooting

### Payment Creation Fails
1. Verify API key is correct
2. Check card details are valid (use test cards for sandbox)
3. Ensure amount is greater than 0
4. Check API endpoint is correct for your environment

### Webhook Not Triggered
1. Verify webhook URL in Myfatoorah dashboard
2. Check function logs in Firebase Console
3. Ensure Supabase credentials are valid
4. Test webhook with Myfatoorah's webhook test tool

### Trip Status Not Updated
1. Check webhook function logs
2. Verify bookingId and userId are in CustomFields
3. Ensure Supabase table has required columns
4. Check RLS policies allow updates

## Support

For Myfatoorah support:
- Documentation: https://docs.myfatoorah.com
- Dashboard: https://dashboard.myfatoorah.com
- Support Email: support@myfatoorah.com
