import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../login/login_screen.dart';

class SignupScreen extends StatefulWidget {
  static String routeName = "/SignupScreen";

  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isCheck = false;

  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';

  void _registerUserWithEmailAndPassword(
      String email, String password, String firstName, String lastName) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'role': 'customer', // Set user role
      });

      // Show a success message and navigate to the login screen
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Successfully registered!'),
      ));
      Navigator.pushNamed(context, LoginScreen.routeName);
    } catch (e) {
      print("Error during registration: $e");

      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration failed. Please try again.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        UserCredential? userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential != null) {
          // Save user data to Firestore
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'firstName': userCredential.user!.displayName,
            'lastName': '',
            'role': 'customer',
            'email': userCredential.user!.email,
          });

          return userCredential;
        }
      }
    } catch (e) {
      print("Google sign-in error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 0, 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Hey there,",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Create an Account",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 20,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                RoundTextField(
                  hintText: "First Name",
                  icon: "assets/icons/profile_icon.png",
                  textInputType: TextInputType.name,
                  onChanged: (value) {
                    firstName = value;
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                RoundTextField(
                    hintText: "Last Name",
                    icon: "assets/icons/profile_icon.png",
                    textInputType: TextInputType.name,
                    onChanged: (value) {
                      lastName = value;
                    }),
                SizedBox(
                  height: 15,
                ),
                RoundTextField(
                    hintText: "Email",
                    icon: "assets/icons/message_icon.png",
                    textInputType: TextInputType.emailAddress,
                    onChanged: (value) {
                      email = value;
                    }),
                SizedBox(
                  height: 15,
                ),
                RoundTextField(
                  hintText: "Password",
                  icon: "assets/icons/lock_icon.png",
                  textInputType: TextInputType.text,
                  isObscureText: true,
                  onChanged: (value) {
                    password = value; // Update the password variable
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
                            color: const Color.fromARGB(255, 180, 177, 178),
                          ))),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            isCheck = !isCheck;
                          });
                        },
                        icon: Icon(
                          isCheck
                              ? Icons.check_box_outline_blank_outlined
                              : Icons.check_box_outlined,
                          color: const Color.fromARGB(255, 197, 194, 195),
                        )),
                    Expanded(
                      child: Text(
                          "By continuing you accept our Privacy Policy and\nTerm of Use",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 194, 192, 192),
                            fontSize: 10,
                          )),
                    )
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                RoundGradientButton(
                  title: "Register",
                  onPressed: () {
                    _registerUserWithEmailAndPassword(
                      email,
                      password,
                      firstName,
                      lastName,
                    );
                  },
                ),
                SizedBox(
                  height: 10,
                ),
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
                      color: const Color.fromARGB(255, 235, 235, 235)
                          .withOpacity(0.5),
                    )),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
  onTap: () async {
    UserCredential? userCredential = await signInWithGoogle();
    if (userCredential != null) {
      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': userCredential.user!.displayName,
        'lastName': '',
        'role': 'customer',
        'email': userCredential.user!.email,
      });
    }
  },
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
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context,
                        LoginScreen.routeName); // Use class name directly
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        const TextSpan(
                          text: "Already have an account? ",
                        ),
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 139, 239, 242),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
