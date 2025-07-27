part of 'global_bloc.dart';

@immutable
abstract class GlobalEvent {}

class NoConnectivityEvent extends GlobalEvent {}

class GlobalNetworkAvailableEvent extends GlobalEvent {}

class GlobalAppUpdatedEvent extends GlobalEvent {}

class ChangePageToAttendanceEvent extends GlobalEvent {}

class ChangePageToProfileEvent extends GlobalEvent {
  final bool isNavigateToEditPage;

  ChangePageToProfileEvent({this.isNavigateToEditPage=false});
}
