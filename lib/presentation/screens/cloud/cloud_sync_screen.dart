import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../services/cloud_sync_service.dart';

class CloudSyncScreen extends ConsumerStatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  ConsumerState<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends ConsumerState<CloudSyncScreen> {
  bool _busy = false;
  String _status = '';
  bool? _connected;

  Future<void> _runTest() async {
    setState(() {
      _busy = true;
      _status = 'Testing connection...';
    });
    final svc = ref.read(cloudSyncServiceProvider);
    final ok = await svc.testConnection();
    setState(() {
      _busy = false;
      _connected = ok;
      _status = ok ? 'Connected to cloud database' : 'Connection failed';
    });
  }

  Future<void> _runPush() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;
    final confirmed = await _confirm('Upload to Cloud',
        'This will overwrite all cloud data for your profile. Continue?');
    if (!confirmed) return;

    setState(() {
      _busy = true;
      _status = 'Uploading data to cloud...';
    });
    final svc = ref.read(cloudSyncServiceProvider);
    final result = await svc.pushAll(user!.id!);
    setState(() {
      _busy = false;
      _status = result.success
          ? 'Upload complete: ${result.summary()}'
          : 'Upload failed: ${result.error}';
    });
    _showSnack(result);
  }

  Future<void> _runPull() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;
    final confirmed = await _confirm('Download from Cloud',
        'This will overwrite all local data with cloud data. Continue?');
    if (!confirmed) return;

    setState(() {
      _busy = true;
      _status = 'Downloading data from cloud...';
    });
    final svc = ref.read(cloudSyncServiceProvider);
    final result = await svc.pullAll(user!.id!);
    setState(() {
      _busy = false;
      _status = result.success
          ? 'Download complete: ${result.summary()}'
          : 'Download failed: ${result.error}';
    });
    _showSnack(result);
  }

  void _showSnack(SyncResult r) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(r.success ? r.summary() : (r.error ?? 'Unknown error')),
        backgroundColor: r.success ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<bool> _confirm(String title, String body) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continue')),
        ],
      ),
    );
    return r ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Sync')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
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
                    const Icon(Icons.cloud, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'PostgreSQL Cloud',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_connected != null)
                      Icon(
                        _connected! ? Icons.check_circle : Icons.error,
                        color: Colors.white,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sync your data with Hostinger Dokploy database. Your data stays accessible across devices.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 16),

          // Security warning
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.warning),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Direct DB credentials in mobile apps are insecure. For production, use a backend API.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Status
          if (_status.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (_busy)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(Icons.info_outline, size: 18, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_status)),
                ],
              ),
            ),

          // Actions
          _ActionTile(
            icon: Icons.network_check,
            color: AppColors.primary,
            title: 'Test Connection',
            subtitle: 'Verify cloud database is reachable',
            onTap: _busy ? null : _runTest,
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.cloud_upload,
            color: AppColors.success,
            title: 'Upload to Cloud',
            subtitle: 'Push all local data to cloud',
            onTap: _busy ? null : _runPush,
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.cloud_download,
            color: AppColors.income,
            title: 'Download from Cloud',
            subtitle: 'Replace local data with cloud data',
            onTap: _busy ? null : _runPull,
          ),

          const SizedBox(height: 32),

          // Connection details
          Text('Connection Details',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: scheme.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(label: 'Host', value: '187.127.141.36'),
                  _DetailRow(label: 'Port', value: '5434'),
                  _DetailRow(label: 'Database', value: 'ET_DB'),
                  _DetailRow(label: 'User', value: 'postgres'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
        ],
      ),
    );
  }
}
