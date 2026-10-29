// Tests for the Visitor Management app: visitor model serialization and
// BLoC check-in/check-out status transitions.

import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management_task/bloc/visitor_bloc.dart';
import 'package:visitor_management_task/bloc/visitor_event.dart';
import 'package:visitor_management_task/bloc/visitor_state.dart';
import 'package:visitor_management_task/data/visitor_api.dart';
import 'package:visitor_management_task/data/visitor_repository.dart';
import 'package:visitor_management_task/models/visitor.dart';

Visitor _visitor({
  required String id,
  String status = 'Registered',
  DateTime? checkInTime,
  DateTime? checkOutTime,
}) {
  return Visitor(
    id: id,
    name: 'Visitor $id',
    mobile: '1234567890',
    email: null,
    visitorType: 'Customer',
    project: 'Project A',
    purpose: 'Testing purpose',
    status: status,
    createdAt: DateTime(2026, 10, 29),
    checkInTime: checkInTime,
    checkOutTime: checkOutTime,
  );
}

class _FakeVisitorApi extends VisitorApi {
  final Map<String, Visitor> _visitors = {};

  @override
  Future<List<Visitor>> getVisitors() async => _visitors.values.toList();

  @override
  Future<Visitor> getVisitor(String id) async {
    final visitor = _visitors[id];
    if (visitor == null) {
      throw Exception('Visitor not found.');
    }
    return visitor;
  }

  @override
  Future<Visitor> createVisitor(Visitor visitor) async {
    final created = visitor.copyWith(id: 'created-${_visitors.length + 1}');
    _visitors[created.id] = created;
    return created;
  }

  @override
  Future<Visitor> updateVisitor(Visitor visitor) async {
    _visitors[visitor.id] = visitor;
    return visitor;
  }

  @override
  Future<void> deleteVisitor(String id) async {
    _visitors.remove(id);
  }

  @override
  Future<Visitor> checkInVisitor(String id) async {
    final current = await getVisitor(id);
    if (current.status != 'Registered') {
      throw Exception('Only registered visitors can check in.');
    }
    final updated = current.copyWith(
      status: 'Checked In',
      checkInTime: DateTime.now(),
      clearCheckOut: true,
    );
    _visitors[id] = updated;
    return updated;
  }

  @override
  Future<Visitor> checkOutVisitor(String id) async {
    final current = await getVisitor(id);
    if (current.status != 'Checked In') {
      throw Exception('Only checked-in visitors can check out.');
    }
    final updated = current.copyWith(
      status: 'Checked Out',
      checkOutTime: DateTime.now(),
    );
    _visitors[id] = updated;
    return updated;
  }
}

VisitorBloc _buildBloc() {
  final api = _FakeVisitorApi();
  api._visitors['v-1'] = _visitor(id: 'v-1');
  api._visitors['v-2'] = _visitor(
    id: 'v-2',
    status: 'Checked In',
    checkInTime: DateTime(2026, 10, 29, 9, 0),
  );
  return VisitorBloc(VisitorRepository(api));
}

void main() {
  group('Visitor model', () {
    test('fromJson maps snake_case API fields', () {
      final visitor = Visitor.fromJson({
        'id': '1',
        'name': 'Krishna',
        'mobile': '9685474446',
        'email': null,
        'visitor_type': 'Customer',
        'project': 'Project A',
        'purpose': 'Helo',
        'status': 'Checked Out',
        'created_at': '2026-10-28T13:25:29.148581',
        'check_in_time': '2026-10-28T14:04:52.981832',
        'check_out_time': '2026-10-28T14:05:04.239583',
      });

      expect(visitor.id, '1');
      expect(visitor.name, 'Krishna');
      expect(visitor.mobile, '9685474446');
      expect(visitor.email, isNull);
      expect(visitor.visitorType, 'Customer');
      expect(visitor.project, 'Project A');
      expect(visitor.purpose, 'Helo');
      expect(visitor.status, 'Checked Out');
      expect(visitor.createdAt, DateTime.parse('2026-10-28T13:25:29.148581'));
      expect(visitor.checkInTime, DateTime.parse('2026-10-28T14:04:52.981832'));
      expect(
        visitor.checkOutTime,
        DateTime.parse('2026-10-28T14:05:04.239583'),
      );
    });

    test('toJson uses snake_case API keys without the local id', () {
      final json = _visitor(id: '1').toJson();

      expect(json['visitor_type'], 'Customer');
      expect(json['created_at'], isA<String>());
      expect(json.containsKey('id'), isFalse);
      expect(json['status'], 'Registered');
    });

    test('copyWith applies status transitions', () {
      final checkedIn = _visitor(id: '1').copyWith(
        status: 'Checked In',
        checkInTime: DateTime.now(),
        clearCheckOut: true,
      );

      expect(checkedIn.status, 'Checked In');
      expect(checkedIn.checkInTime, isNotNull);
      expect(checkedIn.checkOutTime, isNull);
    });
  });

  group('VisitorBloc check-in / check-out transitions', () {
    test('loads visitors from the repository', () async {
      final bloc = _buildBloc();
      final states = <VisitorState>[];
      final subscription = bloc.stream.listen(states.add);
      addTearDown(subscription.cancel);

      bloc.add(const VisitorsRequested());
      final state = await bloc.stream.firstWhere(
        (s) => s.status == VisitorStatus.loaded,
      );

      expect(state.status, VisitorStatus.loaded);
      expect(state.visitors.length, 2);
    });

    test('checks in a registered visitor and refreshes the list', () async {
      final bloc = _buildBloc();
      bloc.add(const VisitorsRequested());
      final before = await bloc.stream.firstWhere(
        (s) => s.status == VisitorStatus.loaded,
      );
      expect(
        before.visitors.firstWhere((v) => v.id == 'v-1').status,
        'Registered',
      );

      bloc.add(const VisitorCheckInRequested('v-1'));
      final after = await bloc.stream.firstWhere(
        (s) => s.status == VisitorStatus.loaded,
      );

      expect(after.message, 'Visitor checked in successfully.');
      expect(
        after.visitors.firstWhere((v) => v.id == 'v-1').status,
        'Checked In',
      );
    });

    test('checks out a checked in visitor', () async {
      final bloc = _buildBloc();
      bloc.add(const VisitorsRequested());
      await bloc.stream.firstWhere((s) => s.status == VisitorStatus.loaded);

      bloc.add(const VisitorCheckOutRequested('v-2'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == VisitorStatus.loaded,
      );

      expect(state.message, 'Visitor checked out successfully.');
      expect(
        state.visitors.firstWhere((v) => v.id == 'v-2').status,
        'Checked Out',
      );
    });

    test('rejects a repeated check-in for a checked in visitor', () async {
      final bloc = _buildBloc();
      bloc.add(const VisitorsRequested());
      await bloc.stream.firstWhere((s) => s.status == VisitorStatus.loaded);

      bloc.add(const VisitorCheckInRequested('v-2'));
      final state = await bloc.stream.firstWhere(
        (s) => s.status == VisitorStatus.failure,
      );

      expect(state.message, 'Only registered visitors can check in.');
    });
  });
}
