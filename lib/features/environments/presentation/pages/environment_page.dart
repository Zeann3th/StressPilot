import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stress_pilot/features/environments/presentation/provider/environment_provider.dart';
import 'package:stress_pilot/features/environments/presentation/widgets/environment_table.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/features/shared/presentation/widgets/fleet_page_bar.dart';
import 'package:stress_pilot/features/projects/presentation/provider/project_provider.dart';

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
    final selected = envProvider.environments
        .where((e) => e.id == selectedId)
        .firstOrNull;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Icon(LucideIcons.serverCog, size: 16, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Text(
            selected?.name ?? 'Environment',
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _EnvironmentDropdown(
            selectedEnvironmentId: selectedId,
            onSelected: (environmentId) async {
              await projectProvider.switchActiveEnvironment(
                projectId: projectId,
                environmentId: environmentId,
              );
              if (context.mounted) {
                await context.read<EnvironmentProvider>().loadVariables(
                  environmentId,
                );
              }
            },
          ),
          const SizedBox(width: AppSpacing.sm),
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

class _EnvironmentDropdown extends StatelessWidget {
  final int? selectedEnvironmentId;
  final ValueChanged<int> onSelected;

  const _EnvironmentDropdown({
    required this.selectedEnvironmentId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EnvironmentProvider>();
    return PopupMenuButton<int>(
      tooltip: 'Select Environment',
      color: AppColors.elevatedSurface,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.br6,
        side: BorderSide(color: AppColors.border),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => provider.environments
          .map(
            (environment) => PopupMenuItem<int>(
              value: environment.id,
              height: 36,
              child: Row(
                children: [
                  Icon(
                    environment.id == selectedEnvironmentId
                        ? LucideIcons.check
                        : LucideIcons.server,
                    size: 14,
                    color: environment.id == selectedEnvironmentId
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    environment.name,
                    style: AppTypography.body.copyWith(
                      color: environment.id == selectedEnvironmentId
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: AppRadius.br6,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.environments
                      .where((e) => e.id == selectedEnvironmentId)
                      .firstOrNull
                      ?.name ??
                  'Select',
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              LucideIcons.chevronsUpDown,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
