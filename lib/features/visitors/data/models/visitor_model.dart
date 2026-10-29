import '../../domain/entities/visitor.dart';

class VisitorModel extends Visitor {
  const VisitorModel({
    required super.id,
    required super.name,
    required super.mobile,
    super.email,
    required super.visitorType,
    required super.project,
    required super.purpose,
    required super.status,
    required super.createdAt,
    super.checkInTime,
    super.checkOutTime,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(
      '${json['created_at'] ?? json['createdAt'] ?? ''}',
    );

    return VisitorModel(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      mobile: '${json['mobile'] ?? ''}',
      email: json['email'] as String?,
      visitorType: '${json['visitor_type'] ?? json['visitorType'] ?? 'Other'}',
      project: '${json['project'] ?? 'Project A'}',
      purpose: '${json['purpose'] ?? ''}',
      status: '${json['status'] ?? VisitorStatusValue.registered}',
      createdAt: createdAt ?? DateTime.now(),
      checkInTime: DateTime.tryParse(
        '${json['check_in_time'] ?? json['checkInTime'] ?? ''}',
      ),
      checkOutTime: DateTime.tryParse(
        '${json['check_out_time'] ?? json['checkOutTime'] ?? ''}',
      ),
    );
  }

  factory VisitorModel.fromEntity(Visitor visitor) => VisitorModel(
    id: visitor.id,
    name: visitor.name,
    mobile: visitor.mobile,
    email: visitor.email,
    visitorType: visitor.visitorType,
    project: visitor.project,
    purpose: visitor.purpose,
    status: visitor.status,
    createdAt: visitor.createdAt,
    checkInTime: visitor.checkInTime,
    checkOutTime: visitor.checkOutTime,
  );

  Map<String, dynamic> toJson({bool includeId = false}) => {
    if (includeId) 'id': id,
    'name': name,
    'mobile': mobile,
    'email': email,
    'visitor_type': visitorType,
    'project': project,
    'purpose': purpose,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'check_in_time': checkInTime?.toIso8601String(),
    'check_out_time': checkOutTime?.toIso8601String(),
  };
}
