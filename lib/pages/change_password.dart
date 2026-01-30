import 'package:flutter/material.dart';
import 'package:raheel/theme_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final newPasswordController = TextEditingController();
    final repeatPasswordController = TextEditingController();
    return Scaffold(
      backgroundColor: kBodyColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.lock, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text('تغيير كلمة المرور', style: TextStyle(color: Colors.white)),
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
        child: _ChangePasswordForm(
          newPasswordController: newPasswordController,
          repeatPasswordController: repeatPasswordController,
        ),
      ),
    );
  }
}

class _ChangePasswordForm extends StatefulWidget {
  final TextEditingController newPasswordController;
  final TextEditingController repeatPasswordController;

  const _ChangePasswordForm({
    required this.newPasswordController,
    required this.repeatPasswordController,
  });

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  String? errorMessage;
  bool isLoading = false;

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: kAppBarColor),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            _buildPasswordField(
              controller: widget.newPasswordController,
              label: 'كلمة المرور الجديدة',
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: widget.repeatPasswordController,
              label: 'إعادة كلمة المرور الجديدة',
            ),
            const SizedBox(height: 24),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  errorMessage ?? '',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
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
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        final newPassword = widget.newPasswordController.text.trim();
                        final repeatPassword = widget.repeatPasswordController.text.trim();
                        if (newPassword.isEmpty || repeatPassword.isEmpty) {
                          setState(() {
                            errorMessage = 'يرجى إدخال كلمة المرور الجديدة في كلا الحقلين';
                            isLoading = false;
                          });
                          return;
                        }
                        if (newPassword != repeatPassword) {
                          setState(() {
                            errorMessage = 'كلمتا المرور غير متطابقتين';
                            isLoading = false;
                          });
                          return;
                        }
                        try {
                          final authUser = await Supabase.instance.client.auth.getUser();
                          final userId = authUser.user?.id;
                          if (userId == null) {
                            setState(() {
                              errorMessage = 'لم يتم العثور على المستخدم.';
                              isLoading = false;
                            });
                            return;
                          }
                          // Update password in Supabase Auth
                          final updateResponse = await Supabase.instance.client.auth.updateUser(
                            UserAttributes(password: newPassword),
                          );
                          if (updateResponse.user == null) {
                            setState(() {
                              errorMessage = 'حدث خطأ أثناء تغيير كلمة المرور.';
                              isLoading = false;
                            });
                            return;
                          }
                          // Optionally update your user table as well
                          await Supabase.instance.client
                              .from('user')
                              .update({'Password': newPassword, 'Password2': newPassword})
                              .eq('id', userId)
                              .select();
                          setState(() {
                            isLoading = false;
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم تغيير كلمة المرور بنجاح', textAlign: TextAlign.center),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          setState(() {
                            errorMessage = 'حدث خطأ غير متوقع.';
                            isLoading = false;
                          });
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
