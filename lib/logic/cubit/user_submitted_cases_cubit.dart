import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/dataprovider/exception.dart';
import 'package:find_them/data/models/submitted_case.dart';
import 'package:find_them/data/repositories/submitted_cases_repo.dart';

part 'user_submitted_cases_state.dart';

class UserSubmittedCasesCubit extends Cubit<UserSubmittedCasesState> {
  final SubmittedCaseRepository repository;
  
  UserSubmittedCasesCubit(this.repository) : super(UserSubmittedCasesInitial());

  Future<void> getSubmittedCases() async {
    emit(UserSubmittedCasesLoading());
    try {
      log("Fetching user submitted cases");
      
      final cases = await repository.getSubmittedCases();
      emit(UserSubmittedCasesLoaded(cases: cases));
      
    } on UnauthorisedException catch (e) {
      emit(UserSubmittedCasesError("Authentication error: $e"));
    } on SocketException {
      emit(UserSubmittedCasesError("Network error: Check your internet connection"));
    } on TimeoutException {
      emit(UserSubmittedCasesError("Connection timed out"));
    } catch (e) {
      emit(UserSubmittedCasesError("An unexpected error occurred: $e"));
    }
  }
}