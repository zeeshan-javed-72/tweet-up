import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tweet_up/util/utils.dart';

class ClassesViewModel extends ChangeNotifier {
  Future<void> teacherClasses() async {}

  File? _img;
  File? get img => _img;

  void setImg(File file) {
    _img = file;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setImg(File(image.path));
      }
    } catch (e) {}
  }

  Future<dynamic> downloadFile(String fileUrl, BuildContext context,
      {required String? topicName}) async {
    try {
      // final storageRef = FirebaseStorage.instance.ref();
      final httpsReference = FirebaseStorage.instance.refFromURL(fileUrl);
      // final parts = fileUrl.split('/');
      // final filename = parts.last;
      const downloadsDirectoryPath = '/storage/emulated/0/Download';
      final downloadsDirectory = Directory(downloadsDirectoryPath);
      if (!(await downloadsDirectory.exists())) {
        await downloadsDirectory.create(recursive: true);
      }
      final filePath = '${downloadsDirectory.path}/$topicName.pdf';
      final File localFile = File(filePath);
      // log('path is ==> ${localFile}');
      final downloadTask = httpsReference.writeToFile(localFile);
      // File downloadedFile = File(localFile.path);
      _showDownloadCompleteDialog(
        context,
        downloadTask,
      );
    } catch (e) {
      log('Error in try cathc==> ${e}');
    }
  }

// Optional dialog functions to handle success, error, and general error cases
  void _showDownloadCompleteDialog(
      BuildContext context, DownloadTask downloadTask) {
    showDialog(
      context: context,
      builder: (context) => StreamBuilder<TaskSnapshot>(
          stream: downloadTask.snapshotEvents,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final snap = snapshot.data!;
              double progress = snap.bytesTransferred / snap.totalBytes;
              var percentage = (progress * 100).roundToDouble();
              log('download progress is ==>$percentage');
              if (percentage == 100.0) {
                Navigator.pop(context, 'dasd');
                Utils.showToast(message: 'File downloaded');
              }
              return Center(
                child: Transform.scale(
                  scale: 2,
                  child: CircularProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.white,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
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
