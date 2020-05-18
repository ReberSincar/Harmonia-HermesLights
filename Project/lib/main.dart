import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hermes_lights/models/help.dart';

void main() {
  runApp(HermesLights());
}

class HermesLights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GeoPoint destination;
  CameraPosition initialPosition;
  Position _currentPosition;
  Set<Marker> markers = Set();
  GoogleMapController _controller;
  Set<Polyline> _polyLines;
  List<LatLng> polylineCoordinates;
  PolylinePoints polylinePoints;
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  String name,
      surname,
      gender,
      blood,
      type,
      adress,
      adressCaption,
      patientCount;
  int documentSize;
  String apiKey;
  bool getDirectPressed;
  final notifications = FlutterLocalNotificationsPlugin();
  List<HelpObject> dataList;

  @override
  void initState() {
    _polyLines = {};
    polylineCoordinates = [];
    polylinePoints = PolylinePoints();
    dataList = List<HelpObject>();
    adress = "";
    adressCaption = "";
    apiKey = "AIzaSyBQTtOClieSEu-MT4nR7dc4cde-QGa-Vtw";
    getDirectPressed = false;
    getLocation();
    startNotification();
    setSourceAndDestinationIcons();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('Destinations').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                documentSize = snapshot.data.documents.length;
                if (documentSize != 0) {
                  destination = snapshot.data.documents[0]['Location'];
                  name = snapshot.data.documents[0]['Name'];
                  surname = snapshot.data.documents[0]['Surname'];
                  blood = snapshot.data.documents[0]['BloodGroup'];
                  gender = snapshot.data.documents[0]['Gender'];
                  type = snapshot.data.documents[0]['Type'];
                  patientCount = snapshot.data.documents[0]['PatientCount'];
                  _getAdress();
                  setMapPins();
                } else {
                  clearMarkersPolyLines();
                }
                /*
                showOngoingNotification(notifications,
                    title: nameSurname, body: 'Help!');
                */
                return _currentPosition != null
                    ? Stack(
                        children: <Widget>[
                          GoogleMap(
                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            initialCameraPosition: initialPosition,
                            markers: markers,
                            polylines: _polyLines,
                            onMapCreated: (GoogleMapController controller) {
                              _controller = controller;

                              if (documentSize != 0) {
                                moveCameraDestination();
                              } else {
                                moveCameraLocation();
                              }
                              changeMapStyle();
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: documentSize != 0
                                ? Column(
                                    children: <Widget>[
                                      Container(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        width: double.infinity,
                                        height: 80,
                                        child: Card(
                                          color: Colors.grey.shade800,
                                          elevation: 4,
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                gender == "Female"
                                                    ? Image.asset(
                                                        "assets/female.png",
                                                        color: Colors.white,
                                                        width: 50,
                                                        height: 50,
                                                      )
                                                    : Image.asset(
                                                        "assets/male.png",
                                                        color: Colors.white,
                                                        width: 50,
                                                        height: 50,
                                                      ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      "$name $surname",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          blood,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        SizedBox(
                                                          width: 20,
                                                        ),
                                                        Text(
                                                          type,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.amber),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 0, 5, 5),
                                        width: double.infinity,
                                        height: 320,
                                        child: Card(
                                          color: Colors.grey.shade900,
                                          elevation: 4,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 30, vertical: 5),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      "EMERGENCY CALL",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 24,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                          width: 120,
                                                          height: 30,
                                                          padding:
                                                              EdgeInsets.all(2),
                                                          child: Card(
                                                            color: Colors.red,
                                                            child: Text(
                                                              "$patientCount Injured",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 120,
                                                          height: 30,
                                                          padding:
                                                              EdgeInsets.all(2),
                                                          child: Card(
                                                            color: Colors.white,
                                                            child: Text(
                                                              adressCaption,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(Icons.warning),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                        "Drivers are informed with street lamps and traffic lamps")
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(Icons.traffic),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text("Lamps in action: 250")
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Icon(Icons.directions),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(adress)
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 40,
                                                  width: double.infinity,
                                                  child: RaisedButton(
                                                    onPressed: () {
                                                      if (!getDirectPressed) {
                                                        clearPolyLines();
                                                        setPolylines();
                                                      } else {
                                                        setState(() {
                                                          clearPolyLines();
                                                        });
                                                      }
                                                      getDirectPressed =
                                                          !getDirectPressed;
                                                    },
                                                    child: getDirectPressed
                                                        ? Text("Go Destination")
                                                        : Text(
                                                            "Get Directions"),
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                                    width: double.infinity,
                                    height: 320,
                                    child: Card(
                                      color: Colors.grey.shade900,
                                      elevation: 4,
                                      child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 5),
                                          child: Center(
                                            child: Text(
                                              "There is not any emergency call.",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 20),
                                            ),
                                          )),
                                    ),
                                  ),
                          ),
                        ],
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      );
            }
          },
        ),
      ),
    );
  }

  showGeneralInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black45,
          child: Center(
            child: Container(
              width: 400,
              height: 300,
              child: Card(
                elevation: 10,
                color: Colors.grey.shade900,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.heartbeat,
                        size: 100,
                        color: Colors.red,
                      ),
                      Divider(
                        endIndent: 10,
                        indent: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(FontAwesomeIcons.road),
                          SizedBox(width: 20),
                          Text(
                            "You have traveled 547 km this year.",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.solidHeart,
                            color: Colors.red,
                          ),
                          SizedBox(width: 20),
                          Text(
                            "You saved the lives of 152 people.",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(FontAwesomeIcons.car),
                          SizedBox(width: 20),
                          Text(
                            "You have earned 20 driver points.",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Close"))
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  getDataFromFireStore() {
    var dbRef = Firestore.instance;
    dbRef.collection('Destinations').getDocuments().then((value) {
      value.documents.forEach((f) => dataList.add(HelpObject(
          f.data["Name"],
          f.data["Surname"],
          f.data["Gender"],
          f.data["BloodGroup"],
          f.data["Type"],
          f.data["PatientCount"],
          f.data["location"],
          adress,
          adressCaption)));
    });
  }

  clearMarkersPolyLines() {
    markers.clear();
    _polyLines.clear();
    polylineCoordinates.clear();
  }

  clearPolyLines() {
    _polyLines.clear();
    polylineCoordinates.clear();
  }

  startNotification() {
    final settingsAndroid = AndroidInitializationSettings('app_icon');
    final settingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) =>
            onSelectNotification(payload));

    notifications.initialize(
        InitializationSettings(settingsAndroid, settingsIOS),
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    await notifications.cancelAll();
    setMapPins();
    setPolylines();
    getDirectPressed = true;
  }

  getLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      print(position.latitude.toString());
      print(position.longitude.toString());
      setState(() {
        _currentPosition = position;
        initialPosition = CameraPosition(
            target:
                LatLng(_currentPosition.latitude, _currentPosition.longitude),
            zoom: 14.5);
      });
    }).catchError((e) {
      print(e);
    });
  }

  moveCameraDestination() {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(destination.latitude, destination.longitude),
            zoom: 14.0),
      ),
    );
  }

  moveCameraLocation() {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target:
                LatLng(_currentPosition.latitude, _currentPosition.longitude),
            zoom: 14.0),
      ),
    );
  }

  void setMapPins() {
    markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: LatLng(destination.latitude, destination.longitude),
        icon: destinationIcon));
  }

  setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        apiKey,
        _currentPosition.latitude,
        _currentPosition.longitude,
        destination.latitude,
        destination.longitude);
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    Polyline polyline = Polyline(
        polylineId: PolylineId(destination.toString()),
        color: Color.fromARGB(255, 40, 122, 198),
        points: polylineCoordinates);
    setState(() {
      _polyLines.add(polyline);
    });
  }

  void setSourceAndDestinationIcons() async {
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/marker128.png');
  }

  changeMapStyle() async {
    var mapStyle = await DefaultAssetBundle.of(context)
        .loadString("assets/map_theme.json");
    _controller.setMapStyle(mapStyle);
  }

  _getAdress() async {
    final coordinates =
        new Coordinates(destination.latitude, destination.longitude);
    var adresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    adress = adresses.first.addressLine;
    adressCaption = adresses.first.subLocality;
  }
}
