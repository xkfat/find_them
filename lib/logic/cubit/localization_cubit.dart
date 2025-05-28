import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:find_them/data/services/localization_service.dart';

part 'localization_state.dart';





class LocalizationCubit extends Cubit<LocalizationState> {
  LocalizationCubit() : super(const LocalizationState(locale: Locale('en', ''))) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    emit(state.copyWith(isLoading: true));
    try {
      final savedLanguage = await LocalizationService.getSavedLanguage();
      final locale = LocalizationService.getLocaleFromLanguage(savedLanguage);
      emit(state.copyWith(locale: locale, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    emit(state.copyWith(isLoading: true));
    try {
      await LocalizationService.saveLanguage(languageCode);
      final locale = LocalizationService.getLocaleFromLanguage(languageCode);
      emit(state.copyWith(locale: locale, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  String get currentLanguage => state.locale.languageCode;
  
  String get currentLanguageDisplayName => 
      LocalizationService.languageNames[currentLanguage] ?? 'English';
}