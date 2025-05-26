part of 'location_sharing_cubit.dart';

sealed class LocationSharingState extends Equatable {
  const LocationSharingState();

  @override
  List<Object> get props => [];
}

final class LocationSharingInitial extends LocationSharingState {}

final class LocationSharingLoading extends LocationSharingState {}

final class LocationSharingLoaded extends LocationSharingState {
  final List<LocationRequestModel> requests;
  final List<LocationSharingModel> friends;

  const LocationSharingLoaded({
    required this.requests,
    required this.friends,
  });

  @override
  List<Object> get props => [requests, friends];
}

final class LocationSharingError extends LocationSharingState {
  final String message;

  const LocationSharingError(this.message);

  @override
  List<Object> get props => [message];
}

final class LocationSharingActionLoading extends LocationSharingState {}

final class LocationSharingActionSuccess extends LocationSharingState {
  final String message;

  const LocationSharingActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}