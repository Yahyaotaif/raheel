import 'package:flutter/material.dart';
import 'package:raheel/widgets/button_loading_indicator.dart';
import 'package:raheel/theme_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:raheel/widgets/modern_back_button.dart';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  /// Retrieves the current user from SharedPreferences session storage.
  Future<Map<String, dynamic>?> getCurrentUserFromCustomSession() async {
    final prefs = await SharedPreferences.getInstance();
    final authId = prefs.getString('auth_id') ?? prefs.getString('user_id') ?? prefs.getInt('user_id')?.toString();
    final firstName = prefs.getString('first_name');
    final lastName = prefs.getString('last_name');
    final email = prefs.getString('email');
    final mobile = prefs.getString('mobile');
    final userType = prefs.getString('user_type');
    if (authId == null) return null;
    return {
      'auth_id': authId,
      'FirstName': firstName ?? '',
      'LastName': lastName ?? '',
      'EmailAddress': email ?? '',
      'MobileNumber': mobile ?? '',
      'user_type': userType ?? 'traveler',
    };
  }
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await getCurrentUserFromCustomSession();
    if (user == null) return;
    _firstNameController.text = user['FirstName'] ?? '';
    _lastNameController.text = user['LastName'] ?? '';
    final mobileNumber = user['MobileNumber'];
    _mobileController.text = mobileNumber != null ? mobileNumber.toString() : '';
    setState(() {});
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = await getCurrentUserFromCustomSession();
      final authId = user?['auth_id'];
      if (authId == null) {
        setState(() {
          _errorMessage = 'لم يتم العثور على المستخدم.';
          _isLoading = false;
        });
        return;
      }
      final mobileText = _mobileController.text.trim();
      if (mobileText.isNotEmpty) {
        // Validate Saudi local format: 05XXXXXXXX or 7XXXXXXXX
        if (!RegExp(r'^05\d{8}$').hasMatch(mobileText) && !RegExp(r'^7\d{8}$').hasMatch(mobileText)) {
          setState(() {
            _errorMessage = 'رقم الجوال يجب أن يبدأ بـ 05 ويتكون من 10 أرقام أو يبدأ بـ 7 ويتكون من 9 أرقام';
            _isLoading = false;
          });
          return;
        }
      }
      
      // Update Supabase database
      final supabase = Supabase.instance.client;
      await supabase
          .from('user')
          .update({
            'FirstName': _firstNameController.text.trim(),
            'LastName': _lastNameController.text.trim(),
            'MobileNumber': mobileText,
          })
          .eq('auth_id', authId);
      
      // Update user data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('first_name', _firstNameController.text.trim());
      await prefs.setString('last_name', _lastNameController.text.trim());
      await prefs.setString('mobile', mobileText);
      
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الملف الشخصي بنجاح', textAlign: TextAlign.center),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحديث الملف الشخصي.';
        _isLoading = false;
      });
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
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
          children: const [
            Icon(Icons.edit, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text('تعديل الملف الشخصي', style: kAppBarTitleStyle),
          ],
        ),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
        centerTitle: true,
        elevation: 0,
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
          padding: EdgeInsets.fromLTRB(
            24.0,
            32.0,
            24.0,
            24.0 + MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Form(
            key: _formKey,
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
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextFormField(
                    controller: _firstNameController,
                    label: 'الاسم الأول',
                    icon: Icons.person_outline,
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'يرجى إدخال الاسم الأول' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _lastNameController,
                    label: 'اسم العائلة',
                    icon: Icons.person_outline,
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? 'يرجى إدخال اسم العائلة' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _mobileController,
                    label: 'رقم الجوال',
                    icon: Icons.phone_iphone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال رقم الجوال';
                      }
                      if (!RegExp(r'^05\d{8}$').hasMatch(value.trim()) && !RegExp(r'^7\d{8}$').hasMatch(value.trim())) {
                        return 'رقم الجوال يجب أن يبدأ بـ 05 ويتكون من 10 أرقام أو يبدأ بـ 7 ويتكون من 9 أرقام';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(
                    width: 320,
                    height: 48,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                        backgroundColor: WidgetStateProperty.resolveWith((states) {
                          return kAppBarColor;
                        }),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 18)),
                        elevation: WidgetStateProperty.all(4),
                      ),
                      onPressed: _isLoading ? null : _saveProfile,
                      child: _isLoading
                          ? const SizedBox(
                              width: 100,
                              height: 100,
                              child: ButtonLoadingIndicator(),
                            )
                          : const Text('حفظ'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}