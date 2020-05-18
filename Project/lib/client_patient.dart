import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PatientPage extends StatefulWidget {
  PatientPage({Key key}) : super(key: key);

  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _patientCountController = new TextEditingController();
  TextEditingController _situationController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _surnameController = new TextEditingController();
  String genderValue;
  String bloodValue;
  GeoPoint location;

  getLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      location = new GeoPoint(position.latitude, position.longitude);
      print(position.latitude.toString());
      print(position.longitude.toString());
    }).catchError((e) {
      print(e);
    });
  }

  addEmergencyCall() async {
    var cloudDb = Firestore.instance;
    var userRef =
        cloudDb.collection('Destinations').document("SlXRZ117n2do1OBa25WO");
    await userRef.setData({
      'Name': _nameController.text,
      'Surname': _surnameController.text,
      'Gender': genderValue ?? "",
      'BloodGroup': bloodValue ?? "",
      'PatientCount': _patientCountController.text,
      'Type': _situationController.text,
      'Location': location
    });
    BotToast.showText(text: "Çağrı Yapıldı");
  }

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Acil Çağrı",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 35),
                ),
                TextFormField(
                  controller: _nameController,
                  /*
                  validator: (value) {
                    if (value.isEmpty) {
                      return "İsim giriniz";
                    } else if (value.length < 3) {
                      return "İsim En Az 2 Karakter Olmalı";
                    }
                    return null;
                  },*/
                  decoration: InputDecoration(
                      labelText: 'İsim',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                      //hintText: 'İsim Soyisim',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 3))),
                ),
                TextFormField(
                  controller: _surnameController,
                  /*
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Soyisim giriniz";
                    } else if (value.length < 3) {
                      return "Soyisim En Az 2 Karakter Olmalı";
                    }
                    return null;
                  },*/
                  decoration: InputDecoration(
                      labelText: 'Soyisim',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                      //hintText: 'İsim Soyisim',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 3))),
                ),
                TextFormField(
                  controller: _patientCountController,
                  /*
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Yaralı Sayısı";
                    } else if (value.length == 0) {
                      return "Yaralı Sayısı Girin";
                    }
                    return null;
                  },*/
                  decoration: InputDecoration(
                      labelText: 'Yaralı Sayısı',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                      //hintText: 'İsim Soyisim',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 3))),
                ),
                TextFormField(
                  controller: _situationController,
                  /*
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Olay giriniz";
                    } else if (value.length < 3) {
                      return "Olay 3 Karakterten Az Olamaz";
                    }
                    return null;
                  },*/
                  decoration: InputDecoration(
                      labelText: 'Olay',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                      //hintText: 'İsim Soyisim',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 3))),
                ),
                DropdownButton<String>(
                  value: genderValue,
                  hint: Text(
                    "Cinsiyet",
                    style: TextStyle(color: Colors.black),
                  ),
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: Colors.red,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      genderValue = newValue;
                    });
                  },
                  items: <String>['Erkek', 'Kadın']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  value: bloodValue,
                  hint: Text(
                    "Kan Grubu",
                    style: TextStyle(color: Colors.black),
                  ),
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: Colors.red,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      bloodValue = newValue;
                    });
                  },
                  items: <String>[
                    'A Rh +',
                    'A Rh -',
                    'B Rh +',
                    'B Rh -',
                    'AB Rh +',
                    'AB Rh -',
                    '0 Rh +',
                    '0 Rh -'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                RaisedButton(
                  onPressed: addEmergencyCall,
                  color: Colors.red,
                  child: Text("Gönder"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
