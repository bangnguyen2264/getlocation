import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const GetLocation(),
    );
  }
}

class GetLocation extends StatefulWidget {
  const GetLocation({Key? key}) : super(key: key);

  @override
  _GetLocationState createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocation> {
  String currentAddress = '';
  Position? currentPosition;

  Future<void> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions is denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions is denied forever');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
    setState(() {
      currentPosition = position;
    });
    print('Position: $position');
    print('Current Position: $currentPosition');
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      print('Placemarks: $placemarks');

      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark place = placemarks[1];
        print('Place: $place');
        setState(() {
          currentAddress = "${place.administrativeArea}, ${place.country}";
        });
      } else {
        setState(() {
          currentAddress = "No address found";
        });
      }
    } catch (e) {
      print('position: $position');
      print(currentPosition);
      print(currentAddress);
      print('Error fetching placemarks: $e');
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   determinePosition();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Location Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Address: $currentAddress'),
            Text('Latitude: ${currentPosition?.latitude}'),
            Text('Longitude: ${currentPosition?.longitude}'),
            SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: determinePosition,
              child: Text('Get Location'),
            ),
          ],
        ),
      ),
    );
  }
}
