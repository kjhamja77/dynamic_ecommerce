import 'dart:developer' as developer;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/refund_request.dart';
import '../../domain/usecases/get_refund_requests.dart';

abstract class RefundRequestsEvent extends Equatable {
  const RefundRequestsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRefundRequests extends RefundRequestsEvent {
  final int page;

  const LoadRefundRequests({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class RefreshRefundRequests extends RefundRequestsEvent {
  final int page;

  const RefreshRefundRequests({this.page = 1});

  @override
  List<Object?> get props => [page];
}

abstract class RefundRequestsState extends Equatable {
  const RefundRequestsState();

  @override
  List<Object?> get props => [];
}

class RefundRequestsInitial extends RefundRequestsState {
  const RefundRequestsInitial();
}

class RefundRequestsLoading extends RefundRequestsState {
  const RefundRequestsLoading();
}

class RefundRequestsLoaded extends RefundRequestsState {
  final List<RefundRequest> requests;

  const RefundRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class RefundRequestsError extends RefundRequestsState {
  final String message;

  const RefundRequestsError(this.message);

  @override
  List<Object?> get props => [message];
}

class RefundRequestsBloc
    extends Bloc<RefundRequestsEvent, RefundRequestsState> {
  final GetRefundRequests getRefundRequests;

  RefundRequestsBloc({required this.getRefundRequests})
      : super(const RefundRequestsInitial()) {
    on<LoadRefundRequests>(_onLoadRefundRequests);
    on<RefreshRefundRequests>(_onRefreshRefundRequests);
  }

  Future<void> _onLoadRefundRequests(
    LoadRefundRequests event,
    Emitter<RefundRequestsState> emit,
  ) async {
    developer.log('📦 Loading refund requests (page: ${event.page})...');
    emit(const RefundRequestsLoading());

    try {
      final result =
          await getRefundRequests(GetRefundRequestsParams(page: event.page));

      result.fold(
        (failure) {
          final message =
              failure.message ?? 'Failed to load refund requests';
          developer.log('❌ Failed to load refund requests: $message');
          emit(RefundRequestsError(message));
        },
        (requests) {
          developer.log(
            '✅ Refund requests loaded: ${requests.length} items',
          );
          emit(RefundRequestsLoaded(requests));
        },
      );
    } catch (e) {
      developer.log('💥 Exception while loading refund requests: $e');
      emit(
        RefundRequestsError('Failed to load refund requests: $e'),
      );
    }
  }

  Future<void> _onRefreshRefundRequests(
    RefreshRefundRequests event,
    Emitter<RefundRequestsState> emit,
  ) async {
    developer.log('🔄 Refreshing refund requests (page: ${event.page})...');
    add(LoadRefundRequests(page: event.page));
  }
}

