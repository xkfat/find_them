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

  // NEW SIMPLIFIED METHODS

  /// Toggle global location sharing (for settings screen)
  Future<void> toggleGlobalSharing(bool isSharing) async {
    try {
      emit(LocationSharingLoading());
      await _repository.toggleGlobalSharing(isSharing);
      
      final message = isSharing 
          ? 'Location sharing enabled' 
          : 'Location sharing disabled';
      emit(LocationSharingActionSuccess(message));
      
      // Don't reload location data here as this is for settings screen
    } catch (e) {
      emit(LocationSharingError(e.toString()));
    }
  }

  /// Toggle sharing with a specific friend (can_see_me)
  Future<void> toggleFriendSharing(int friendId, bool canSeeMe) async {
    try {
      // Optimistic update
      final currentState = state;
      if (currentState is LocationSharingLoaded) {
        final updatedFriends = currentState.friends.map((friend) {
          if (friend.friendId == friendId) {
            // Create updated friend with new canSeeYou status
            return LocationSharingModel(
              id: friend.id,
              userId: friend.userId,
              friendId: friend.friendId,
              createdAt: friend.createdAt,
              friendDetails: friend.friendDetails,
              isSharing: friend.isSharing,
              canSeeYou: canSeeMe,
            );
          }
          return friend;
        }).toList();
        
        // Emit optimistic update
        emit(LocationSharingLoaded(
          requests: currentState.requests,
          friends: updatedFriends,
        ));
      }

      // Make API call
      await _repository.toggleFriendSharing(friendId, canSeeMe);
      
      final message = canSeeMe 
          ? 'Now sharing location with friend' 
          : 'Stopped sharing location with friend';
      emit(LocationSharingActionSuccess(message));
      
      // Reload to get actual server state
      await loadLocationData();
    } catch (e) {
      emit(LocationSharingError(e.toString()));
      // Reload on error to revert optimistic update
      await loadLocationData();
    }
  }

  /// Get current sharing settings (for settings screen)
  Future<Map<String, dynamic>?> getSharingSettings() async {
    try {
      return await _repository.getSharingSettings();
    } catch (e) {
      emit(LocationSharingError(e.toString()));
      return null;
    }
  }
}