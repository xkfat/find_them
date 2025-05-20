import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
    double? latitude,
    double? longitude, ) async {
    emit(SubmitCaseLoading());
    try {
      print("Checking authentication status");

      dynamic responseDta = await _submitCaseRepository.submitCase(
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
        );
        
      if (responseDta["code"] == "201") {
        emit(SubmitCaseLoaded());
      } else if (responseDta["code"] == "401") {
        emit(SubmitCaseerreur(responseDta["msg"]));
      } else {
        emit(SubmitCaseerreur("Connect to server first"));
      }
    } catch (e) {
      emit(SubmitCaseerreur("Connect to server first"));
    }
  }
}
