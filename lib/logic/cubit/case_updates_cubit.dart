import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/dataprovider/exception.dart';
import 'package:find_them/data/models/submitted_case.dart';
import 'package:find_them/data/repositories/submitted_cases_repo.dart';

part 'case_updates_state.dart';

class CaseUpdatesCubit extends Cubit<CaseUpdatesState> {
  final SubmittedCaseRepository repository;

  CaseUpdatesCubit(this.repository) : super(CaseUpdatesInitial());

  Future<void> getCaseWithUpdates(int caseId) async {
    try {
      emit(CaseUpdatesLoading());
      
      log("Fetching case updates for case ID: $caseId");
      
      final caseWithUpdates = await repository.getCaseWithUpdates(caseId);
      
      emit(CaseUpdatesLoaded(caseWithUpdates: caseWithUpdates));
      
    } on UnauthorisedException catch (e) {
      emit(CaseUpdatesError("Authentication error: $e"));
    } on SocketException {
      emit(CaseUpdatesError("Network error: Check your internet connection"));
    } on TimeoutException {
      emit(CaseUpdatesError("Connection timed out"));
    } catch (e) {
      log("Error fetching case updates: $e");
      emit(CaseUpdatesError("An unexpected error occurred: $e"));
    }
  }

  void reset() {
    emit(CaseUpdatesInitial());
  }

}