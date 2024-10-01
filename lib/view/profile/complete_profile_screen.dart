import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../your_goal/your_goal_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  static String routeName = "/CompleteProfileScreen";

  @override
  _CompleteProfileScreenState createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late String selectedGender = "male";
  late DateTime selectedDateOfBirth;
  late String selectedWeight = "";
  late String selectedHeight = "";
  late TextEditingController dateOfBirthController;

  @override
  void initState() {
    super.initState();
    selectedDateOfBirth = DateTime.now();
    dateOfBirthController = TextEditingController(
      text:
          "${selectedDateOfBirth.day}/${selectedDateOfBirth.month}/${selectedDateOfBirth.year}",
    );
  }

  @override
  void dispose() {
    dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ModalRoute.of(context)!.settings.arguments as String;
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Column(
              children: [
                Image.asset("assets/images/complete_profile.png",
                    width: media.width),
                SizedBox(height: 15),
                Text(
                  "Let’s complete your profile",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "It will help us to know more about you!",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 172, 164, 166),
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Gender",
                          icon: Image.asset("assets/icons/gender_icon.png"),
                          
                        ),
                        value: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                        items: ["male", "female", "Other"]
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                      color: Colors
                                          .white), // Set text color to white
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 15),
                      InkWell(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDateOfBirth,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null &&
                              pickedDate != selectedDateOfBirth) {
                            setState(() {
                              selectedDateOfBirth = pickedDate;
                              dateOfBirthController.text =
                                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            });
                          }
                        },
                        child: TextFormField(
                          style: TextStyle(
                                      color: Colors
                                          .white),
                          enabled: false,
                          controller: dateOfBirthController,
                          decoration: InputDecoration(
                            labelText: "Date of Birth",
                            icon: Image.asset("assets/icons/calendar_icon.png"),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        style: TextStyle(
                                      color: Colors
                                          .white),
                        decoration: InputDecoration(
                          labelText: "Your Weight",
                          icon: Image.asset("assets/icons/weight_icon.png"),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          selectedWeight = value;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        style: TextStyle(
                                      color: Colors
                                          .white),
                        decoration: InputDecoration(
                          labelText: "Your Height",
                          icon: Image.asset("assets/icons/swap_icon.png"),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          selectedHeight = value;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                RoundGradientButton(
                  title: "Next >",
                  onPressed: () async {
                    try {
                      final firestore = FirebaseFirestore.instance;
                      final userDoc =
                          firestore.collection('user_profiles').doc(userId);

                      final userDocSnapshot = await userDoc.get();
                      if (!userDocSnapshot.exists) {
                        await userDoc.set({});
                      }

                      await userDoc.update({
                        'gender': selectedGender,
                        'dateOfBirth': selectedDateOfBirth.toString(),
                        'weight': selectedWeight,
                        'height': selectedHeight,
                      });

                      Navigator.pushNamed(
                        context,
                        YourGoalScreen.routeName,
                        arguments: userId,
                      );
                    } catch (e) {
                      print("Error saving profile data: $e");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
