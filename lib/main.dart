import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tweet_up/Bloc-Patteren/theme_cubit.dart';
import 'package:tweet_up/screens/authenticate/login.dart';
import 'package:tweet_up/screens/authenticate/sign_up.dart';
import 'package:tweet_up/screens/views/Teacher-Module/create_class.dart';
import 'package:tweet_up/screens/views/Teacher-Module/enrolled_classes.dart';
import 'package:tweet_up/screens/views/Teacher-Module/home.dart';
import 'package:tweet_up/screens/views/homestu.dart';
import 'package:tweet_up/screens/views/Student-Module/join_class.dart';
import 'package:tweet_up/screens/views/role.dart';
import 'package:tweet_up/screens/views/Teacher-Module/subject_class.dart';
import 'package:tweet_up/screens/views/Student-Module/subject_class_student.dart';
import 'package:tweet_up/services/auth.dart';
import 'package:tweet_up/util/bottom_app_bar.dart';
import 'Bloc-Patteren/theme_state.dart';
import 'screens/views/Student-Module/created_classes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint("............Handle background messages ${message.messageId}/...........");
}

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  runApp(const MyApp());
}

Map<int, Color> color = {
  50: const Color.fromRGBO(2, 72, 124, .1),
  100: const Color.fromRGBO(2, 72, 124, .2),
  200: const Color.fromRGBO(2, 72, 124, .3),
  300: const Color.fromRGBO(2, 72, 124, .4),
  400: const Color.fromRGBO(2, 72, 124, .5),
  500: const Color.fromRGBO(2, 72, 124, .6),
  600: const Color.fromRGBO(2, 72, 124, .7),
  700: const Color.fromRGBO(2, 72, 124, .8),
  800: const Color.fromRGBO(2, 72, 124, .9),
  900: const Color.fromRGBO(2, 72, 124, 1.0),
};

MaterialColor colorCustomAccent = MaterialColor(0xff02487c, color);
MaterialColor colorCustomSwatch = MaterialColor(0xff02487c, color);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) => AuthViewModel(),
        child: StreamProvider<User?>.value(
          value: AuthViewModel().user,
          initialData: null,
          child: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => ThemeCubit()),
              ],
              child: BlocBuilder<ThemeCubit, ThemeInitial>(
                builder: (context, state) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(
                        useMaterial3: true,
                        primaryColor: const Color(0xff02487c),
                        colorScheme: ColorScheme.fromSwatch(
                                primarySwatch: colorCustomSwatch)
                            .copyWith(secondary: colorCustomAccent)
                            .copyWith(
                                primary: MaterialColor(0xff02487c, color),
                                background: const Color(0xffE5E5E5))),
                    home: FirebaseAuth.instance.currentUser == null
                        ? const LoginScreen()
                        : const BottomBar(),
                    routes: {
                      Register.routeName: (_) => const Register(),
                      Role.routeName: (_) => const Role(),
                      Home.routeName: (_) => const Home(),
                      HomeStudent.routeName: (_) => const HomeStudent(),
                      LoginScreen.id: (_) => const LoginScreen(),
                      CreateClass.routeName: (_) => const CreateClass(),
                      CreatedClasses.routeName: (_) => const CreatedClasses(),
                      JoinClass.routeName: (_) => const JoinClass(),
                      SubjectClass.routeName: (_) => const SubjectClass(),
                      EnrolledClasses.routeName: (_) => EnrolledClasses(),
                      SubjectClassStudent.routeName: (_) => const SubjectClassStudent(),
                    },
                  );
                },
              ),
            ),
          ),
        ),
    );
  }
}