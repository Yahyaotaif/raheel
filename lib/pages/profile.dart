import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raheel/pages/change_password.dart';
import 'package:raheel/pages/driver_set.dart';
import 'package:raheel/pages/driver_bookings.dart';
import 'package:raheel/pages/traveler_bookings.dart';
import 'package:raheel/pages/login.dart';
import 'package:raheel/pages/traveler_set.dart';
import 'package:raheel/pages/privacy_policy.dart';
import 'package:raheel/theme_constants.dart';
import 'package:raheel/pages/edit_profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raheel/l10n/app_localizations.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>?> _userFuture;
  late Future<String?> _roleFuture;

  /// Retrieves the current user from SharedPreferences session storage.
  Future<Map<String, dynamic>?> getCurrentUserFromCustomSession() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('first_name');
    final lastName = prefs.getString('last_name');
    final email = prefs.getString('email');
    final userType = prefs.getString('user_type');
    if (firstName == null && lastName == null && email == null && userType == null) return null;
    return {
      'FirstName': firstName ?? '',
      'LastName': lastName ?? '',
      'EmailAddress': email ?? '',
      'user_type': userType ?? 'traveler',
    };
  }
  @override
  void initState() {
    super.initState();
    _userFuture = getCurrentUserFromCustomSession();
    _roleFuture = _loadUserRoleForButton();
  }

  Future<String?> _loadUserRoleForButton() async {
    try {
      // Get user info from your custom session logic
      final user = await getCurrentUserFromCustomSession();
      if (user == null) return 'traveler';
      final userType = user['user_type']?.toString().toLowerCase().trim();
      return userType ?? 'traveler';
    } catch (e) {
      return 'traveler';
    }
  }

  Future<void> _sendHelpEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'raheelcorp@outlook.com',
      query: 'subject=طلب مساعدة - Raheel App',
    );
    
    try {
      final canLaunch = await canLaunchUrl(emailUri);
      if (canLaunch) {
        await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Show email address if can't open email app
        if (!mounted) return;
        _showEmailDialog();
      }
    } catch (e) {
      if (!mounted) return;
      _showEmailDialog();
    }
  }

  void _showEmailDialog() {
    const emailAddress = 'raheelcorp@outlook.com';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تواصل معنا',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'يمكنك التواصل معنا عبر البريد الإلكتروني:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const SelectableText(
                      emailAddress,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: emailAddress));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ البريد الإلكتروني'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      tooltip: 'نسخ',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).profile, style: const TextStyle(color: Colors.white)),
          ],
        ),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.black,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kAppBarColor,
                Color.fromARGB(255, 85, 135, 105),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),


      
      body: Container(
        color: kBodyColor,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: _userFuture,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  final first = (data?['FirstName'] ?? '').toString().trim();
                  final last = (data?['LastName'] ?? '').toString().trim();
                  final email = (data?['EmailAddress'] ?? '').toString().trim();
                  final displayName = (first.isNotEmpty || last.isNotEmpty)
                      ? ('$first $last').trim()
                      : AppLocalizations.of(context).profile;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person, size: 36, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.connectionState == ConnectionState.waiting
                                  ? '...'
                                  : displayName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.connectionState == ConnectionState.waiting
                                  ? '...'
                                  : (email.isNotEmpty ? email : 'user@email.com'),
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context).settings,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined, color: Colors.black54),
                      title: Text(
                        AppLocalizations.of(context).privacyPolicy,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: Colors.black54),
                      title: Text(
                        AppLocalizations.of(context).changePassword,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordPage(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.black54),
                      title: Text(
                        AppLocalizations.of(context).editProfile,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: Colors.black54),
                      title: Text(
                        AppLocalizations.of(context).helpAndSupport,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
                      onTap: _sendHelpEmail,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).bookings,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<String?>(
                future: _roleFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data == 'driver') {
                    return _buildActionCard(
                      icon: Icons.calendar_today,
                      title: AppLocalizations.of(context).manageBookings,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DriverBookingsPage(),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              FutureBuilder<String?>(
                future: _roleFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data == 'traveler') {
                    return _buildActionCard(
                      icon: Icons.bookmark,
                      title: AppLocalizations.of(context).myTrips,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TravelerBookingsPage(),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<String?>(
                future: _roleFuture,
                builder: (context, snapshot) {
                  String buttonText = AppLocalizations.of(context).searchTrip;
                  String? userRole = snapshot.data;
                  if (snapshot.connectionState == ConnectionState.done && userRole != null) {
                    if (userRole == 'driver') {
                      buttonText = AppLocalizations.of(context).createTrip;
                    }
                  }
                  return SizedBox(
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
                      onPressed: snapshot.connectionState == ConnectionState.waiting
                          ? null
                          : () {
                              if (userRole == 'driver') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const DriverSetPage(),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const TravelerSetPage(),
                                  ),
                                );
                              }
                            },
                      icon: Icon(userRole == 'driver' ? Icons.add_location : Icons.search),
                      label: Text(buttonText),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
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
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(AppLocalizations.of(context).logout),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}


