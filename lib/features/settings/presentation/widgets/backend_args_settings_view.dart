import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/features/settings/presentation/provider/setting_provider.dart';

const String backendJvmArgsExample =
    '-javaagent:/absolute/path/agent.jar\n'
    '-Xmx2g\n'
    '--add-opens=java.base/java.lang=ALL-UNNAMED';

const String backendAppArgsExample =
    '--application.distributed.enabled=true\n'
    '--spring.data.redis.host=127.0.0.1\n'
    '--spring.data.redis.port=6379\n'
    '--spring.config.additional-location=file:/absolute/path/stresspilot.yaml';

class BackendArgsSettingsView extends StatefulWidget {
  final bool embedded;

  const BackendArgsSettingsView({super.key, this.embedded = false});

  @override
  State<BackendArgsSettingsView> createState() =>
      _BackendArgsSettingsViewState();
}

class _BackendArgsSettingsViewState extends State<BackendArgsSettingsView> {
  late final TextEditingController _jvmController;
  late final TextEditingController _appController;
  String? _lastJvmProviderValue;
  String? _lastAppProviderValue;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _jvmController = TextEditingController();
    _appController = TextEditingController();
  }

  @override
  void dispose() {
    _jvmController.dispose();
    _appController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await context.read<SettingProvider>().saveBackendLaunchOptions(
        jvmArgsRaw: _jvmController.text,
        appArgsRaw: _appController.text,
      );
      if (mounted) {
        PilotToast.show(context, 'Backend runtime options saved');
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
        _jvmController.clear();
        _appController.clear();
        PilotToast.show(context, 'Backend runtime options reset');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingProvider>();
    final providerJvmValue = provider.backendJvmArgsRaw;
    final providerAppValue = provider.backendAppArgsRaw;

    if (_lastJvmProviderValue != providerJvmValue &&
        _jvmController.text != providerJvmValue) {
      _jvmController.text = providerJvmValue;
      _lastJvmProviderValue = providerJvmValue;
    }
    if (_lastAppProviderValue != providerAppValue &&
        _appController.text != providerAppValue) {
      _appController.text = providerAppValue;
      _lastAppProviderValue = providerAppValue;
    }

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backend Runtime Overrides',
              style: AppTypography.heading.copyWith(
                color: AppColors.textPrimary,
                fontSize: widget.embedded ? 16 : 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Applied the next time the backend process starts. JVM options run before -jar; Spring arguments run after the profile.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _RuntimeTextArea(
              title: 'JVM Options',
              description:
                  'Use for javaagent, memory, module opens, and other Java VM flags.',
              controller: _jvmController,
              placeholder: backendJvmArgsExample,
              minLines: 4,
            ),
            const SizedBox(height: 16),
            _RuntimeTextArea(
              title: 'Spring / Application Arguments',
              description:
                  'Use for YAML override locations, Redis, distributed mode, server ports, and other Spring properties.',
              controller: _appController,
              placeholder: backendAppArgsExample,
              minLines: 5,
            ),
            const SizedBox(height: 12),
            Text(
              'Blank lines and lines starting with # are ignored.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
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
    );

    if (widget.embedded) {
      return content;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: content,
    );
  }
}

class _RuntimeTextArea extends StatelessWidget {
  final String title;
  final String description;
  final TextEditingController controller;
  final String placeholder;
  final int minLines;

  const _RuntimeTextArea({
    required this.title,
    required this.description,
    required this.controller,
    required this.placeholder,
    required this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.br8,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.label),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          PilotInput(
            controller: controller,
            maxLines: minLines,
            placeholder: placeholder,
            style: AppTypography.codeSm,
          ),
          const SizedBox(height: 12),
          Text(
            'Example:\n$placeholder',
            style: AppTypography.codeSm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
