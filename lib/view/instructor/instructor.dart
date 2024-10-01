import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/common_widgets/round_button.dart';
import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:fitnessapp/view/ratings/rratings.dart';
import 'package:flutter/material.dart';

class InstructorScreen extends StatefulWidget {
  static String routeName = "/InstructorScreen";
  final String userId;

  const InstructorScreen({Key? key, required this.userId});

  @override
  State<InstructorScreen> createState() => _InstructorScreenState();
}

class _InstructorScreenState extends State<InstructorScreen> {
  String firstname = "";
  String lastname = "";
  late final String userId;

  @override
  void initState() {
    super.initState();
    fetchSingleDocumentFromFirestore();
    userId = widget.userId;
    fetchUserData();
  }

  List<Map<String, dynamic>> requests = [];
  List photoArr = [
    {
      "time": "2 June",
      "photo": [
        "assets/images/pp_1.png",
        "assets/images/pp_2.png",
        "assets/images/pp_3.png",
        "assets/images/pp_4.png",
      ]
    },
    {
      "time": "5 May",
      "photo": [
        "assets/images/pp_5.png",
        "assets/images/pp_6.png",
        "assets/images/pp_7.png",
        "assets/images/pp_8.png",
      ]
    }
  ];

  List<String> timeSlots = [
    "8h - 9h",
    "9h - 10h",
    "10h - 11h",
    "11h - 12h",
    "13h - 14h",
    "14h - 15h",
    "15h - 16h",
  ];

  List<TextEditingController> timeControllers = [];

  void _showAssignScheduleDialog() {
    for (int i = 0; i < timeSlots.length; i++) {
      timeControllers.add(TextEditingController());
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Assign Schedule"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(timeSlots.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: timeControllers[index],
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    decoration: InputDecoration(
                      labelText: timeSlots[index],
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 35, 32, 32)),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                List<String> selectedTimeSlots = [];

                for (int i = 0; i < timeControllers.length; i++) {
                  selectedTimeSlots.add(timeControllers[i].text);
                }

                try {
                  CollectionReference scheduleCollection =
                      FirebaseFirestore.instance.collection('schedule');

                  Map<String, dynamic> documentData = {};

                  for (int i = 0; i < selectedTimeSlots.length; i++) {
                    documentData[(i + 1).toString()] = selectedTimeSlots[i];
                  }

                  await scheduleCollection.doc('today').set(documentData);

                  Navigator.of(context).pop();
                } catch (e) {
                  print("Error saving data to Firestore: $e");
                }
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchSingleDocumentFromFirestore() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.userId)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          List<Map<String, dynamic>> requestData = [];

          data.forEach((key, value) {
            print("Key: $key, Value: $value");
            requestData.add({"id": key, "value": value});
          });

