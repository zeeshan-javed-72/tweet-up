import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'appColors.dart';


class CustomTextField extends StatelessWidget {
  var labelText;
  var hintText;
  var iconField;
  var contrroller;
  var keyboardInputType;
  var textInputAction;
  var errorMessage;
  dynamic onChange;
  FormFieldValidator? validator;
  bool? obscureTextt;
  double borderRadius;
  List<TextInputFormatter>? inputFormatters;
  CustomTextField({Key? key,
    this.validator,
    this.errorMessage,
    this.inputFormatters,
    this.onChange,
    this.contrroller,this.hintText,this.iconField,
    this.labelText,this.obscureTextt=false,
    this.keyboardInputType,this.borderRadius=8,this.textInputAction=TextInputAction.next}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  TextFormField(
      keyboardType: keyboardInputType,
      obscureText: obscureTextt!,
      controller: contrroller,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChange,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(12),
        isDense: true,
        errorText: errorMessage,
        border:   OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.dividerColor),
            borderRadius: BorderRadius.circular(borderRadius)
        ),
        focusedBorder:  OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primaryRedColor),
            borderRadius: BorderRadius.circular(borderRadius)
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.dividerColor),
            borderRadius: BorderRadius.circular(borderRadius)
        ),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.errorColor),
            borderRadius: BorderRadius.circular(borderRadius)
        ),
        disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.dividerColor),
            borderRadius: BorderRadius.circular(borderRadius)
        ),
        labelText: labelText,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        hintText: hintText,
        // hintStyle: AppTextStyles.hintStyle,
        // labelStyle: AppTextStyles.hintStyle,
        // icon: Icon(Icons.star),
        // prefixIcon: Icon(Icons.favorite),
        suffixIcon: iconField,
      ),
    );
  }
}