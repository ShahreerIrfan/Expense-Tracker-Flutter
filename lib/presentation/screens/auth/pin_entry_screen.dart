import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/security/secure_storage.dart';
import '../../../providers/auth_provider.dart';

class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _pin = [];
  static const int _pinLength = 4;
  bool _error = false;
  int _attempts = 0;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _tryBiometric();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final user = ref.read(currentUserProvider);
    if (user?.biometricEnabled != true) return;
    final available = await AuthService.isBiometricAvailable();
    if (!available) return;
    final ok = await AuthService.authenticateWithBiometrics();
    if (ok && mounted) _unlock();
  }

  void _onKey(String key) {
    if (_pin.length >= _pinLength) return;
    setState(() {
      _pin.add(key);
      _error = false;
    });
    if (_pin.length == _pinLength) _verify();
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin.removeLast());
  }

  Future<void> _verify() async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    final entered = _pin.join();
    final verified = await SecureStorageService.verifyPin(user!.id!, entered);

    if (verified) {
      _unlock();
    } else {
      _attempts++;
      setState(() {
        _error = true;
        _pin.clear();
      });
      _shakeController.forward(from: 0);
    }
  }

  void _unlock() {
    ref.read(isAuthenticatedProvider.notifier).state = true;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _switchProfile() {
    Navigator.of(context).pushReplacementNamed('/profile-select');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(currentUserProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color avatarColor;
    try {
      final hex = (user?.avatarColor ?? '#4CAF50').replaceAll('#', '');
      avatarColor = Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      avatarColor = AppColors.primary;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // Avatar + greeting
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: avatarColor,
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 12),
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ).animate(delay: 100.ms).fadeIn(),
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate(delay: 150.ms).fadeIn(),
                ],
              ),

              const SizedBox(height: 40),

              // PIN dots
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final shake =
                      _error ? _shakeAnimation.value * 16 * (1 - _shakeAnimation.value) : 0.0;
                  return Transform.translate(
                    offset: Offset(shake, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (i) {
                    final filled = i < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                        border: Border.all(
                          color: _error
                              ? Colors.red.shade300
                              : Colors.white.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ).animate(delay: 200.ms).fadeIn(),

              const SizedBox(height: 12),

              // Error text
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _error ? 1.0 : 0.0,
                child: Text(
                  _attempts >= 3
                      ? 'Too many attempts. Try again.'
                      : 'Incorrect PIN. Try again.',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),

              const Spacer(),

              // Numpad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _buildRow(['1', '2', '3'], scheme),
                    const SizedBox(height: 12),
                    _buildRow(['4', '5', '6'], scheme),
                    const SizedBox(height: 12),
                    _buildRow(['7', '8', '9'], scheme),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Biometric button
                        Expanded(
                          child: user?.biometricEnabled == true
                              ? _PadButton(
                                  onTap: _tryBiometric,
                                  child: const Icon(Icons.fingerprint,
                                      color: Colors.white, size: 28),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Expanded(child: _buildKey('0', scheme)),
                        Expanded(
                          child: _PadButton(
                            onTap: _onDelete,
                            child: const Icon(Icons.backspace_outlined,
                                color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 24),

              // Switch profile
              TextButton(
                onPressed: _switchProfile,
                child: Text(
                  'Switch Profile',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildRow(List<String> keys, ColorScheme scheme) {
    return Row(
      children: keys
          .map((k) => Expanded(child: _buildKey(k, scheme)))
          .toList(),
    );
  }

  Widget _buildKey(String key, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: _PadButton(
        onTap: () => _onKey(key),
        child: Text(
          key,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _PadButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _PadButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: child),
      ),
    );
  }
}
