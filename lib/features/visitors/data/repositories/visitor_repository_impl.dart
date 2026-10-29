import '../../domain/entities/visitor.dart';
import '../../domain/repositories/visitor_repository.dart';
import '../datasources/visitor_remote_data_source.dart';

class VisitorRepositoryImpl implements VisitorRepository {
  VisitorRepositoryImpl(this._remoteDataSource);

  final VisitorRemoteDataSource _remoteDataSource;

  @override
  Future<List<Visitor>> getVisitors() => _remoteDataSource.getVisitors();

  @override
  Future<Visitor> getVisitor(String id) => _remoteDataSource.getVisitor(id);

  @override
  Future<Visitor> createVisitor(Visitor visitor) =>
      _remoteDataSource.createVisitor(visitor);

  @override
  Future<Visitor> updateVisitor(Visitor visitor) =>
      _remoteDataSource.updateVisitor(visitor);

  @override
  Future<void> deleteVisitor(String id) => _remoteDataSource.deleteVisitor(id);

  @override
  Future<Visitor> checkIn(Visitor visitor) {
    if (visitor.status != VisitorStatusValue.registered) {
      throw Exception('Only registered visitors can check in.');
    }
    return _remoteDataSource.checkInVisitor(visitor.id);
  }

  @override
  Future<Visitor> checkOut(Visitor visitor) {
    if (visitor.status != VisitorStatusValue.checkedIn ||
        visitor.checkInTime == null) {
      throw Exception('Only checked-in visitors can check out.');
    }
    return _remoteDataSource.checkOutVisitor(visitor.id);
  }
}
