import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/dataprovider/exception.dart';
import 'package:find_them/data/models/case.dart';
import 'package:find_them/data/repositories/case_repo.dart';

part 'submit_case_state.dart';

class SubmitCaseCubit extends Cubit<SubmitCaseState> {
  CaseRepository _submitCaseRepository;
  SubmitCaseCubit(this._submitCaseRepository) : super(SubmitCaseInitial()); 


  Future<void> submitCase(  String firstName,
     String lastName,
     int age,
     String gender,
     File photo,
     String description,
     DateTime lastSeenDate,
     String lastSeenLocation,
      String contactPhone,
    double? latitude,
    double? longitude, ) async {
    emit(SubmitCaseLoading());
    try {
      log("Checking authentication status");

      final caseObject  = await _submitCaseRepository.submitCase(
        firstName: firstName,
       lastName: lastName,
         age: age,
        gender: gender,
        photo: photo,
         description: description,
         lastSeenDate : lastSeenDate,
         lastSeenLocation: lastSeenLocation,
         latitude: latitude,
         longitude: longitude,
          contactPhone: contactPhone,
        );
        
          emit(SubmitCaseLoaded(caseObject));
  } on UnauthorisedException catch (e) {
    emit(SubmitCaseError("Authentication error: $e"));

  } on SocketException  {
    emit(SubmitCaseError("Network error: Check your internet connection"));
  } on TimeoutException {
    emit(SubmitCaseError("Connection timed out"));
  } catch (e) {
    emit(SubmitCaseError("An unexpected error occurred: $e"));
  }
}
}