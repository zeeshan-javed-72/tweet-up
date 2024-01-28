import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweet_up/generated/assets.dart';
import 'package:tweet_up/screens/authenticate/sign_up.dart';
import 'package:tweet_up/util/bottom_app_bar.dart';
import '../../constants/custom_textfield.dart';
import '../../services/auth.dart';

class LoginScreen extends StatefulWidget {
  static const id = '/login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final AuthViewModel _auth = AuthViewModel();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height / 812;
    final w = MediaQuery.of(context).size.width / 375;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 10 * h,
                  ),
                  Image.asset(
                    Assets.imagesAppLogo,
                    width: 120 * w,
                  ),
                  SizedBox(height: 60 * h),
                  Consumer<AuthViewModel>(
                    builder: (context, provider, child) {
                      return CustomTextField(
                        contrroller: email,
                        hintText: "Email",
                        errorMessage: provider.emailError,
                        onChange: (v) {
                          provider.emailErrorText(null);
                        },
                        validator: (value) {
                          if (value.isEmpty || value == "") {
                            return 'Enter a email first';
                          } else if (!value.contains('@') ||
                              !value.contains('.com')) {
                            return 'enter a valid email';
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(height: 20 * h),
                  Consumer<AuthViewModel>(
                    builder: (context, provider, child) {
                      return CustomTextField(
                        contrroller: pass,
                        hintText: "Password",
                        errorMessage: provider.passwordError,
                        textInputAction: TextInputAction.next,
                        onChange: (v) {
                          provider.passwordErrorTex(null);
                        },
                        validator: (v) {
                          if (v == null || v == "") {
                            return "Enter password";
                          } else if (v.length <= 5) {
                            "password length is too short!";
                          }
                        },
                        obscureTextt: provider.obscurePasswordLogin,
                        iconField: IconButton(
                            onPressed: () {
                              provider.setLoginObscure();
                            },
                            icon: provider.obscurePasswordLogin
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility)),
                      );
                    },
                  ),
                  SizedBox(height: 10 * h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (email.text.isNotEmpty) {
                            await _auth.resetPassword(email.text, context);
                          } else {}
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                              fontFamily: "Poppins",
                              color: Theme.of(context).primaryColor),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 40 * h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Consumer<AuthViewModel>(
                          builder: (context, provider, child) {
                            return CupertinoButton(
                              color: Theme.of(context).primaryColor,
                              padding: EdgeInsets.zero,
                              borderRadius: BorderRadius.circular(6),
                              onPressed: () async {
                                provider.signIn(email.text.trim(),
                                    pass.text.trim(), context);
                              },
                              child: provider.loginLoader
                                  ? Center(
                                      child: Transform.scale(
                                      scale: 0.5,
                                      child: const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 3,
                                      ),
                                    ))
                                  : const Text('Login'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40 * h,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                        color: Theme.of(context).primaryColor,
                        thickness: 2,
                      )),
                      SizedBox(
                        width: 30 * w,
                      ),
                      const Text('or'),
                      SizedBox(
                        width: 30 * w,
                      ),
                      Expanded(
                          child: Divider(
                        color: Theme.of(context).primaryColor,
                        thickness: 2,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 40 * h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: const Color(0xffE5E5E5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor))),
                          onPressed: () {
                            _auth.signInWithGoogle(context).then((value) {
                              Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => const BottomBar()));
                            });
                          },
                          child: Image.asset(
                            Assets.imagesGoogleLogo,
                            height: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50 * h,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(
                        children: [
                          const Text(
                            "Not a member?",
                            style: TextStyle(fontSize: 16),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Register.routeName,
                              );
                            },
                            child: Text(
                              "Register",
                              softWrap: true,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30 * h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
