import 'package:equatable/equatable.dart';

abstract final class VisitorStatusValue {
  static const registered = 'Registered';
  static const checkedIn = 'Checked In';
  static const checkedOut = 'Checked Out';
}

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
