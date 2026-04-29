import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Try to load the previously logged-in user
    await ref.read(currentUserProvider.notifier).loadCurrentUser();
    final user = ref.read(currentUserProvider);

    if (!mounted) return;

    if (user == null) {
      // No saved user → go to profile select / create
      Navigator.of(context).pushReplacementNamed('/profile-select');
    } else if (user.pin != null && user.pin!.isNotEmpty) {
      // User has PIN → go to PIN entry screen
      Navigator.of(context).pushReplacementNamed('/pin-entry');
    } else {
      // User exists, no PIN → go straight to home
      ref.read(isAuthenticatedProvider.notifier).state = true;
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // App icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 64,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 32),
            // App name
            Text(
              AppConstants.appName,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              'Smart Financial Management',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 500.ms),
            const Spacer(flex: 3),
            // Developer credit
            Text(
              'Developed by',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white54,
              ),
            ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 4),
            Text(
              AppConstants.developerName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ).animate(delay: 1000.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 32),
            // Loading indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.7)),
              ),
            ).animate(delay: 1200.ms).fadeIn(duration: 300.ms),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
