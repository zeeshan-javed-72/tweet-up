import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ClassesViewModel extends ChangeNotifier{

  Future<void> teacherClasses() async{

  }

  File? _img;
  File? get img => _img;

  void setImg(File file){
    _img = file;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try{
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if(image != null){
        setImg(File(image.path));
      }
    }catch(e){

    }
    }

}