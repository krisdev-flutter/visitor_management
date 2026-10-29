import 'package:visitor_management_task/models/visitor.dart';
import 'package:visitor_management_task/data/visitor_api.dart';

class VisitorRepository {
  VisitorRepository(this._api);
  final VisitorApi _api;
  Future<List<Visitor>> getVisitors() => _api.getVisitors();
  Future<Visitor> getVisitor(String id) => _api.getVisitor(id);
  Future<Visitor> createVisitor(Visitor visitor) => _api.createVisitor(visitor);
  Future<Visitor> updateVisitor(Visitor visitor) => _api.updateVisitor(visitor);
  Future<void> deleteVisitor(String id) => _api.deleteVisitor(id);

  Future<Visitor> checkIn(Visitor visitor) {
    if (visitor.status != 'Registered') {
      throw Exception('Only registered visitors can check in.');
    }
    return _api.checkInVisitor(visitor.id);
  }

  Future<Visitor> checkOut(Visitor visitor) {
    if (visitor.status != 'Checked In' || visitor.checkInTime == null) {
      throw Exception('Only checked-in visitors can check out.');
    }
    return _api.checkOutVisitor(visitor.id);
  }
}
