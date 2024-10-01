import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Rratings extends StatefulWidget {
  static String rutename = '/rating';
  final String userId;

  Rratings({Key? key, required this.userId}) : super(key: key);

  @override
  State<Rratings> createState() => _RratingsState();
}

class _RratingsState extends State<Rratings> {
  @override
  void initState() {
    super.initState();
    fetchClientsAndRatings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
            child: Text(
          "Customer Reviews",
          style: TextStyle(color: Colors.white),
        )),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchClientsAndRatings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(
                "FutureBuilder Error: ${snapshot.error}"); // Add this to see the full error
            return Center(child: Text("Error fetching data"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No ratings found"));
          }

          // Display the list of clients and their ratings
          List<Map<String, dynamic>> clients = snapshot.data!;
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              var client = clients[index];
              return ListTile(
                title: Text(
                  client['name'],
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "Rating: ${client['rating']}",
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchClientsAndRatings() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> clientsList = [];

    try {
      // Get all users from the 'users' collection
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        try {
          // Fetch the user's ID and name
          String clientId = userDoc.id;
          String clientName = userDoc[
              'firstName']; // Adjust this field as per your data structure

          // Get all documents from the 'rating' collection
          QuerySnapshot ratingsSnapshot =
              await _firestore.collection('rating').get();

          // Loop through each document in the 'rating' collection
          for (var ratingDoc in ratingsSnapshot.docs) {
            // Get the data from the document
            Map<String, dynamic>? ratingData =
                ratingDoc.data() as Map<String, dynamic>?;

            if (ratingData != null) {
              // Construct the dynamic field name using clientId + 'rating'
              String ratingFieldName = clientId + 'rating';

              // Check if the field exists in the current rating document
              if (ratingData.containsKey(ratingFieldName)) {
                // Get the rating value
                var ratingValue = ratingData[ratingFieldName];

                // Check if the rating is double or int and convert to int if necessary
                int rating = (ratingValue is int)
                    ? ratingValue
                    : (ratingValue as double).toInt();

                // Add the client name and rating to the list
                clientsList.add({
                  'name': clientName,
                  'rating': rating,
                });
                break; // Break the loop if rating found for this client
              }
            }
          }
        } catch (e) {
          print("Error processing user ${userDoc.id}: $e");
        }
      }
    } catch (e) {
      print("Error fetching users or ratings: $e");
    }

    return clientsList;
  }
}
