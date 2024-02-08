import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<File?> downloadFileFromUrl(String storageReferenceUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(storageReferenceUrl);
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}'; // You can change the file name if needed
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final File localFile = File('${appDocDir.path}/$fileName');
      await ref.writeToFile(localFile);
      File downloadedFile = File(localFile.path);
      print('downloaded file from URL: $downloadedFile');
      return localFile;
    } catch (e) {
      print('Error downloading file from URL: $e');
      return null;
    }
  }
  Future<dynamic> downloadFile(String fileUrl,BuildContext context) async{
   try{
     // final storageRef = FirebaseStorage.instance.ref();
     final httpsReference = FirebaseStorage.instance.refFromURL(fileUrl);
     final String fileName = '${DateTime.now().millisecondsSinceEpoch}'; // You can change the file name if needed
     final Directory appDocDir = await getApplicationDocumentsDirectory();
     final File localFile = File('${appDocDir.path}/$fileName');
     final downloadTask = httpsReference.writeToFile(localFile);
     File downloadedFile = File(localFile.path);
     _showDownloadCompleteDialog(
       context,
       downloadTask,
     );
     // downloadTask.snapshotEvents.listen((taskSnapshot) {
     //   log('State of downloading is===> ${taskSnapshot.state.toString()}');
     //   switch (taskSnapshot.state) {
     //     case TaskState.running:
     //      return _showDownloadCompleteDialog(
     //        context,
     //        downloadTask,
     //      );
     //     case TaskState.paused:
     //     // TODO: Handle this case.
     //       break;
     //     case TaskState.success:
     //      return Navigator.pop(context);
     //     // TODO: Handle this case.
     //       break;
     //     case TaskState.canceled:
     //     // TODO: Handle this case.
     //       break;
     //     case TaskState.error:
     //     // TODO: Handle this case.
     //       break;
     //   }
     // });
   }catch(e){
     log('Error in try cathc==> ${e}');
   }
  }
// Optional dialog functions to handle success, error, and general error cases
  void _showDownloadCompleteDialog(BuildContext context,DownloadTask downloadTask) {
    showDialog(
      context: context,
      builder: (context) => StreamBuilder<TaskSnapshot>(
        stream: downloadTask.snapshotEvents,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            final snap = snapshot.data!;
            double progress = snap.bytesTransferred / snap.totalBytes;
            var percentage = (progress * 100).roundToDouble();
            log('message==>$percentage');
            return Center(
                child: Transform.scale(
              scale: 2,
              child: CircularProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ),
             ),
            );
          }
          return const SizedBox.shrink();
        }
      ),
    );
  }

  void _showDownloadErrorDialog(BuildContext context, FirebaseException error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Error'),
        content: Text(
          'There was an error downloading the PDF: ${error.code} - ${error.message}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showGeneralErrorDialog(BuildContext context, Exception error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('An unexpected error occurred: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


}