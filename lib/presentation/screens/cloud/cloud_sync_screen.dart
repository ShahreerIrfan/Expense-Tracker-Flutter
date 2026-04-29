import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/database_provider.dart';

class CloudSyncScreen extends ConsumerStatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  ConsumerState<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends ConsumerState<CloudSyncScreen> {
  bool _busy = false;
  bool? _lastSuccess;
  String _lastMsg = '';
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() => _busy = true);
    final svc = ref.read(cloudSyncServiceProvider);
    final ok = await svc.testConnection();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastSuccess = ok;
      _lastMsg = ok ? 'Connected to cloud' : 'Cannot reach server';
    });
  }

  Future<void> _syncNow() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;
    setState(() {
      _busy = true;
      _lastMsg = 'Syncing your data...';
    });
    final svc = ref.read(cloudSyncServiceProvider);
    final result = await svc.pushAll(user!.id!);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastSuccess = result.success;
      _lastSyncTime = DateTime.now();
      _lastMsg = result.success
          ? 'Sync complete — ${result.summary()}'
          : 'Sync failed: ${result.error ?? 'Unknown error'}';
    });
  }

  String _formatTime(DateTime? t) {
    if (t == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Sync')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.cloud_done, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cloud Backup',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text('Your data is safe in the cloud',
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    if (_lastSuccess != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _lastSuccess! ? Colors.green.shade400 : Colors.red.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _lastSuccess! ? Icons.check_circle : Icons.error_outline,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _lastSuccess! ? 'Online' : 'Offline',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      user?.email ?? user?.name ?? 'Unknown user',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Last sync: ${_formatTime(_lastSyncTime)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),

          const SizedBox(height: 20),

          if (_lastMsg.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _lastSuccess == false
                    ? AppColors.error.withValues(alpha: 0.08)
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _lastSuccess == false
                      ? AppColors.error.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  if (_busy)
                    const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Icon(
                      _lastSuccess == false
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      size: 18,
                      color: _lastSuccess == false ? AppColors.error : AppColors.success,
                    ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_lastMsg, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ).animate().fadeIn(),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: _busy ? null : _syncNow,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.sync),
              label: Text(_busy ? 'Syncing...' : 'Sync Now',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

          const SizedBox(height: 16),

          _InfoCard(
            icon: Icons.security,
            color: AppColors.success,
            title: 'Automatic Backup',
            body: 'Your expenses, incomes, budgets, and accounts are automatically backed up to the cloud every time you make a change.',
          ).animate(delay: 300.ms).fadeIn(),

          const SizedBox(height: 12),

          _InfoCard(
            icon: Icons.devices,
            color: AppColors.primary,
            title: 'Multi-Device Access',
            body: 'Log in with your account on any device to access all your financial data instantly.',
          ).animate(delay: 350.ms).fadeIn(),

          const SizedBox(height: 12),

          _InfoCard(
            icon: Icons.lock_outline,
            color: AppColors.warning,
            title: 'Your Data is Private',
            body: 'Data is stored securely under your account. No one else can access your financial records.',
          ).animate(delay: 400.ms).fadeIn(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _InfoCard({required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
