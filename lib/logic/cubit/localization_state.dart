part of 'localization_cubit.dart';

class LocalizationState {
  final Locale locale;
  final bool isLoading;

  const LocalizationState({
    required this.locale,
    this.isLoading = false,
  });

  LocalizationState copyWith({
    Locale? locale,
    bool? isLoading,
  }) {
    return LocalizationState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}