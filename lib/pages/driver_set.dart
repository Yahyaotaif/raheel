import 'package:flutter/material.dart';
import 'package:raheel/theme_constants.dart';
import 'package:raheel/widgets/payment_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Convert 24-hour time string to 12-hour format with AM/PM
String convertTo12HourFormat(TimeOfDay time) {
  final hour = time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  final isPM = hour >= 12;
  final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  final period = isPM ? 'PM' : 'AM';
  return '$displayHour:$minute $period';
}

class DriverSetPage extends StatefulWidget {
  const DriverSetPage({super.key});

  @override
  State<DriverSetPage> createState() => _DriverSetPageState();
}

class _DriverSetPageState extends State<DriverSetPage> {
  String? _selectedPassengers;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedDestinationDropdown;
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _meetingPointController = TextEditingController();
  final bool _isLoading = false;
  String? _errorMessage;
  double _tripPrice = 0;

  // List of destination cities
  static const List<String> _destinationCities = [
    'اليمن',
    'البحرين',
    'قطر',
    'الامارات',
    'الكويت',
    'الرياض',
    'جدة',
    'مكة',
    'أبها',
    'جيزان',
    'الاردن',
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(
                255,
                105,
                156,
                122,
              ), // header background, selected day
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    // Calculate initial time - use current time + 3 hours if date is today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDateOnly = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    final TimeOfDay initialTime = (selectedDateOnly == today)
        ? TimeOfDay(hour: (now.hour + 3) % 24, minute: now.minute)
        : (_selectedTime ?? TimeOfDay.now());

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(
                255,
                105,
                156,
                122,
              ), // dial, selected time
              onPrimary: Colors.white, // text on primary
              onSurface: Colors.black, // body text color
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Check if the selected date is today and enforce 3-hour minimum
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDateOnly = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );

