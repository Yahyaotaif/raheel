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
import 'edit_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<String?> _loadUserRoleForButton() async {
    try {
      final authUser = await Supabase.instance.client.auth.getUser();
      final userId = authUser.user?.id;
      if (userId == null) return 'traveler';
      
      final response = await Supabase.instance.client
          .from('user')
          .select('user_type')
          .eq('id', userId)
          .single();
      
      final userType = response['user_type']?.toString().toLowerCase().trim();
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
          children: const [
            Icon(Icons.person, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text('الملف الشخصي', style: TextStyle(color: Colors.white)),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User info container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Image placeholder
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
                    // User info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder(
                          future: () async {
                            final authUser = await Supabase.instance.client.auth.getUser();
                            final userId = authUser.user?.id;
                            if (userId == null) return null;
                            final response = await Supabase.instance.client
                                .from('user')
                                .select('FirstName, LastName')
                                .eq('id', userId)
                                .single();
                            return response;
                          }(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text('...');
                            }
                            if (snapshot.hasError || snapshot.data == null) {
                              return const Text(
                                'اسم المستخدم',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              );
                            }
                            final data = snapshot.data as Map?;
                            final first = (data?['FirstName'] ?? '').toString().trim();
                            final last = (data?['LastName'] ?? '').toString().trim();
                            final displayName = (first.isNotEmpty || last.isNotEmpty)
                                ? ('$first $last').trim()
                                : 'اسم المستخدم';
                            return Text(
                              displayName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder(
                          future: Supabase.instance.client.auth.getUser(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text('...');
                            }
                            if (snapshot.hasError || snapshot.data?.user == null) {
                              return const Text(
                                'user@email.com',
                                style: TextStyle(fontSize: 16, color: Colors.black54),
                              );
                            }
                            final user = snapshot.data!.user;
                            return Text(
                              user?.email ?? 'user@email.com',
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Settings buttons container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Change password
                    // Privacy Policy
                    InkWell(
                      borderRadius: BorderRadius.circular(0),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: const [
                            Icon(Icons.privacy_tip_outlined, color: Colors.black54),
                            SizedBox(width: 12),
                            Text(
                              'سياسة الخصوصية',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    // Help center
                    InkWell(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordPage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: const [
                            Icon(Icons.lock_outline, color: Colors.black54),
                            SizedBox(width: 12),
                            Text(
                              'تغيير كلمة المرور',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    // Edit profile
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: const [
                            Icon(Icons.edit, color: Colors.black54),
                            SizedBox(width: 12),
                            Text(
                              'تعديل ملفك',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    // Help and support
                    InkWell(
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                      onTap: _sendHelpEmail,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: const [
                            Icon(Icons.help_outline, color: Colors.black54),
                            SizedBox(width: 12),
                            Text(
                              'المساعدة والدعم',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16, width: 300),
              
              // Manage bookings container - only for drivers
              FutureBuilder<String?>(
                future: _loadUserRoleForButton(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && 
                      snapshot.data == 'driver') {
                    return SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DriverBookingsPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.calendar_today, color: Colors.black54),
                              SizedBox(width: 12),
                              Text(
                                'إدارة الحجوزات',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16, width: 300),
              
              // Manage traveler bookings container - only for travelers
              FutureBuilder<String?>(
                future: _loadUserRoleForButton(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && 
                      snapshot.data == 'traveler') {
                    return SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TravelerBookingsPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.bookmark, color: Colors.black54),
                              SizedBox(width: 12),
                              Text(
                                'إدارة حجوزاتك',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              Icon(Icons.arrow_forward_ios, color: Colors.black38, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            // ...existing containers...
              Spacer(),
              FutureBuilder<String?>(
                future: _loadUserRoleForButton(),
                builder: (context, snapshot) {
                  String buttonText = 'بحث عن رحلة';
                  String? userRole = snapshot.data;
                  
                  if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                    buttonText = userRole == 'driver' ? 'إنشاء رحلة' : 'بحث عن رحلة';
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
                  label: const Text('خروج'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


