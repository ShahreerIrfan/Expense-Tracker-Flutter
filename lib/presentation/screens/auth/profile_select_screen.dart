import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../core/security/secure_storage.dart';
import '../../../providers/auth_provider.dart';
import '../../../domain/entities/user.dart';
import '../../../utils/validators.dart';

class ProfileSelectScreen extends ConsumerStatefulWidget {
  const ProfileSelectScreen({super.key});

  @override
  ConsumerState<ProfileSelectScreen> createState() =>
      _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends ConsumerState<ProfileSelectScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(allUsersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Welcome',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
              const SizedBox(height: 8),
              Text(
                'Select your profile or create a new one',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),
              Expanded(
                child: usersAsync.when(
                  data: (users) {
                    if (users.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return _UserProfileCard(
                          user: users[index],
                          onTap: () => _selectUser(users[index]),
                        )
                            .animate(delay: Duration(milliseconds: 100 * index))
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.1);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) =>
                      Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProfileSheet(context),
        icon: const Icon(Icons.person_add),
        label: const Text('New Profile'),
      ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.5),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_alt_1_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No profiles yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first profile to get started',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateProfileSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Profile'),
          ),
        ],
      ),
    );
  }

  void _selectUser(UserEntity user) async {
    if (user.pin != null && user.pin!.isNotEmpty) {
      final authenticated = await _showPinDialog(user);
      if (!authenticated) return;
    }
    ref.read(currentUserProvider.notifier).setCurrentUser(user);
    ref.read(isAuthenticatedProvider.notifier).state = true;
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<bool> _showPinDialog(UserEntity user) async {
    final pinController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Enter PIN for ${user.name}'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: 'Enter your PIN',
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final verified = await SecureStorageService.verifyPin(
                  user.id!, pinController.text);
              if (context.mounted) {
                Navigator.pop(context, verified);
                if (!verified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect PIN'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
    pinController.dispose();
    return result ?? false;
  }

  void _showCreateProfileSheet(BuildContext context) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int selectedColorIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose Avatar Color',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(
                    AppColors.avatarColors.length,
                    (index) => GestureDetector(
                      onTap: () =>
                          setSheetState(() => selectedColorIndex = index),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.avatarColors[index],
                        child: selectedColorIndex == index
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final color = AppColors.avatarColors[selectedColorIndex];
                        final hexColor =
                            '#${color.value.toRadixString(16).substring(2)}';
                        final user = UserEntity(
                          name: nameController.text.trim(),
                          avatarColor: hexColor,
                        );
                        await ref
                            .read(currentUserProvider.notifier)
                            .createUser(user);
                        ref.read(isAuthenticatedProvider.notifier).state = true;
                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.of(context)
                              .pushReplacementNamed('/home');
                        }
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('Create & Continue'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onTap;

  const _UserProfileCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color avatarColor;
    try {
      final hex = user.avatarColor.replaceAll('#', '');
      avatarColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      avatarColor = AppColors.primary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: avatarColor,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        subtitle: Text(
          user.pin != null && user.pin!.isNotEmpty
              ? 'PIN protected'
              : 'No PIN set',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}
