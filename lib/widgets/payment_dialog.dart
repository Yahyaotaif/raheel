import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raheel/services/moyasar_service.dart';
import 'package:raheel/theme_constants.dart';
import 'package:raheel/widgets/loading_indicator.dart';

class PaymentDialog extends StatefulWidget {
  final double amount;
  final String description;
  final String userId;
  final String bookingId;
  final VoidCallback onSuccess;
  final Function(String)? onError;

  const PaymentDialog({
    required this.amount,
    required this.description,
    required this.userId,
    required this.bookingId,
    required this.onSuccess,
    this.onError,
    super.key,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Get card details from user
      final cardData = await _getCardData();
      
      if (cardData == null) {
        throw Exception('ألغيت عملية الدفع');
      }

      // Create payment directly with card details
      final paymentId = await MoyasarService.createPaymentWithCard(
        amount: widget.amount,
        currency: 'sar',
        description: widget.description,
        userId: widget.userId,
        bookingId: widget.bookingId,
        cardNumber: cardData['number'] ?? '',
        month: cardData['month'] ?? '',
        year: cardData['year'] ?? '',
        cvc: cardData['cvc'] ?? '',
        name: cardData['name'] ?? 'Customer',
      );

      if (paymentId == null) {
        throw Exception('فشلت عملية الدفع');
      }

      // Payment created successfully - the webhook will handle status updates
      if (mounted) {
        // Close dialog with success result
        Navigator.pop(context, {'success': true, 'error': null});
      }
    } catch (e) {
      // Extract just the message without the Exception prefix
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.replaceFirst('Exception: ', '');
      }

      // If the user cancels, just close the dialog immediately
      if (errorMsg == 'ألغيت عملية الدفع') {
        if (mounted) {
          Navigator.pop(context, {'success': false, 'error': errorMsg});
        }
        return;
      }

      setState(() {
        _errorMessage = errorMsg;
      });
      if (mounted) {
        Navigator.pop(context, {'success': false, 'error': _errorMessage ?? 'فشلت عملية الدفع'});
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Get card data from user input
  Future<Map<String, String>?> _getCardData() async {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _CardInputDialog(onCardDataReceived: (data) {
        Navigator.pop(context, data);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kBodyColor,
      title: const Text('تأكيد عملية الدفع',
        textAlign: TextAlign.center,
        style: TextStyle(color: kAppBarColor, fontWeight: FontWeight.bold),
      ),
      actionsAlignment: MainAxisAlignment.center,
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Text(
              'المبلغ: ${widget.amount.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '')} ريال سعودي',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'الوصف: ${widget.description}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '(ملاحظة : الرسوم خاصة بالإعلان فقط وليست قيمة التوصيل )',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            ],
          ]),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: kAppBarColor,
          ),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _handlePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: kAppBarColor,
            foregroundColor: Colors.white,
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: LoadingIndicator(size: 100),
                )
              : const Text('ادفع الآن'),
        ),
      ],
    );
  }
}

/// Card input dialog for collecting card details
/// These details are sent to Moyasar for tokenization
class _CardInputDialog extends StatefulWidget {
  final Function(Map<String, String>) onCardDataReceived;

  const _CardInputDialog({required this.onCardDataReceived});

  @override
  State<_CardInputDialog> createState() => _CardInputDialogState();
}

class _CardInputDialogState extends State<_CardInputDialog> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitCard() {
    // Validate inputs
    if (_cardNumberController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvcController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول')),
      );
      return;
    }

    // Parse card details
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    final expiryParts = _expiryController.text.split('/');
    final month = expiryParts.isNotEmpty ? expiryParts[0].padLeft(2, '0') : '00';
    final year = expiryParts.length > 1 ? expiryParts[1] : '00';
    final cvc = _cvcController.text;
    final name = _nameController.text.isNotEmpty ? _nameController.text : 'Customer';

    // Return card data as a map (not JSON encoded)
    widget.onCardDataReceived({
      'name': name,
      'number': cardNumber,
      'month': month,
      'year': year,
      'cvc': cvc,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kBodyColor,
      title: const Text('الرجاء إدخال تفاصيل البطاقة',
        style: TextStyle(color: kAppBarColor, fontWeight: FontWeight.bold),
      ),
      actionsAlignment: MainAxisAlignment.center,
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم حامل البطاقة',
                  labelStyle: const TextStyle(color: kAppBarColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kAppBarColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'رقم البطاقة',
                  labelStyle: const TextStyle(color: kAppBarColor),
                  hintText: 'يجب أن يكون 16 رقم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kAppBarColor, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'MM/YY',
                        labelStyle: const TextStyle(color: kAppBarColor),
                        hintText: '12/25',
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kAppBarColor, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          String text = newValue.text;
                          
                          // Limit to 4 digits only
                          if (text.length > 4) {
                            text = text.substring(0, 4);
                          }
                          
                          // Add slash after 2 digits
                          if (text.length >= 3) {
                            text = '${text.substring(0, 2)}/${text.substring(2, text.length)}';
                          }
                          
                          return newValue.copyWith(
                            text: text,
                            selection: TextSelection.collapsed(offset: text.length),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvcController,
                      decoration: InputDecoration(
                        labelText: 'CVC',
                        labelStyle: const TextStyle(color: kAppBarColor),
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kAppBarColor, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 4,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'ℹ️ بيانات البطاقة تُرسل بشكل آمن إلى Moyasar للمعالجة.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: kAppBarColor,
          ),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _submitCard,
          style: ElevatedButton.styleFrom(
            backgroundColor: kAppBarColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('إرسال'),
        ),
      ],
    );
  }
}
