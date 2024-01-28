// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tweet_up/widgets/flush_bar.dart';
import 'dart:async';
import '../constants/appColors.dart';
import '../util/bottom_app_bar.dart';

class AuthViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  BuildContext? context;
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future signOut() async{
    try {
      return await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      notifyListeners();
    }
  }

  bool registerLoading = false;
  bool get registerLoader => registerLoading;

  setRegisterLoading(bool loading) {
    registerLoading = loading;
    notifyListeners();
  }

  bool loginLoading = false;
  bool get loginLoader => loginLoading;

  setLoginLoading(bool loading) {
    loginLoading = loading;
    notifyListeners();
  }

  String? _passwordError;
  String? get passwordError => _passwordError;

  void passwordErrorTex(error){
    _passwordError = error;
    notifyListeners();
  }

  String? _emailError;
  String? get emailError => _emailError;

  void emailErrorText(error){
    _emailError = error;
    notifyListeners();
  }
  UserCredential? result;
  Future<UserCredential?> signIn(String email, String password, BuildContext context) async {
    try {
      setLoginLoading(true);
       result = await _auth.signInWithEmailAndPassword(email: email, password: password).then((value){
         setLoginLoading(false);
         if (value.user!.emailVerified) {
           Navigator.popUntil(context, (route) => route.isFirst);
           Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context)=> const BottomBar()));
         } else {
           logout(context);
           _emailError = "Please verify your email first";
           notifyListeners();
         }
       });
       return result;
    } on FirebaseAuthException catch (e) {
      setLoginLoading(false);
      // Utils.topFlushBarMessage(e.code, context, AppColors.errorColor);
      switch(e.code){
        case "invalid-email":
          _emailError = "Please enter a valid email";
          notifyListeners();
          break;
        case 'user-not-found':
          _emailError = 'No user found with this email address';
          notifyListeners();
          break;
        case 'wrong-password':
          _passwordError = 'Please enter a valid password';
          notifyListeners();
          break;
        case 'weak-password':
          _passwordError = 'The password provided is too weak';
          notifyListeners();
          break;
        case "network-request-failed":
          Utils.flushBarErrorMessage("Please check your internet connection and try again",
              context, AppColors.errorColor);
          notifyListeners();
          break;
        default:
          _emailError = 'An error occurred, please try again later';
          notifyListeners();
      }

    }catch(e){
      Utils.flushBarErrorMessage(e.toString(), context, AppColors.errorColor);
      notifyListeners();
    }
  }

  bool resetLoading = false;
  bool get resetLoader => resetLoading;

  setResetLoading(bool loading) {
    resetLoading = loading;
    notifyListeners();
  }

  String? _resetEmailError;
  String? get resetEmailError => _resetEmailError;

  void resetEmailErrorText(error){
    _resetEmailError = error;
    notifyListeners();
  }

  Future<void> resetPassword(String email,BuildContext context ) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      notifyListeners();
      Utils.flushBarErrorMessage('Check your email for resetting your password', context, AppColors.warningColor);
      notifyListeners();
    }on FirebaseAuthException catch(e){
      setResetLoading(false);
      switch(e.code){
        case "invalid-email":
          _resetEmailError = "Please enter a valid email address";
          notifyListeners();
          break;
        case "user-not-found":
          _resetEmailError = "User not found for following email address";
          notifyListeners();
          break;
        case "unknown":
          _resetEmailError = "Unknown Error Occurred";
          notifyListeners();
          break;
        case "network-request-failed":
          Utils.flushBarErrorMessage("Please check your internet connection and try again", context, AppColors.errorColor);
          notifyListeners();
          break;
        default:
          _resetEmailError = 'An error occurred, please try again later';
          notifyListeners();
      }
      notifyListeners();
    }
  }


  String? _registerPasswordError;
  String? get registerPasswordError => _registerPasswordError;

  void registerPasswordText(error){
    _registerPasswordError = error;
    notifyListeners();
  }

  String? _registerEmailError;
  String? get registerEmailError => _registerEmailError;

  void registerEmailText(error){
    _registerEmailError = error;
    notifyListeners();
  }

 UserCredential? userCredential;
  Future<UserCredential?> signUp(String email, String password, String name, var phone, BuildContext context) async {
    try {
      setRegisterLoading(true);
      userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).set({
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
      });
      User? user = userCredential?.user;
      await user?.sendEmailVerification();
      setRegisterLoading(false);
      logout(context);
      Utils.flushBarErrorMessage("visit gmail to verify your email account on $email", context, AppColors.warningColor);
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch(e){
      setRegisterLoading(false);
      switch(e.code){
        case "invalid-email":
          _registerEmailError = "Please enter a valid email address";
          notifyListeners();
          break;
        case 'requires-recent-login':
          _registerEmailError = 'Please sign in again to continue';
          notifyListeners();
          break;
        case 'email-already-in-use':
          _registerEmailError = 'The account already exists for that email';
          notifyListeners();
          break;
        case 'weak-password':
          _registerPasswordError = 'The password provided is too weak';
          notifyListeners();
          break;
        case 'operation-not-allowed':
          _registerPasswordError = 'Firebase Authentication is not enabled';
          notifyListeners();
          break;
        case 'too-many-requests':
          _registerPasswordError = 'Too many requests. Try again later';
          notifyListeners();
          break;
        case "network-request-failed":
          Utils.flushBarErrorMessage("Please check your internet connection and try again",
              context, AppColors.errorColor);
          notifyListeners();
          break;
        default:
          _registerEmailError = 'An error occurred, please try again later';
          notifyListeners();
      }
      notifyListeners();
      return userCredential;
    }
  }

  Future signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      assert(!user!.isAnonymous);
      assert(await user!.getIdToken() != null);
      final User? currentUser = _auth.currentUser;
      assert(user?.uid == currentUser?.uid);
      return user;
    } catch (e) {
      return null;
    }
  }

  bool obscurePassword = false;
  setRegisterObscure(){
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  bool obscurePasswordLogin = false;
  setLoginObscure(){
    obscurePasswordLogin = !obscurePasswordLogin;
    notifyListeners();
  }

  void logout(context) {
    FirebaseAuth.instance.signOut();
    notifyListeners();
  }

}
final GoogleSignIn googleSignIn = GoogleSignIn();