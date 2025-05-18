import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/models/case.dart';
import 'package:find_them/data/repositories/case_repo.dart';
import 'package:find_them/logic/cubit/case_filter_state.dart';

part 'case_list_state.dart';

class CaseCubit extends Cubit<CaseListState> {
    final CaseRepository _caseRepository;

  CaseFilterState _currentFilters = const CaseFilterState();
  CaseFilterState get currentFilters => _currentFilters;

  CaseCubit(this._caseRepository) : super(CaseListInitial());

 Future<void> getCases() async {
    try {
      emit(CaseLoading());
      final cases = await _caseRepository.getCases(
        name: _currentFilters.name,
        ageMin: _currentFilters.ageMin,
        ageMax: _currentFilters.ageMax,
        gender: _currentFilters.gender,
        status: _currentFilters.status,
        startDate: _currentFilters.startDate,
        endDate: _currentFilters.endDate,
      );
      emit(CaseLoaded(cases));
    } catch (e) {
      emit(CaseError(e.toString()));
    }
  }

Future<void> getCaseDetail(int id) async {
    try {
      emit(CaseLoading());
      final caseData = await _caseRepository.getCaseById(id);
      emit(CaseDetailLoaded(caseData));
    } catch (e) {
      emit(CaseError(e.toString()));
    }
  }
  Future<void> getCaseWithUpdates(int id) async {
    try {
      emit(CaseLoading());
      final caseData = await _caseRepository.getCaseWithUpdates(id);
      emit(CaseDetailLoaded(caseData));
    } catch (e) {
      emit(CaseError(e.toString()));
    }
  }

   Future<void> setFilters(CaseFilterState filters) async {
    _currentFilters = filters;
    await getCases();
  }

   Future<void> clearFilters() async {
    _currentFilters = const CaseFilterState();
    await getCases();
  }


   Future<void> updateFilter({
    String? name,
    int? ageMin,
    int? ageMax,
    String? gender,
    String? status,
    String? startDate,
    String? endDate,
    bool clearName = false,
    bool clearAgeMin = false,
    bool clearAgeMax = false,
    bool clearGender = false,
    bool clearStatus = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) async {
 _currentFilters = _currentFilters.copyWith(
      name: name,
      ageMin: ageMin, 
      ageMax: ageMax,
      gender: gender,
      status: status,
      startDate: startDate,
      endDate: endDate,
      clearName: clearName,
      clearAgeMin: clearAgeMin,
      clearAgeMax: clearAgeMax,
      clearGender: clearGender,
      clearStatus: clearStatus,
      clearStartDate: clearStartDate,
 clearEndDate: clearEndDate,
    );
    
    await getCases();
  }
 Future<void> searchByName(String name) async {
    if (name.isEmpty) {
      _currentFilters = _currentFilters.copyWith(clearName: true);
    } else {
      _currentFilters = _currentFilters.copyWith(name: name);
    }
    await getCases();
  }
  
}
