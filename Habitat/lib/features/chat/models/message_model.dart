class MessageModel {
  final String id;
  final String? moduleId;
  final String userId;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    this.moduleId,
    required this.userId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      moduleId: json['module_id'] as String?,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      if (moduleId != null) 'module_id': moduleId,
      'user_id': userId,
      'role': role,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
