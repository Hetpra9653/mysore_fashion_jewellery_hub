part of 'global_bloc.dart';

@immutable
abstract class GlobalState {}

class GlobalInitial extends GlobalState {}

class GlobalNoConnectivityState extends GlobalState {
  @override
  bool operator ==(Object other) {
    return other is GlobalNoConnectivityState;
  }

  @override
  int get hashCode => -1;
}

class GlobalConnectivityBackState extends GlobalState {
  @override
  bool operator ==(Object other) {
    return other is GlobalConnectivityBackState;
  }

  @override
  int get hashCode => -2;
}

class GlobalAppUpdatedState extends GlobalState {}

class ChangePageToAttendanceState extends GlobalState {}

class ChangePageToProfileState extends GlobalState {
  final bool isNavigateToEditPage;

  ChangePageToProfileState({this.isNavigateToEditPage=false});
}
