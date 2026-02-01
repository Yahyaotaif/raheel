
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
      .select('auth_id')
        .eq('Username', username)
        .limit(1)
        .maybeSingle();
    if (duplicateUsername != null) {
      throw Exception('اسم المستخدم مستخدم بالفعل من قبل مستخدم آخر.');
    }

    // Check for duplicate MobileNumber
    final duplicateMobile = await _supabase
      .from('user')
      .select('auth_id')
        .eq('MobileNumber', phone)
        .limit(1)
        .maybeSingle();
    if (duplicateMobile != null) {
      throw Exception('رقم الجوال مستخدم بالفعل من قبل مستخدم آخر.');
    }

    // Check for duplicate EmailAddress
    final duplicateEmail = await _supabase
      .from('user')
      .select('auth_id')
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
      await _supabase.rpc(
        'create_user_profile',
        params: {
          'p_auth_id': authResponse.user!.id,
          'p_first_name': firstName,
          'p_last_name': lastName,
          'p_username': username,
          'p_mobile': phone,
          'p_email': emailAddress,
          'p_password': hashedPassword,
          'p_car_type': carType,
          'p_car_plate': carPlate,
          'p_user_type': userType,
        },
      );
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
      .select('auth_id, FirstName, LastName, EmailAddress, Username, MobileNumber, Password, user_type')
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
    final email = userQuery['EmailAddress'] as String?;
    if (storedHash != inputHash) {
      // Fallback: try Supabase Auth (in case password was reset there)
      if (email != null && email.isNotEmpty) {
        try {
          await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          // Sync hashed password in custom user table
          await _supabase
              .from('user')
              .update({'Password': inputHash})
              .eq('EmailAddress', email);
          debugPrint('Password synced from Supabase Auth for user: $email');
        } catch (e) {
          debugPrint('Supabase Auth fallback failed: $e');
          throw Exception('كلمة المرور غير صحيحة');
        }
      } else {
        throw Exception('كلمة المرور غير صحيحة');
      }
    } else {
      // Ensure Supabase Auth session exists for RLS-protected writes
      if (email != null && email.isNotEmpty) {
        try {
          await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
        } catch (e) {
          debugPrint('Supabase Auth sign-in failed after hash match: $e');
          throw Exception('تعذر تسجيل الدخول. يرجى المحاولة مرة أخرى');
        }
      }
    }
    // Return user info (without password)
    userQuery.remove('Password');
    return userQuery;
  }

  // No-op sign out for custom auth
  Future<void> signOut() async {}
}
