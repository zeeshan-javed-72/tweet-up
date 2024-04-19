import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tweet_up/screens/views/Teacher-Module/students.dart';
import 'package:tweet_up/screens/views/Student-Module/upcoming_classes.dart';
import 'class_announcements.dart';
import 'classwork.dart';

class SubjectClass extends StatefulWidget {
  static const routeName = '/subject-class';
  const SubjectClass({super.key});

  @override
  _SubjectClassState createState() => _SubjectClassState();
}

class _SubjectClassState extends State<SubjectClass> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> classData = ModalRoute.of(context)?.settings.arguments as dynamic;
    final tabs = [
      Announcements(classData: classData),
      Classwork(classData),
      Students(classData),
      UpcomingClasses(classData),
    ];
    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
          indicatorColor: Colors.transparent,
        ),
        child: NavigationBar(
            height: 45,
            shadowColor: Colors.black,
            surfaceTintColor: Colors.white,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index)=>{
              setState((){
                _currentIndex = index;
              })
            },
            destinations: [
              NavigationDestination(
                icon: Icon(CupertinoIcons.chat_bubble_text,color:  Theme.of(context).primaryColor),
                label: 'asseveration',
                selectedIcon: Icon(CupertinoIcons.chat_bubble_text_fill,color:  Theme.of(context).primaryColor ),
              ),
              NavigationDestination(
                icon: Icon(CupertinoIcons.rectangle_grid_2x2,color:  Theme.of(context).primaryColor),
                selectedIcon: Icon(CupertinoIcons.rectangle_grid_2x2_fill,
                  color:  Theme.of(context).primaryColor),
                label: 'Classwork',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_pin_outlined,color:  Theme.of(context).primaryColor),
                selectedIcon: Icon(Icons.person_pin_rounded, color:  Theme.of(context).primaryColor),
                label: 'Students',
              ),
              NavigationDestination(
                icon: Icon(Icons.upcoming_outlined,color:  Theme.of(context).primaryColor),
                selectedIcon: Icon(Icons.upcoming_sharp, color:  Theme.of(context).primaryColor),
                label: 'Up Coming',
              ),
            ]
        ),
      ),
    );
  }
}
