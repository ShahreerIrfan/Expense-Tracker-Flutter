import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.account_balance_wallet,
                    size: 64, color: Colors.white),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.5, 0.5)),
              const SizedBox(height: 24),

              // App name
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Version ${AppConstants.appVersion}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 32),

              // Description
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'A comprehensive expense tracking application built with Flutter. '
                  'Track your daily expenses, manage budgets, generate reports, '
                  'and gain insights into your spending habits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 32),

              // Developer info
              const Text(
                'Developed by',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                AppConstants.developerName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2),
              const SizedBox(height: 32),

              // Features
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text('Key Features',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...[
                      '📊 Smart Dashboard & Analytics',
                      '💰 Multi-Account Management',
                      '📈 Budget Tracking & Alerts',
                      '🏷️ Custom Categories with Icons',
                      '📄 PDF/CSV Export',
                      '🔒 PIN & Biometric Security',
                      '🌙 Dark/Light Theme',
                      '🌐 Multi-language (EN/বাংলা)',
                      '👥 Multi-user Support',
                      '🗣️ Voice Input',
                      '💡 AI-Powered Insights',
                      '☁️ Backup & Restore',
                    ].map((f) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(f,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ).animate(delay: 700.ms).fadeIn(duration: 500.ms),
              const SizedBox(height: 24),

              // Tech stack
              Text(
                'Built with Flutter & Dart',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '© ${DateTime.now().year} ${AppConstants.developerName}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
