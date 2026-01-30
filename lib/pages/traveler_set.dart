import 'package:flutter/material.dart';
import 'package:raheel/theme_constants.dart';
import 'package:raheel/widgets/payment_dialog.dart';
import 'package:raheel/widgets/trip_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'dart:async';

final logger = Logger();

/// Convert 24-hour time string (HH:MM) to 12-hour format with AM/PM
String convertTo12HourFormatFromString(String timeString) {
  try {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final isPM = hour >= 12;
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = isPM ? 'PM' : 'AM';
    return '$displayHour:$minute $period';
  } catch (e) {
    return timeString; // Return original if parsing fails
  }
}

class TravelerSetPage extends StatefulWidget {
  const TravelerSetPage({super.key});

  @override
  State<TravelerSetPage> createState() => _TravelerSetPageState();
}

class _TravelerSetPageState extends State<TravelerSetPage> {
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedDestinationDropdown;
  final TextEditingController _destinationController = TextEditingController();
  List<Map<String, dynamic>> _trips = [];
  bool _isLoadingTrips = false;
  bool _isLoadingMore = false;
  bool _hasMoreTrips = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  Timer? _refreshTimer;
  final ScrollController _scrollController = ScrollController();

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
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreTrips &&
        _selectedDate != null) {
      _loadMoreTrips();
    }
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
              primary: Color.fromARGB(255, 105, 156, 122),
              onPrimary: Colors.white,
              onSurface: Colors.black,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
        _trips = [];
        _currentPage = 0;
        _hasMoreTrips = true;
      });

      // Auto-fetch trips immediately after date selection so results show without extra taps
      await _fetchTripsForDate(picked);
    }
  }

  Future<void> _fetchTripsForDate(DateTime date) async {
    setState(() {
      _isLoadingTrips = true;
      _currentPage = 0;
      _hasMoreTrips = true;
      _trips = [];
    });

    await _loadTripsPage(date, 0);

    setState(() {
      _isLoadingTrips = false;
    });
  }

  Future<void> _loadMoreTrips() async {
    if (_isLoadingMore || !_hasMoreTrips || _selectedDate == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    await _loadTripsPage(_selectedDate!, _currentPage + 1);

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _loadTripsPage(DateTime date, int page) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];

      var query = Supabase.instance.client
          .from('trips')
          .select()
          .eq('trip_date', dateString);

      // Filter by destination if one is selected
      if (_selectedDestinationDropdown != null) {
        query = query.eq('destination', _selectedDestinationDropdown!);
      }

      final response = await query.range(
        page * _pageSize,
        (page + 1) * _pageSize - 1,
      );

      if (!mounted) return;

      // Convert response to List<Map<String, dynamic>>
      final tripsList = List<Map<String, dynamic>>.from(response as List);
      final tripsWithBookings = <Map<String, dynamic>>[];

      // Get booking count for all trips to show availability
      for (final trip in tripsList) {
        final tripId = trip['id'];

        // Count how many travelers have booked this trip (all bookings)
        final bookingResponse = await Supabase.instance.client
            .from('bookings')
            .select('id')
            .eq('trip_id', tripId);

        final bookedSeats = (bookingResponse as List).length;

        logger.d(
          'Trip $tripId: Found $bookedSeats bookings. Raw response: $bookingResponse',
        );

        // Create a new map with booking count included
        final tripWithBooking = Map<String, dynamic>.from(trip);
        tripWithBooking['booked_seats'] = bookedSeats;

        tripsWithBookings.add(tripWithBooking);
      }

      if (!mounted) return;

      setState(() {
        if (page == 0) {
          _trips = tripsWithBookings;
        } else {
          _trips.addAll(tripsWithBookings);
        }
        _currentPage = page;
        _hasMoreTrips = tripsList.length >= _pageSize;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        if (page == 0) {
          _isLoadingTrips = false;
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'حدث خطأ في تحميل الرحلات. يرجى المحاولة مرة أخرى',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _bookTripWithPayment() async {
    try {
      // Get current traveler info
      final authUser = await Supabase.instance.client.auth.getUser();

      if (!mounted) return;

      final travelerId = authUser.user?.id;

      if (travelerId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على المستخدم'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get traveler details
      final travelerResponse = await Supabase.instance.client
          .from('user')
          .select('FirstName, LastName, MobileNumber')
          .eq('id', travelerId)
          .single();

      if (!mounted) return;
      final firstName = travelerResponse['FirstName'];
      final lastName = travelerResponse['LastName'];
      final phone = travelerResponse['MobileNumber'];

      // Find the selected trip to get driver info and price
      final selectedTrip = _trips.firstWhere(
        (trip) => trip['trip_time'] == _selectedTime,
      );

      final tripId = selectedTrip['id'];
      final driverId = selectedTrip['driver_id'];
      final numPassengers = selectedTrip['num_passengers'] as int;

      final bookingFee = 0.0; // Free for now - change to 5.0 to re-enable payment
      final bookingId = 'booking_${DateTime.now().millisecondsSinceEpoch}';

      if (!mounted) return;

      // Check current booking count before showing payment dialog
      // This prevents travelers from paying when trip might already be full
      try {
        final bookingCount = await Supabase.instance.client
            .from('bookings')
            .select('id')
            .eq('trip_id', tripId);

        final currentBookedSeats = (bookingCount as List).length;

        logger.d(
          'Pre-payment check - Trip $tripId: currentBookedSeats=$currentBookedSeats, numPassengers=$numPassengers',
        );
        logger.d('Pre-payment booking response: $bookingCount');

        if (currentBookedSeats >= numPassengers) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'عذراً، لقد امتلأت هذه الرحلة للتو. يرجى اختيار رحلة أخرى.',
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
          // Refresh trips to show updated availability
          await _fetchTripsForDate(_selectedDate!);
          return;
        }
      } catch (e) {
        // If capacity check fails, continue with booking attempt
        // The RPC function will provide proper validation
        logger.e('Pre-payment check error: $e');
      }

      // Skip payment dialog if booking fee is 0 (free bookings)
      if (!mounted) return;

      Map<String, dynamic>? paymentResult = {'success': true};
      
      if (bookingFee > 0) {
        // Show payment dialog only if there's a fee
        paymentResult = await showDialog<Map<String, dynamic>>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => PaymentDialog(
            amount: bookingFee,
            description: 'رسوم الحجز - $bookingFee ريال سعودي',
            userId: travelerId,
            bookingId: bookingId,
            onSuccess: () {},
          ),
        );

        // Handle payment result with proper context guarding
        if (!mounted) return;

        if (paymentResult?['success'] != true) {
          // Payment was cancelled or failed
          String paymentError = 'تم إلغاء عملية الدفع';
          if (paymentResult?['error'] != null) {
            final error = paymentResult?['error']?.toString() ?? '';
            if (error.contains('فشل') || error.contains('fail')) {
              paymentError = 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى';
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(paymentError, textDirection: TextDirection.rtl),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Payment successful (or skipped if free), proceed with booking
      try {
        // Call the Supabase RPC function that atomically validates and inserts
        final bookingResult = await Supabase.instance.client.rpc(
          'book_trip',
          params: {
            'p_traveler_id': travelerId,
            'p_driver_id': driverId,
            'p_trip_id': tripId,
            'p_trip_date': _selectedDate!.toIso8601String().split('T')[0],
            'p_trip_time': _selectedTime,
            'p_booking_fee': bookingFee,
          },
        );

        // Check if booking was successful
        if (bookingResult != null && bookingResult['success'] == true) {
          // Booking successful, send email to driver
          try {
            await _sendEmailToDriver(
              driverEmail: (await Supabase.instance.client
                  .from('user')
                  .select('EmailAddress')
                  .eq('id', driverId)
                  .single())['EmailAddress'],
              travelerName: '$firstName $lastName',
              travelerPhone: phone.toString(),
            );
          } catch (e) {
            // Email failed but booking was successful
          }

          if (!mounted) return;

          // Show success dialog
          setState(() {
            _selectedDate = null;
            _selectedTime = null;
            _destinationController.clear();
            _trips = [];
          });

          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                backgroundColor: kBodyColor,
                title: const Text(
                  'تم الحجز بنجاح',
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
                    children: const [
                      SizedBox(height: 16),
                      Text(
                        'تم حجز رحلتك بنجاح! يرجى التوجه إلى إدارة حجوزاتك للتحقق من السائق الذي ستسافر معه والتواصل معه.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
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
                      Navigator.of(dialogContext).pop();
                      // Navigate to profile page
                      Navigator.of(context).pushReplacementNamed('/profile');
                    },
                    child: const Text('حسناً'),
                  ),
                ],
              ),
            );
          }
        } else {
          // Booking failed
          if (!mounted) return;

          final errorMessage = bookingResult?['error'] ?? 'حدث خطأ في الحجز';
          String userMessage =
              'عذراً، انتهت المقاعد المتاحة في هذه الرحلة. تم حجزها من قبل مسافر آخر في نفس اللحظة.';

          // Customize message based on specific error
          if (errorMessage.contains('Already booked') ||
              errorMessage.contains('already')) {
            userMessage = 'عذراً، أنت قد حجزت هذه الرحلة بالفعل';
          } else if (errorMessage.contains('not found') ||
              errorMessage.contains('متاحة')) {
            userMessage = 'عذراً، هذه الرحلة لم تعد متاحة';
          } else if (errorMessage.contains('full') ||
              errorMessage.contains('مقاعد')) {
            userMessage = 'عذراً، لا توجد مقاعد متاحة في هذه الرحلة';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userMessage, textDirection: TextDirection.rtl),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
          // Refresh trips
          await _fetchTripsForDate(_selectedDate!);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ أثناء عملية الحجز. يرجى المحاولة مرة أخرى',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendEmailToDriver({
    required String driverEmail,
    required String travelerName,
    required String travelerPhone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer re_XgBBrHtN_LodV3Ksiv911uoVqJJ6gBz44',
        },
        body: jsonEncode({
          'from': 'delivered@resend.dev',
          'to': driverEmail,
          'subject': 'حجز جديد للرحلة',
          'html':
              '''
            <h2>حجز جديد للرحلة</h2>
            <p>لديك حجز جديد من المسافر:</p>
            <ul>
              <li><strong>الاسم:</strong> $travelerName</li>
              <li><strong>رقم الجوال:</strong> $travelerPhone</li>
              <li><strong>التاريخ:</strong> ${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}</li>
              <li><strong>الوقت:</strong> $_selectedTime</li>
            </ul>
          ''',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('فشل إرسال البريد الإلكتروني');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: kBodyColor,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text('بحث عن رحلة', style: TextStyle(color: Colors.white)),
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
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          itemCount:
              1 +
              (_selectedDate != null
                  ? _trips.where((trip) {
                      // Filter logic
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final selectedDateOnly = DateTime(
                        _selectedDate!.year,
                        _selectedDate!.month,
                        _selectedDate!.day,
                      );

                      if (selectedDateOnly == today) {
                        final tripTime = trip['trip_time'] as String;
                        final timeParts = tripTime.split(':');
                        final tripHour = int.parse(timeParts[0]);
                        final tripMinute = int.parse(timeParts[1]);

                        if (tripHour < now.hour ||
                            (tripHour == now.hour && tripMinute < now.minute)) {
                          return false;
                        }
                      }

                      final bookedSeats = trip['booked_seats'] as int? ?? 0;
                      final numPassengers = trip['num_passengers'] as int;
                      if (bookedSeats >= numPassengers) {
                        return false;
                      }

                      return true;
                    }).length
                  : 0) +
              (_isLoadingMore ? 1 : 0) +
              (!_hasMoreTrips && _trips.isNotEmpty ? 1 : 0),
          itemBuilder: (context, index) {
            // Header section with search fields
            if (index == 0) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
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
                            _selectedTime = null;
                            _trips = [];
                            _currentPage = 0;
                            _hasMoreTrips = true;
                          });
                          // Refresh trips if date is already selected
                          if (_selectedDate != null) {
                            _fetchTripsForDate(_selectedDate!);
                          }
                        },
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
                    if (_selectedDate != null)
                      Center(
                        child: SizedBox(
                          width: 200,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: kAppBarColor,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                            onPressed: () => _fetchTripsForDate(_selectedDate!),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.search, size: 18),
                                SizedBox(width: 6),
                                Text('بحث'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (_selectedDate != null) const SizedBox(height: 12),
                    if (_selectedDate != null && _isLoadingTrips)
                      const Center(child: CircularProgressIndicator()),
                    if (_selectedDate != null &&
                        !_isLoadingTrips &&
                        _trips.isEmpty)
                      const Text(
                        'لا توجد رحلات متاحة في هذا التاريخ',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    if (_selectedDate != null &&
                        !_isLoadingTrips &&
                        _trips.isNotEmpty)
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الرحلات المتاحة:',
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            // Trip cards
            if (_selectedDate != null && !_isLoadingTrips) {
              final filteredTrips = _trips.where((trip) {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final selectedDateOnly = DateTime(
                  _selectedDate!.year,
                  _selectedDate!.month,
                  _selectedDate!.day,
                );

                if (selectedDateOnly == today) {
                  final tripTime = trip['trip_time'] as String;
                  final timeParts = tripTime.split(':');
                  final tripHour = int.parse(timeParts[0]);
                  final tripMinute = int.parse(timeParts[1]);

                  if (tripHour < now.hour ||
                      (tripHour == now.hour && tripMinute < now.minute)) {
                    return false;
                  }
                }

                final bookedSeats = trip['booked_seats'] as int? ?? 0;
                final numPassengers = trip['num_passengers'] as int;
                if (bookedSeats >= numPassengers) {
                  return false;
                }

                return true;
              }).toList();

              final tripIndex = index - 1;

              if (tripIndex < filteredTrips.length) {
                final trip = filteredTrips[tripIndex];
                final time = trip['trip_time'];
                final destination = trip['destination'] as String;
                final destinationDescription =
                    trip['destination_description'] as String?;
                final meetingPoint = trip['meeting_point_description'] as String?;
                final numPassengers = trip['num_passengers'] as int;
                final price = (trip['price'] ?? 0).toDouble();
                final driverName = trip['driver_name'] ?? 'سائق';
                final bookedSeats = trip['booked_seats'] as int? ?? 0;
                final isSelected = _selectedTime == time;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TripCard(
                    tripTime: time,
                    destination: destination,
                    destinationDescription: destinationDescription,
                    meetingPoint: meetingPoint,
                    numPassengers: numPassengers,
                    bookedSeats: bookedSeats,
                    price: price,
                    driverName: driverName,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedTime = isSelected ? null : time;
                      });
                    },
                  ),
                );
              }

              // Loading more indicator
              if (_isLoadingMore && tripIndex == filteredTrips.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // No more trips message
              if (!_hasMoreTrips && tripIndex == filteredTrips.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'لا توجد مزيد من الرحلات',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            left: 24,
            right: 24,
          ),
          child: SizedBox(
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
              onPressed: _selectedTime == null
                  ? null
                  : () {
                      _bookTripWithPayment();
                    },
              icon: const Icon(Icons.event_seat),
              label: const Text('احجز الرحلة'),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
}
