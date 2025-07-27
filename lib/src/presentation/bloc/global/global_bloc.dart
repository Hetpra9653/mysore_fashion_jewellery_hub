import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'global_event.dart';

part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  bool _connectivityGone = false;

  GlobalBloc() : super(GlobalInitial()) {
    on<NoConnectivityEvent>(_noConnectivity);
    on<GlobalNetworkAvailableEvent>(_networkAvailable);
    on<GlobalAppUpdatedEvent>(_globalAppUpdated);
    on<ChangePageToAttendanceEvent>(_changePageToAttendanceEvent);
    on<ChangePageToProfileEvent>(_changePageToProfileEvent);
  }

  FutureOr<void> _noConnectivity(NoConnectivityEvent event, Emitter<GlobalState> emit) {
    _connectivityGone = true;
    emit(GlobalNoConnectivityState());
  }

  FutureOr<void> _networkAvailable(GlobalNetworkAvailableEvent event, Emitter<GlobalState> emit) {
    if (_connectivityGone) {
      _connectivityGone = false;

      emit(GlobalConnectivityBackState());
    }
  }

  FutureOr<void> _globalAppUpdated(GlobalAppUpdatedEvent event, Emitter<GlobalState> emit) async {
    emit(GlobalAppUpdatedState());
  }

  FutureOr<void> _changePageToAttendanceEvent(ChangePageToAttendanceEvent event, Emitter<GlobalState> emit) async {
    emit(ChangePageToAttendanceState());
  }

  FutureOr<void> _changePageToProfileEvent(ChangePageToProfileEvent event, Emitter<GlobalState> emit) async {
    emit(ChangePageToProfileState(isNavigateToEditPage: event.isNavigateToEditPage));
  }
}
