/// Agent log entry model for tracking agent actions
class AgentLogEntry {
  final DateTime timestamp;
  final AgentLogType type;
  final String message;
  final Map<String, dynamic>? data;

  AgentLogEntry({
    DateTime? timestamp,
    required this.type,
    required this.message,
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
    return '[$timeStr] ${type.label}: $message';
  }
}

enum AgentLogType {
  perceive,
  plan,
  act,
  reflect,
  present,
  error,
  info;

  String get label {
    switch (this) {
      case AgentLogType.perceive:
        return '👁️ PERCEIVE';
      case AgentLogType.plan:
        return '🧠 PLAN';
      case AgentLogType.act:
        return '⚡ ACT';
      case AgentLogType.reflect:
        return '🤔 REFLECT';
      case AgentLogType.present:
        return '🎨 PRESENT';
      case AgentLogType.error:
        return '❌ ERROR';
      case AgentLogType.info:
        return 'ℹ️ INFO';
    }
  }

  String get emoji {
    switch (this) {
      case AgentLogType.perceive:
        return '👁️';
      case AgentLogType.plan:
        return '🧠';
      case AgentLogType.act:
        return '⚡';
      case AgentLogType.reflect:
        return '🤔';
      case AgentLogType.present:
        return '🎨';
      case AgentLogType.error:
        return '❌';
      case AgentLogType.info:
        return 'ℹ️';
    }
  }
}

