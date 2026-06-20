import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stress_pilot/features/environments/presentation/provider/environment_provider.dart';
import 'package:stress_pilot/features/environments/presentation/widgets/environment_table.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/fleet_page_bar.dart';
import 'package:stress_pilot/features/shared/presentation/provider/project_provider.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/pulse_indicator.dart';

class EnvironmentPage extends StatefulWidget {
  final int projectId;
  final int environmentId;
  final String projectName;

  const EnvironmentPage({
    super.key,
    required this.projectId,
    required this.environmentId,
    required this.projectName,
  });

  @override
  State<EnvironmentPage> createState() => _EnvironmentPageState();
}

class _EnvironmentPageState extends State<EnvironmentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnvironmentProvider>().loadProjectEnvironments(
        projectId: widget.projectId,
        activeEnvironmentId: widget.environmentId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseBackground,
      body: Column(
        children: [
          FleetPageBar(title: '${widget.projectName} Environments'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: PilotPanel(
                padding: EdgeInsets.zero,
                borderRadius: AppRadius.br12,
                child: Column(
                  children: [
                    _EnvironmentHeader(projectId: widget.projectId),
                    Divider(height: 1, color: AppColors.border),
                    const Expanded(child: EnvironmentTable()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnvironmentHeader extends StatelessWidget {
  final int projectId;

  const _EnvironmentHeader({required this.projectId});

  @override
  Widget build(BuildContext context) {
    final envProvider = context.watch<EnvironmentProvider>();
    final projectProvider = context.read<ProjectProvider>();
    final selectedId = envProvider.currentEnvironmentId;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...envProvider.environments.map((env) {
                    final isSelected = env.id == selectedId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: isSelected
                            ? null
                            : () async {
                                await projectProvider.switchActiveEnvironment(
                                  projectId: projectId,
                                  environmentId: env.id,
                                );
                                if (context.mounted) {
                                  await context
                                      .read<EnvironmentProvider>()
                                      .loadVariables(env.id);
                                }
                              },
                        child: AnimatedContainer(
                          duration: AppDurations.short,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: AppRadius.br6,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent.withValues(alpha: 0.4)
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const PulseIndicator(size: 5),
                                const SizedBox(width: 5),
                              ],
                              Text(
                                env.name,
                                style: AppTypography.body.copyWith(
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          PilotButton.primary(
            icon: LucideIcons.plus,
            compact: true,
            tooltip: 'Create Environment',
            onPressed: () => _showCreateEnvironmentDialog(context, projectId),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateEnvironmentDialog(
    BuildContext context,
    int projectId,
  ) async {
    final controller = TextEditingController(text: 'New Environment');
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => PilotDialog(
        title: 'Create Environment',
        content: SizedBox(
          width: 360,
          child: PilotInput(
            controller: controller,
            autofocus: true,
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
        ),
        actions: [
          PilotButton.ghost(
            label: 'Cancel',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          PilotButton.primary(
            label: 'Create',
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name == null || name.trim().isEmpty || !context.mounted) return;

    final envProvider = context.read<EnvironmentProvider>();
    final projectProvider = context.read<ProjectProvider>();
    final environment = await envProvider.createEnvironment(
      projectId: projectId,
      name: name,
    );
    await projectProvider.switchActiveEnvironment(
      projectId: projectId,
      environmentId: environment.id,
    );
    await envProvider.loadVariables(environment.id);
  }
}
