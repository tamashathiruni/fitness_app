import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Pay extends StatefulWidget {
  static const routeName = "/Pay";
  final String userId;

  Pay({Key? key, required this.userId}) : super(key: key);

  @override
  State<Pay> createState() => _PayState();
}

class _PayState extends State<Pay> {
  String? selectedPackage;
  List<String> dropdownMenu = ['base', 'Gold', 'titan', 'common', 'gradient'];
  final _formKey = GlobalKey<FormState>();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    priceController.text = '0';
    fetchFirstName(); // Initialize price to 0
  }

  void _updatePrice(String? package) {
    // Update the price based on the selected package
    switch (package) {
      case 'base':
        priceController.text = '1000';
        break;
      case 'Gold':
        priceController.text = '2000';
        break;
      case 'titan':
        priceController.text = '3000';
        break;
      case 'common':
        priceController.text = '1500';
        break;
      case 'gradient':
        priceController.text = '2500';
        break;
      default:
        priceController.text = '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'Payment',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown Menu for Package Selection
              Center(
                child: Text(
                  'Select Package',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Center(
                child: DropdownButton<String>(
                  value: selectedPackage,
                  hint: Text(
                    'Choose your package',
                    style: TextStyle(color: Colors.white),
                  ),
                  items: dropdownMenu.map((String package) {
                    return DropdownMenuItem<String>(
                      value: package,
                      child:
                          Text(package, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPackage = newValue;
                      _updatePrice(
                          newValue); // Update price when package is selected
                    });
                  },
                  dropdownColor: Colors.black, // Set dropdown color
                ),
              ),

              SizedBox(height: 100),

              // Price Input
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800], // Price field color
                ),
                keyboardType: TextInputType.number,
                readOnly: true,
              ),

              SizedBox(height: 20),

              // Card Number Input
              TextFormField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your card number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Expiry Date Input
              TextFormField(
                controller: expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date (MM/YY)',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter expiry date';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // CVV Input
              TextFormField(
                controller: cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CVV';
                  }
                  return null;
                },
              ),

              SizedBox(height: 30),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process the payment
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Processing Payment...'),
                        ),
                      );
                    }

                    sendEmail();
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchFirstName() async {
    try {
      // Fetch the document from 'users' collection using the userId
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId) // Access the document with userId
          .get();

      // Check if the document exists
      if (userDoc.exists) {
        // Cast the document data as a map and get the 'firstName'
        var userData = userDoc.data() as Map<String, dynamic>;
        String firstName = userData['firstName'] ??
            'No First Name'; // Ensure 'firstName' exists

        print('First Name: $firstName'); // Successfully fetched first name
      } else {
        print('User document does not exist.');
      }
    } catch (e) {
      print('Error fetching first name: $e');
    }
  }

  @override
  void dispose() {
    // Dispose of controllers
    cardNumberController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> sendEmail() async {
    final url = 'https://api.emailjs.com/api/v1.0/email/send';

    // API credentials
    final publicKey = 'NoQHvq6Ycch6Nhdkw';
    final serviceId = 'service_cqpixks';
    final templateId = 'template_bdcjyot';
    final privateKey = '4wxMK5xRqVK73YtMnlT7X';

    // Template parameters
    final templateParams = {
      'to_email': 'letfit96@gmail.com',
      'from_email': 'madup133@gmail.com',
      'subject':
          'Payment notification {{$userName}}', // Template with placeholder
    };

    print("Template Params: $templateParams");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'accessToken': privateKey,
          'template_params': templateParams,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Email sent successfully');
        print(widget.userId);
      } else {
        print('Failed to send email: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('ERROR: $error');
    }
  }
}
