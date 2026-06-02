import 'dart:convert';

class Flow {
  final int id;
  final String name;
  final String? description;
  final String type;
  final int projectId;
  final List<FlowStep> steps;

  Flow({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.projectId,
    this.steps = const [],
  });

  static int _toInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static Map<String, dynamic>? _parseProcessor(dynamic value) {
    if (value == null) return null;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) {
      if (value.isEmpty) return null;
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  factory Flow.fromJson(Map<String, dynamic> json) {
    return Flow(
      id: _toInt(json['id']),
      name: json['name'] ?? '',
      description: json['description'],
      type: json['type'] ?? 'DEFAULT',
      projectId: _toInt(json['projectId']),
      steps:
          (json['steps'] as List?)
              ?.map((e) => FlowStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type,
    'projectId': projectId,
    'steps': steps.map((e) => e.toJson()).toList(),
  };

  Flow copyWith({List<FlowStep>? steps}) {
    return Flow(
      id: id,
      name: name,
      description: description,
      type: type,
      projectId: projectId,
      steps: steps ?? this.steps,
    );
  }
}

class FlowStep {
  final String id;
  final String type;

  final int? endpointId;

  final String? endpointName;
  final String? endpointUrl;
  final String? endpointType;
  final String? endpointMethod;

  final String? nextIfTrue;
  final String? nextIfFalse;
  final String? condition;
  final Map<String, dynamic>? preProcessor;
  final Map<String, dynamic>? postProcessor;

  FlowStep({
    required this.id,
    required this.type,
    this.endpointId,
    this.endpointName,
    this.endpointUrl,
    this.endpointType,
    this.endpointMethod,
    this.nextIfTrue,
    this.nextIfFalse,
    this.condition,
    this.preProcessor,
    this.postProcessor,
  });

  factory FlowStep.fromJson(Map<String, dynamic> json) {
    final endpointObj = json['endpoint'];
    int? endpointId;
    String? endpointName;
    String? endpointUrl;
    String? endpointType;
    String? endpointMethod;

    final Map<String, dynamic>? pre = Flow._parseProcessor(
      json['preProcessor'],
    );

    if (endpointObj is Map<String, dynamic>) {
      endpointId = Flow._toInt(endpointObj['id']);
      endpointName = endpointObj['name']?.toString();
      endpointUrl = endpointObj['url']?.toString();
      endpointType = endpointObj['type']?.toString();
      endpointMethod =
          endpointObj['httpMethod']?.toString() ??
          endpointObj['method']?.toString();
    } else {
      final raw = json['endpointId'];
      endpointId = raw == null ? null : Flow._toInt(raw);
      endpointName = json['endpointName']?.toString();
      endpointUrl = json['endpointUrl']?.toString();
      endpointType = json['endpointType']?.toString();
      endpointMethod = json['endpointMethod']?.toString();

      if (endpointId == null && pre != null) {
        endpointId = Flow._toInt(pre['endpoint_id'], -1);
        if (endpointId == -1) endpointId = null;
      }
      endpointName ??= pre?['endpoint_name']?.toString();
      endpointUrl ??= pre?['endpoint_url']?.toString();
      endpointType ??= pre?['endpoint_type']?.toString();
      endpointMethod ??= pre?['endpoint_method']?.toString();
    }

    return FlowStep(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'ENDPOINT',
      endpointId: endpointId,
      endpointName: endpointName,
      endpointUrl: endpointUrl,
      endpointType: endpointType,
      endpointMethod: endpointMethod,
      nextIfTrue: json['nextIfTrue']?.toString(),
      nextIfFalse: json['nextIfFalse']?.toString(),
      condition: json['condition']?.toString(),
      preProcessor: pre,
      postProcessor: Flow._parseProcessor(json['postProcessor']),
    );
  }

  Map<String, dynamic> toJson({bool includeMetadata = true}) {
    Map<String, dynamic> pre;
    if (preProcessor == null) {
      pre = {};
    } else {
      pre = Map<String, dynamic>.from(preProcessor!);
      if (!includeMetadata) {
        pre.remove('location');
        pre.remove('_canvas_x');
        pre.remove('_canvas_y');
      }
    }

    final Map<String, dynamic> json = {
      'id': id,
      'type': type,
      'endpointId': endpointId,
      'endpointName': endpointName,
      'endpointUrl': endpointUrl,
      'endpointType': endpointType,
      'endpointMethod': endpointMethod,
      'nextIfTrue': nextIfTrue,
      'nextIfFalse': nextIfFalse,
      'condition': condition,
      'postProcessor': postProcessor,
    };

    if (pre.isNotEmpty) {
      json['preProcessor'] = pre;
    }

    return json;
  }
}

class CreateFlowRequest {
  final int projectId;
  final String name;
  final String? description;
  final String type;

  CreateFlowRequest({
    required this.projectId,
    required this.name,
    this.description,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'name': name,
    'description': description,
    'type': type,
  };
}

class RunFlowRequest {
  final int threads;
  final int totalDuration;
  final int rampUpDuration;
  final Map<String, dynamic>? variables;

  RunFlowRequest({
    this.threads = 1,
    this.totalDuration = 60,
    this.rampUpDuration = 0,
    this.variables,
  });

  Map<String, dynamic> toJson() => {
    'threads': threads,
    'totalDuration': totalDuration,
    'rampUpDuration': rampUpDuration,
    'variables': variables,
  };
}

class DryRunStepRequest {
  final String stepId;
  final int? environmentId;
  final Map<String, dynamic>? variables;
  final Map<String, dynamic>? temporaryVariables;

  DryRunStepRequest({
    required this.stepId,
    this.environmentId,
    this.variables,
    this.temporaryVariables,
  });

  Map<String, dynamic> toJson() => {
    'stepId': stepId,
    'environmentId': environmentId,
    'variables': variables,
    'temporaryVariables': temporaryVariables,
  };
}

class DryRunStepResult {
  final String stepId;
  final String stepType;
  final String? nextStepId;
  final String? correlationId;
  final bool persisted;
  final dynamic outputData;
  final Map<String, dynamic> variables;
  final List<DryRunRequestLog> requestLogs;

  DryRunStepResult({
    required this.stepId,
    required this.stepType,
    this.nextStepId,
    this.correlationId,
    this.persisted = false,
    this.outputData,
    this.variables = const {},
    this.requestLogs = const [],
  });

  factory DryRunStepResult.fromJson(Map<String, dynamic> json) {
    return DryRunStepResult(
      stepId: json['stepId']?.toString() ?? '',
      stepType: json['stepType']?.toString() ?? '',
      nextStepId: json['nextStepId']?.toString(),
      correlationId: json['correlationId']?.toString(),
      persisted: json['persisted'] == true,
      outputData: json['outputData'],
      variables: json['variables'] is Map
          ? Map<String, dynamic>.from(json['variables'] as Map)
          : const {},
      requestLogs: json['requestLogs'] is List
          ? (json['requestLogs'] as List)
                .whereType<Map>()
                .map((item) => DryRunRequestLog.fromJson(item))
                .toList()
          : const [],
    );
  }
}

class DryRunRequestLog {
  final int? endpointId;
  final String? endpointName;
  final int? statusCode;
  final bool? success;
  final int? responseTime;
  final String? correlationId;
  final String request;
  final String response;
  final String? createdAt;

  DryRunRequestLog({
    this.endpointId,
    this.endpointName,
    this.statusCode,
    this.success,
    this.responseTime,
    this.correlationId,
    this.request = '',
    this.response = '',
    this.createdAt,
  });

  factory DryRunRequestLog.fromJson(Map<dynamic, dynamic> json) {
    return DryRunRequestLog(
      endpointId: Flow._toInt(json['endpointId'], -1) == -1
          ? null
          : Flow._toInt(json['endpointId']),
      endpointName: json['endpointName']?.toString(),
      statusCode: Flow._toInt(json['statusCode'], -1) == -1
          ? null
          : Flow._toInt(json['statusCode']),
      success: json['success'] is bool ? json['success'] as bool : null,
      responseTime: Flow._toInt(json['responseTime'], -1) == -1
          ? null
          : Flow._toInt(json['responseTime']),
      correlationId: json['correlationId']?.toString(),
      request: json['request']?.toString() ?? '',
      response: json['response']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
    );
  }
}
