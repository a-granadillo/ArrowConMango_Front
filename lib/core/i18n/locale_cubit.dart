import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Controls the active application locale.
///
/// Emits a new [Locale] whenever the user changes the language from
/// [SettingsScreen]. The root [MaterialApp.router] rebuilds via
/// [BlocBuilder] so the whole app reflects the selected locale.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('es'));

  void setLocale(Locale locale) => emit(locale);
}
