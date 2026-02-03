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
import 'package:provider/provider.dart';
import 'package:raheel/providers/language_provider.dart';
import 'package:raheel/l10n/app_localizations.dart';
// Custom Logo Widget
class RaheelLogo extends StatelessWidget {
  const RaheelLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
    final subject =
        '${AppLocalizations.of(context).requestHelp} - ${AppLocalizations.of(context).appTitle}';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'raheelcorp@outlook.com',
      queryParameters: {
        'subject': subject,
      },
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
        title: Text(
          AppLocalizations.of(context).contactUs,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Noto Naskh Arabic'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).emailUsAt,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Noto Naskh Arabic', fontSize: 16),
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
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).emailCopied,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'Noto Naskh Arabic'),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    tooltip: AppLocalizations.of(context).copyEmail,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context).ok,
              style: const TextStyle(fontFamily: 'Noto Naskh Arabic'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).enterEmailOrUsername;
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
        // Store auth_id (UUID from Supabase Auth) for use as driver_id/traveler_id
        if (user['auth_id'] != null) {
          await prefs.setString('auth_id', user['auth_id']);
          await prefs.setString('user_id', user['auth_id']);
        }
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = AppLocalizations.of(context).loginFailed;
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
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        backgroundColor: Colors.transparent,
        actions: [
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: TextButton.icon(
                  onPressed: () {
                    languageProvider.toggleLanguage();
                  },
                  icon: Icon(
                    languageProvider.languageCode == 'ar'
                        ? Icons.language
                        : Icons.language_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: Text(
                    AppLocalizations.of(context).language,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                ),
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kAppBarColor.withValues(alpha: 0.95),
                Color.fromARGB(255, 85, 135, 105).withValues(alpha: 0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kBodyColor.withValues(alpha: 0.98),
              Color.fromARGB(255, 240, 245, 242),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Image.asset(
                            'assets/logo.png',
                            width: MediaQuery.of(context).size.width - 10,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 0),
                        // Email/Username Field
                        _buildStyleTextField(
                          controller: _identifierController,
                          label: AppLocalizations.of(context).emailOrUsername,
                          hint: AppLocalizations.of(context).enterEmailOrUsername,
                          icon: Icons.person_outline,
                          width: 340,
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        _buildStyleTextField(
                          controller: _passwordController,
                          label: AppLocalizations.of(context).password,
                          hint: '',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          width: 340,
                        ),
                        const SizedBox(height: 28),
                        // Error Message
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Noto Naskh Arabic',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        // Login Button
                        SizedBox(
                          width: 320,
                          height: 52,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: kAppBarColor.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: kAppBarColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.login_outlined, size: 22),
                                        const SizedBox(width: 10),
                                        Text(
                                          AppLocalizations.of(context).login,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.grey[300]!,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(
                                'أو',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.grey[300]!,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Register Button
                        Container(
                          width: 320,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: kAppBarColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RegistrationPage(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_add_outlined,
                                  size: 20,
                                  color: kAppBarColor,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${AppLocalizations.of(context).dontHaveAccount} ${AppLocalizations.of(context).registerNow}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: kAppBarColor,
                                    fontFamily: 'Noto Naskh Arabic',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Bottom Help Buttons
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Builder(
                    builder: (BuildContext builderContext) {
                      return TextButton.icon(
                        onPressed: () {
                          Navigator.of(builderContext).push(
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.help_outline,
                          size: 20,
                          color: kAppBarColor,
                        ),
                        label: Text(
                          AppLocalizations.of(builderContext).forgotPassword,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kAppBarColor,
                            fontFamily: 'Noto Naskh Arabic',
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey[300],
                  ),
                  TextButton.icon(
                    onPressed: _sendHelpEmail,
                    icon: Icon(
                      Icons.support_agent_outlined,
                      size: 20,
                      color: kAppBarColor,
                    ),
                    label: Text(
                      AppLocalizations.of(context).requestHelp,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kAppBarColor,
                        fontFamily: 'Noto Naskh Arabic',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: kAppBarColor,
              size: 22,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: kAppBarColor,
                width: 2,
              ),
            ),
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontFamily: 'Noto Naskh Arabic',
            ),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontFamily: 'Noto Naskh Arabic',
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
