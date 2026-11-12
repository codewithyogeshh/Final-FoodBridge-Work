class AuditLogEntry {
  final String id;
  final String actorId;
  final String actorRole;
  final String action;
  final String targetEntity;
  final String targetId;
  final String details;
  final DateTime timestamp;
  final String ipHash;

  const AuditLogEntry({
    required this.id,
    required this.actorId,
    required this.actorRole,
    required this.action,
    required this.targetEntity,
    required this.targetId,
    required this.details,
    required this.timestamp,
    this.ipHash = '103.21.***.***',
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] as String,
      actorId: json['actor_id'] as String,
      actorRole: json['actor_role'] as String,
      action: json['action'] as String,
      targetEntity: json['target_entity'] as String,
      targetId: json['target_id'] as String,
      details: json['details'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ipHash: json['ip_hash'] as String? ?? '103.21.***.***',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actor_id': actorId,
      'actor_role': actorRole,
      'action': action,
      'target_entity': targetEntity,
      'target_id': targetId,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'ip_hash': ipHash,
    };
  }
}
