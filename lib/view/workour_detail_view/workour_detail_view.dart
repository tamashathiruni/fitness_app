import 'package:fitnessapp/common_widgets/round_gradient_button.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/view/workour_detail_view/widgets/exercises_set_section.dart';
import 'package:fitnessapp/view/workour_detail_view/widgets/icon_title_next_row.dart';
import 'package:flutter/material.dart';

import '../notification/notification_screen.dart';
import 'exercises_stpe_details.dart';

class WorkoutDetailView extends StatefulWidget {
  final Map dObj;
  final String userId;
  const WorkoutDetailView({Key? key, required this.dObj, required this.userId})
      : super(key: key);

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  List latestArr = [
    {
      "image": "assets/images/Workout1.png",
      "title": "Fullbody Workout",
      "time": "Today, 03:00pm"
    },
    {
      "image": "assets/images/Workout2.png",
      "title": "Upperbody Workout",
      "time": "June 05, 02:00pm"
    },
  ];

  List youArr = [
    {"image": "assets/icons/barbell.png", "title": "Barbell"},
    {"image": "assets/icons/skipping_rope.png", "title": "Skipping Rope"},
    {"image": "assets/icons/bottle.png", "title": "Bottle 1 Liters"},
  ];

  List exercisesArr = [
    {
      "name": "Set 1",
      "set": [
        {
          "image": "assets/images/1.png",
          "title": "Warm Up",
          "value": "05:00",
          "destitle": "Relax your Body",
          "destitle2": "Breathe Deeply",
          "destitle3": "Stretch Your Muscles",
          "destitle4": "Prepare for Workout",
          "long":
              "Begin your workout with a dynamic warm-up. This includes light cardio exercises like jogging in place and performing gentle jumping jacks. These activities raise your heart rate, increase blood flow to your muscles, and prepare your body for more intense movements. As you move, focus on taking deep breaths to increase oxygen intake and circulation. Gently stretch your major muscle groups to enhance flexibility, prevent injuries, and improve your range of motion. Use this time to mentally prepare yourself for the workout ahead by setting positive intentions.",
          "descriptiontitle1":
              "Start by doing light cardio exercises like jogging in place or jumping jacks.",
          "descriptiontitle2":
              "Focus on taking deep breaths to increase oxygen intake and warm up your muscles.",
          "descriptiontitle3":
              "Gently stretch major muscle groups to improve flexibility and prevent injuries.",
          "descriptiontitle4":
              "Mentally prepare yourself for the upcoming workout session.",
          "urlvideo": "assets/images/warmup.mp4",
        },
        {
          "image": "assets/images/2.png",
          "title": "Jumping Jack",
          "value": "12x",
          "destitle": "Relax your Body",
          "destitle2": "Activate Your Muscles",
          "destitle3": "Increase Heart Rate",
          "destitle4": "Cardio Exercise",
          "long":
              "Jumping jacks are a classic cardio exercise that engages your entire body. Stand with your feet together and arms by your sides. Jump and spread your legs wide while raising your arms overhead. Return to the starting position by jumping again with your feet together and arms by your sides. This exercise boosts your heart rate, burns calories, and improves cardiovascular fitness.",
          "descriptiontitle1":
              "Stand with your feet together and arms by your sides.",
          "descriptiontitle2":
              "Jump and spread your legs wide while raising your arms overhead.",
          "descriptiontitle3":
              "Jump again, returning to the starting position, and repeat for the specified repetitions.",
          "descriptiontitle4":
              "This exercise increases heart rate and improves cardiovascular endurance.",
          "urlvideo": "assets/images/jack.mp4",
        },
        {
          "image": "assets/images/3.png",
          "title": "Skipping",
          "value": "15x",
          "destitle": "Relax your Body",
          "destitle2": "Improve Coordination",
          "destitle3": "Burn Calories",
          "destitle4": "Cardio Exercise",
          "long":
              "Grab a skipping rope and let's get skipping! Hold the handles and swing the rope under your feet as you jump over it. Increase your jumping speed as you become more comfortable. Skipping is a fantastic way to improve coordination, enhance agility, and elevate your heart rate. It's an effective cardio exercise that also strengthens your calf muscles.",
          "descriptiontitle1":
              "Hold a skipping rope and jump over it as it swings under your feet.",
          "descriptiontitle2":
              "Use wrist and forearm movements to control the rope's movement.",
          "descriptiontitle3":
              "Continue jumping and gradually increase the speed to challenge yourself.",
          "descriptiontitle4":
              "Skipping is a fun way to burn calories and improve coordination.",
          "urlvideo": "assets/images/skipping.mp4",
        },
        {
          "image": "assets/images/4.png",
          "title": "Squats",
          "value": "20x",
          "destitle": "Relax your Body",
          "destitle2": "Engage Leg Muscles",
          "destitle3": "Strengthen Lower Body",
          "destitle4": "Build Leg Endurance",
          "long":
              "Stand with your feet shoulder-width apart and extend your arms forward for balance. Lower your body by bending your knees and pushing your hips back as if sitting in a chair. Maintain a straight back and chest up throughout the movement. Ensure your knees align with your ankles. Push through your heels to return to the starting position. Squats target your quadriceps, hamstrings, glutes, and lower back muscles.",
          "descriptiontitle1":
              "Stand with your feet shoulder-width apart and your arms extended forward.",
          "descriptiontitle2":
              "Lower your body by bending your knees and pushing your hips back as if sitting down.",
          "descriptiontitle3":
              "Keep your back straight and chest up while lowering yourself.",
          "descriptiontitle4":
              "Push through your heels to return to the starting position and repeat.",
          "urlvideo": "assets/images/squarts.mp4",
        },
        {
          "image": "assets/images/5.png",
          "title": "Arm Raises",
          "value": "00:53",
          "destitle": "Relax your Body",
          "destitle2": "Activate Shoulder Muscles",
          "destitle3": "Improve Upper Body Mobility",
          "destitle4": "Warm Up Upper Body",
          "long":
              "Activate your upper body with arm raises. Stand with your feet hip-width apart and arms by your sides. Raise your arms forward until they're parallel to the ground, keeping them straight. Slowly lower your arms back down while maintaining control. Arm raises engage your shoulder muscles and improve upper body mobility. This exercise is a great warm-up for your upper body workout.",
          "descriptiontitle1":
              "Stand with your feet hip-width apart and arms by your sides.",
          "descriptiontitle2":
              "Raise your arms forward until they are parallel to the ground.",
          "descriptiontitle3":
              "Lower your arms back to the starting position and repeat the movement.",
          "descriptiontitle4":
              "This exercise helps warm up your shoulder muscles and improves mobility.",
          "urlvideo": "assets/images/armraise.mp4",
        },
        {
          "image": "assets/images/6.png",
          "title": "Rest and Drink",
          "value": "02:00",
          "destitle": "Relax your Body",
          "destitle2": "Hydrate Yourself",
          "destitle3": "Catch Your Breath",
          "destitle4": "Prepare for Next Exercise",
          "long":
              "ake a moment to catch your breath and recover. Hydrate yourself by sipping water from your bottle. Use this time to calm your heart rate and prepare for the next exercise. Focus on breathing deeply to restore your energy levels. Mentally prepare yourself for the upcoming challenges in your workout routine.",
          "descriptiontitle1": "Take a moment to relax and catch your breath.",
          "descriptiontitle2":
              "Grab a water bottle and hydrate yourself to stay energized.",
          "descriptiontitle3":
              "Focus on slowing down your breathing and preparing for the next exercise.",
          "descriptiontitle4":
              "Use this time to mentally prepare for the upcoming challenges.",
          "urlvideo": "assets/images/rest.mp4",
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    print("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr" + widget.userId);
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
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
                      color: const Color.fromARGB(0, 247, 248, 248),
                      borderRadius: BorderRadius.circular(10)),
                  child: Image.asset(
                    "assets/icons/back_icon.png",
                    width: 15,
                    height: 15,
                    fit: BoxFit.contain,
                  ),
                ),
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
                        color: const Color.fromARGB(0, 247, 248, 248),
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
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: Container(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/images/detail_top.png",
                  width: media.width * 0.75,
                  height: media.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 0, 0),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 175, 170, 172)
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.dObj["title"].toString(),
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  "${widget.dObj["exercises"].toString()} | ${widget.dObj["time"].toString()} | 320 Calories Burn",
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 192, 191, 191),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Image.asset(
                              "assets/icons/fav_icon.png",
                              width: 15,
                              height: 15,
                              fit: BoxFit.contain,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      IconTitleNextRow(
                          icon: "assets/icons/difficulity_icon.png",
                          title: "Difficulity",
                          time: "Beginner",
                          color:
                              Color.fromARGB(255, 60, 255, 0).withOpacity(0.8),
                          onPressed: () {}),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "You'll Need",
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "${youArr.length} Items",
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.5,
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: youArr.length,
                            itemBuilder: (context, index) {
                              var yObj = youArr[index] as Map? ?? {};
                              return Container(
                                  margin: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: media.width * 0.35,
                                        width: media.width * 0.35,
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 0, 0, 0),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          yObj["image"].toString(),
                                          width: media.width * 0.2,
                                          height: media.width * 0.2,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          yObj["title"].toString(),
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontSize: 12),
                                        ),
                                      )
                                    ],
                                  ));
                            }),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Exercises",
                            style: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "${youArr.length} Sets",
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 175, 175, 175),
                                  fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: exercisesArr.length,
                          itemBuilder: (context, index) {
                            var sObj = exercisesArr[index] as Map? ?? {};
                            return ExercisesSetSection(
                              sObj: sObj,
                              onPressed: (obj) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExercisesStepDetails(
                                      eObj: obj,
                                      userId: widget.userId,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                      SizedBox(
                        height: media.width * 0.1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
