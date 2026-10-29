import 'package:equatable/equatable.dart';
import 'package:visitor_management_task/models/visitor.dart';

abstract class VisitorEvent extends Equatable {
  const VisitorEvent();
  @override
  List<Object?> get props => [];
}

class VisitorsRequested extends VisitorEvent {
  const VisitorsRequested();
}

class VisitorCreated extends VisitorEvent {
  const VisitorCreated(this.visitor);
  final Visitor visitor;
  @override
  List<Object?> get props => [visitor];
}

class VisitorUpdated extends VisitorEvent {
  const VisitorUpdated(this.visitor);
  final Visitor visitor;
  @override
  List<Object?> get props => [visitor];
}

class VisitorDeleted extends VisitorEvent {
  const VisitorDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class VisitorCheckInRequested extends VisitorEvent {
  const VisitorCheckInRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class VisitorCheckOutRequested extends VisitorEvent {
  const VisitorCheckOutRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class VisitorByIdRequested extends VisitorEvent {
  const VisitorByIdRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class VisitorSearchChanged extends VisitorEvent {
  const VisitorSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}
