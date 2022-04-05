import 'package:hrms_app/services/http_service.dart';
import 'package:hrms_app/views/gps_alert.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as tk;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../widgets/appbar.dart';
import 'camera.dart';
import 'package:camera/camera.dart';
import '../widgets/drawer.dart';
import 'login.dart';
import 'package:easy_localization/easy_localization.dart' as localization;

class Home extends StatefulWidget {
// /  final latitude = 17.391911;
//   final longitude = 78.442108;

  //final double latitude = 17.390689;

  final double innerRadius;
  final double outerRadius;
  final double longitude;
  final double latitude;
  final double gain;
  const Home(
      {Key? key,
      required this.latitude,
      required this.longitude,
      required this.innerRadius,
      required this.outerRadius,
      required this.gain})
      : super(key: key);

  @override
  State<Home> createState() =>
      // ignore: no_logic_in_create_state
      _HomeState(latitude, longitude, innerRadius, outerRadius, gain);
}

class _HomeState extends State<Home> {
  late double _latitude;
  late double _longitude;
  late LatLng _center;
  late LatLng mapCircle;
  late double _innerRadius;
  late double _outerRadius;
  // ignore: unused_field
  late double _gain;

  _HomeState(double centerX, double centerY, double innerRadius,
      double outerRadius, double gain) {
    _latitude = centerX;
    _longitude = centerY;
    _innerRadius = innerRadius;
    _outerRadius = outerRadius;
    _center = LatLng(centerX, centerY);
    _gain = gain;
    mapCircle = LatLng(_latitude, _longitude);
  }

  Location currentLocation = Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late GoogleMapController mapController;
  double _mapZoom = 1.0;

  var inLoginZone = false;
  double h = 1.0;
  // ignore: unused_field
  late LatLng _cameraPosition;
  final Set<Marker> _markers = {};
  late final SharedPreferences prefs;

  intSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();

    // BioAuth();
  }

  void logout(context) async {
    await prefs.setString('logged_in', "false");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void getLocation() async {
    // currentLocation.enableBackgroundMode(enable: true);
    _serviceEnabled = await currentLocation.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await currentLocation.requestService();

      if (!_serviceEnabled) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GpsAlert()),
        );
      }
    }

    _permissionGranted = await currentLocation.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await currentLocation.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GpsAlert()),
        );
      }
    }

    var location = await currentLocation.getLocation();

    currentLocation.onLocationChanged.listen((LocationData loc) async {
      mapController
          // ignore: unnecessary_new
          .animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
        zoom: 12.0,
      )));

      setState(() {
        LatLng(loc.latitude!.toDouble(), loc.longitude!.toDouble());
        h = location.altitude!.toDouble();
      });

      bool x = userInRarius(
          tk.LatLng(loc.latitude!.toDouble(), loc.longitude!.toDouble()));
      if (x) {
        setState(() {
          inLoginZone = true;
        });
      } else {
        //NotifyUser("Please move into Login zone to enter the attendance");
        inLoginZone = false;
      }

      setState(() {
        _markers.add(Marker(
            markerId: const MarkerId('Office'),
            position: LatLng(_latitude, _latitude)));
      });
    });
  }

  late Set<Circle> circles;

  // NotifyUser(String? title) {
  //   const snackBar = SnackBar(
  //     content: Text(title),
  //   );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
  //ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //}

  @override
  void initState() {
    super.initState();
    intSharedPrefs();

    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Allow Notifications'),
              content:
                  const Text('Our app would like to send you notifications'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Don\'t Allow',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () => AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context)),
                  child: const Text(
                    'Allow',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );

    setState(() {
      getLocation();
      circles = {
        Circle(
            fillColor: const Color.fromARGB(57, 4, 245, 16),
            circleId: const CircleId("one"),
            center: mapCircle,
            radius: _outerRadius,
            strokeColor: const Color.fromARGB(0, 33, 149, 243)),
        Circle(
            fillColor: const Color.fromARGB(136, 245, 133, 4),
            circleId: const CircleId("one"),
            center: mapCircle,
            radius: _innerRadius,
            strokeColor: const Color.fromARGB(0, 33, 149, 243)),
      };
    });
  }

  bool userInRarius(l) {
    final distance = tk.SphericalUtil.computeDistanceBetween(
        tk.LatLng(widget.latitude, widget.longitude), l);

    return distance < widget.innerRadius;
  }

  @override
  Widget build(BuildContext context) {
    //context.locale = Locale('ar', 'UAE');
    var data = HttpService.getSessions();

    print("==============data============");
    print(data);

    return SafeArea(
      child: Scaffold(
        appBar: headerNav(),
        drawer: const MyDrawer(),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 0),
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Visibility(
                visible: inLoginZone ? false : true,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(5),
                  color: const Color.fromARGB(82, 244, 132, 3),
                  child: SingleChildScrollView(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.info),
                        ),
                        Text(
                          "warning".tr().toString(),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 7, 7, 7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.green,
                                  primary:
                                      const Color.fromARGB(221, 27, 202, 65)),
                              onPressed: inLoginZone
                                  ? () async {
                                      await availableCameras()
                                          .then((value) => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CameraPage(
                                                  session: "IN",
                                                  cameras: value,
                                                ),
                                              )));
                                    }
                                  : null,
                              child: const Text(
                                "IN",
                                style: TextStyle(fontSize: 25),
                              ))),
                      SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromARGB(226, 244, 67, 54)),
                              onPressed: //inLoginZone
                                  () async {
                                await availableCameras()
                                    .then((value) => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CameraPage(
                                            session: "OUT",
                                            cameras: value,
                                          ),
                                        )));
                              },
                              child: const Text("OUT",
                                  style: TextStyle(fontSize: 25)))),
                    ]),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10, left: 20),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(131, 244, 132, 3),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        height: 20,
                        width: 20,
                      ),
                      const Text("Login zone"),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 10, left: 20),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(167, 27, 202, 65),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        height: 20,
                        width: 20,
                      ),
                      const Text("Office zone")
                    ],
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                height: MediaQuery.of(context).size.height * 0.72,
                child: GoogleMap(
                    minMaxZoomPreference: const MinMaxZoomPreference(15, 1000),
                    zoomControlsEnabled: true,
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: _onMapCreated,
                    onCameraMove: (CameraPosition position) {
                      _cameraPosition = position.target;
                      _mapZoom = position.zoom;
                    },
                    markers: _markers,
                    circles: circles,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: _mapZoom,
                    )),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}