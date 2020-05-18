import 'package:cloud_firestore/cloud_firestore.dart';

class HelpObject {
  final String name;
  final String surname;
  final String gender;
  final String bloodGroup;
  final String type;
  final int patientCount;
  final GeoPoint destination;
  final String adress;
  final String adressCaption;

  HelpObject(this.name, this.surname, this.gender, this.bloodGroup, this.type,
      this.patientCount, this.destination, this.adress, this.adressCaption);
}
