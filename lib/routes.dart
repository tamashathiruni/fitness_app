import 'package:fitnessapp/view/activity/activity_screen.dart';
import 'package:fitnessapp/view/activity_tracker/activity_tracker_screen.dart';
import 'package:fitnessapp/view/chat/chat.dart';
import 'package:fitnessapp/view/chat/chatins.dart';
import 'package:fitnessapp/view/dashboard/dashboard_screen.dart';
import 'package:fitnessapp/view/finish_workout/finish_workout_screen.dart';
import 'package:fitnessapp/view/instructor/instructor.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:fitnessapp/view/notification/notification_screen.dart';
import 'package:fitnessapp/view/payments/pay.dart';
import 'package:fitnessapp/view/profile/complete_profile_screen.dart';
import 'package:fitnessapp/view/ratings/rratings.dart';
import 'package:fitnessapp/view/signup/signup_screen.dart';
import 'package:fitnessapp/view/time/time.dart';
import 'package:fitnessapp/view/welcome/welcome_screen.dart';
import 'package:fitnessapp/view/workout_schedule_view/workout_schedule_view.dart';
import 'package:fitnessapp/view/your_goal/your_goal_screen.dart';
import 'package:flutter/cupertino.dart';

import 'view/profile/user_profile.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (context) => LoginScreen(),
  ReserveTimePage.rutename: (context) => ReserveTimePage(),
  Rratings.rutename: (context) {
    final userId = ModalRoute.of(context)!.settings.arguments as String;
    return Rratings(userId: userId);
  },
  ChatScreen.routeName: (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final userId = args['userId']!; // Get userId from the arguments map
    final documentId =
        args['documentId']!; // Get documentId from the arguments map

    return ChatScreen(
        userId: userId, documentId: documentId); // Pass the correct parameters
  },
  Chat.routeName: (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final userId = args['userId']!; // Get userId from the arguments map

    return Chat(userId: userId); // Pass the correct parameters
  },
  Pay.routeName: (context) {
    final userId = ModalRoute.of(context)!.settings.arguments as String;
    return Pay(userId: userId);
  },
  SignupScreen.routeName: (context) => const SignupScreen(),
  CompleteProfileScreen.routeName: (context) => CompleteProfileScreen(),
  YourGoalScreen.routeName: (context) => const YourGoalScreen(),
  WelcomeScreen.routeName: (context) {
    final userId = ModalRoute.of(context)!.settings.arguments as String;
    return WelcomeScreen(userId: userId);
  },
  DashboardScreen.routeName: (context) => DashboardScreen(
      userId: ModalRoute.of(context)!.settings.arguments as String? ?? ''),
  InstructorScreen.routeName: (context) => InstructorScreen(
      userId: ModalRoute.of(context)!.settings.arguments as String? ?? ''),
  UserProfile.routeName: (context) => UserProfile(
      userId: ModalRoute.of(context)!.settings.arguments as String? ?? ''),
  NotificationScreen.routeName: (context) => NotificationScreen(
      userId: ModalRoute.of(context)!.settings.arguments as String? ?? ''),
  FinishWorkoutScreen.routeName: (context) => const FinishWorkoutScreen(),
  ActivityTrackerScreen.routeName: (context) {
    final userId = ModalRoute.of(context)!.settings.arguments as String;
    return ActivityTrackerScreen(userId: userId);
  },
  ActivityScreen.routeName: (context) {
    final userId = ModalRoute.of(context)!.settings.arguments as String;
    return ActivityScreen(userId: userId);
  },
  WorkoutScheduleView.routeName: (context) => const WorkoutScheduleView(),
};
