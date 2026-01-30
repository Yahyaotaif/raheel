import 'package:flutter/material.dart';
import 'package:raheel/theme_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordHandler extends StatefulWidget {
  const ResetPasswordHandler({super.key});

  @override
  State<ResetPasswordHandler> createState() => _ResetPasswordHandlerState();
}

class _ResetPasswordHandlerState extends State<ResetPasswordHandler> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _initializePasswordReset();
  }

  Future<void> _initializePasswordReset() async {
    try {
      // Get arguments from navigation (access token from deep link)
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _accessToken = args?['access_token'] as String?;
      final tokenType = args?['type'] as String?;

      // Check if we have a recovery token from deep link
      if (_accessToken != null && tokenType == 'recovery') {
        setState(() {
          _isInitialized = true;
        });
        return;
      }

      // Fallback: Check if user is already authenticated (for web-based reset)
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session == null) {
        setState(() {
          _errorMessage = 'جلسة غير صالحة. يرجى محاولة طلب استعادة كلمة المرور مرة أخرى.';
          _isInitialized = true;
        });
        return;
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: ${e.toString()}';
        _isInitialized = true;
      });
    }
  }

  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'يرجى ملء جميع الحقول';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'كلمات المرور غير متطابقة';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _errorMessage = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // If we have a recovery token from deep link, use Supabase REST API
      if (_accessToken != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: newPassword),
        );
      } else {
        // Use regular session-based update
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: newPassword),
        );
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير كلمة المرور بنجاح!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate back to login after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'خطأ: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: kBodyColor,
        appBar: AppBar(
          title: const Text('استعادة كلمة المرور'),
          backgroundColor: kAppBarColor,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null && _errorMessage!.contains('جلسة غير صالحة')) {
      return Scaffold(
        backgroundColor: kBodyColor,
        appBar: AppBar(
          title: const Text('استعادة كلمة المرور'),
          backgroundColor: kAppBarColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppBarColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('العودة إلى تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBodyColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.lock, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text('كلمة مرور جديدة', style: TextStyle(color: Colors.white)),
          ],
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'أدخل كلمة مرور جديدة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'كلمة المرور الجديدة',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppBarColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _resetPassword,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('تحديث كلمة المرور'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
