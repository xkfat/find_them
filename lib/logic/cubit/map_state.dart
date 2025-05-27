part of 'map_cubit.dart';

sealed class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

final class MapInitial extends MapState {}

final class MapLoading extends MapState {}

final class MapLocationPermissionRequired extends MapState {}

final class MapDataLoaded extends MapState {
  final List<Case> cases;
  final List<UserLocationModel> friendsLocations;
  final List<LocationSharingModel> friends;
  final Position? currentPosition;

  const MapDataLoaded({
    required this.cases,
    required this.friendsLocations,
    required this.friends,
    this.currentPosition,
  });

  @override
  List<Object?> get props => [cases, friendsLocations, friends, currentPosition];
}

final class MapLocationUpdated extends MapState {
  final Position position;

  const MapLocationUpdated(this.position);

  @override
  List<Object?> get props => [position];
}

final class MapAlertSent extends MapState {
  final String message;

  const MapAlertSent(this.message);

  @override
  List<Object?> get props => [message];
}

final class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}