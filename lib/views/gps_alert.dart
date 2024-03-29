// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:location/location.dart';

// ignore: must_be_immutable
class GpsAlert extends StatelessWidget {
  GpsAlert({Key? key}) : super(key: key);

  Location location = Location();

  // ignore: non_constant_identifier_names
  request_location(context) async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();

      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    Navigator.pop(context);

    //_locationData = await location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Center(
            child: Image.asset(
              "assets/media/gps.png",
              width: 250,
            ),
          ),
          const Text(
            "Location is Off",
            style: TextStyle(fontSize: 30, fontFamily: 'Calistoga'),
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
            "Please turn on your phone's location",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 50.0,
            child: RaisedButton(
              onPressed: () async {
                //AuthUser();

                request_location(context);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0)),
              padding: const EdgeInsets.all(0.0),
              child: Ink(
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10.7)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  constraints: const BoxConstraints(minHeight: 50.0),
                  alignment: Alignment.center,
                  child: const Text(
                    "Turn on GPS",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    ));
  }
}
