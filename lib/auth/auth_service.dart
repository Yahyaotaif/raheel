
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'password_utils.dart';
  import 'package:flutter/foundation.dart';

  // Validate mobile number: must be exactly 10 digits
  void validateMobileNumber(String mobile) {
    final trimmed = mobile.trim();
    final isValid = RegExp(r'^\d{10}$').hasMatch(trimmed);
    if (!isValid) {
      throw Exception('يرجى إدخال رقم الجوال الصحيح المكون من 10 أرقام');
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
    required String username,
    required String userType, // 'driver' or 'traveler'
    required String emailAddress,
    String? carType,
    String? carPlate,
  }) async {
    // Validate non-empty Username and EmailAddress
    if (username.trim().isEmpty) {
      throw Exception('اسم المستخدم مطلوب ولا يمكن أن يكون فارغًا.');
    }
    if (emailAddress.trim().isEmpty) {
      throw Exception('البريد الإلكتروني مطلوب ولا يمكن أن يكون فارغًا.');
    }

    // Check for duplicate Username
    final duplicateUsername = await _supabase
        .from('user')
        .select('id')
        .eq('Username', username)
        .limit(1)
        .maybeSingle();
    if (duplicateUsername != null) {
      throw Exception('اسم المستخدم مستخدم بالفعل من قبل مستخدم آخر.');
    }

    // Check for duplicate MobileNumber
    final duplicateMobile = await _supabase
        .from('user')
        .select('id')
        .eq('MobileNumber', phone)
        .limit(1)
        .maybeSingle();
    if (duplicateMobile != null) {
      throw Exception('رقم الجوال مستخدم بالفعل من قبل مستخدم آخر.');
    }

    // Check for duplicate EmailAddress
    final duplicateEmail = await _supabase
        .from('user')
        .select('id')
        .eq('EmailAddress', emailAddress)
        .limit(1)
        .maybeSingle();
    if (duplicateEmail != null) {
      throw Exception('البريد الإلكتروني مستخدم بالفعل من قبل مستخدم آخر.');
    }

    // Create user in Supabase Auth
    final authResponse = await _supabase.auth.signUp(
      email: emailAddress,
      password: password,
    );
    if (authResponse.user == null) {
      throw Exception('فشل إنشاء المستخدم في نظام المصادقة.');
    }

    // Hash the password before storing in your table
    final hashedPassword = hashPassword(password);
    final userData = {
      'created_at': DateTime.now().toIso8601String(),
      'FirstName': firstName,
      'LastName': lastName,
      'Username': username,
      'MobileNumber': phone,
      'EmailAddress': emailAddress,
      'Password': hashedPassword,
      'CarType': carType,
      'CarPlate': carPlate,
      'user_type': userType,
      'auth_id': authResponse.user!.id,
    };
    userData.removeWhere((key, value) => value == null);
    try {
      final response = await _supabase.from('user').insert(userData).select();
      debugPrint('Supabase insert response:');
      debugPrint(response.toString());
      // If response is empty, treat as failure
      if (response.isEmpty) {
        debugPrint('Insert returned empty list');
        throw Exception('فشل إدراج المستخدم في جدول المستخدمين.');
      }
    } catch (e, stack) {
      debugPrint('Exception in registerUser: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  // Sign up method (basic, for completeness; use registerUser for full registration)
  Future<AuthResponse> signUp(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  // Sign in with email or username
  Future<Map<String, dynamic>?> signInWithEmailOrUsername(String identifier, String password) async {
    debugPrint('Attempting login with identifier: "$identifier"');
    final userQuery = await _supabase
        .from('user')
        .select('id, FirstName, LastName, EmailAddress, Username, MobileNumber, Password, user_type')
        .or('EmailAddress.eq.$identifier,Username.eq.$identifier')
        .maybeSingle();
    debugPrint('Login query result: $userQuery');
    if (userQuery == null) {
      debugPrint('No user found for identifier: "$identifier"');
      throw Exception('البريد الإلكتروني أو اسم المستخدم غير مسجل في النظام');
    }
    final storedHash = userQuery['Password'] as String?;
    if (storedHash == null) {
      throw Exception('لا توجد كلمة مرور مسجلة لهذا الحساب');
    }
    final inputHash = hashPassword(password);
    if (storedHash != inputHash) {
      throw Exception('كلمة المرور التي أدخلتها غير صحيحة');
    }
    // Return user info (without password)
    userQuery.remove('Password');
    return userQuery;
  }

  // No-op sign out for custom auth
  Future<void> signOut() async {}
}
