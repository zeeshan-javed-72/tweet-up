import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tweet_up/constants/appColors.dart';
import 'package:tweet_up/util/utils.dart';
import '../../../services/database.dart';
import '../../../widgets/formFields.dart';

class UploadAssignment extends StatefulWidget {
  final code;
  final String? email;
 final bool page;
 final DocumentSnapshot? snapshot;
 final String? classCode;
  const UploadAssignment({super.key, this.code, this.page = false, this.email, this.snapshot, this.classCode});


  @override
  UploadAssignmentState createState() => UploadAssignmentState();
}

class UploadAssignmentState extends State<UploadAssignment> {
  final topic = TextEditingController();
  String msg = ' ';
  final url = TextEditingController();
  bool loading = false;
  File? file;
  final notes = File;
  UploadTask? uploadTask;
  var timeStamp = Timestamp.fromMillisecondsSinceEpoch(100000000000);
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      keyboardType: TextInputType.datetime,
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future selectFile() async{
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowedExtensions: ['pdf', 'doc'],
      type: FileType.custom,
      dialogTitle: "Picked file is uploading",
    );
    if(result==null) return;
    final path = result.files.single.path;
    setState((){
      file = File(path!);
    });
  }
  Future<String?> uploadNotes(File pdfFile, context) async{
    Reference? reference;
    String? url;
    if(widget.page == false) {
       reference = FirebaseStorage.instance.ref().child('Assignments/$timeStamp');
    }else{
      reference = FirebaseStorage.instance.ref().child('Submitted/$timeStamp');
    }
    uploadTask =  reference.putFile(pdfFile);
    final snapshot = await uploadTask?.whenComplete(() => {
      Utils.snackBar(message: "Assignment uploaded", context: context, color: Colors.green)
    });
     url = await snapshot?.ref.getDownloadURL();
    return url;

  }
  Widget buildUploadStatus() => StreamBuilder<TaskSnapshot>(
    stream: uploadTask?.snapshotEvents,
    builder: (context, snapshot) {
      if (snapshot.hasData){
        final snap = snapshot.data!;
        double progress = snap.bytesTransferred / snap.totalBytes;
        var percentage = (progress * 100).roundToDouble();
        return SizedBox(
          height: 50,
          child: Stack(
            fit: StackFit.expand,
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ),
              Center(
                child: Text("$percentage%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),),
              )
            ],
          ),
        );
      } else {
        return Container();
      }
    },
  );


  @override
  Widget build(BuildContext context) {
    final fileName =  file != null ? path.basename(file!.path): "No Selected File";
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
            appBar: AppBar(
              title: const Text('Assignment'),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                       widget.page ==false? formField(controller: topic, title: 'Topic',context: context): Container(),
                        SizedBox(height: height*0.01,),
                        ListTile(
                          visualDensity: const VisualDensity(horizontal: -4),
                          leading: TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: const VisualDensity(horizontal: -4),
                              textStyle: const TextStyle(color: Colors.blue),
                              backgroundColor: Colors.white30,
                              shape:RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                            onPressed: () => {
                              selectFile(),
                              debugPrint('attach file button pressed'),
                            },
                            child: const Icon(Icons.attach_file_rounded,),
                          ),
                          trailing: const Icon(Icons.visibility_outlined),
                          title: const Text("Attachment",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(fileName,),
                        ),
                        SizedBox(height: height*0.01),
                        widget.page ==false? SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextButton(
                            onPressed: () => _selectDate(context),
                            child: Text(
                              'Due date ${"${selectedDate.toLocal()}".split(' ')[0]}',
                            ),
                          ),
                        ) : Container(),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                                onPressed: () {
                                  topic.text = '';
                                  url.text = '';
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width*0.02,),
                            Expanded(
                              flex: 2,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child:  const Text(
                                  'Post',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      loading = true;
                                    });
                                    if(widget.page ==false) {
                                      await uploadNotes(file!, context).then((value) async {
                                     await ClassDatabase.postAssignment(
                                         code: widget.code,
                                         topicName: topic.text,
                                         url: value.toString(),
                                         dueDate: selectedDate,
                                         page: widget.page,
                                      );
                                    });
                                    }else if(widget.page == true){
                                      if(file != null){
                                        await uploadNotes(file!, context).then((value) async {
                                          await ClassDatabase.postAssignment(
                                            url: value.toString(),
                                            page: widget.page,
                                            code: widget.classCode,
                                            assignmentCode: widget.snapshot!.id,
                                          );
                                        });
                                      }else{
                                        Utils.snackBar(message: "Please select assignment",
                                            context: context, color: AppColors.errorColor);
                                        print("Please select assignment");
                                      }
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        buildUploadStatus(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

}
