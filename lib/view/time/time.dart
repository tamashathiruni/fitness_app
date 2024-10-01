import 'package:flutter/material.dart';

class ReserveTimePage extends StatefulWidget {
  static String rutename = '/time';

  @override
  _ReserveTimePageState createState() => _ReserveTimePageState();
}

class _ReserveTimePageState extends State<ReserveTimePage> {
  List<String> timeSlots = [];
  String? selectedTime;

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
  }

  // Generate time slots from 9 AM to 9 PM
  void _generateTimeSlots() {
    for (int hour = 9; hour <= 21; hour++) {
      String time = hour < 12
          ? "$hour:00 AM"
          : (hour == 12 ? "12:00 PM" : "${hour - 12}:00 PM");
      timeSlots.add(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Reserve Time Slot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a time slot:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(timeSlots[index]),
                    leading: Radio<String>(
                      value: timeSlots[index],
                      groupValue: selectedTime,
                      onChanged: (value) {
                        setState(() {
                          selectedTime = value;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: selectedTime == null
                  ? null
                  : () {
                      // Handle reservation logic here
                      print('Reserved time: $selectedTime');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Reserved time: $selectedTime'),
                      ));
                    },
              child: Text('Reserve'),
            ),
          ],
        ),
      ),
    );
  }
}
