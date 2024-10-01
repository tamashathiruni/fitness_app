import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/activity/widgets/what_train_row.dart';
import 'package:fitnessapp/view/chat/chat.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import '../notification/notification_screen.dart';
import '../workour_detail_view/workour_detail_view.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ActivityScreen extends StatefulWidget {
  static const routeName = '/ActivityScreen';
  final String userId;

  const ActivityScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List whatArr = [
    {
      "image": "assets/images/what_1.png",
      "title": "Full Body Workout",
      "exercises": "11 Exercises",
      "time": "32mins"
    },
    {
      "image": "assets/images/what_2.png",
      "title": "Lowebody Workout",
      "exercises": "12 Exercises",
      "time": "40mins"
    }
  ];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // checkPaymentStatus();
    _timer = Timer.periodic(Duration(seconds: 60), (timer) {
      fetchData();
      //checkPaymentStatus();
    });
  }

  void fetchData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('requests').get();

      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /*void checkPaymentStatus() async {
    try {
      DocumentSnapshot paymentSnapshot = await FirebaseFirestore.instance
          .collection('payment')
          .doc(widget.userId) // Assuming userId is the document ID
          .get();

      if (paymentSnapshot.exists) {
        bool paymentStatus =
            paymentSnapshot['payment']; // Assuming the field name is 'payment'
        if (!paymentStatus) {
          // Payment is false, show popup
          showMembershipPopup();
        }
      }
    } catch (error) {
      print('Error checking payment status: $error');
    }
  }

  void showMembershipPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Disable background touch interactions
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            // Prevent back navigation
            return false;
          },
          child: AlertDialog(
            title: Text("Membership Payment"),
            content: Text(
                "You have to pay for a membership to access this feature."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Close the initial payment dialog
                  showCreditCardDetailsPopup(); // Show the credit card details popup
                },
                child: Text("Pay Now"),
              ),
            ],
          ),
        );
      },
    );
  }

  void showCreditCardDetailsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController cardNumberController = TextEditingController();
        TextEditingController expirationDateController =
            TextEditingController();
        TextEditingController cvvController = TextEditingController();

        return AlertDialog(
          title: Text("Enter Credit Card Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardNumberController,
                decoration: InputDecoration(labelText: "Card Number"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: expirationDateController,
                decoration: InputDecoration(labelText: "Expiration Date"),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 16),
              TextField(
                controller: cvvController,
                decoration: InputDecoration(labelText: "CVV"),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Retrieve entered data
                String cardNumber = cardNumberController.text;
                String expirationDate = expirationDateController.text;
                String cvv = cvvController.text;

                // Process the payment with collected data
                // You would typically call a payment processing service here

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    print('gggggggggggggggggggggggggggggggggggggggggggg' + widget.userId);
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Color.fromARGB(0, 255, 255, 255),
              centerTitle: true,
              elevation: 0,
              // pinned: true,
              title: const Text(
                "Workout Tracker",
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
                      width: 15,
                      height: 15,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ],
            ),
            SliverAppBar(
              backgroundColor: const Color.fromARGB(0, 248, 248, 248),
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: const SizedBox(),
              expandedHeight: media.height * 0.01,
              flexibleSpace: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: media.width * 0.5,
                width: double.maxFinite,
              ),
            )
          ];
        },
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 0, 0),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.grayColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3)),
                    ),
                    SizedBox(
                      height: media.width * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Request an Instructor",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: media.width * 0.1,
                        ),
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 2),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 0, 0, 0),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 2)
                            ]),
                        child: Row(
                          children: [
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('instructors')
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }

                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return Text('No data available.');
                                    }

                                    return buildInstructorCards(
                                        snapshot.data!, widget.userId);
                                  },
                                ),
                              ],
                            )),
                          ],
                        )),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "What Do You Want to Train",
                          style: TextStyle(
                              color: AppColors.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: whatArr.length,
                        itemBuilder: (context, index) {
                          var wObj = whatArr[index] as Map? ?? {};
                          return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorkoutDetailView(
                                      dObj: wObj,
                                      userId: widget
                                          .userId, // Pass the userId to the next screen
                                    ),
                                  ),
                                );
                              },
                              child: WhatTrainRow(wObj: wObj));
                        }),
                    SizedBox(
                      height: media.width * 0.1,
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  void _showInstructorDetailsPopup(
    String instructorName,
    String instructorAge,
    String instructorTotalMembers,
    String instructorExperience,
    String documentId,
    double averageRating,
  ) async {
    bool userHasRequested =
        await hasUserRequestedInstructor(documentId, widget.userId);

    setState(() {
      documentId = documentId; // Store the documentId
    });

    if (!userHasRequested) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Instructor profile",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("Name", instructorName),
                _buildInfoRow("Age", instructorAge),
                _buildInfoRow("Total Members", instructorTotalMembers),
                _buildInfoRow("Experience", instructorExperience),
                Text(
                  "Average Rating: ${averageRating.toStringAsFixed(2)}", // Display average rating
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  bool confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Are you sure?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text("Confirm"),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    _sendRequest(documentId);
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  "Request",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      double userRating = 0;
      String userFeedback = "";

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Instructor Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("Name", instructorName),
                _buildInfoRow("Age", instructorAge),
                _buildInfoRow("Total Members", instructorTotalMembers),
                _buildInfoRow("Experience", instructorExperience),
                RatingBar.builder(
                  initialRating: userRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 30.0,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    userRating = rating;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Feedback"),
                  onChanged: (value) {
                    userFeedback = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Close",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  bool confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Are you sure?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text("Confirm"),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    _sendRequest(documentId);
                    _submitRatingFeedback(documentId, userRating, userFeedback);
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  "Submit Rating & Feedback",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _submitRatingFeedback(
      String documentId, double userRating, String userFeedback) async {
    try {
      await FirebaseFirestore.instance
          .collection('rating')
          .doc(documentId)
          .set({
        widget.userId + "rating": userRating,
        widget.userId + "feedback": userFeedback,
      }, SetOptions(merge: true));
    } catch (error) {
      print('Error submitting rating and feedback: $error');
    }
  }

  Future<double> getAverageRating(String instructorId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('rating')
          .doc(instructorId)
          .get();

      if (!querySnapshot.exists) {
        return 0.0;
      }

      final data = querySnapshot.data() as Map<String, dynamic>;
      final userRatings = data.values.whereType<double>().toList();

      if (userRatings.isEmpty) {
        return 0.0;
      }

      double totalRating = userRatings.reduce((a, b) => a + b);
      double averageRating = totalRating / userRatings.length;

      return averageRating;
    } catch (error) {
      print('Error getting average rating: $error');
      return 0.0;
    }
  }

  void _sendRequest(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(documentId)
          .set({
        widget.userId: false,
      }, SetOptions(merge: true));
    } catch (error) {
      print('Error sending request: $error');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInstructorCards(QuerySnapshot snapshot, String userId) {
    return Column(
      children: snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final instructorName = data['name'].toString();
        final instructorAge = data['age'].toString();
        final instructorTotalmembers = data['totalmembers'].toString();
        final instructorExperience = data['experience'].toString();
        final documentId = doc.id;

        return FutureBuilder<bool>(
          future: hasUserRequestedInstructor(documentId, userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Display a loading indicator while waiting for the result
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              bool hasRequested = snapshot.data ?? false;

              return GestureDetector(
                onTap: () async {
                  double averageRating = await getAverageRating(documentId);

                  _showInstructorDetailsPopup(
                    instructorName,
                    instructorAge,
                    instructorTotalmembers,
                    instructorExperience,
                    documentId,
                    averageRating,
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 17, 0, 0),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name: $instructorName",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Age: $instructorAge",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 10,
                        ),
                      ),
                      FutureBuilder<double>(
                        future: getAverageRating(
                            documentId), // Pass the documentId here
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          double averageRating = snapshot.data ?? 0.0;
                          return Text(
                            "Instructor Rating: $averageRating",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                      Text(
                        "Instructor ID: $documentId",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              ChatScreen.routeName,
                              arguments: {
                                'userId': widget.userId,
                                'documentId':
                                    documentId, // Pass documentId here
                              },
                            );
                          },
                          child: Text("Chat"))
                    ],
                  ),
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }

  Future<bool> hasUserRequestedInstructor(
      String documentId, String userId) async {
    print(documentId);
    print(userId);
    bool hasRequested = false; // Default to false

    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .doc(documentId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> requestData =
            docSnapshot.data() as Map<String, dynamic>;
        if (requestData.containsKey(userId) && requestData[userId] == true) {
          hasRequested = true;
        }
      }
    } catch (error) {
      print('Error checking user request: $error');
    }

    print(hasRequested);
    return hasRequested;
  }

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
            //tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            ),
      );

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        color: AppColors.whiteColor,
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
        color: AppColors.whiteColor.withOpacity(0.5),
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

  SideTitles get rightTitles => SideTitles(
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
      );
}
