part of 'theme_cubit.dart';


sealed class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

final class ThemeInitial extends ThemeState {}

final class ThemeChanged extends ThemeState {
  final Theme currentTheme;

  const ThemeChanged(this.currentTheme);

  @override
  List<Object> get props => [currentTheme];
}