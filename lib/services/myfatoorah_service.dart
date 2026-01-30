import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';

final logger = Logger();

class MyfatoorahService {
  // Replace with your Myfatoorah API Key from dashboard.myfatoorah.com
  // Use test API key for testing, live API key for production
  static const String apiKey = 'SK_SAU_fQ28kZaqVONVGWIn3Wiy9mXnFmGOSZ7L76OA7bdaL6W6RWPxEFegJSKGDbzIPZ4U';
  static const String baseUrl = 'https://apitest.myfatoorah.com/v2';
  static const String productionUrl = 'https://api.myfatoorah.com/v2';
  
  // Use test or production URL based on your needs
  static const String activeUrl = productionUrl; // Changed from baseUrl to productionUrl

  /// Create a payment directly with card details
  /// This is the recommended way to accept payments with Myfatoorah
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

      logger.i('Creating payment with card: ${sanitizedCardNumber.substring(sanitizedCardNumber.length - 4).padLeft(sanitizedCardNumber.length, '*')}');

      final requestBody = {
        'InvoiceAmount': amount,
        'CurrencyIso': 'SAR',
        'CardNumber': sanitizedCardNumber,
        'CardExpiryMonth': sanitizedMonth.padLeft(2, '0'),
        'CardExpiryYear': '20$sanitizedYear',
        'CardCvv': sanitizedCvc,
        'CardHolderName': sanitizedName,
      };

      logger.i('Request URL: $activeUrl/SendPayment');
      logger.i('Request Body: ${jsonEncode(requestBody)}');
      logger.i('Auth Header: Bearer $apiKey');

