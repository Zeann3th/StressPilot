import 'package:flutter/widgets.dart';

class PilotIntent extends Intent {
  final String actionId;

  const PilotIntent(this.actionId);
}

class PilotAction extends Action<PilotIntent> {
  final Map<String, void Function()> handlers;

  PilotAction(this.handlers);

  @override
  Object? invoke(PilotIntent intent) {
    final handler = handlers[intent.actionId];
    if (handler != null) {
      handler();
    }
    return null;
  }

  @override
  bool isEnabled(covariant PilotIntent intent) {
    return handlers.containsKey(intent.actionId);
  }
}