      if (selectedDateOnly == today) {
        // Calculate the minimum allowed time (current time + 3 hours)
        final minimumHour = now.hour + 3;

        // If it's today, check if the selected time is at least 3 hours in the future
        if (picked.hour < minimumHour ||
            (picked.hour == minimumHour && picked.minute < now.minute)) {
          if (mounted) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              const SnackBar(
                content: Text(
                  'يجب اختيار وقت يزيد عن الوقت الحالي بـ ثلاث ساعات على الاقل',
                  textDirection: TextDirection.rtl,
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createTrip() async {
    // Clear previous error message
    setState(() {
      _errorMessage = null;
    });
    
    if (_selectedDate == null ||
        _selectedTime == null ||
        _destinationController.text.isEmpty ||
        _meetingPointController.text.isEmpty ||
        _selectedPassengers == null) {
      setState(() {
        _errorMessage = 'يرجى ملء جميع الحقول';
      });
      return;
    }

    final currentSession = Supabase.instance.client.auth.currentSession;
    final driverId = currentSession?.user.id;

    if (driverId == null) {
      setState(() {
        _errorMessage = 'لم يتم العثور على المستخدم. يرجى تسجيل الدخول مرة أخرى.';
      });
      return;
    }

    final advertisingFee = 0.0; // Free for now - change to 50.0 to re-enable payment
    final bookingId = 'trip_${DateTime.now().millisecondsSinceEpoch}';

    if (!mounted) return;

    // Skip payment dialog if advertising fee is 0 (free trip creation)
    Map<String, dynamic>? paymentResult = {'success': true};
    
    if (advertisingFee > 0) {
      // Show payment dialog only if there's a fee
      paymentResult = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PaymentDialog(
          amount: advertisingFee,
          description: 'رسوم نشر الإعلان - $advertisingFee ريال سعودي',
          userId: driverId,
          bookingId: bookingId,
          onSuccess: () {},
        ),
      );

      // Handle payment result with proper context guarding
      if (!mounted) return;

      if (paymentResult == null || paymentResult['success'] != true) {
        // Payment was cancelled or failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل الدفع: ${(paymentResult?['error'] ?? 'تم الإلغاء')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Payment successful (or skipped if free), create the trip
    try {
      final formattedTime =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      await Supabase.instance.client.from('trips').insert({
        'driver_id': driverId,
        'trip_date': _selectedDate!.toIso8601String().split('T')[0],
        'trip_time': formattedTime,
        'destination': _selectedDestinationDropdown,
        'destination_description': _destinationController.text.trim(),
        'meeting_point_description': _meetingPointController.text.trim(),
        'num_passengers': int.parse(_selectedPassengers!),
        'price': _tripPrice,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _destinationController.clear();
        _meetingPointController.clear();
        _selectedPassengers = null;
        _selectedDestinationDropdown = null;
        _errorMessage = null;
        _tripPrice = 0;
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: kBodyColor,
            title: const Text(
              'تم إعلان الرحلة بنجاح',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kAppBarColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'تم الإعلان عن رحلتك بنجاح! يرجى التوجه إلى إدارة حجوزاتك في حسابك للتحقق من الركاب الذين حجزوا معك والتواصل معهم.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppBarColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Close the success dialog and go back to profile
                  Navigator.of(dialogContext).pop();
                  // Pop the DriverSetPage to return to home/profile
                  Navigator.of(context).pop();
                },
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'خطأ في إنشاء الرحلة: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBodyColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.directions_car, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text('إنشاء رحلة', style: TextStyle(color: Colors.white)),
          ],
        ),
        titleTextStyle: const TextStyle(fontSize: 24, color: Colors.white),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kAppBarColor, Color.fromARGB(255, 85, 135, 105)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(
                          color: Colors.black54,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 48),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => _pickDate(context),
                      child: const Center(
                        child: Text(
                          'اختر التاريخ',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _selectedDate == null
                        ? const Text(
                            'لم يتم اختيار تاريخ',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          )
                        : Column(
                            children: [
                              const Text(
                                'التاريخ المختار:',
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              Text(
                                '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kAppBarColor,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(
                          color: Colors.black54,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 48),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => _pickTime(context),
                      child: const Center(
                        child: Text(
                          'اختر الوقت',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _selectedTime == null
                        ? const Text(
                            'لم يتم اختيار وقت\n(لضمان وصول إعلانك لعدد كبير من المسافرين ، يفضل أن يتم الحجز لليوم التالي  )',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          )
                        : Column(
                            children: [
                              const Text(
                                'الوقت المختار:',
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              Text(
                                convertTo12HourFormat(_selectedTime!),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kAppBarColor,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedDestinationDropdown,
                        decoration: const InputDecoration(
                          labelText: 'اختر المكان',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        items: _destinationCities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            alignment: Alignment.centerRight,
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDestinationDropdown = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _destinationController,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          labelText: 'حدد مكان الوصول',
                          hintText: 'الرجاء كتابة اسم المنطقة التي ستصل إليها',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _meetingPointController,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          labelText: 'حدد مكان الإنطلاق',
                          hintText: 'الرجاء كتابة اسم المنطقة التي ستسافر منها',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedPassengers,
                        decoration: const InputDecoration(
                          labelText: 'عدد الركاب',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          alignLabelWithHint: true,
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        hint: const Text('اختر عدد الركاب'),
                        items: const [
                          DropdownMenuItem(value: '1', alignment: Alignment.centerRight, child: Text('1')),
                          DropdownMenuItem(value: '2', alignment: Alignment.centerRight, child: Text('2')),
                          DropdownMenuItem(value: '3', alignment: Alignment.centerRight, child: Text('3')),
                          DropdownMenuItem(value: '4', alignment: Alignment.centerRight, child: Text('4')),
                          DropdownMenuItem(value: '5', alignment: Alignment.centerRight, child: Text('5')),
                          DropdownMenuItem(value: '6', alignment: Alignment.centerRight, child: Text('6')),
                          DropdownMenuItem(value: '7', alignment: Alignment.centerRight, child: Text('7')),
                          DropdownMenuItem(value: '8', alignment: Alignment.centerRight, child: Text('8')),
                          DropdownMenuItem(value: '9', alignment: Alignment.centerRight, child: Text('9')),
                          DropdownMenuItem(value: '10', alignment: Alignment.centerRight, child: Text('10')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPassengers = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: kAppBarColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _isLoading ? null : _createTrip,
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.add_location_alt),
                  label: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('إنشاء رحلة'),
                ),
              ),
              const SizedBox(height: 24), // Add bottom padding for button
            ],
          ),
        ),
      ),
    );
  }
}
