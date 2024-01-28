import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:tweet_up/Bloc-Patteren/theme_state.dart';

class ThemeCubit extends Cubit<ThemeInitial> {
  ThemeCubit() : super(ThemeInitial(themeData: ThemeData.light()));

  void changeTheme(){
    if(state.themeData == ThemeData.light()){
      emit(ThemeInitial(themeData: ThemeData.dark()));
    }else{
      emit(ThemeInitial(themeData: ThemeData.light()));
    }
  }
}
