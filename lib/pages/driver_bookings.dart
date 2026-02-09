import 'package:flutter/material.dart';
import 'package:raheel/widgets/loading_indicator.dart';
import 'package:raheel/theme_constants.dart';
import 'package:raheel/l10n/app_localizations.dart';
import 'package:raheel/widgets/modern_back_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverBookingsPage extends StatefulWidget {
  const DriverBookingsPage({super.key});

  @override
  State<DriverBookingsPage> createState() => _DriverBookingsPageState();
}

class _DriverBookingsPageState extends State<DriverBookingsPage>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchBookings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchBookings();
    }
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use auth_id from SharedPreferences for driver_id
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getString('auth_id') ?? prefs.getString('user_id');

      if (driverId == null) {
        throw Exception('لم يتم العثور على المستخدم');
      }

      // Fetch trip data
      final tripResponse = await Supabase.instance.client
          .from('trips')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _trips = List<Map<String, dynamic>>.from(tripResponse);
      });

      final response = await Supabase.instance.client
          .from('bookings')
          .select()
          .eq('driver_id', driverId)
          .or('status.is.null,status.neq.completed')
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _bookings = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      final errorMsg = AppLocalizations.of(context).errorLoadingTrips;
      if (!mounted) return;

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTrip(String tripId) async {
    try {
      // First delete all bookings associated with this trip
      await Supabase.instance.client
          .from('bookings')
          .delete()
          .eq('trip_id', tripId);

      // Then delete the trip
      await Supabase.instance.client
          .from('trips')
          .delete()
          .eq('id', tripId);

      // Remove from local list immediately
      setState(() {
        _trips.removeWhere((trip) => trip['id'].toString() == tripId.toString());
        _bookings.removeWhere((booking) => booking['trip_id'].toString() == tripId.toString());
      });

      if (!mounted) return;

      final successMsg = AppLocalizations.of(context).tripDeletedSuccess;
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMsg),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      _fetchBookings();
    } catch (e) {
      if (!mounted) return;

      final errorMsg = AppLocalizations.of(context).error;
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMsg: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteBooking(dynamic bookingId) async {
    try {
      // Mark booking as completed instead of deleting
      await Supabase.instance.client
          .from('bookings')
          .update({'status': 'completed'})
          .eq('id', bookingId);

      // Remove from local list immediately
      setState(() {
        _bookings.removeWhere((booking) => booking['id'] == bookingId);
      });

      if (!mounted) return;

      final travelerDeletedMsg = AppLocalizations.of(context).travelerDeleted;
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(travelerDeletedMsg),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final errorMsg = AppLocalizations.of(context).error;
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMsg: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show phone number as stored in the user table
  String _asStored(String phone) {
    return phone;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: _asStored(phoneNumber));
    final cannotOpenMsg = AppLocalizations.of(context).cannotOpenPhone;
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cannotOpenMsg,
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBodyColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? const ModernBackButton()
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_car, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).manageBookings,
                style: kAppBarTitleStyle,
            ),
          ],
        ),
        elevation: 0,
        centerTitle: true,
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
      body: _isLoading
          ? const Center(child: LoadingIndicator(size: 100))
          : _errorMessage != null
          ? Center(
              child: Text(_errorMessage!, textAlign: TextAlign.center),
            )
          : _bookings.isEmpty && _trips.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context).noTripsOrBookings,
                textDirection: TextDirection.rtl,
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchBookings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _trips.length,
                itemBuilder: (context, index) {
                  final trip = _trips[index];
                  // Get bookings for this specific trip
                  final tripBookings = _bookings.where((booking) => 
                    booking['trip_id'] == trip['id']
                  ).toList();
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.only(top: 20, left: 12, right: 12, bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kAppBarColor.withValues(alpha: 0.5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                    children: [
                      // Trip Card
                      Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kAppBarColor, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        textDirection: TextDirection.rtl,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 28,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                        AppLocalizations.of(context).confirmDeleteTrip,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Text(
                                          AppLocalizations.of(context).deleteThisTrip,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('إلغاء'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.red.shade500,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteTrip(trip['id'].toString());
                                          },
                                          child: Text(AppLocalizations.of(context).deleteTrip),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Text(
                                AppLocalizations.of(context).tripInfoLabel,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kAppBarColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${trip['destination']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppLocalizations.of(context).departingFrom}: ${trip['destination_description'] ?? 'غير محدد'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppLocalizations.of(context).date}: ${trip['trip_date']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppLocalizations.of(context).time}: ${trip['trip_time']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppLocalizations.of(context).availableSeatsLabel}: ${trip['num_passengers']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                            ),
                            // Trip ID Square
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: kAppBarColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    trip['id'].toString().substring(
                                      0,
                                      trip['id'].toString().length > 8 
                                        ? 8 
                                        : trip['id'].toString().length,
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: kAppBarColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    
                    // Bookings for this trip
                    if (tripBookings.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Text(
                              '${AppLocalizations.of(context).bookings} (${tripBookings.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kAppBarColor,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          ...tripBookings.map((booking) {
                              final status = booking['status'] ?? 'pending';
                              final statusColor = status == 'accepted'
                                  ? Colors.green
                      : status == 'rejected'
                      ? Colors.red
                      : Colors.orange;

                  // Check if 24 hours have passed since trip date
                  final tripDate = DateTime.tryParse(
                    booking['trip_date'] as String? ?? '',
                  );
                  final now = DateTime.now();
                  final hasExpired =
                      tripDate != null &&
                      now.difference(tripDate).inHours >= 24;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: status == 'completed'
                          ? Colors.grey.shade200
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: status == 'completed'
                            ? Colors.grey.shade400
                            : Colors.black12,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: hasExpired 
                                ? Colors.green.withAlpha((0.1 * 255).toInt())
                                : statusColor.withAlpha((0.1 * 255).toInt()),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            hasExpired ? '' : AppLocalizations.of(context).newBookingRequest,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: hasExpired ? Colors.green : statusColor,
                            ),
                          ),
                        ),
                        // Traveler Info
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            textDirection: TextDirection.rtl,
                            children: [
                              Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      textDirection: TextDirection.rtl,
                                      children: [
                                        Text(
                                          '${booking['traveler_first_name']} ${booking['traveler_last_name']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.person,
                                    color: kAppBarColor,
                                    size: 24,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (status != 'completed')
                                InkWell(
                                  onTap: () {
                                    final phoneNumber =
                                      '0${booking['traveler_phone'].toString()}';
                                    _makePhoneCall(phoneNumber);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      textDirection: TextDirection.rtl,
                                      children: [
                                        Text(
                                          '0${booking['traveler_phone'] ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: kAppBarColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.phone,
                                          color: kAppBarColor,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              // Trip Details
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).tripDetailsLabel,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${AppLocalizations.of(context).date}: ${booking['trip_date']}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                textDirection: TextDirection.rtl,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: status == 'completed'
                                          ? Colors.grey
                                          : kAppBarColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: status == 'completed'
                                        ? null
                                        : () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text(
                                                  AppLocalizations.of(context).confirmDelete,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: Directionality(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  child: Text(
                                                    AppLocalizations.of(context).deleteTraveler,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                actionsAlignment:
                                                    MainAxisAlignment.center,
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('لا'),
                                                  ),
                                                  ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors
                                                                  .red
                                                                  .shade500,
                                                          foregroundColor:
                                                              Colors.white,
                                                        ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      _deleteBooking(
                                                        booking['id'],
                                                      );
                                                    },
                                                    child: const Text('نعم'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                    child: Text(AppLocalizations.of(context).contactDone),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                        ],
                      ),
                    ],
                    ),
                  );
                },
              ),
            ),
          );
  }
}
