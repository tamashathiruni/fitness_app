import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/profile/widgets/setting_row.dart';
import 'package:fitnessapp/view/profile/widgets/title_subtitle_cell.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../common_widgets/round_button.dart';
import '../notification/notification_screen.dart';

class UserProfile extends StatefulWidget {
  static String routeName = "/UserProfile";
  final String userId;

  const UserProfile({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool positive = false;
  late String userId;
  late String firstName = "";
  late String height = "";
  late String weight = "";
  late String gender = "";
  late String selectedGoal = "";
  String profileImageUrl = "";
  File? _selectedImage;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  late Timer _timer;

  @override
  void initState() {
    userId = widget.userId;

    super.initState();
    fetchUserData();

    // Refresh user data every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchUserData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void fetchUserData() async {
    print("Fetching user data...");
    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch user name from 'users' collection
      final userDoc = firestore.collection('users').doc(widget.userId);
      final userDocSnapshot = await userDoc.get();
      if (userDocSnapshot.exists) {
        final userData = userDocSnapshot.data() as Map<String, dynamic>;
        final firstNames = userData['firstName'] ?? '';
        setState(() {
          firstName = firstNames;
        });
      } else {
        print("User not found.");
      }

      final userProfileDoc =
          firestore.collection('user_profiles').doc(widget.userId);
      final userProfileSnapshot = await userProfileDoc.get();
      if (userProfileSnapshot.exists) {
        final userProfileData =
            userProfileSnapshot.data() as Map<String, dynamic>;
        final userWeight = userProfileData['weight'] ?? '';
        final userHeight = userProfileData['height'] ?? '';
        final userGender = userProfileData['gender'] ?? '';
        final userselectedGoal = userProfileData['selectedGoal'] ?? '';
        final profileImage = userProfileData['profileImageUrl'];
        if (profileImage != null && profileImage.isNotEmpty) {
          setState(() {
            profileImageUrl = profileImage;
          });
        }
        setState(() {
          weight = userWeight;
          height = userHeight;
          gender = userGender;
          selectedGoal = userselectedGoal;
        });
      } else {
        print("User profile not found.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void showEditProfilePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Pick Image"),
                ),
                TextFormField(
                  initialValue: height,
                  onChanged: (value) {
                    setState(() {
                      height = value;
                    });
                  },
                  decoration: InputDecoration(labelText: "Height"),
                ),
                TextFormField(
                  initialValue: weight,
                  onChanged: (value) {
                    setState(() {
                      weight = value;
                    });
                  },
                  decoration: InputDecoration(labelText: "Weight"),
                ),
                DropdownButton<String>(
                  value: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value!;
                    });
                  },
                  items: ["male", "female", "other"].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: Text("Gender"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                saveProfileChanges(firstName, height, weight, gender);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveProfileChanges(String newFirstName, String newHeight,
      String newWeight, String newGender) async {
    final userId = _auth.currentUser!.uid; // Get current user ID

    try {
      // Upload image to Firebase Storage and get the download URL
      String imageUrl = "";
      if (_selectedImage != null) {
        final imageRef = _storage.ref().child('profile_images/$userId.jpg');
        final uploadTask = imageRef.putFile(_selectedImage!);
        final snapshot = await uploadTask.whenComplete(() => null);
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Update Firestore with the new data
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        'firstName': newFirstName,
      });

      await FirebaseFirestore.instance
          .collection("user_profiles")
          .doc(userId)
          .set({
        'height': newHeight,
        'weight': newWeight,
        'gender': newGender,
        'profileImageUrl': imageUrl, // Save the image URL
      });

      // Update the local state
      setState(() {
        firstName = newFirstName;
        height = newHeight;
        weight = newWeight;
        gender = newGender;
      });

      Navigator.pop(context);
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/LoginScreen',
      (route) => false,
    );
  }

  List otherArr = [
    {"image": "assets/icons/p_contact.png", "name": "Contact Us", "tag": "5"},
    {
      "image": "assets/icons/p_privacy.png",
      "name": "Privacy Policy",
      "tag": "6"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(
                      userId: widget.userId), // Pass the userId
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/icons/more_icon.png",
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: profileImageUrl.isNotEmpty
                        ? Image.network(
                            profileImageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons
                                .account_circle, // Default icon if no profile image
                            size: 24,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstName ??
                              "", // Display the name, use an empty string if null
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          selectedGoal,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 182, 181, 181),
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 25,
                    child: RoundButton(
                      title: "Edit",
                      type: RoundButtonType.primaryBG,
                      onPressed: () {
                        showEditProfilePopup();
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: TitleSubtitleCell(
                      title: height,
                      subtitle: "Height",
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: weight,
                      subtitle: "Weight",
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: gender,
                      subtitle: "Gender",
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Other",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: otherArr.length,
                      itemBuilder: (context, index) {
                        var iObj = otherArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {},
                        );
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                      height: 30,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _logout, // Call the _logout function when the button is pressed
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red, // Customize the button color
                        ),
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
