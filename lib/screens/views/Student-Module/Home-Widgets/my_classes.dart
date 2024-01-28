import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tweet_up/screens/views/Teacher-Module/subject_class.dart';

class MyClasses extends StatefulWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;
  const MyClasses({Key? key, required this.snapshot}) : super(key: key);

  @override
  State<MyClasses> createState() => _MyClassesState();
}

class _MyClassesState extends State<MyClasses> {
   Color? _backgroundColor;
  final Random _random = Random();

   Color _randomColor() {
     return Color.fromARGB(
       255,
       _random.nextInt(256),
       _random.nextInt(256),
       _random.nextInt(256),
     );
   }

  @override
  void initState() {
    _backgroundColor = _randomColor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 15),
      itemCount: widget.snapshot.data?.docs.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: MediaQuery.of(context).size.height*0.09,
      ),
      itemBuilder: (BuildContext context, int index) {
        var document = widget.snapshot.data!.docs[index];
        return ListTile(
          onTap: (){
            Navigator.of(context).pushNamed(
              SubjectClass.routeName,
              arguments: document.data(),
            );
          },
          onLongPress: (){
            showDialog<void>(
              context: context,
              barrierDismissible: true,
              // false = user must tap button, true = tap outside dialog
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: Text('${document['subName']}'),
                  content: const Text('Do you want to delete class?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(dialogContext)
                            .pop(); // Dismiss alert dialog
                      },
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () async{
                       await FirebaseFirestore.instance.collection("classes").doc(document.id).delete();
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              },
            );
          },
          tileColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
          leading: CircleAvatar(
            backgroundColor: _backgroundColor,
            child: Text(
              document['subName'].substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text("${document['subName']}",
          style: TextStyle(
             fontWeight: FontWeight.bold,
            fontSize: MediaQuery.textScaleFactorOf(context)*17,
           ),
          ),
          subtitle: Text("${document['batch']}"),
        );
      },
    );
  }
}
