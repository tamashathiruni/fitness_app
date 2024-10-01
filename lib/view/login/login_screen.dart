import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/instructor/instructor.dart';
import 'package:fitnessapp/view/signup/signup_screen.dart';
import 'package:fitnessapp/view/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../profile/complete_profile_screen.dart';

class LoginScreen extends StatelessWidget {
  static String routeName = "/LoginScreen";
  const LoginScreen({Key? key}) : super(key: key);
  Future<bool> checkUserProfileExists(String userId) async {
    try {
      final userProfileDoc =
          FirebaseFirestore.instance.collection('user_profiles').doc(userId);
      final userProfileSnapshot = await userProfileDoc.get();
      return userProfileSnapshot.exists;
    } catch (e) {
      print("Error checking user profile existence: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    String email = "";
    String password = "";
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            children: [
              SizedBox(
                width: media.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: media.width * 0.1,
                    ),
                    const Text(
                      "Hey there,",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: media.width * 0.01),
                    const Text(
                      "Welcome Back",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: media.width * 0.2),
              RoundTextField(
                hintText: "Email",
                icon: "assets/icons/message_icon.png",
                textInputType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value; // Update email when the text changes
                },
              ),
              SizedBox(height: media.width * 0.05),
              RoundTextField(
                hintText: "Password",
                icon: "assets/icons/lock_icon.png",
                textInputType: TextInputType.text,
                isObscureText: true,
                onChanged: (value) {
                  password = value; // Update password when the text changes
                },
                rightIcon: TextButton(
                    onPressed: () {},
                    child: Container(
                        alignment: Alignment.center,
                        width: 20,
                        height: 20,
                        child: Image.asset(
                          "assets/icons/hide_pwd_icon.png",
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ))),
              ),
              SizedBox(height: media.width * 0.03),
              const Text("Forgot your password?",
                  style: TextStyle(
                    color: Color.fromARGB(255, 190, 185, 187),
                    fontSize: 10,
                  )),
              const Spacer(),
              RoundGradientButton(
                title: "Login",
                onPressed: () async {
                  try {
                    UserCredential userCredential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    if (userCredential.user != null) {
                      String userId = userCredential.user!.uid;

                      bool userProfileExists =
                          await checkUserProfileExists(userId);

                      if (userProfileExists) {
                        // Retrieve user's role from Firestore
                        DocumentSnapshot userSnapshot = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(userId)
                            .get();
                        String userRole = userSnapshot['role'];

                        if (userRole == 'instructor') {
                          // Navigate to the InstructorScreen
                          Navigator.pushNamed(
                              context, InstructorScreen.routeName,
                              arguments: userId);
                        }
                      } else {
                        // Navigate to the CompleteProfileScreen
                        Navigator.pushNamed(
                            context, CompleteProfileScreen.routeName,
                            arguments: userId);
                      }
                    }
                  } catch (e) {
                    // Handle login errors here
                    print("Login failed: $e");
                  }
                },
              ),
              SizedBox(height: media.width * 0.01),
              Row(
                children: [
                  Expanded(
                      child: Container(
                    width: double.maxFinite,
                    height: 1,
                    color: AppColors.grayColor.withOpacity(0.5),
                  )),
                  Text("  Or  ",
                      style: TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                  Expanded(
                      child: Container(
                    width: double.maxFinite,
                    height: 1,
                    color: AppColors.grayColor.withOpacity(0.5),
                  )),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primaryColor1.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Image.asset(
                        "assets/icons/google_icon.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primaryColor1.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Image.asset(
                        "assets/icons/facebook_icon.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, SignupScreen.routeName);
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                        children: [
                          const TextSpan(
                            text: "Don’t have an account yet? ",
                          ),
                          TextSpan(
                              text: "Register",
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 139, 213, 242),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ]),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
