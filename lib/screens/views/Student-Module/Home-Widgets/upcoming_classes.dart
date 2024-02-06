import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

String image = "https://img.freepik.com/free-vector/laptop-with-program-code-isometric-icon-software-development-programming-applications-dark-neon_39422-971.jpg";
class UpcomingClasses extends StatelessWidget {
  final DocumentSnapshot snapshot;
  final String meetingTime,subname,batch;
  const UpcomingClasses({super.key, required this.snapshot, required this.meetingTime, required this.subname, required this.batch});
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 8, top: 8),
      child: Container(
        width: MediaQuery.of(context).size.width*0.45,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.16,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    border:
                    Border.all(color: Colors.transparent),
                    image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.fill)),
              ),
              SizedBox(height: height*0.01,),
               Text("$meetingTime",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: height*0.01,),
               Text("$subname",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: height*0.01,),
               Text("$batch"),
            ],
          ),
        ),
      ),
    );
  }
}