      final response = await http.post(
        Uri.parse('$activeUrl/SendPayment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      );

      logger.i('Response Status: ${response.statusCode}');
      logger.i('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('Response Status: ${response.statusCode}');
        logger.i('Response Body: ${response.body}');
        final json = jsonDecode(response.body);
        
        // Check if payment was successful
        if (json['IsSuccess'] == true) {
          final paymentData = json['Data'];
          logger.i('Payment created successfully: ${paymentData['InvoiceId']}');
          return paymentData['InvoiceId'].toString();
        } else {
          logger.e('Payment failed: ${json['Message']}');
          throw Exception(json['Message'] ?? 'فشل إنشاء الدفع');
        }
      } else {
        logger.e('Failed to create payment');
        logger.e('Status Code: ${response.statusCode}');
        logger.e('Response Body: ${response.body}');
        logger.e('Response Headers: ${response.headers}');
        try {
          final errorJson = jsonDecode(response.body);
          final errorMessage = errorJson['Message'] ?? errorJson['message'] ?? 'فشل إنشاء الدفع';
          final errorDetails = errorJson['ValidationErrors'] ?? errorJson['Errors'] ?? errorJson['Error'] ?? '';
          logger.e('Error Details: $errorDetails');
          throw Exception('$errorMessage${errorDetails.isNotEmpty ? ' - $errorDetails' : ''}');
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('فشل إنشاء الدفع. الرجاء التحقق من بيانات البطاقة والاتصال بالدعم الفني. (${response.statusCode})');
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

      final response = await http.post(
        Uri.parse('$activeUrl/InitiatePayment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'InvoiceAmount': amount,
          'CurrencyIso': 'SAR',
          'InvoiceNumber': bookingId,
          'InvoiceDate': DateTime.now().toIso8601String(),
          'NotificationOption': 'Webhook',
          'WebhookUrl': 'https://mwjjaiqqfzmlaiaamlhu.supabase.co/functions/v1/myfatoorah-webhook',
          'DisplayCurrencyIso': 'SAR',
          'Language': 'ar',
          'CardToken': cardToken,
          'CustomFields': {
            'userId': userId,
            'bookingId': bookingId,
            'description': description,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        
        if (json['IsSuccess'] == true) {
          final paymentData = json['Data'];
          logger.i('Payment created with token: ${paymentData['InvoiceId']}');
          return paymentData['InvoiceId'].toString();
        } else {
          logger.e('Payment failed: ${json['Message']}');
          throw Exception(json['Message'] ?? 'فشل إنشاء الدفع');
        }
      } else {
        logger.e('Failed to create payment: ${response.body}');
        throw Exception('فشل إنشاء الدفع. الرجاء المحاولة مرة أخرى.');
      }
    } catch (e) {
      logger.e('Error creating payment: $e');
      rethrow;
    }
  }

  /// Create a payment for a booking (Legacy - for backward compatibility)
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

      // Parse card details from cardToken (it's actually JSON)
      final cardDetails = jsonDecode(cardToken);

      final response = await http.post(
        Uri.parse('$activeUrl/InitiatePayment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'InvoiceAmount': amount,
          'CurrencyIso': 'SAR',
          'InvoiceNumber': bookingId,
          'InvoiceDate': DateTime.now().toIso8601String(),
          'CustomerName': cardDetails['name'] ?? 'Customer',
          'NotificationOption': 'Webhook',
          'WebhookUrl': 'https://mwjjaiqqfzmlaiaamlhu.supabase.co/functions/v1/myfatoorah-webhook',
          'DisplayCurrencyIso': 'SAR',
          'Language': 'ar',
          'CardNumber': cardDetails['number'] ?? '',
          'CardExpiryMonth': cardDetails['month'] ?? '',
          'CardExpiryYear': '20${cardDetails['year'] ?? ''}',
          'CardCvv': cardDetails['cvc'] ?? '',
          'CustomFields': {
            'userId': userId,
            'bookingId': bookingId,
            'description': description,
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        
        if (json['IsSuccess'] == true) {
          final paymentData = json['Data'];
          logger.i('Payment created: ${paymentData['InvoiceId']}');
          return paymentData['InvoiceId'].toString();
        } else {
          throw Exception(json['Message'] ?? 'فشل إنشاء الدفع');
        }
      } else {
        logger.e('Failed to create payment: ${response.body}');
        throw Exception('فشل إنشاء الدفع. الرجاء المحاولة مرة أخرى.');
      }
    } catch (e) {
      logger.e('Error creating payment: $e');
      rethrow;
    }
  }

  /// Get payment status
  /// Returns payment details including status ('Paid', 'Failed', 'Pending', etc.)
  static Future<Map<String, dynamic>?> getPaymentStatus(
      String invoiceId) async {
    try {
      final response = await http.get(
        Uri.parse('$activeUrl/GetPaymentStatus')
            .replace(queryParameters: {'Key': invoiceId, 'KeyType': 'InvoiceId'}),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['IsSuccess'] == true) {
          final paymentData = json['Data'];
          logger.i('Payment status: ${paymentData['InvoiceStatus']}');
          return paymentData;
        } else {
          throw Exception(json['Message'] ?? 'فشل الحصول على حالة الدفع');
        }
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
  /// Amount should be in SAR
  static Future<bool> refundPayment({
    required String invoiceId,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$activeUrl/RefundInvoice'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'Key': invoiceId,
          'KeyType': 'InvoiceId',
          'RefundAmount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['IsSuccess'] == true) {
          logger.i('Refund processed for invoice: $invoiceId');
          return true;
        } else {
          throw Exception(json['Message'] ?? 'فشل استرجاع المبلغ');
        }
      } else {
        logger.e('Failed to refund payment: ${response.body}');
        throw Exception('فشل استرجاع المبلغ. الرجاء المحاولة مرة أخرى.');
      }
    } catch (e) {
      logger.e('Error refunding payment: $e');
      throw Exception('حدث خطأ أثناء معالجة استرجاع المبلغ.');
    }
  }

  /// List all invoices
  static Future<List<Map<String, dynamic>>?> listPayments({
    int? skip,
    int? take,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (skip != null) queryParams['Skip'] = skip.toString();
      if (take != null) queryParams['Take'] = take.toString();

      final response = await http.get(
        Uri.parse('$activeUrl/GetInvoices')
            .replace(queryParameters: queryParams.isEmpty ? null : queryParams),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['IsSuccess'] == true) {
          final invoices = List<Map<String, dynamic>>.from(json['Data'] ?? []);
          logger.i('Retrieved ${invoices.length} invoices');
          return invoices;
        } else {
          throw Exception(json['Message'] ?? 'فشل تحميل قائمة الدفعات');
        }
      } else {
        logger.e('Failed to list invoices: ${response.body}');
        throw Exception('فشل تحميل قائمة الدفعات. الرجاء المحاولة مرة أخرى.');
      }
    } catch (e) {
      logger.e('Error listing invoices: $e');
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
