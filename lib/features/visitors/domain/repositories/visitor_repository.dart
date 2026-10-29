import '../entities/visitor.dart';

abstract interface class VisitorRepository {
  Future<List<Visitor>> getVisitors();
  Future<Visitor> getVisitor(String id);
  Future<Visitor> createVisitor(Visitor visitor);
  Future<Visitor> updateVisitor(Visitor visitor);
  Future<void> deleteVisitor(String id);
  Future<Visitor> checkIn(Visitor visitor);
  Future<Visitor> checkOut(Visitor visitor);
}
