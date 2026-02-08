import 'package:flutter/material.dart';
import 'package:raheel/widgets/loading_indicator.dart';
import 'package:raheel/theme_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:raheel/l10n/app_localizations.dart';
import 'package:raheel/widgets/modern_back_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: kAppBarColor) : null,
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black12.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black12.withValues(alpha: 0.5)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: kAppBarColor, width: 1.6),
        ),
      ),
    );
  }

  Future<void> _sendResetEmail() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      setState(() {
        _message = l10n.pleaseEnterEmail;
        _isSuccess = false;
      });
      return;
    }

    // Validate email format: must contain '@' and '.'
    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _message = l10n.pleaseEnterValidEmail;
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // For Android, we use the direct deep link
      // Supabase will redirect through their verification URL first, 
      // then to this deep link
      final redirectUrl = 'com.raheelcorp.raheel://reset-password';

      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
      setState(() {
        _isLoading = false;
        _message = l10n.resetLinkSent;
        _isSuccess = true;
        _emailController.clear();
      });
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.statusCode == '429' || e.message.contains('rate_limit')) {
          _message = l10n.rateLimitError;
        } else {
          _message = '${l10n.error}: ${e.message}';
        }
        _isSuccess = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = '${l10n.error}: ${e.toString()}';
        _isSuccess = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            const Icon(Icons.mail_outline, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(l10n.recoverPassword, style: const TextStyle(color: Colors.white)),
          ],
        ),
        elevation: 0,
        centerTitle: true,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.transparent, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  l10n.enterEmailToRecover,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: l10n.emailAddress,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _isSuccess ? Colors.green : Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: _isLoading ? null : _sendResetEmail,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: LoadingIndicator(size: 24),
                          )
                        : Text(l10n.send),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}