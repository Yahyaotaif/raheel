import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';

final logger = Logger();

class MoyasarService {
  // Replace with your Moyasar API Key from dashboard.moyasar.com
  // Use pk_test_* for testing, pk_live_* for production
  // Note: Live API keys require account activation
  static const String apiKey = 'pk_test_6eJrvfwL28jRAymCxYFTiFUTjCudaBwTsu8ibTsv';
  static const String baseUrl = 'https://api.moyasar.com/v1';

  /// Create a payment directly with card details
  /// This is the recommended way to accept payments with Moyasar
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
  }) async {
    try {
      // Validate amount
      if (amount <= 0) {
        throw Exception('المبلغ يجب أن يكون أكبر من صفر');
      }

      // Sanitize card data - remove whitespace and validate
      final sanitizedCardNumber = cardNumber.replaceAll(' ', '').trim();
      final sanitizedMonth = month.replaceAll(' ', '').trim();
      final sanitizedYear = year.replaceAll(' ', '').trim();
      final sanitizedCvc = cvc.replaceAll(' ', '').trim();
      final sanitizedName = name.replaceAll(RegExp(r'\s+'), ' ').trim();

      // Validate card data
      if (sanitizedCardNumber.isEmpty || 
          sanitizedMonth.isEmpty || 
          sanitizedYear.isEmpty || 
          sanitizedCvc.isEmpty ||
          sanitizedName.isEmpty) {
        throw Exception('الرجاء ملء جميع بيانات البطاقة');
      }

      // Validate card number length (should be 13-19 digits)
      if (sanitizedCardNumber.length < 13 || sanitizedCardNumber.length > 19) {
        throw Exception('رقم البطاقة غير صحيح. يجب أن يكون بين 13 و 19 رقم');
      }

      // Validate card number using Luhn algorithm
      if (!_isValidCardNumber(sanitizedCardNumber)) {
        throw Exception('رقم البطاقة غير صحيح. يرجى التحقق من الرقم');
      }

      // Validate month (01-12)
      final monthInt = int.tryParse(sanitizedMonth);
      if (monthInt == null || monthInt < 1 || monthInt > 12) {
        throw Exception('الشهر غير صحيح. يجب أن يكون بين 01 و 12');
      }

      // Validate year (should be 2 digits for expiry)
      if (sanitizedYear.length != 2) {
        throw Exception('السنة غير صحيحة. يجب أن تكون رقمين (YY)');
      }
      final yearInt = int.tryParse(sanitizedYear);
      if (yearInt == null || yearInt < 0 || yearInt > 99) {
        throw Exception('السنة غير صحيحة');
      }

      // Validate CVC (should be 3-4 digits)
      if (sanitizedCvc.length < 3 || sanitizedCvc.length > 4) {
        throw Exception('رمز الأمان (CVC) غير صحيح. يجب أن يكون 3 أو 4 أرقام');
      }

      // Convert amount to fils (smallest currency unit for SAR)
      final amountInFils = (amount * 100).toInt();

      logger.i('Creating payment with card: ${sanitizedCardNumber.substring(sanitizedCardNumber.length - 4).padLeft(sanitizedCardNumber.length, '*')}');

      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
        },
        body: jsonEncode({
          'amount': amountInFils,
          'currency': currency.toUpperCase(),
          'description': description,
          'source': {
            'type': 'card',
            'name': sanitizedName,
            'number': sanitizedCardNumber,
            'month': sanitizedMonth.padLeft(2, '0'),
            'year': sanitizedYear,
            'cvc': sanitizedCvc,
          },
          'callback_url': 'https://mwjjaiqqfzmlaiaamlhu.supabase.co/functions/v1/moyasar-webhook',
          'metadata': {
            'userId': userId,
            'bookingId': bookingId,
          },
        }),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        logger.i('Payment created successfully: ${json['id']}');
        return json['id'];
      } else {
        logger.e('Failed to create payment: ${response.body}');
        try {
          final errorJson = jsonDecode(response.body);
          final errorData = errorJson['errors'] ?? {};
          String errorMessage = errorJson['message'] ?? 'فشل إنشاء الدفع';
          
          // Parse specific field errors
          if (errorData is Map && errorData.isNotEmpty) {
            final firstError = errorData.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError[0];
            }
          }
          
          throw Exception(errorMessage);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('فشل إنشاء الدفع. الرجاء التحقق من بيانات البطاقة والاتصال بالدعم الفني.');
        }
      }
    } catch (e) {
      logger.e('Error creating payment: $e');
      rethrow;
    }
  }

  /// Create a payment using a card token
  /// This is the secure way to create payments
  static Future<String?> createPaymentWithToken({
    required double amount,
    required String currency,
    required String description,
    required String userId,
    required String bookingId,
    required String cardToken,
  }) async {
    try {
      // Validate amount
      if (amount <= 0) {
        throw Exception('المبلغ يجب أن يكون أكبر من صفر');
      }

      // Convert amount to fils (smallest currency unit for SAR)
      final amountInFils = (amount * 100).toInt();

      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
        },
        body: jsonEncode({
          'amount': amountInFils,
          'currency': currency.toUpperCase(),
          'description': description,
          'source': {
            'type': 'token',
            'token': cardToken,
          },
          'callback_url': 'https://mwjjaiqqfzmlaiaamlhu.supabase.co/functions/v1/moyasar-webhook',
          'metadata': {
            'userId': userId,
            'bookingId': bookingId,
          },
        }),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        logger.i('Payment created with token: ${json['id']}');
        return json['id'];
      } else {
        logger.e('Failed to create payment: ${response.body}');
        try {
          final errorJson = jsonDecode(response.body);
          final errorMessage = errorJson['message'] ?? 'فشل إنشاء الدفع';
          throw Exception('فشل إنشاء الدفع: $errorMessage');
        } catch (_) {
          throw Exception('فشل إنشاء الدفع. الرجاء المحاولة مرة أخرى.');
        }
      }
    } catch (e) {
      logger.e('Error creating payment: $e');
      rethrow;
    }
  }

  /// Create a payment for a booking (Legacy - for backward compatibility)
  /// DEPRECATED: Use createPaymentWithToken instead for security
  static Future<String?> createPayment({
    required double amount,
    required String currency,
    required String description,
    required String userId,
    required String bookingId,
    required String cardToken,
  }) async {
    try {
      // Validate amount
      if (amount <= 0) {
        throw Exception('المبلغ يجب أن يكون أكبر من صفر');
      }

      // Convert amount to fils (smallest currency unit for SAR)
      final amountInFils = (amount * 100).toInt();

      // Parse card details from cardToken (it's actually JSON)
      final cardDetails = jsonDecode(cardToken);

      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
        },
        body: jsonEncode({
          'amount': amountInFils,
          'currency': currency.toUpperCase(),
          'description': description,
          'source': {
            'type': 'card',
            'name': cardDetails['name'] ?? 'Customer',
            'number': cardDetails['number'] ?? '',
            'month': cardDetails['month'] ?? '',
            'year': cardDetails['year'] ?? '',
            'cvc': cardDetails['cvc'] ?? '',
          },
          'callback_url': 'https://mwjjaiqqfzmlaiaamlhu.supabase.co/functions/v1/moyasar-webhook',
          'metadata': {
            'userId': userId,
            'bookingId': bookingId,
          },
        }),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        logger.i('Payment created: ${json['id']}');
        return json['id'];
      } else {
        logger.e('Failed to create payment: ${response.body}');
        try {
          final errorJson = jsonDecode(response.body);
          final errorMessage = errorJson['message'] ?? 'فشل إنشاء الدفع';
          throw Exception('فشل إنشاء الدفع: $errorMessage');
        } catch (_) {
          throw Exception('فشل إنشاء الدفع. الرجاء المحاولة مرة أخرى.');
        }
      }
    } catch (e) {
      logger.e('Error creating payment: $e');
      rethrow;
    }
  }

  /// Get payment status
  /// Returns payment details including status ('paid', 'pending', 'failed')
  static Future<Map<String, dynamic>?> getPaymentStatus(
      String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/$paymentId'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        logger.i('Payment status: ${json['status']}');
        return json;
      } else {
        logger.e('Failed to get payment status: ${response.body}');
        throw Exception('فشل الحصول على حالة الدفع. الرجاء المحاولة مرة أخرى.');
      }
    } catch (e) {
      logger.e('Error getting payment status: $e');
      rethrow;
    }
  }

  /// Refund a payment
  /// Amount should be in SAR (optional for partial refunds)
  static Future<bool> refundPayment({
    required String paymentId,
    required double amount,
  }) async {
    try {
      // Convert amount to fils
      final amountInFils = (amount * 100).toInt();

      final response = await http.post(
        Uri.parse('$baseUrl/payments/$paymentId/refund'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
        },
        body: jsonEncode({
          'amount': amountInFils,
        }),
      );

      if (response.statusCode == 201) {
        logger.i('Refund processed for payment: $paymentId');
        return true;
      } else {
        logger.e('Failed to refund payment: ${response.body}');
        throw Exception('فشل استرجاع المبلغ. الرجاء المحاولة مرة أخرى.');
      }
    } catch (e) {
      logger.e('Error refunding payment: $e');
      throw Exception('حدث خطأ أثناء معالجة استرجاع المبلغ.');
    }
  }

  /// List all payments
  static Future<List<Map<String, dynamic>>?> listPayments({
    int? limit,
    String? accountId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (accountId != null) queryParams['account_id'] = accountId;

      final response = await http.get(
        Uri.parse('$baseUrl/payments')
            .replace(queryParameters: queryParams.isEmpty ? null : queryParams),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final payments = List<Map<String, dynamic>>.from(json['data'] ?? []);
        logger.i('Retrieved ${payments.length} payments');
        return payments;
      } else {
        logger.e('Failed to list payments: ${response.body}');
        throw Exception('فشل تحميل قائمة الدفعات. الرجاء المحاولة مرة أخرى.');
      }
    } catch (e) {
      logger.e('Error listing payments: $e');
      throw Exception('حدث خطأ أثناء تحميل الدفعات.');
    }
  }

  /// Validate credit card number using Luhn algorithm
  static bool _isValidCardNumber(String cardNumber) {
    // Remove any non-digit characters
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    // Check if it contains only digits
    if (digits.isEmpty || digits.length < 13) {
      return false;
    }
    
    // Luhn algorithm validation
    int sum = 0;
    int isEven = 0;
    
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);
      
      if (isEven == 1) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      isEven ^= 1;
    }
    
    return sum % 10 == 0;
  }
}
