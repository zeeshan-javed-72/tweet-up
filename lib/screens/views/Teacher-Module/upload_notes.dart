import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tweet_up/constants/appColors.dart';
import 'package:tweet_up/services/firebase_api.dart';
import 'package:tweet_up/util/utils.dart';
import '../../../services/database.dart';
import '../../../services/loading.dart';
import '../../../widgets/formFields.dart';

class Notes extends StatefulWidget {
  String code;
  Notes(this.code, {super.key});

  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  File? file;
  var timeStamp = Timestamp.fromMillisecondsSinceEpoch(100000000000);

  final notes = File;
  final url = TextEditingController();
  UploadTask? uploadTask;
  final topic = TextEditingController();
  String msg = ' ';
  // final notes = File;
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowedExtensions: ['pdf', 'doc'],
      type: FileType.custom,
      dialogTitle: "Picked file is uploading",
    );

    if (result == null) return;
    final path = result.files.single.path;

    setState(() {
      file = File(path!);
    });
  }

  Future uploadFile() async {
    if (file == null) return null;

    final fileName = Path.basename(file!.path);
    final destination = "files/$fileName";

    UploadFilesFirebase.uploadFile(destination, context, file!);
    if (uploadTask == null) return null;

    final snapshot = await uploadTask?.whenComplete(() => {});
    final urlFile = await snapshot!.ref.getDownloadURL();
    debugPrint("Download-Link$urlFile");
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return CircularPercentIndicator(
              radius: 45,
              lineWidth: 4.0,
              percent: 0.90,
              center: Text(
                "$percentage" "%",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              progressColor: Colors.green,
            );
          } else {
            return Container();
          }
        },
      );

  Future<String?> uploadNotes(File pdfFile) async {
    String url;
    Reference reference = FirebaseStorage.instance.ref().child('Notes/$timeStamp');
    uploadTask = reference.putFile(pdfFile);
    url = await reference.getDownloadURL();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final fileName =
        file != null ? Path.basename(file!.path) : "No Selected File";
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return loading
        ? Loader()
        : Scaffold(
            appBar: AppBar(
              title: const Text('notes'),
            ),
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    formField(
                        controller: topic, title: 'Topic', context: context),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'You can upload files down below',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(color: Colors.blue),
                        backgroundColor: Colors.white30,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      onPressed: () => {
                        selectFile(),
                        debugPrint('attach file button pressed'),
                      },
                      icon: const Icon(
                        Icons.attach_file_rounded,
                      ),
                      label: const Text(
                        'attach file',
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Text(
                      fileName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 1,
                          ),
                          child: TextButton(
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: height * 0.010,
                                  horizontal: width * 0.010,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                    )),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width * .4,
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                )),
                            onPressed: () {
                              topic.text = '';
                              url.text;
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: TextButton(
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white)),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width * .4,
                                child: const Text(
                                  'Post',
                                  style: TextStyle(color: Colors.white),
                                )),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                               await uploadNotes(file!).then((value) async {
                                  await ClassDatabase.postNote(
                                    context,
                                    topic.text,
                                    value.toString(),
                                    widget.code,
                                  );
                                });
                               Utils.snackBar(message: "Notes Uploaded", context: context, color: AppColors.successColor);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
