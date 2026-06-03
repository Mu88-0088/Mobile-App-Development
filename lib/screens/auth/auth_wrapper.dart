import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../admin/admin_dashboard.dart';
import '../user/home_screen.dart';
import 'login_screen.dart';

/// Listens to auth state and routes to the correct screen.
/// - Not logged in  → LoginScreen
/// - Admin          → AdminDashboard
/// - Regular user   → HomeScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Still loading the user model
    if (auth.isLoggedIn && auth.userModel == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!auth.isLoggedIn) return const LoginScreen();
    if (auth.isAdmin)     return const AdminDashboard();
    return const HomeScreen();
  }
}
