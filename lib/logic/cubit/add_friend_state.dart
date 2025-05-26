part of 'add_friend_cubit.dart';

sealed class AddFriendState extends Equatable {
  const AddFriendState();

  @override
  List<Object> get props => [];
}

final class AddFriendInitial extends AddFriendState {}

final class AddFriendSearching extends AddFriendState {}

final class AddFriendSearchResults extends AddFriendState {
  final List<UserSearchModel> results;
  final String query;

  const AddFriendSearchResults({
    required this.results,
    required this.query,
  });

  @override
  List<Object> get props => [results, query];
}

final class AddFriendSendingRequest extends AddFriendState {
  final int userId;

  const AddFriendSendingRequest(this.userId);

  @override
  List<Object> get props => [userId];
}

final class AddFriendRequestSent extends AddFriendState {
  final String message;

  const AddFriendRequestSent(this.message);

  @override
  List<Object> get props => [message];
}

final class AddFriendError extends AddFriendState {
  final String message;

  const AddFriendError(this.message);

  @override
  List<Object> get props => [message];
}