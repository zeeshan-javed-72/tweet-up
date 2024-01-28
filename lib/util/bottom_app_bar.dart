import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tweet_up/screens/views/homestu.dart';
import '../screens/views/Student-Module/chat_screen.dart';
import '../screens/views/Student-Module/upcoming_classes_student.dart';

class BottomBar extends StatefulWidget {
   const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const HomeStudent(),
       const UpcomingClassesStudent(),
      const ChatScreen(),

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
          destinations:  [
            NavigationDestination(
              icon: Icon(CupertinoIcons.home, color: Theme.of(context).primaryColor),
              label: 'asseveration',
              selectedIcon: Icon(CupertinoIcons.house_fill,color: Theme.of(context).primaryColor),
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.calendar,color: Theme.of(context).primaryColor),
              selectedIcon: Icon(CupertinoIcons.calendar_today, color: Theme.of(context).primaryColor),
              label: 'Classwork',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.chat_bubble_text, color: Theme.of(context).primaryColor),
              selectedIcon: Icon(CupertinoIcons.chat_bubble_text_fill, color: Theme.of(context).primaryColor),
              label: 'Up Coming',
            ),
          ],
        ),
      ),
    );
  }
}
