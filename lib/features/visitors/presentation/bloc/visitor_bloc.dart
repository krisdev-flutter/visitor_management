import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visitor_management_task/features/visitors/domain/repositories/visitor_repository.dart';
import 'package:visitor_management_task/features/visitors/domain/entities/visitor.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_event.dart';
import 'package:visitor_management_task/features/visitors/presentation/bloc/visitor_state.dart';

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  VisitorBloc(this._repository) : super(const VisitorState()) {
    on<VisitorsRequested>(_load);
    on<VisitorCreated>(_create);
    on<VisitorUpdated>(_update);
    on<VisitorDeleted>(_delete);
    on<VisitorCheckInRequested>(_checkIn);
    on<VisitorCheckOutRequested>(_checkOut);
    on<VisitorByIdRequested>(_getById);
    on<VisitorSearchChanged>(
      (event, emit) => emit(
        state.copyWith(searchQuery: event.query, status: VisitorStatus.loaded),
      ),
    );
  }
  final VisitorRepository _repository;
  Future<Visitor> lookupVisitor(String id) => _repository.getVisitor(id);
  Future<void> _load(
    VisitorsRequested event,
    Emitter<VisitorState> emit,
  ) async {
    emit(state.copyWith(status: VisitorStatus.loading, message: null));
    try {
      emit(
        state.copyWith(
          status: VisitorStatus.loaded,
          visitors: await _repository.getVisitors(),
          message: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: VisitorStatus.failure, message: _message(e)));
    }
  }

  Future<void> _create(VisitorCreated event, Emitter<VisitorState> emit) async {
    emit(state.copyWith(status: VisitorStatus.submitting, message: null));
    try {
      await _repository.createVisitor(event.visitor);
      await _refresh(emit, 'Visitor registered successfully.');
    } catch (e) {
      emit(state.copyWith(status: VisitorStatus.failure, message: _message(e)));
    }
  }

  Future<void> _update(VisitorUpdated event, Emitter<VisitorState> emit) async {
    emit(state.copyWith(status: VisitorStatus.submitting, message: null));
    try {
      await _repository.updateVisitor(event.visitor);
      await _refresh(emit, 'Visitor updated successfully.');
    } catch (e) {
      emit(state.copyWith(status: VisitorStatus.failure, message: _message(e)));
    }
  }

  Future<void> _delete(VisitorDeleted event, Emitter<VisitorState> emit) async {
    emit(state.copyWith(status: VisitorStatus.submitting, message: null));
    try {
      await _repository.deleteVisitor(event.id);
      await _refresh(emit, 'Visitor deleted successfully.');
    } catch (e) {
      emit(state.copyWith(status: VisitorStatus.failure, message: _message(e)));
    }
  }

  Future<void> _checkIn(
    VisitorCheckInRequested event,
    Emitter<VisitorState> emit,
  ) async {
    final visitor = _find(event.id);
    if (visitor == null) {
      emit(
        state.copyWith(
          status: VisitorStatus.failure,
          message: 'Visitor not found.',
        ),
      );
      return;
    }
    emit(state.copyWith(status: VisitorStatus.submitting, message: null));
    try {
      await _repository.checkIn(visitor);
      await _refresh(emit, 'Visitor checked in successfully.');
    } catch (e) {
      emit(state.copyWith(status: VisitorStatus.failure, message: _message(e)));
    }
  }

  Future<void> _checkOut(
    VisitorCheckOutRequested event,
    Emitter<VisitorState> emit,
  ) async {
    final visitor = _find(event.id);
    if (visitor == null) {
      emit(
        state.copyWith(
          status: VisitorStatus.failure,
          message: 'Visitor not found.',
        ),
      );
      return;
    }
    emit(state.copyWith(status: VisitorStatus.submitting, message: null));
    try {
      await _repository.checkOut(visitor);
      await _refresh(emit, 'Visitor checked out successfully.');
    } catch (e) {
      emit(state.copyWith(status: VisitorStatus.failure, message: _message(e)));
    }
  }

  Future<void> _getById(
    VisitorByIdRequested event,
    Emitter<VisitorState> emit,
  ) async {
    emit(
      state.copyWith(
        status: VisitorStatus.loading,
        clearSelected: true,
        message: null,
      ),
    );
    try {
      final visitor = await _repository.getVisitor(event.id);
      emit(
        state.copyWith(
          status: VisitorStatus.loaded,
          selectedVisitor: visitor,
          message: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: VisitorStatus.failure, message: _message(e)));
    }
  }

  Visitor? _find(String id) {
    for (final visitor in state.visitors) {
      if (visitor.id == id) return visitor;
    }
    return null;
  }

  Future<void> _refresh(Emitter<VisitorState> emit, String success) async {
    final visitors = await _repository.getVisitors();
    emit(
      state.copyWith(
        status: VisitorStatus.loaded,
        visitors: visitors,
        message: success,
      ),
    );
  }

  String _message(Object e) => e.toString().replaceFirst('Exception: ', '');
}
