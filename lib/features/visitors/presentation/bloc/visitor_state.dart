import 'package:equatable/equatable.dart';
import 'package:visitor_management_task/features/visitors/domain/entities/visitor.dart';

enum VisitorStatus { initial, loading, loaded, submitting, failure }

class VisitorState extends Equatable {
  const VisitorState({
    this.status = VisitorStatus.initial,
    this.visitors = const [],
    this.searchQuery = '',
    this.selectedVisitor,
    this.message,
  });
  final VisitorStatus status;
  final List<Visitor> visitors;
  final String searchQuery;
  final Visitor? selectedVisitor;
  final String? message;

  List<Visitor> get filteredVisitors {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return visitors;
    return visitors
        .where((v) => v.name.toLowerCase().contains(q) || v.mobile.contains(q))
        .toList();
  }

  int get totalToday {
    final now = DateTime.now();
    return visitors
        .where(
          (v) =>
              v.createdAt.year == now.year &&
              v.createdAt.month == now.month &&
              v.createdAt.day == now.day,
        )
        .length;
  }

  int get checkedIn =>
      visitors.where((v) => v.status == VisitorStatusValue.checkedIn).length;
  int get checkedOutToday {
    final now = DateTime.now();
    return visitors
        .where(
          (v) =>
              v.checkOutTime != null &&
              v.checkOutTime!.year == now.year &&
              v.checkOutTime!.month == now.month &&
              v.checkOutTime!.day == now.day,
        )
        .length;
  }

  VisitorState copyWith({
    VisitorStatus? status,
    List<Visitor>? visitors,
    String? searchQuery,
    Visitor? selectedVisitor,
    bool clearSelected = false,
    String? message,
  }) => VisitorState(
    status: status ?? this.status,
    visitors: visitors ?? this.visitors,
    searchQuery: searchQuery ?? this.searchQuery,
    selectedVisitor: clearSelected
        ? null
        : (selectedVisitor ?? this.selectedVisitor),
    message: message,
  );
  @override
  List<Object?> get props => [
    status,
    visitors,
    searchQuery,
    selectedVisitor,
    message,
  ];
}
