import 'package:equatable/equatable.dart';

class Visitor extends Equatable {
  const Visitor({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
  });

  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String visitorType;
  final String project;
  final String purpose;
  final String status;
  final DateTime createdAt;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  factory Visitor.fromJson(Map<String, dynamic> json) => Visitor(
    id: '${json['id'] ?? ''}',
    name: '${json['name'] ?? ''}',
    mobile: '${json['mobile'] ?? ''}',
    email: json['email'] as String?,
    visitorType: '${json['visitor_type'] ?? json['visitorType'] ?? 'Other'}',
    project: '${json['project'] ?? 'Project A'}',
    purpose: '${json['purpose'] ?? ''}',
    status: '${json['status'] ?? 'Registered'}',
    createdAt:
        DateTime.tryParse('${json['created_at'] ?? json['createdAt'] ?? ''}') ??
        DateTime.now(),
    checkInTime: DateTime.tryParse(
      '${json['check_in_time'] ?? json['checkInTime'] ?? ''}',
    ),
    checkOutTime: DateTime.tryParse(
      '${json['check_out_time'] ?? json['checkOutTime'] ?? ''}',
    ),
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

  Visitor copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? visitorType,
    String? project,
    String? purpose,
    String? status,
    DateTime? createdAt,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    bool clearEmail = false,
    bool clearCheckIn = false,
    bool clearCheckOut = false,
  }) => Visitor(
    id: id ?? this.id,
    name: name ?? this.name,
    mobile: mobile ?? this.mobile,
    email: clearEmail ? null : (email ?? this.email),
    visitorType: visitorType ?? this.visitorType,
    project: project ?? this.project,
    purpose: purpose ?? this.purpose,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    checkInTime: clearCheckIn ? null : (checkInTime ?? this.checkInTime),
    checkOutTime: clearCheckOut ? null : (checkOutTime ?? this.checkOutTime),
  );

  @override
  List<Object?> get props => [
    id,
    name,
    mobile,
    email,
    visitorType,
    project,
    purpose,
    status,
    createdAt,
    checkInTime,
    checkOutTime,
  ];
}
