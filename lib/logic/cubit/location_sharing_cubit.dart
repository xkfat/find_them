import 'package:find_them/data/repositories/location_sharing_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/location_request.dart';
import '../../data/models/location_sharing.dart';

part 'location_sharing_state.dart';

class LocationSharingCubit extends Cubit<LocationSharingState> {
  final LocationSharingRepository _repository;

  LocationSharingCubit(this._repository) : super(LocationSharingInitial());

  Future<void> loadLocationData() async {
    emit(LocationSharingLoading());
    try {
      final requests = await _repository.getPendingRequests();
      final friends = await _repository.getFriends();

      emit(LocationSharingLoaded(requests: requests, friends: friends));
    } catch (e) {
      emit(LocationSharingError(e.toString()));
    }
  }

  Future<void> acceptRequest(int requestId) async {
    try {
      await _repository.acceptRequest(requestId);
      emit(LocationSharingActionSuccess('Request accepted'));
      await loadLocationData();
    } catch (e) {
      emit(LocationSharingError(e.toString()));
    }
  }

  Future<void> declineRequest(int requestId) async {
    try {
      await _repository.declineRequest(requestId);
      emit(LocationSharingActionSuccess('Request declined'));
      await loadLocationData();
    } catch (e) {
      emit(LocationSharingError(e.toString()));
    }
  }

  Future<void> removeFriend(int friendId) async {
    try {
      await _repository.removeFriend(friendId);
       emit(LocationSharingActionSuccess('Friend removed'));
      await loadLocationData();
    } catch (e) {
      emit(LocationSharingError(e.toString()));
    }
  }

  Future<bool> sendAlert(int friendId) async {
    try {
      await _repository.sendAlert(friendId);
      return true;
    } catch (e) {
      emit(LocationSharingError(e.toString()));
      return false;
    }
  }

  Future<void> sendLocationRequest(String identifier) async {
    try {
      await _repository.sendLocationRequest(identifier);
      emit(LocationSharingActionSuccess('Request sent'));
      await loadLocationData();
    } catch (e) {
      emit(LocationSharingError(e.toString()));
    }
  }

  Future<void> toggleLocationSharing(int friendId, bool shouldShare) async {
    try {
      emit(LocationSharingLoading());

      await _repository.toggleLocationSharing(friendId, shouldShare);

      await loadLocationData();
    } catch (e) {
      emit(LocationSharingError(e.toString()));
    }
  }
}
