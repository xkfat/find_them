import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/repositories/auth_repo.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  AuthRepository _authRepository;

  SignUpCubit(this._authRepository) : super(SignUpInitial());

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(SignUpLoading());
    try {
      print("Processing signup request");

      var responseData = await _authRepository.signup(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      print("Signup response data: $responseData");

      if (responseData is Map) {
        if (responseData.containsKey("refresh") &&
            responseData.containsKey("access")) {
          print("Success detected - emitting SignUploaded state");
          emit(SignUploaded());
          return;
        }

        if (responseData.containsKey("user")) {
          print("User object found - emitting SignUploaded state");
          emit(SignUploaded());
          return;
        }

        if (responseData.containsKey("field") &&
            responseData.containsKey("message")) {
          String field = responseData["field"];
          String message = responseData["message"];
          print("Field error detected: $field - $message");

          emit(SignUpFieldError(field: field, message: message));
          return;
        }

        if (responseData.containsKey("message")) {
          String messageValue = responseData["message"];

          String errorMessage;
          if (messageValue is String) {
            errorMessage = messageValue;
          } else if (messageValue is Map) {
            errorMessage = messageValue.toString();
          } else {
            errorMessage = "Unknown error format: $messageValue";
          }
          print("Error message: $errorMessage");

          if (errorMessage.toLowerCase().contains("username") &&
              (errorMessage.toLowerCase().contains("already") ||
                  errorMessage.toLowerCase().contains("taken"))) {
            emit(
              SignUpFieldError(
                field: "username",
                message: "Username is already taken",
              ),
            );
            return;
          }

          if (errorMessage.toLowerCase().contains("email") &&
              (errorMessage.toLowerCase().contains("already") ||
                  errorMessage.toLowerCase().contains("taken") ||
                  errorMessage.toLowerCase().contains("in use"))) {
            emit(
              SignUpFieldError(
                field: "email",
                message: "Email is already in use",
              ),
            );
            return;
          }
          emit(SignUperreur(errorMessage));
          return;
        }
      }
      emit(SignUperreur("An unexpected error occurred. Please try again."));
    } catch (e) {
      print("Exception during signup: ${e.toString()}");
    }
  }
}
