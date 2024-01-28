import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tweet_up/util/utils.dart';

class UploadFilesFirebase {
  UploadTask? uploadTask;
  File? file;
  var timeStamp = Timestamp.now().millisecondsSinceEpoch;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ['pdf', 'doc'],
      type: FileType.custom,
      dialogTitle: "Picked file is uploading",
    );
    if (result == null) return;
    final path = result.files.single.path;
    file = File(path!);
  }

  Future<String?> uploadDocuments({pdfFile, docName, context}) async {
    String? url;
    Reference reference =
        FirebaseStorage.instance.ref().child(docName / timeStamp);
    uploadTask = reference.putFile(pdfFile);
    uploadTask?.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          if (kDebugMode) {
            print(progress);
          }
          break;
        case TaskState.paused:
          if (kDebugMode) {
            print("Upload is paused.");
          }
          break;
        case TaskState.canceled:
          if (kDebugMode) {
            print("Upload was canceled");
          }
          break;
        case TaskState.error:
          // Handle unsuccessful uploads
          break;
        case TaskState.success:
          // Handle successful uploads on complete
          // ...
          break;
        default:
      }
    });
    final snapshot = await uploadTask?.whenComplete(() => {
          Utils.snackBar(
              message: "$docName has been upload",
              context: context,
              color: Colors.green)
        });
    url = await snapshot?.ref.getDownloadURL();
    return url;
  }

  static UploadTask? uploadFile(String destination, context, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      Utils.snackBar(message: e.message, context: context, color: Colors.red);
      return null;
    }
  }

  static Future downloadFile({required Reference reference, context}) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/${reference.name}");

    await reference.writeToFile(file);
    Utils.snackBar(
        message: "Downloaded ${reference.name}",
        context: context,
        color: Colors.green);
  }
  // Future uploadFile() async{
  //   if(file==null) return null;
  //   final fileName = Path.basename(file!.path);
  //   final destination = "Assignments/$fileName";
  //   FirebaseApi.uploadFile(destination,context, file!);
  //   if(uploadTask==null)return null;
  //   final snapshot = await uploadTask?.whenComplete(() => {
  //     Utils.snackBar(message: "Assignment is ready to upload", context: context, color: Colors.lightGreen),
  //   });
  //   final urlFile = await snapshot!.ref.getDownloadURL();
  //   debugPrint("Download-Link$urlFile");
  // }

  static Future<void> downloadFile2(String url, context) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/Assignments';

    try {
      var response = await http.get(Uri.parse(url));
      var file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      if (url.contains(".pdf")) {
        final result = await ImageGallerySaver.saveFile(file.path,
            name: file.path.toString());
        debugPrint("This is file save result $result......................");
      }

      Utils.snackBar(
          message: "Download complete.",
          context: context,
          color: Theme.of(context).primaryColor);
      debugPrint('Download complete.$filePath');
    } catch (e) {
      Utils.snackBar(
          message: "Error while downloading file: $e",
          context: context,
          color: Colors.red);
      debugPrint('Error while downloading file: $e');
    }
  }
}
