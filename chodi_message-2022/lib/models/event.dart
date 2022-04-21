import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String eventID;
  String ein;
  String name;
  int zip;
  String city;
  String state;
  String country;

  String address;
  String? imageURL;
  String? description;
  Timestamp startTime;
  Timestamp endTime;

  Event({
    required this.eventID,
    required this.ein,
    required this.name,
    required this.zip,
    required this.city,
    required this.state,
    required this.country,
    required this.address,
    this.imageURL,
    this.description,
    required this.startTime,
    required this.endTime,
  });

  factory Event.fromFirestore(QueryDocumentSnapshot fbData) {
    Map data = fbData.data() as Map;

    return Event(
      eventID: data['eventID'],
      ein: data['EIN'] ?? '',
      name: data['Name'] ?? '',
      zip: data['Zip'] ?? 0,
      city: data['City'] ?? '',
      state: data['State'] ?? '',
      country: data['Country'] ?? '',
      address: data['Address'] ?? '',
      imageURL: data['imageURL'] ?? '',
      description: data['Description'] ?? '',
      startTime: data['startTime'],
      endTime: data['endTime'],
    );
  }
}
