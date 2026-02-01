import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raheel/pages/forgot_password.dart';
import 'package:raheel/pages/registration.dart';
import 'package:raheel/theme_constants.dart';
import 'package:raheel/pages/profile.dart';
import 'package:raheel/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// Custom Logo Widget
class RaheelLogo extends StatelessWidget {
  const RaheelLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'توكلنا على الله',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'QTSHoby',
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    Future<void> _cleanupOldTripsStartup() async {
      try {
        await Supabase.instance.client.rpc('cleanup_old_trips');
      } catch (e) {
        debugPrint('Startup cleanup failed: $e');
      }
    }
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
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
          style: TextStyle(fontFamily: 'Noto Naskh Arabic'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'يمكنك مراسلتنا على',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Noto Naskh Arabic', fontSize: 16),
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
                  const Flexible(
                    child: Text(
                      emailAddress,
                      style: TextStyle(
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
                      await Clipboard.setData(const ClipboardData(text: emailAddress));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم نسخ البريد الإلكتروني',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Noto Naskh Arabic'),
                          ),
                          duration: Duration(seconds: 2),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً', style: TextStyle(fontFamily: 'Noto Naskh Arabic')),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      setState(() {
        _errorMessage = 'يرجى إدخال البريد الإلكتروني أو اسم المستخدم';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    bool shouldSetLoadingFalse = true;
    try {
      final user = await _authService.signInWithEmailOrUsername(
        identifier,
        _passwordController.text.trim(),
      );
      if (!mounted) {
        shouldSetLoadingFalse = false;
        return;
      }
      if (user != null) {
        // Run cleanup only after successful login
        await _cleanupOldTripsStartup();
        if (!mounted) return;
        // Save user info to SharedPreferences for ProfilePage role logic
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('first_name', user['FirstName'] ?? '');
        await prefs.setString('last_name', user['LastName'] ?? '');
        await prefs.setString('email', user['EmailAddress'] ?? '');
        await prefs.setString('username', user['Username'] ?? '');
        await prefs.setString('user_type', user['user_type'] ?? 'traveler');
        // Store user.id (UUID from user table) for use as driver_id
        if (user['id'] != null) {
          await prefs.setString('user_id', user['id']);
        }
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'فشل تسجيل الدخول. تحقق من البريد الإلكتروني أو اسم المستخدم وكلمة المرور.';
        });
      }
    } catch (e, stack) {
      if (mounted) {
        String errorMessage = 'حدث خطأ غير متوقع.';
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('البريد الإلكتروني أو اسم المستخدم غير مسجل')) {
          errorMessage = 'البريد الإلكتروني أو اسم المستخدم غير صحيح.';
        } else if (errorString.contains('كلمة المرور التي أدخلتها غير صحيحة') || errorString.contains('كلمة المرور غير صحيحة')) {
          errorMessage = 'كلمة المرور غير صحيحة.';
        } else if (errorString.contains('رقم الجوال غير مسجل')) {
          errorMessage = 'رقم الجوال غير مسجل.';
        } else if (errorString.contains('لا توجد كلمة مرور مسجلة')) {
          errorMessage = 'لا توجد كلمة مرور مسجلة لهذا الحساب.';
        } else if (errorString.contains('socketexception') || 
            errorString.contains('failed host lookup') ||
            errorString.contains('network') ||
            errorString.contains('no address associated')) {
          errorMessage = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى';
        } else if (errorString.contains('timeout')) {
          errorMessage = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
        }
        debugPrint('Login error: \\${e.toString()}');
        debugPrint('Stack trace: $stack');
        setState(() {
          _errorMessage = errorMessage;
        });
      } else {
        shouldSetLoadingFalse = false;
      }
    } finally {
      if (mounted && shouldSetLoadingFalse) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBodyColor,
      appBar: AppBar(
        title: const RaheelLogo(),
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Image.asset(
                          'assets/logo.png',
                          width: MediaQuery.of(context).size.width - 8, // Increased width
                          height: 220, // Slightly increased height for better aspect
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        width: 340,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: _identifierController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                              labelText: 'البريد الإلكتروني أو اسم المستخدم',
                              hintText: 'example@email.com أو اسم المستخدم',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                      SizedBox(
                        width: 340,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                              labelText: 'كلمة المرور',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            obscureText: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_errorMessage != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      SizedBox(
                        width: 320,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: kAppBarColor,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.login, size: 20),
                                    SizedBox(width: 8),
                                    Text('الدخول'),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegistrationPage(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.person_add,
                              size: 18,
                              color: Color.fromARGB(255, 119, 135, 149),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'التسجيل كمستخدم جديد',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Noto Naskh Arabic',
                                color: Color.fromARGB(255, 119, 135, 149),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Builder(
                  builder: (BuildContext builderContext) {
                    return TextButton(
                      onPressed: () {
                        Navigator.of(builderContext).push(
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.help_outline,
                            size: 18,
                            color: Color.fromARGB(255, 119, 135, 149),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'نسيت اسم المستخدم أو كلمة المرور؟',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Noto Naskh Arabic',
                              color: Color.fromARGB(255, 119, 135, 149),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                TextButton(
                  onPressed: _sendHelpEmail,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.support_agent,
                        size: 18,
                        color: Color.fromARGB(255, 119, 135, 149),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'طلب المساعدة',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Noto Naskh Arabic',
                          color: Color.fromARGB(255, 119, 135, 149),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
