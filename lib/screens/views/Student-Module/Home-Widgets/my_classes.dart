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
        mainAxisExtent: MediaQuery.of(context).size.height * 0.11,
      ),
      itemBuilder: (BuildContext context, int index) {
        var document = widget.snapshot.data!.docs[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              SubjectClass.routeName,
              arguments: document.data(),
            );
          },
          onLongPress: () {
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
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection("classes")
                            .doc(document.id)
                            .delete();
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              },
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.11,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _backgroundColor,
                      child: Text(
                        document['subName'].substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${document['subName']}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.textScaleFactorOf(context) * 14,
                            ),
                          ),
                          Text(
                            "${document['batch']}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
