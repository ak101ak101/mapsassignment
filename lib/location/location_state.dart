part of 'location_bloc.dart';

@immutable
abstract class LocationState {}

class LocationInitial extends LocationState {}

class currentLocationstate extends LocationState {
  Position position;

  currentLocationstate(this.position);
}
