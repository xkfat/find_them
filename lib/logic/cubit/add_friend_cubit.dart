import 'package:find_them/data/repositories/location_sharing_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/models/user_search.dart';

part 'add_friend_state.dart';

class AddFriendCubit extends Cubit<AddFriendState> {
  final LocationSharingRepository _repository;

  AddFriendCubit(this._repository) : super(AddFriendInitial());

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      emit(AddFriendInitial());
      return;
    }

    emit(AddFriendSearching());
    try {
      final results = await _repository.searchUsers(query.trim());
      emit(AddFriendSearchResults(results: results, query: query));
    } catch (e) {
      emit(AddFriendError(e.toString()));
    }
  }

 Future<void> sendLocationRequest(String identifier, int userId) async {
  emit(AddFriendSendingRequest(userId)); 
  try {
    await _repository.sendLocationRequest(identifier);
    emit(AddFriendRequestSent('Location request sent successfully!'));
  } catch (e) {
    emit(AddFriendError(e.toString()));
  }
}

  void resetState() {
    emit(AddFriendInitial());
  }
}