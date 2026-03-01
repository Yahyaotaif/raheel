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
import 'package:raheel/widgets/modern_back_button.dart';
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
  bool _isSettingsExpanded = false;

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
        backgroundColor: const Color(0xFFE3F2FD), // Light blue
        title: Text(
          'تواصل معنا',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Noto Naskh Arabic'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'يمكنك مراسلتنا على',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Noto Naskh Arabic',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      emailAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () async {
                      await Clipboard.setData(
                        const ClipboardData(text: emailAddress),
                      );
                      if (!context.mounted) return;
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
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'واتساب:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Noto Naskh Arabic',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: InkWell(
                      onTap: () async {
                        final whatsappNumber = '+966546388404';
                        final whatsappUrl = Uri.parse('https://wa.me/${whatsappNumber.replaceAll('+', '')}');
                        if (await canLaunchUrl(whatsappUrl)) {
                          await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Text(
                        '+966546388404',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Noto Naskh Arabic',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildBookingsActionTile({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? const ModernBackButton()
            : null,
        title: FutureBuilder<Map<String, dynamic>?>(
          future: _userFuture,
          builder: (context, snapshot) {
            final data = snapshot.data;
            final first = (data?['FirstName'] ?? '').toString().trim();
            final last = (data?['LastName'] ?? '').toString().trim();
            final email = (data?['EmailAddress'] ?? '').toString().trim();
            final displayName = (first.isNotEmpty || last.isNotEmpty)
                ? ('$first $last').trim()
                : AppLocalizations.of(context).profile;

            return Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, size: 28, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.connectionState == ConnectionState.waiting
                            ? '...'
                            : displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.connectionState == ConnectionState.waiting
                            ? '...'
                            : (email.isNotEmpty ? email : 'user@email.com'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        toolbarHeight: 96,
        centerTitle: false,
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
            children: [
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
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isSettingsExpanded = !_isSettingsExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.settings, color: Colors.black54),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context).settings,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _isSettingsExpanded ? 0.25 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black38,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _isSettingsExpanded
                          ? Column(
                              children: [
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
                                const Divider(height: 1, color: Colors.black12),
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
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<String?>(
                future: _roleFuture,
                builder: (context, snapshot) {
                  String? userRole = snapshot.data;
                  String createButtonText = AppLocalizations.of(context).searchTrip;
                  if (snapshot.connectionState == ConnectionState.done && userRole == 'driver') {
                    createButtonText = AppLocalizations.of(context).createTrip;
                  }
                  
                  return Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.bookmark, color: Colors.black54),
                              const SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(context).bookings,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (snapshot.connectionState == ConnectionState.done && userRole == 'driver') ...[
                          const Divider(height: 1, color: Colors.black12),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: _buildBookingsActionTile(
                                      label: AppLocalizations.of(context).createTrip,
                                      icon: Icons.add_location,
                                      color: Colors.green.shade700,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const DriverSetPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: _buildBookingsActionTile(
                                      label: AppLocalizations.of(context).manageBookings,
                                      icon: Icons.calendar_today,
                                      color: Colors.teal.shade700,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const DriverBookingsPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (snapshot.connectionState == ConnectionState.done && userRole == 'traveler') ...[
                          const Divider(height: 1, color: Colors.black12),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: _buildBookingsActionTile(
                                      label: AppLocalizations.of(context).searchTrip,
                                      icon: Icons.search,
                                      color: Colors.green.shade700,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const TravelerSetPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: _buildBookingsActionTile(
                                      label: AppLocalizations.of(context).myTrips,
                                      icon: Icons.bookmark,
                                      color: Colors.teal.shade700,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const TravelerBookingsPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (snapshot.connectionState != ConnectionState.done || (userRole != 'driver' && userRole != 'traveler')) ...[
                          const Divider(height: 1, color: Colors.black12),
                          ListTile(
                            leading: Icon(
                              userRole == 'driver' ? Icons.add_location : Icons.search,
                              color: Colors.black54,
                            ),
                            title: Text(
                              createButtonText,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
                            onTap: snapshot.connectionState == ConnectionState.waiting
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
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(
          top: 24.0,
          left: 24.0,
          right: 24.0,
          bottom: 24.0 + MediaQuery.of(context).viewPadding.bottom,
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
      ),
    ],
  ),
      ),
    );
  }
}
