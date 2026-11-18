import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/app_colors.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _entered = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometrics());
  }

  Future<void> _tryBiometrics() async {
    final state = context.read<AppStateProvider>();
    if (!state.settings.biometricEnabled) return;
    final ok = await state.securityService.authenticateWithBiometrics();
    if (ok && mounted) {
      state.unlockApp();
    }
  }

  void _onDigit(String d) {
    if (_entered.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      _entered += d;
      _error = null;
    });
    if (_entered.length == 4) {
      final state = context.read<AppStateProvider>();
      if (_entered == state.settings.appPin) {
        state.unlockApp();
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _entered = '';
          _error = 'Incorrect PIN';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 42, color: AppColors.emeraldPrimary),
              const SizedBox(height: 16),
              Text('DayPilot Locked', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Enter your 4-digit PIN',
                style: TextStyle(color: _error != null ? AppColors.terracotta : null),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _entered.length;
                  return Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: filled ? AppColors.emeraldPrimary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.emeraldPrimary, width: 1.8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 20,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  for (final n in ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
                    _PinButton(label: n, onTap: () => _onDigit(n)),
                  if (state.settings.biometricEnabled)
                    _PinButton(
                      icon: Icons.fingerprint_rounded,
                      onTap: _tryBiometrics,
                    )
                  else
                    const SizedBox(width: 72, height: 72),
                  _PinButton(label: '0', onTap: () => _onDigit('0')),
                  _PinButton(
                    icon: Icons.backspace_outlined,
                    onTap: () {
                      if (_entered.isNotEmpty) {
                        setState(() => _entered = _entered.substring(0, _entered.length - 1));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _PinButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(36),
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: label != null
            ? Text(label!, style: Theme.of(context).textTheme.headlineMedium)
            : Icon(icon),
      ),
    );
  }
}
