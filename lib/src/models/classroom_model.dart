class ClassroomModel {
  final String id;
  final String className;
  final String teacherName;

  ClassroomModel({
    required this.id,
    required this.className,
    required this.teacherName,
  });

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      id: json['id'] as String,
      className: json['class_name'] as String,
      teacherName: json['teacher_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_name': className,
      'teacher_name': teacherName,
    };
  }

  ClassroomModel copyWith({
    String? id,
    String? className,
    String? teacherName,
  }) {
    return ClassroomModel(
      id: id ?? this.id,
      className: className ?? this.className,
      teacherName: teacherName ?? this.teacherName,
    );
  }
}