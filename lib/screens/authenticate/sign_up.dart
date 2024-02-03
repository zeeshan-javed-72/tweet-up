import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweet_up/generated/assets.dart';
import 'package:tweet_up/screens/authenticate/login.dart';
import 'package:tweet_up/services/auth.dart';
import '../../constants/custom_textfield.dart';

class Register extends StatefulWidget {
  static const routeName = '/Register';
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailC = TextEditingController();
  final nameC = TextEditingController();
  final pass = TextEditingController();
  final phone = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height/812;
    final w = MediaQuery.of(context).size.width/375;
    final textSize = MediaQuery.textScaleFactorOf(context);
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8*w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50*h),
                Image.asset(
                  Assets.assetsImagesAppIcon,
                  height: 150*h,
                  width: 150*w,
                ),
                SizedBox(height: 50*h),
                CustomTextField(
                  contrroller: nameC,
                  keyboardInputType: TextInputType.name,
                  hintText: "Name",
                  validator: (v) {
                    if (v == null || v == "") {
                      return "Enter user name";
                    }
                  },
                ),
                SizedBox(height: 8*h),
                CustomTextField(
                  contrroller: phone,
                  hintText: "Phone Number",
                  keyboardInputType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v == "") {
                      return "Enter phone number";
                    } else if (v.length <= 11) {
                      "Enter correct phone number!";
                    }
                  },

                ),
                SizedBox(height: 8*h),
                Consumer<AuthViewModel>(
                  builder: (context, provider, child) {
                    return CustomTextField(
                      contrroller: emailC,
                      keyboardInputType: TextInputType.emailAddress,
                      hintText: "Email",
                      errorMessage: provider.registerEmailError,
                      onChange: (v) {
                        provider.registerEmailText(null);
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
                SizedBox(height: 8*h),
                Consumer<AuthViewModel>(
                  builder: (context, provider, child) {
                    return CustomTextField(
                      contrroller: pass,
                      keyboardInputType: TextInputType.visiblePassword,
                      hintText: "Password",
                      errorMessage: provider.registerPasswordError,
                      textInputAction: TextInputAction.next,
                      onChange: (v) {
                        provider.registerPasswordText(null);
                      },
                      validator: (v) {
                        if (v == null || v == "") {
                          return "Enter password";
                        } else if (v.length <= 5) {
                          "password length is too short!";
                        }
                      },
                      obscureTextt: provider.obscurePassword,
                      iconField: IconButton(onPressed: (){
                        provider.setRegisterObscure();
                      }, icon: provider.obscurePassword ?
                      const Icon(Icons.visibility_off):
                      const Icon(Icons.visibility)
                      ),
                    );
                  },
                ),
                SizedBox(height: 40*h),
                Row(
                  children: [
                    Expanded(
                      child: Consumer<AuthViewModel>(
                        builder: (context, provider, child) {
                          return CupertinoButton(
                            padding: EdgeInsets.zero,
                            color: Theme.of(context).primaryColor,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                provider.signUp(emailC.text.trim(), pass.text.trim(), nameC.text, phone.text,  context);
                              } else {

                              }
                            },
                            child: provider.registerLoader
                                ?  Center(
                                    child: Transform.scale(
                                      scale: 0.6,
                                      child: const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 80*h),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: [
                    Text(
                      "Already a member?",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: textSize * 17),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          LoginScreen.id,
                        );
                      },
                      child: Text(
                        "Sign In",
                        softWrap: true,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: textSize * 17),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
