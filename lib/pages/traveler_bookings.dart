import 'package:flutter/material.dart';
import 'package:raheel/theme_constants.dart';
import 'package:raheel/l10n/app_localizations.dart';
import 'package:raheel/widgets/modern_back_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelerBookingsPage extends StatefulWidget {
  const TravelerBookingsPage({super.key});

  @override
  State<TravelerBookingsPage> createState() => _TravelerBookingsPageState();
}

class _TravelerBookingsPageState extends State<TravelerBookingsPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _bookings = [];
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
      // Use auth_id from SharedPreferences for traveler_id
      final prefs = await SharedPreferences.getInstance();
      final travelerId = prefs.getString('auth_id') ?? prefs.getString('user_id');

      if (travelerId == null) {
        if (!mounted) return;
        throw Exception(AppLocalizations.of(context).userNotFound);
      }

      // Fetch bookings for the current traveler
      final response = await Supabase.instance.client
          .from('bookings')
          .select()
          .eq('traveler_id', travelerId)
          .or('status.is.null,status.neq.completed')
          .order('created_at', ascending: false);

      if (!mounted) return;

      // Fetch driver information for each booking
      List<Map<String, dynamic>> enrichedBookings = [];
      for (var booking in response) {
        try {
            final driverResponse = await Supabase.instance.client
              .from('user')
              .select('FirstName, LastName, MobileNumber')
              .eq('auth_id', booking['driver_id'])
              .single();

          enrichedBookings.add({
            ...booking,
            'driver': driverResponse,
          });
        } catch (e) {
          // If driver not found, still add the booking
          enrichedBookings.add({
            ...booking,
            'driver': null,
          });
        }
      }

      setState(() {
        _bookings = enrichedBookings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).travelerDeleted),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Get error message inside mounted check
      final errorMsg = AppLocalizations.of(context).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMsg: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).cannotOpenPhone),
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
            const Icon(Icons.event, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).bookings, style: const TextStyle(color: Colors.white)),
          ],
        ),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kAppBarColor,
                const Color.fromARGB(255, 85, 135, 105),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                )
              : _bookings.isEmpty
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
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          final driver = booking['driver'];
                          final status = booking['status'] ?? 'pending';

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                textDirection: TextDirection.rtl,
                                children: [
                                  // Driver Information
                                  if (driver != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: kAppBarColor, width: 2),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        textDirection: TextDirection.rtl,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context).driverInfo,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            textDirection: TextDirection.rtl,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${driver['FirstName'] ?? ''} ${driver['LastName'] ?? ''}',
                                                  textDirection: TextDirection.rtl,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Icon(Icons.person,
                                                  size: 24, color: Colors.black54),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          InkWell(
                                            onTap: () {
                                              final phoneNumber = driver['MobileNumber']?.toString() ?? '';
                                              if (phoneNumber.isNotEmpty) {
                                                _makePhoneCall(phoneNumber);
                                              }
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
                                                    driver['MobileNumber']?.toString() ?? '',
                                                    textDirection: TextDirection.rtl,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: kAppBarColor,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Icon(Icons.phone,
                                                      size: 24, color: kAppBarColor),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      AppLocalizations.of(context).driverInfoNotAvailable,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
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
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: Text(
                                                      AppLocalizations.of(context).confirmDelete,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: Directionality(
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      child: Text(
                                                        AppLocalizations.of(context).deleteDriver,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    actionsAlignment:
                                                        MainAxisAlignment.center,
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: Text(AppLocalizations.of(context).no),
                                                      ),
                                                      ElevatedButton(
                                                        style:
                                                            ElevatedButton
                                                                .styleFrom(
                                                          backgroundColor:
                                                              Colors.red
                                                                  .shade500,
                                                          foregroundColor:
                                                              Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          _deleteBooking(
                                                              booking['id']);
                                                        },
                                                        child: Text(AppLocalizations.of(context).yes),
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
                          );
                        },
                      ),
                    ),
    );
  }
}