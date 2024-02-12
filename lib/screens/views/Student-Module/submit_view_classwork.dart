import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:tweet_up/Model-View_Classes/classes_view_model.dart';
import 'package:tweet_up/screens/views/Teacher-Module/upload_assignment.dart';
import 'assignments.dart';

class SubmitClasswork extends StatefulWidget {
  final Map<dynamic, dynamic>? classData;
  const SubmitClasswork({Key? key,this.classData,}) : super(key: key);

  @override
  SubmitClassworkState createState() => SubmitClassworkState();
}

class SubmitClassworkState extends State<SubmitClasswork> with SingleTickerProviderStateMixin {

  bool isDownloading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    final classNotifier = Provider.of<ClassesViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.classData?['subName']}'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(
              text: "Notes",
            ),
            Tab(
              text: "Assignments",
            ),
          ],
        ),
      ),
       body: TabBarView(
         controller: _tabController,
           children: [
         StreamBuilder(
             stream: FirebaseFirestore.instance
                 .collection("classes")
                 .doc(widget.classData?['code'])
                 .collection('notes')
                 .snapshots(),
             builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
               if (snapshot.hasError) {
                 return const Text('Something went wrong');
               }

               if (!snapshot.hasData) {
                 return const Center(child: CircularProgressIndicator());
               }
               if (snapshot.data!.docs.isEmpty) {
                 return const Center(child: Text("You don't have any notes to download"));
               }
               return  ListView(
                 shrinkWrap: true,
                 padding: const EdgeInsets.symmetric(horizontal: 10),
                 children: snapshot.data!.docs.map((document){
                   return Card(
                     child: Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(
                             document['topic'] ?? 'Loading',
                             style: const TextStyle(fontWeight: FontWeight.bold),
                           ),
                           TextButton(
                             style: TextButton.styleFrom(
                               backgroundColor:  Colors.amber,
                             ),
                             child: const Text('Download Notes'),
                             onPressed: () async {
                             await classNotifier.downloadFile(
                                 document['url'],
                                 context,
                                 topicName: document['topic']);
                             },
                           ),
                         ],
                       ),
                     ),
                   );
                 }).toList().cast(),
               );
             }),
         StreamBuilder(
             stream: FirebaseFirestore.instance
                 .collection("classes")
                 .doc(widget.classData?['code'])
                 .collection('assignments')
                 .snapshots(),
             builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
               if (snapshot.hasError) {
                 return const Text('Something went wrong');
               }
               if (!snapshot.hasData) {
                 return const Center(child: CircularProgressIndicator());
               }
               if (snapshot.data!.docs.isEmpty) {
                 return const Center(child: Text("You don't have any assigned work"));
               }
               return  ListView(
                 shrinkWrap: true,
                 padding: const EdgeInsets.symmetric(horizontal: 10),
                 children: snapshot.data!.docs.map((e){
                   return Assignments(
                     snapshot: e,
                     code: widget.classData?['code'],
                   );
                 }).toList().cast(),
               );
             }),
       ],
       )
    );
  }
}
