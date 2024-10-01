import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/activity_tracker/widgets/latest_activity_row.dart';
import 'package:fitnessapp/view/activity_tracker/widgets/today_target_cell.dart';
import 'package:flutter/material.dart';

import '../notification/notification_screen.dart';

class ActivityTrackerScreen extends StatefulWidget {
  static String routeName = "/ActivityTrackerScreen";
  final String userId;
  const ActivityTrackerScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  String Intake = '';
  String Steps = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('exercise_data').doc(widget.userId);

      final userDocSnapshot = await userDoc.get();
      if (userDocSnapshot.exists) {
        final userData = userDocSnapshot.data() as Map<String, dynamic>;
        final waterIntake = userData['waterIntake'] ?? '';
        final footSteps = userData['footSteps'] ?? '';
        setState(() {
          Intake = waterIntake;
          Steps = footSteps;
        });
      } else {
        // If no user data exists, create a new document with default values
        await userDoc.set({
          'waterIntake': '',
          'footSteps': '',
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> _buildWorkoutList(
      BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('progress')
          .doc(widget.userId)
          .collection('workouts')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text("Error fetching workout data");
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text("No workout data available");
        } else {
          return Column(
            children: snapshot.data!.docs.map((doc) {
              final title = doc['title'] as String;
              final value = doc['value'].toString();

              return Card(
                // Customize the card appearance as needed
                child: ListTile(
                  title: Text(title),
                  subtitle: Text(value),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  final _formKey = GlobalKey<FormState>();
  String waterIntake = "";
  String footSteps = "";

  int touchedIndex = -1;

  void _showAddDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: AlertDialog(
            title: Text("Add Water Intake and Foot Steps"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Water Intake (ml)'),
                    onChanged: (value) {
                      waterIntake = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Foot Steps'),
                    onChanged: (value) {
                      footSteps = value;
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveDataToFirestore();
                    Navigator.pop(context);
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveDataToFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userId = ModalRoute.of(context)!.settings.arguments as String;
      await firestore.collection('exercise_data').doc(userId).set({
        'waterIntake': waterIntake,
        'footSteps': footSteps,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data saved successfully")),
      );
    } catch (e) {
      print("Error saving data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/icons/back_icon.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Activity Tracker",
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('exercise_data')
            .doc(widget.userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show loading indicator
          } else if (snapshot.hasError) {
            return Text("Error fetching user data");
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text(
                "Hello there your data is creating please come back again in 5 second");
          } else {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final waterIntake = userData['waterIntake'] ?? '';
            final footSteps = userData['footSteps'] ?? '';

            return SingleChildScrollView(
              child: Container(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            const Color.fromARGB(255, 0, 38, 255)
                                .withOpacity(0.3),
                            const Color.fromARGB(255, 47, 0, 255)
                                .withOpacity(0.3)
                          ]),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Today Target",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: AppColors.primaryG,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: MaterialButton(
                                      onPressed:
                                          _showAddDataDialog, // Connect to the popup form
                                      padding: EdgeInsets.zero,
                                      height: 30,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      textColor: Color.fromARGB(255, 9, 255, 0),
                                      minWidth: double.maxFinite,
                                      elevation: 0,
                                      color: const Color.fromARGB(
                                          0, 255, 255, 255),
                                      child: Icon(
                                        Icons.add,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        size: 15,
                                      ),
                                    ),
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
                                  child: TodayTargetCell(
                                    icon: "assets/icons/water_icon.png",
                                    value: Intake,
                                    title: "Water Intake",
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: TodayTargetCell(
                                    icon: "assets/icons/foot_icon.png",
                                    value: Steps,
                                    title: "Foot Steps",
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: media.width * 0.1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Workout Done",
                            style: TextStyle(
                                color: Color.fromARGB(255, 253, 253, 253),
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('progress')
                            .doc(widget.userId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Show loading indicator
                          } else if (snapshot.hasError) {
                            return Text("Error fetching workout data");
                          } else if (!snapshot.hasData ||
                              !snapshot.data!.exists) {
                            return Text("No workout data available");
                          } else {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final fieldValues = data.entries.map((entry) {
                              return "${entry.key}: ${entry.value}" +
                                  " cal burned";
                            }).toList();

                            return Column(
                              children: fieldValues.map((fieldValue) {
                                return Card(
                                  // Customize the card appearance as needed
                                  child: ListTile(
                                    title: Text(fieldValue),
                                  ),
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),
                      SizedBox(
                        height: media.width * 0.1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