          setState(() {
            requests = requestData;
          });
        }
      } else {
        print("Document does not exist.");
      }
    } catch (e) {
      print("Error fetching document from Firestore: $e");
    }
  }

  Future<void> updateRequestStatus(String requestId, bool accepted) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.userId)
          .update({
        requestId: accepted,
      });

      await fetchSingleDocumentFromFirestore();
    } catch (e) {
      print("Error updating request status: $e");
    }
  }

  void _showAddTipsDialog() {
    String tipsText = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Daily Tips"),
          content: TextFormField(
            onChanged: (value) {
              tipsText = value;
            },
            decoration: InputDecoration(
              hintText: "Enter your daily tips",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (tipsText.isNotEmpty) {
                  try {
                    CollectionReference notificationsCollection =
                        FirebaseFirestore.instance.collection('notification');

                    await notificationsCollection.doc('instructors').set({
                      'notification': tipsText,
                    });

                    Navigator.of(context).pop();
                  } catch (e) {
                    print("Error adding tips to Firestore: $e");
                  }
                }
              },
              child: Text("Submit"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  void _showProgressDialog(String requestId) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('progress')
              .doc(requestId) // Use the requestId as the document ID
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return AlertDialog(
                title: Text("Error"),
                content:
                    Text("An error occurred while fetching progress data."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return AlertDialog(
                title: Text("Progress Data Not Found"),
                content: Text("No progress data found for this request."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            }

            final progressData = snapshot.data!.data() as Map<String, dynamic>?;

            if (progressData == null) {
              return AlertDialog(
                title: Text("Empty Progress Data"),
                content: Text("Progress data is empty."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            }

            // Create a list of progress entries
            List<Widget> progressEntries = [];
            progressData.forEach((key, value) {
              progressEntries.add(
                ListTile(
                  title: Text("Entry $key"),
                  subtitle: Text(value.toString()),
                ),
              );
            });

            return AlertDialog(
              title: Text("Progress Data"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: progressEntries,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteRequestDocument(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.userId)
          .update({
        requestId: FieldValue.delete(), // Delete the specific field
      });

      await fetchSingleDocumentFromFirestore();
    } catch (e) {
      print("Error deleting request document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox(),
        title: Text(
          "Welcome to Instructor Page",
          style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: _logout,
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/icons/logout.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(20),
                    height: media.width * 0.4,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Color.fromARGB(255, 0, 217, 255).withOpacity(0.4),
                          AppColors.primaryColor1.withOpacity(0.4)
                        ]),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Add Today shedule",
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 110,
                                height: 35,
                                child: RoundButton(
                                    title: "Assign Schedule",
                                    onPressed: () {
                                      _showAssignScheduleDialog();
                                    }),
                              )
                            ]),
                        Image.asset(
                          "assets/images/progress_each_photo.png",
                          width: media.width * 0.35,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor2.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add Daily Tips",
                        style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 100,
                        height: 25,
                        child: RoundButton(
                          title: "Add Tips",
                          onPressed: () {
                            _showAddTipsDialog();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor2.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "View Appointments",
                        style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 100,
                        height: 25,
                        child: RoundButton(
                          title: "Refresh",
                          onPressed: () {
                            fetchSingleDocumentFromFirestore();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor2.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "View Ratings",
                        style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 100,
                        height: 25,
                        child: RoundButton(
                          title: "view",
                          onPressed: () {
                            Navigator.pushNamed(context, Rratings.rutename,
                                arguments: widget.userId);
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor2.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Manage profile",
                        style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 100,
                        height: 25,
                        child: RoundButton(
                          title: "Edit",
                          onPressed: () {
                            showEditProfilePopup();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: media.width * 0.05,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final bool accepted = request['value'] as bool? ?? false;
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  color: accepted
                      ? Color.fromARGB(255, 130, 233, 70)
                      : Color.fromARGB(255, 230, 103, 103),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(request['id'])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            }
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return Text("User not found");
                            }

                            final userData =
                                snapshot.data!.data() as Map<String, dynamic>?;

                            if (userData == null) {
                              return Text("User data is empty");
                            }

                            final firstname = userData['firstName'] as String?;

                            return Text(
                              "Request ID: ${request['id']}\nFirst Name: $firstname",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                updateRequestStatus(request['id'], true);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                    fontSize: 14,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255))),
                              ),
                              child: Text("Accept"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                updateRequestStatus(request['id'], false);
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 255, 0, 0)),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                    fontSize: 14,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255))),
                              ),
                              child: Text("Reject"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showProgressDialog(request['id']);
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 255, 255, 255)),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                    fontSize: 14,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255))),
                              ),
                              child: Text("Progress"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                deleteRequestDocument(
                                    request['id']); // Delete the document
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 255, 0, 0)),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                    fontSize: 14,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255))),
                              ),
                              child: Text("X"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
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
                TextFormField(
                  initialValue: firstname,
                  onChanged: (value) {
                    setState(() {
                      firstname = value;
                    });
                  },
                  decoration: InputDecoration(labelText: "firstname"),
                ),
                TextFormField(
                  initialValue: lastname,
                  onChanged: (value) {
                    setState(() {
                      lastname = value;
                    });
                  },
                  decoration: InputDecoration(labelText: "lastname"),
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
                saveProfileChanges(firstname, lastname);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
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
        final lastnames = userData['lastName'] ?? '';

        setState(() {
          firstname = firstNames;
          lastname = lastnames;
        });
      } else {
        print("User not found.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> saveProfileChanges(
      String newFirstName, String newlastname) async {
    final userId = widget.userId; // Get current user ID

    try {
      // Update Firestore with the new data
      await FirebaseFirestore.instance.collection("users").doc(userId).update({
        'firstName': newFirstName,
        'lastName': newlastname,
      });

      // Update the local state
      setState(() {
        firstname = newFirstName;
        lastname = newlastname;
      });

      Navigator.pop(context);
    } catch (e) {
      print("Error updating profile: $e");
    }
  }
}
