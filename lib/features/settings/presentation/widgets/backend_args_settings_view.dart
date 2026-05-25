import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/features/settings/presentation/provider/setting_provider.dart';

const String backendArgsExample =
    '--application.distributed.enabled=true\n'
    '--spring.data.redis.host=127.0.0.1\n'
    '--spring.data.redis.port=6379';

class BackendArgsSettingsView extends StatefulWidget {
  const BackendArgsSettingsView({super.key});

  @override
  State<BackendArgsSettingsView> createState() =>
      _BackendArgsSettingsViewState();
}

class _BackendArgsSettingsViewState extends State<BackendArgsSettingsView> {
  late final TextEditingController _controller;
  String? _lastProviderValue;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await context.read<SettingProvider>().saveBackendArgs(_controller.text);
      if (mounted) {
        PilotToast.show(context, 'Backend arguments saved');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _reset() async {
    setState(() => _isSaving = true);
    try {
      await context.read<SettingProvider>().resetBackendArgs();
      if (mounted) {
        _controller.clear();
        PilotToast.show(context, 'Backend arguments reset');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerValue = context.watch<SettingProvider>().backendArgsRaw;
    if (_lastProviderValue != providerValue &&
        _controller.text != providerValue) {
      _controller.text = providerValue;
      _lastProviderValue = providerValue;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Backend Launch Arguments',
                style: AppTypography.heading.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Applied the next time the backend process starts.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.br8,
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Raw Arguments', style: AppTypography.label),
                    const SizedBox(height: 12),
                    PilotInput(
                      controller: _controller,
                      maxLines: 8,
                      placeholder: backendArgsExample,
                      style: AppTypography.codeSm,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Example:\n$backendArgsExample',
                      style: AppTypography.codeSm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PilotButton.ghost(
                    label: 'Reset',
                    icon: Icons.restart_alt_rounded,
                    onPressed: _isSaving ? null : _reset,
                  ),
                  const SizedBox(width: 8),
                  PilotButton.primary(
                    label: 'Save',
                    icon: Icons.save_rounded,
                    onPressed: _isSaving ? null : _save,
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
