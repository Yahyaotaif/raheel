
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'password_utils.dart';

  // Validate mobile number: must be exactly 10 digits
  void validateMobileNumber(String mobile) {
    final trimmed = mobile.trim();
    final isValid = RegExp(r'^\d{10}$').hasMatch(trimmed);
    if (!isValid) {
      throw Exception('يرجى إدخال الرقم الصحيح المكون من 10 ارقام');
    }
  }

class AuthService {
  // Access the Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;
  // Register user: sign up and insert extra info into user table
  Future<void> registerUser({
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    required String userType, // 'driver' or 'traveler'
    String? carType,
    String? carPlate,
  }) async {
    // Hash the password before storing
    final hashedPassword = hashPassword(password);
    final userData = {
      'created_at': DateTime.now().toIso8601String(),
      'FirstName': firstName,
      'LastName': lastName,
      'MobileNumber': phone,
      'Password': hashedPassword,
      'CarType': carType,
      'CarPlate': carPlate,
      'user_type': userType,
    };
    userData.removeWhere((key, value) => value == null);
    await _supabase.from('user').insert(userData);
  }

  // Sign up method (basic, for completeness; use registerUser for full registration)
  Future<AuthResponse> signUp(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  // Sign in with mobile number
  Future<Map<String, dynamic>?> signIn(String mobile, String password) async {
    // Validate mobile number before lookup
    // Look up user by mobile number
    final userQuery = await _supabase
        .from('user')
        .select('id, FirstName, LastName, MobileNumber, Password, user_type')
        .eq('MobileNumber', mobile)
        .maybeSingle();
    if (userQuery == null) {
      throw Exception('رقم الجوال غير مسجل');
    }
    final storedHash = userQuery['Password'] as String?;
    if (storedHash == null) {
      throw Exception('لا يوجد كلمة مرور مسجلة لهذا الرقم');
    }
    final inputHash = hashPassword(password);
    if (storedHash != inputHash) {
      throw Exception('كلمة المرور غير صحيحة');
    }
    // Return user info (without password)
    userQuery.remove('Password');
    return userQuery;
  }

  // No-op sign out for custom auth
  Future<void> signOut() async {}
}
