import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/activity/activity_screen.dart';
import 'package:fitnessapp/view/payments/pay.dart';
import 'package:fitnessapp/view/profile/user_profile.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../../common_widgets/round_button.dart';
import '../activity_tracker/activity_tracker_screen.dart';
import '../activity_tracker/make_attendance.dart';

class ScheduleItem {
  final String field1;
  final String field2;
  final String field3;
  final String field4;
  final String field5;
  final String field6;
  final String field7;

  ScheduleItem({
    required this.field1,
    required this.field2,
    required this.field3,
    required this.field4,
    required this.field5,
    required this.field6,
    required this.field7,
  });
}

class DashboardScreen extends StatefulWidget {
  static String routeName = "/DashboardScreen";
  final String userId;

  const DashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Pedometer pedometer;
  String Intake = '';
  String Steps = '';
  String username = '';
  String weight = '';
  late Timer _timer;
  int steps = 0;
  StreamSubscription<StepCount>? _subscription;

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data immediately
    _subscription = Pedometer.stepCountStream.listen((StepCount event) {
      setState(() {
        steps = event.steps;
      });
    });

    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchUserData(); // Fetch user data every 1 minute
      reloadWidget();
      fetchProgressData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _subscription?.cancel();
  }

  void reloadWidget() {
    if (mounted) {
      setState(() {});
    }
  }

  int totalCalories = 0;

  Future<void> fetchProgressData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('progress')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;

        int total = 0;
        data.forEach((key, value) {
          total += value as int;
        });
        setState(() {
          totalCalories = total;
        });
      }
    } catch (error) {
      print("Error fetching progress data: $error");
      // You might want to show an error message to the user here.
    }
  }

  Future<void> fetchUserData() async {
    print("Fetching user data...");
    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch user name from 'users' collection
      final userDoc = firestore.collection('users').doc(widget.userId);
      final userDocSnapshot = await userDoc.get();
      if (userDocSnapshot.exists) {
        final userData = userDocSnapshot.data() as Map<String, dynamic>;
        final firstName = userData['firstName'] ?? '';
        setState(() {
          username = firstName;
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
        final userWeight =
            userProfileData['weight'] ?? ''; // Replace with actual field name
        setState(() {
          weight = userWeight;
        });
      } else {
        print("User profile not found.");
      }

      // Fetch water intake and foot steps from 'exercise_data' collection
      final exerciseDataDoc =
          firestore.collection('exercise_data').doc(widget.userId);
      final exerciseDataSnapshot = await exerciseDataDoc.get();
      if (exerciseDataSnapshot.exists) {
        final exerciseData =
            exerciseDataSnapshot.data() as Map<String, dynamic>;
        final waterIntake = exerciseData['waterIntake'] ?? '';
        final footSteps = exerciseData['footSteps'] ?? '';
        setState(() {
          Intake = waterIntake;
          Steps = footSteps;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<int> fetchAttendanceCount() async {
    int totalCount = 0;

    try {
      final firestore = FirebaseFirestore.instance;
      final QuerySnapshot attendanceSnapshot =
          await firestore.collection('attendance').get();

      for (QueryDocumentSnapshot docSnapshot in attendanceSnapshot.docs) {
        final attendanceData = docSnapshot.data() as Map<String, dynamic>;

        // Count fields that match the format userId$userId
        for (String key in attendanceData.keys) {
          if (key.contains("userId" + widget.userId)) {
            totalCount++;
          }
        }
      }
    } catch (e) {
      print("Error fetching attendance count: $e");
    }

    return totalCount;
  }

  int selectTab = 0;
  List<Widget> _widgetOptions = [];

  List<int> showingTooltipOnSpots = [21];

  List<FlSpot> get allSpots => const [
        FlSpot(0, 20),
        FlSpot(1, 25),
        FlSpot(2, 40),
        FlSpot(3, 50),
        FlSpot(4, 35),
        FlSpot(5, 40),
        FlSpot(6, 30),
        FlSpot(7, 20),
        FlSpot(8, 25),
        FlSpot(9, 40),
        FlSpot(10, 50),
        FlSpot(11, 35),
        FlSpot(12, 50),
        FlSpot(13, 60),
        FlSpot(14, 40),
        FlSpot(15, 50),
        FlSpot(16, 20),
        FlSpot(17, 25),
        FlSpot(18, 40),
        FlSpot(19, 50),
        FlSpot(20, 35),
        FlSpot(21, 80),
        FlSpot(22, 30),
        FlSpot(23, 20),
        FlSpot(24, 25),
        FlSpot(25, 40),
        FlSpot(26, 50),
        FlSpot(27, 35),
        FlSpot(28, 50),
        FlSpot(29, 60),
        FlSpot(30, 40),
      ];

  List waterArr = [
    {"title": "80%", "subtitle": "Your Good"},
    {"title": "70%", "subtitle": "Almost done"},
    {"title": "50%", "subtitle": "average"},
    {"title": "30%", "subtitle": "More to Go"},
    {"title": "10%", "subtitle": "Common!!!"}
  ];

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          AppColors.primaryColor2.withOpacity(0.5),
          AppColors.primaryColor1.withOpacity(0.5),
        ]),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 35),
          FlSpot(2, 70),
          FlSpot(3, 40),
          FlSpot(4, 80),
          FlSpot(5, 25),
          FlSpot(6, 70),
          FlSpot(7, 35),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          Color.fromARGB(255, 245, 25, 25).withOpacity(0.5),
          Color.fromARGB(255, 223, 0, 0).withOpacity(0.5),
        ]),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: false,
        ),
        spots: const [
          FlSpot(1, 80),
          FlSpot(2, 50),
          FlSpot(3, 90),
          FlSpot(4, 40),
          FlSpot(5, 80),
          FlSpot(6, 35),
          FlSpot(7, 60),
        ],
      );

  List lastWorkoutArr = [
    {"name": "Full Body Workout", "kcal": "180", "time": "20", "progress": 0.3},
  ];

  Future<List<ScheduleItem>> fetchTodaySchedule() async {
    final firestore = FirebaseFirestore.instance;
    final scheduleDoc =
        await firestore.collection('schedule').doc('today').get();

    if (scheduleDoc.exists) {
      final scheduleData = scheduleDoc.data() as Map<String, dynamic>;
      return [
        ScheduleItem(
          field1: scheduleData['1'] ?? '',
          field2: scheduleData['2'] ?? '',
          field3: scheduleData['3'] ?? '',
          field4: scheduleData['4'] ?? '',
          field5: scheduleData['5'] ?? '',
          field6: scheduleData['6'] ?? '',
          field7: scheduleData['7'] ?? '',
        ),
      ];
    } else {
      return [];
    }
  }

  void clearProgress(String userId) async {
    DocumentReference progressRef =
        FirebaseFirestore.instance.collection("progress").doc(userId);

    await progressRef.delete();
  }

  void showConfirmationDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Clear Progress"),
          content: Text("Are you sure you want to clear your progress?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                clearProgress(userId); // Clear the progress
              },
              child: Text("Clear"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(steps);
    var media = MediaQuery.of(context).size;
    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: false,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            AppColors.primaryColor2.withOpacity(0.4),
            AppColors.primaryColor1.withOpacity(0.1),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        dotData: FlDotData(show: false),
        gradient: LinearGradient(
          colors: AppColors.primaryG,
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: InkWell(
        onTap: () {},
        child: SizedBox(
          width: 70,
          height: 70,
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryG),
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [
                  BoxShadow(
                      color: Color.fromARGB(31, 255, 255, 255), blurRadius: 2)
                ]),
            child: const Icon(Icons.sports_gymnastics,
                color: Color.fromARGB(255, 0, 0, 0), size: 32),
          ),
        ),
      ),
      body: IndexedStack(
        index: selectTab,
        // children: _widgetOptions,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: media.width * 0.05),
                      Text(
                        "Welcome Back,",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        username.isEmpty ? "loading..." : username,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: media.width * 0.05),
                  Container(
                    height: media.width * 0.4,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(media.width * 0.025),
                          child: Image.asset(
                            "assets/images/bgdash.gif",
                            height: media.width * 0.6,
                            width: double.maxFinite,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 25, horizontal: 25),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your waight is :" + weight,
                                    style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "Lets Start letfit",
                                    style: TextStyle(
                                      color:
                                          AppColors.whiteColor.withOpacity(0.7),
                                      fontSize: 12,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: media.width * 0.05),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor1.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today Target",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 223, 223, 223),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          width: 75,
                          height: 30,
                          child: RoundButton(
                            title: "check",
                            type: RoundButtonType.primaryBG,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                ActivityTrackerScreen.routeName,
                                arguments: widget.userId,
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor1.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Live Step Count: $steps",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        height: media.width * 0.95,
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 10),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 52, 0, 150),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 2)
                            ]),
                        child: Row(children: [
                          SimpleAnimationProgressBar(
                            height: media.width * 0.9,
                            width: media.width * 0.07,
                            backgroundColor:
                                const Color.fromARGB(255, 245, 245, 245),
                            foregrondColor:
                                const Color.fromARGB(255, 39, 176, 39),
                            ratio: 0.5,
                            direction: Axis.vertical,
                            curve: Curves.fastLinearToSlowEaseIn,
                            duration: const Duration(seconds: 3),
                            borderRadius: BorderRadius.circular(30),
                            gradientColor: LinearGradient(
                                colors: AppColors.primaryG,
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Water Intake",
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: media.width * 0.01),
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                          colors: AppColors.primaryG,
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight)
                                      .createShader(Rect.fromLTRB(
                                          0, 0, bounds.width, bounds.height));
                                },
                                child: Text(
                                  Intake + " ml",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 134, 119, 189),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(height: media.width * 0.03),
                              Text(
                                "Real time updates",
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 250, 250, 250),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400),
                              ),
                              SizedBox(height: media.width * 0.01),
                              Column(
                                children: waterArr.map((obj) {
                                  color:
                                  const Color.fromARGB(255, 250, 250, 250);
                                  var isLast = obj == waterArr.last;
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 6),
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                          255, 0, 255, 0)
                                                      .withOpacity(0.9),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                            ),
                                            if (!isLast)
                                              DottedDashedLine(
                                                width: 0,
                                                height: media.width * 0.078,
                                                axis: Axis.vertical,
                                                dashColor: Color.fromARGB(
                                                        255, 0, 255, 55)
                                                    .withOpacity(0.5),
                                              )
                                          ]),
                                      SizedBox(width: 10),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: media.width * 0.01),
                                          Text(
                                            obj["title"].toString(),
                                            style: TextStyle(
                                                color: AppColors.blackColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          SizedBox(height: 1),
                                          ShaderMask(
                                            blendMode: BlendMode.srcIn,
                                            shaderCallback: (bounds) {
                                              return LinearGradient(
                                                      colors:
                                                          AppColors.secondaryG,
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight)
                                                  .createShader(Rect.fromLTRB(
                                                      0,
                                                      0,
                                                      bounds.width,
                                                      bounds.height));
                                            },
                                            child: Text(
                                              obj["subtitle"].toString(),
                                              style: TextStyle(
                                                color: AppColors.blackColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                                }).toList(),
                              )
                            ],
                          ))
                        ]),
                      )),
                      SizedBox(width: media.width * 0.05),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FutureBuilder<int>(
                            future: fetchAttendanceCount(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }

                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }

                              final attendanceCount = snapshot.data ?? 0;

                              return Container(
                                width: double.maxFinite,
                                height: media.width * 0.45,
                                padding: EdgeInsets.symmetric(
                                    vertical: 25, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 87, 0, 0),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12, blurRadius: 2)
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Attendance",
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: media.width * 0.01),
                                    ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                                colors: AppColors.primaryG,
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight)
                                            .createShader(Rect.fromLTRB(0, 0,
                                                bounds.width, bounds.height));
                                      },
                                      child: Text(
                                        "$attendanceCount days",
                                        style: TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Image.asset(
                                        "assets/images/cal.png",
                                        width: double.maxFinite,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: media.width * 0.05),
                          Container(
                            width: double.maxFinite,
                            height: media.width * 0.45,
                            padding: EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                            decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 2)
                                ]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Progress",
                                  style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: media.width * 0.01),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                            colors: AppColors.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                        .createShader(Rect.fromLTRB(
                                            0, 0, bounds.width, bounds.height));
                                  },
                                  child: Text(
                                    "$totalCalories cal",
                                    style: TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Image.asset(
                                  "assets/images/progress.png",
                                  width: double.maxFinite,
                                  fit: BoxFit.fitWidth,
                                ))
                              ],
                            ),
                          ),
                        ],
                      )),
                    ],
                  ),
                  SizedBox(height: media.width * 0.05),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color:
                            Color.fromARGB(255, 218, 92, 92).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Clear Progress",
                          style: TextStyle(
                            color: const Color.fromARGB(255, 223, 223, 223),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          width: 75,
                          height: 30,
                          child: RoundButton(
                            title: "Clear",
                            type: RoundButtonType.primaryBG,
                            onPressed: () {
                              String userId =
                                  "USER_ID_TO_CLEAR_PROGRESS"; // Replace with the actual user ID
                              showConfirmationDialog(context, userId);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today Gym Shedule",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: media.width * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<List<ScheduleItem>>(
                        future: fetchTodaySchedule(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (snapshot.hasData &&
                              snapshot.data!.isEmpty) {
                            return Text("No schedule data found.");
                          } else {
                            final schedule = snapshot.data!;
                            return DataTable(
                              columns: const [
                                DataColumn(
                                    label: Text('Field',
                                        style: TextStyle(color: Colors.white))),
                                DataColumn(
                                    label: Text('Value',
                                        style: TextStyle(color: Colors.white))),
                              ],
                              rows: [
                                DataRow(cells: [
                                  DataCell(Text('8h - 9h',
                                      style: TextStyle(color: Colors.white))),
                                  DataCell(Text(schedule[0].field1,
                                      style: TextStyle(color: Colors.white))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('9h - 10h',
                                      style: TextStyle(color: Colors.white))),
                                  DataCell(Text(schedule[0].field2,
                                      style: TextStyle(color: Colors.white))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('10h - 11h',
                                      style: TextStyle(color: Colors.white))),
                                  DataCell(Text(schedule[0].field3,
                                      style: TextStyle(color: Colors.white))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('11h - 12h',
                                      style: TextStyle(color: Colors.white))),
                                  DataCell(Text(schedule[0].field4,
                                      style: TextStyle(color: Colors.white))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('13h - 14h',
                                      style: TextStyle(color: Colors.white))),
                                  DataCell(Text(schedule[0].field5,
                                      style: TextStyle(color: Colors.white))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('14h - 15h',
                                      style: TextStyle(color: Colors.white))),
                                  DataCell(Text(schedule[0].field6,
                                      style: TextStyle(color: Colors.white))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('15h - 16h',
                                      style: TextStyle(color: Colors.white))),
                                  DataCell(Text(schedule[0].field7,
                                      style: TextStyle(color: Colors.white))),
                                ]),
                              ],
                            );
                          }
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  SizedBox(
                    height: media.width * 0.1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: Platform.isIOS ? 70 : 65,
        color: Colors.transparent,
        padding: const EdgeInsets.all(0),
        child: Container(
          height: Platform.isIOS ? 70 : 65,
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 0, 0, 0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 2, offset: Offset(0, -2))
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                  icon: "assets/icons/home_icon.png",
                  selectIcon: "assets/icons/home_select_icon.png",
                  isActive: selectTab == 0,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 0;
                      });
                    }
                  }),
              SizedBox(
                width: 25,
                height: 37,
                child: TabButton(
                  icon: "assets/icons/ttt.png",
                  selectIcon: "assets/icons/ttt.png",
                  isActive: selectTab == 1,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      UserProfile.routeName,
                      arguments: widget.userId,
                    );
                  },
                ),
              ),
              TabButton(
                icon: "assets/icons/activity_icon.png",
                selectIcon: "assets/icons/activity_select_icon.png",
                isActive: selectTab == 2,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ActivityScreen.routeName,
                    arguments: widget.userId,
                  );
                },
              ),
              const SizedBox(width: 30),
              TabButton(
                icon: "assets/icons/camera_icon.png",
                selectIcon: "assets/icons/camera_select_icon.png",
                isActive: selectTab == 3,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MakeAttendanceScreen(userId: widget.userId),
                    ),
                  );
                },
              ),
              TabButton(
                icon: "assets/icons/user_icon.png",
                selectIcon: "assets/icons/user_select_icon.png",
                isActive: selectTab == 4,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    UserProfile.routeName,
                    arguments: widget.userId,
                  );
                },
              ),
              TabButton(
                  icon: "assets/icons/user_icon.png",
                  selectIcon: "assets/icons/user_icon.png",
                  isActive: selectTab == 5,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Pay.routeName,
                      arguments: widget.userId,
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final String icon;
  final String selectIcon;
  final bool isActive;
  final VoidCallback onTap;

  const TabButton(
      {Key? key,
      required this.icon,
      required this.selectIcon,
      required this.isActive,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isActive ? selectIcon : icon,
            width: 25,
            height: 25,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(height: isActive ? 8 : 12),
          Visibility(
            visible: isActive,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.secondaryG),
                  borderRadius: BorderRadius.circular(2)),
            ),
          )
        ],
      ),
    );
  }
}
