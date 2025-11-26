class PresenceModel {
  final String id;
  final String userId;
  final String classId;
  final DateTime? timeIn;
  final DateTime? timeOut;
  final double? faceConfidence;

  PresenceModel({
    required this.id,
    required this.userId,
    required this.classId,
    this.timeIn,
    this.timeOut,
    this.faceConfidence,
  });

  factory PresenceModel.fromJson(Map<String, dynamic> json) {
    return PresenceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      classId: json['class_id'] as String,
      timeIn: json['time_in'] != null ? DateTime.parse(json['time_in'] as String) : null,
      timeOut: json['time_out'] != null ? DateTime.parse(json['time_out'] as String) : null,
      faceConfidence: json['face_confidence'] != null ? (json['face_confidence'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'class_id': classId,
      'time_in': timeIn?.toIso8601String(),
      'time_out': timeOut?.toIso8601String(),
      'face_confidence': faceConfidence,
    };
  }

  PresenceModel copyWith({
    String? id,
    String? userId,
    String? classId,
    DateTime? timeIn,
    DateTime? timeOut,
    double? faceConfidence,
  }) {
    return PresenceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      classId: classId ?? this.classId,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      faceConfidence: faceConfidence ?? this.faceConfidence,
    );
  }
}