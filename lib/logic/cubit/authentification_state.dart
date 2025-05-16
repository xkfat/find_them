part of 'authentification_cubit.dart';

sealed class AuthentificationState extends Equatable {
  const AuthentificationState();

  @override
  List<Object> get props => [];
}

final class AuthentificationInitial extends AuthentificationState {}

class AuthentificationLoading extends AuthentificationState {}

class Authentificationloaded extends AuthentificationState {
  
}

class Authentificationerreur extends AuthentificationState {
   String msg;
   Authentificationerreur(this.msg);
}
