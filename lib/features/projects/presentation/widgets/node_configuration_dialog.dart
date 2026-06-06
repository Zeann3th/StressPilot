import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:stress_pilot/core/themes/components/components.dart';
import 'package:stress_pilot/core/themes/theme_tokens.dart';
import 'package:stress_pilot/features/workspace/domain/models/canvas.dart';
import 'package:stress_pilot/features/endpoints/presentation/provider/endpoint_provider.dart';
import 'package:stress_pilot/features/endpoints/domain/models/endpoint.dart'
    as domain_endpoint;

class NodeConfigurationDialog extends StatefulWidget {
  final CanvasNode node;
  final List<CanvasNode> availableNodes;

  const NodeConfigurationDialog({
    super.key,
    required this.node,
    this.availableNodes = const [],
  });

  @override
  State<NodeConfigurationDialog> createState() =>
      _NodeConfigurationDialogState();
}

class _NodeConfigurationDialogState extends State<NodeConfigurationDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, dynamic> _preProcessor;
  late Map<String, dynamic> _postProcessor;

  domain_endpoint.Endpoint? _endpointDetail;
  bool _isLoadingEndpoint = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _preProcessor = Map<String, dynamic>.from(
      widget.node.data['preProcessor'] ?? {},
    );
    _postProcessor = Map<String, dynamic>.from(
      widget.node.data['postProcessor'] ?? {},
    );

    _fetchEndpointDetails();
  }

  Future<void> _fetchEndpointDetails() async {
    final endpointId = widget.node.data['id'];
    if (endpointId == null) return;

    setState(() => _isLoadingEndpoint = true);
    try {
      final provider = context.read<EndpointProvider>();
      final endpoint = await provider.getEndpoint(endpointId);
      if (mounted) {
        setState(() {
          _endpointDetail = endpoint;
          _isLoadingEndpoint = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingEndpoint = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PilotDialog(
      title: 'Node Configuration',
      maxWidth: 900,
      content: SizedBox(
        height: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${widget.node.id}',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Flow Control'),
                Tab(text: 'Pre-Processor'),
                Tab(text: 'Post-Processor'),
              ],
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.accent,
              labelStyle: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTypography.body,
              isScrollable: true,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDetailsTab(),
                  _ControlEditor(
                    data: _preProcessor,
                    supportsLoop: widget.node.type == FlowNodeType.endpoint,
                    availableNodes: widget.availableNodes,
                    currentNodeId: widget.node.id,
                    onChanged: (data) => _preProcessor = data,
                  ),
                  _ProcessorEditor(
                    key: const ValueKey('pre'),
                    data: _preProcessor,
                    onChanged: (data) => _preProcessor = data,
                  ),
                  _ProcessorEditor(
                    key: const ValueKey('post'),
                    data: _postProcessor,
                    onChanged: (data) => _postProcessor = data,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_endpointDetail != null)
          PilotButton.ghost(
            label: 'Navigate to Endpoint',
            icon: LucideIcons.externalLink,
            onPressed: () {
              Navigator.of(
                context,
              ).pop({'action': 'navigate', 'endpoint': _endpointDetail});
            },
          ),
        PilotButton.ghost(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        PilotButton.primary(
          label: 'Save Changes',
          onPressed: () {
            Navigator.of(context).pop({
              'preProcessor': _preProcessor,
              'postProcessor': _postProcessor,
            });
          },
        ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    if (_isLoadingEndpoint) {
      return const Center(child: CircularProgressIndicator());
    }

    final endpoint = _endpointDetail;
    final primaryTextColor = AppColors.textPrimary;
    final secondaryTextColor = AppColors.textSecondary;
    final mutedTextColor = AppColors.textMuted;

    if (endpoint == null && widget.node.type == FlowNodeType.loop) {
      final loop = _preProcessor['loop'] is Map
          ? Map<String, dynamic>.from(_preProcessor['loop'])
          : const <String, dynamic>{};
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection('Loop Node', [
              _buildDetailRow(
                'Name',
                widget.node.data['name']?.toString() ?? 'Loop',
                primaryTextColor,
                secondaryTextColor,
              ),
              _buildDetailRow(
                'Source',
                loop['source']?.toString() ?? 'Not configured',
                primaryTextColor,
                secondaryTextColor,
              ),
              _buildDetailRow(
                'Item',
                loop['item']?.toString() ?? 'item',
                primaryTextColor,
                secondaryTextColor,
              ),
              _buildDetailRow(
                'Body step',
                loop['body']?.toString() ?? 'Connect or enter a body step',
                primaryTextColor,
                secondaryTextColor,
              ),
            ]),
          ],
        ),
      );
    }

    if (endpoint == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.info, size: 48, color: mutedTextColor),
            const SizedBox(height: 16),
            Text(
              'Endpoint details not available',
              style: TextStyle(color: mutedTextColor),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection('Basic Information', [
            _buildDetailRow(
              'Name',
              endpoint.name,
              primaryTextColor,
              secondaryTextColor,
            ),
            _buildDetailRow(
              'Type',
              endpoint.type,
              primaryTextColor,
              secondaryTextColor,
            ),
            _buildDetailRow(
              'URL',
              endpoint.url ?? '—',
              primaryTextColor,
              secondaryTextColor,
            ),
            if (endpoint.httpMethod != null)
              _buildDetailRow(
                'Method',
                endpoint.httpMethod!.toUpperCase(),
                primaryTextColor,
                secondaryTextColor,
              ),
          ]),

          if (endpoint.type == 'GRPC')
            _buildDetailSection('gRPC Configuration', [
              _buildDetailRow(
                'Service',
                endpoint.grpcServiceName ?? '—',
                primaryTextColor,
                secondaryTextColor,
              ),
              _buildDetailRow(
                'Method',
                endpoint.grpcMethodName ?? '—',
                primaryTextColor,
                secondaryTextColor,
              ),
            ]),

          const SizedBox(height: 8),
          Text(
            'DATA & PAYLOAD',
            style: AppTypography.label.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const Divider(),

          if (endpoint.httpHeaders != null && endpoint.httpHeaders!.isNotEmpty)
            _buildCodeBlock('Headers', jsonEncode(endpoint.httpHeaders)),

          if (endpoint.body != null && endpoint.body!.toString().isNotEmpty)
            _buildCodeBlock('Body / Payload', endpoint.body.toString()),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTypography.label.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(String title, String code) {
    String formattedCode = code;
    try {
      final decoded = jsonDecode(code);
      formattedCode = const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: AppRadius.br8,
            border: Border.all(color: AppColors.border),
          ),
          child: SelectableText(
            formattedCode,
            style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionLabel({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.elevated.withValues(alpha: 0.7),
        borderRadius: AppRadius.br8,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.settings2, size: 16, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMd),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlEditor extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool supportsLoop;
  final List<CanvasNode> availableNodes;
  final String currentNodeId;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _ControlEditor({
    required this.data,
    required this.supportsLoop,
    required this.availableNodes,
    required this.currentNodeId,
    required this.onChanged,
  });

  @override
  State<_ControlEditor> createState() => _ControlEditorState();
}

class _ControlEditorState extends State<_ControlEditor> {
  late TextEditingController _runIfController;
  late TextEditingController _skipIfController;
  late TextEditingController _sourceController;
  late TextEditingController _itemController;
  late TextEditingController _indexController;
  late TextEditingController _countController;
  late bool _loopEnabled;

  @override
  void initState() {
    super.initState();
    final loop = widget.data['loop'] is Map
        ? Map<String, dynamic>.from(widget.data['loop'])
        : const <String, dynamic>{};
    _loopEnabled = widget.data['loop_enabled'] == true || loop.isNotEmpty;
    _runIfController = TextEditingController(
      text: widget.data['run_if']?.toString() ?? '',
    );
    _skipIfController = TextEditingController(
      text: widget.data['skip_if']?.toString() ?? '',
    );
    _sourceController = TextEditingController(
      text: loop['source']?.toString() ?? '',
    );
    _itemController = TextEditingController(
      text: loop['item']?.toString() ?? 'item',
    );
    _indexController = TextEditingController(
      text: loop['index']?.toString() ?? 'index',
    );
    _countController = TextEditingController(
      text: loop['count']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _runIfController.dispose();
    _skipIfController.dispose();
    _sourceController.dispose();
    _itemController.dispose();
    _indexController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _updateData() {
    final newData = Map<String, dynamic>.from(widget.data);

    _putText(newData, 'run_if', _runIfController.text);
    _putText(newData, 'skip_if', _skipIfController.text);

    if (widget.supportsLoop && _loopEnabled) {
      final loop = <String, dynamic>{};
      _putText(loop, 'source', _sourceController.text);
      _putText(loop, 'item', _itemController.text);
      _putText(loop, 'index', _indexController.text);
      final countText = _countController.text.trim();
      if (countText.isNotEmpty) {
        loop['count'] = int.tryParse(countText) ?? countText;
      }
      newData['loop_enabled'] = true;
      newData['loop'] = loop;
    } else {
      newData.remove('loop_enabled');
      newData.remove('loop');
    }

    widget.onChanged(newData);
  }

  void _putText(Map<String, dynamic> target, String key, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      target.remove(key);
    } else {
      target[key] = trimmed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionLabel(
          title: 'Conditions',
          subtitle: 'Optional expressions evaluated before this node runs.',
        ),
        const SizedBox(height: 12),
        _buildInput('Run if', 'student_iteration <= 10', _runIfController),
        const SizedBox(height: 12),
        _buildInput(
          'Skip if',
          "access_token != null && access_token != ''",
          _skipIfController,
        ),
        if (widget.supportsLoop) ...[
          const SizedBox(height: 24),
          _SectionLabel(
            title: 'Loop',
            subtitle: 'Run this endpoint once per item from a list or count.',
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Run in loop', style: AppTypography.bodyMd),
            subtitle: Text(
              'The app will generate the backend LOOP step when saving.',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            value: _loopEnabled,
            activeThumbColor: AppColors.methodPatch,
            onChanged: (value) {
              setState(() => _loopEnabled = value);
              _updateData();
            },
          ),
        ],
        if (widget.supportsLoop && _loopEnabled) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  'Source list',
                  'questions',
                  _sourceController,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildInput('Count', '10', _countController)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInput('Item name', 'question', _itemController),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInput(
                  'Index name',
                  'question_index',
                  _indexController,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInput(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: 6),
        PilotInput(
          controller: controller,
          placeholder: hint,
          onChanged: (_) => _updateData(),
          style: AppTypography.code,
        ),
      ],
    );
  }
}

class _ProcessorEditor extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _ProcessorEditor({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  State<_ProcessorEditor> createState() => _ProcessorEditorState();
}

class _ProcessorEditorState extends State<_ProcessorEditor> {
  late TextEditingController _sleepController;
  late TextEditingController _clearController;
  late TextEditingController _setController;
  late TextEditingController _incrementController;
  late TextEditingController _appendController;
  late TextEditingController _serializeJsonController;
  late TextEditingController _injectController;
  late TextEditingController _extractController;

  bool _setError = false;
  bool _appendError = false;
  bool _serializeJsonError = false;
  bool _injectError = false;
  bool _extractError = false;

  @override
  void initState() {
    super.initState();

    _sleepController = TextEditingController(
      text:
          widget.data['delay']?.toString() ??
          widget.data['sleep']?.toString() ??
          '',
    );
    final clearData = widget.data['clear'];
    _clearController = TextEditingController(
      text: clearData is List ? clearData.join(', ') : '',
    );
    _setController = TextEditingController(
      text: _formatJson(widget.data['set']),
    );
    _incrementController = TextEditingController(
      text: _formatIncrement(widget.data['increment']),
    );
    _appendController = TextEditingController(
      text: _formatJson(widget.data['append']),
    );
    _serializeJsonController = TextEditingController(
      text: _formatJson(widget.data['serialize_json']),
    );
    _injectController = TextEditingController(
      text: _formatJson(widget.data['inject']),
    );
    _extractController = TextEditingController(
      text: _formatJson(widget.data['extract']),
    );
  }

  String _formatJson(dynamic data) {
    if (data == null) return '';
    try {
      if (data is String) return data;
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  String _formatIncrement(dynamic data) {
    if (data is Map) {
      return data.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    }
    return '';
  }

  void _updateData() {
    final newData = Map<String, dynamic>.from(widget.data);

    if (_sleepController.text.isNotEmpty) {
      newData['delay'] =
          int.tryParse(_sleepController.text) ?? _sleepController.text.trim();
      newData.remove('sleep');
    } else {
      newData.remove('delay');
      newData.remove('sleep');
    }

    if (_clearController.text.isNotEmpty) {
      newData['clear'] = _clearController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      newData.remove('clear');
    }

    bool hasChanged = false;

    hasChanged |= _updateJsonField(
      newData,
      'set',
      _setController.text,
      (value) => _setError = value,
      _setError,
    );

    final incrementText = _incrementController.text.trim();
    if (incrementText.isNotEmpty) {
      final increment = <String, dynamic>{};
      for (final line in incrementText.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        final separator = trimmed.indexOf(':');
        if (separator <= 0) continue;
        final key = trimmed.substring(0, separator).trim();
        final value = trimmed.substring(separator + 1).trim();
        increment[key] = int.tryParse(value) ?? double.tryParse(value) ?? value;
      }
      if (increment.isNotEmpty) {
        newData['increment'] = increment;
      } else {
        newData.remove('increment');
      }
    } else {
      newData.remove('increment');
    }

    hasChanged |= _updateJsonField(
      newData,
      'append',
      _appendController.text,
      (value) => _appendError = value,
      _appendError,
    );
    hasChanged |= _updateJsonField(
      newData,
      'serialize_json',
      _serializeJsonController.text,
      (value) => _serializeJsonError = value,
      _serializeJsonError,
    );

    final injectText = _injectController.text.trim();
    if (injectText.isNotEmpty) {
      try {
        newData['inject'] = jsonDecode(injectText);
        if (_injectError) {
          _injectError = false;
          hasChanged = true;
        }
      } catch (_) {
        if (!_injectError) {
          _injectError = true;
          hasChanged = true;
        }
        newData.remove('inject');
      }
    } else {
      if (_injectError) {
        _injectError = false;
        hasChanged = true;
      }
      newData.remove('inject');
    }

    final extractText = _extractController.text.trim();
    if (extractText.isNotEmpty) {
      try {
        newData['extract'] = jsonDecode(extractText);
        if (_extractError) {
          _extractError = false;
          hasChanged = true;
        }
      } catch (_) {
        if (!_extractError) {
          _extractError = true;
          hasChanged = true;
        }
        newData.remove('extract');
      }
    } else {
      if (_extractError) {
        _extractError = false;
        hasChanged = true;
      }
      newData.remove('extract');
    }

    if (hasChanged) {
      setState(() {});
    }
    widget.onChanged(newData);
  }

  bool _updateJsonField(
    Map<String, dynamic> data,
    String key,
    String text,
    ValueChanged<bool> setError,
    bool currentError,
  ) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      setError(false);
      data.remove(key);
      return currentError;
    }

    try {
      data[key] = jsonDecode(trimmed);
      setError(false);
      return currentError;
    } catch (_) {
      setError(true);
      data.remove(key);
      return !currentError;
    }
  }

  @override
  void dispose() {
    _sleepController.dispose();
    _clearController.dispose();
    _setController.dispose();
    _incrementController.dispose();
    _appendController.dispose();
    _serializeJsonController.dispose();
    _injectController.dispose();
    _extractController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionLabel(
          title: 'Native Operations',
          subtitle: 'Common variable work without JavaScript endpoints.',
        ),
        const SizedBox(height: 12),
        _buildSection(
          context,
          'Delay (ms)',
          'Delay execution by milliseconds',
          _sleepController,
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          'Clear Variables',
          'Comma separated keys (e.g. var1, var2)',
          _clearController,
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          'Set Variables (JSON)',
          '{"student_iteration": 1}',
          _setController,
          isMultiline: true,
          hasError: _setError,
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          'Increment Variables',
          'student_iteration: 1',
          _incrementController,
          isMultiline: true,
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          'Append To Lists (JSON)',
          '{"answers": {"question_id": "{{question.id}}"}}',
          _appendController,
          isMultiline: true,
          hasError: _appendError,
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          'Serialize JSON (JSON)',
          '{"answers_json": "answers"}',
          _serializeJsonController,
          isMultiline: true,
          hasError: _serializeJsonError,
        ),
        const SizedBox(height: 24),
        _SectionLabel(
          title: 'Advanced',
          subtitle: 'Raw processor features for existing flows.',
        ),
        const SizedBox(height: 12),
        _buildSection(
          context,
          'Inject Variables (JSON)',
          '{"key": "value"}',
          _injectController,
          isMultiline: true,
          hasError: _injectError,
        ),
        const SizedBox(height: 16),
        _buildSection(
          context,
          'Extract Variables (JSON)',
          '{"varName": "path.to.value"}',
          _extractController,
          isMultiline: true,
          hasError: _extractError,
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String label,
    String hint,
    TextEditingController controller, {
    bool isMultiline = false,
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            if (hasError) ...[
              const SizedBox(width: 8),
              Text(
                'Invalid JSON',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        PilotInput(
          controller: controller,
          placeholder: hint,
          maxLines: isMultiline ? 8 : 1,
          onChanged: (_) => _updateData(),
          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13),
        ),
      ],
    );
  }
}
