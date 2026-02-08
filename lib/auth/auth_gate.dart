/* This will continously listen to authentication state changes */

import 'package:flutter/material.dart';
import 'package:raheel/pages/login.dart';
import 'package:raheel/pages/home_navigation.dart';
import 'package:raheel/widgets/loading_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: LoadingIndicator(size: 100)),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: \\${snapshot.error}')),
          );
        }
        final session = snapshot.data?.session ?? Supabase.instance.client.auth.currentSession;
        if (session == null) {
          // User is not logged in
          return LoginPage();
        } else {
          // User is logged in
          return const HomeNavigationPage();
        }
      },
    );
  }
}