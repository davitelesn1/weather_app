import 'package:geolocator/geolocator.dart';

class Location {
  double? latitude;
  double? longitude;

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    // Store values for later API calls
    latitude = position.latitude;
    longitude = position.longitude;

    // Optional log
    print('Latitude: $latitude, Longitude: $longitude');
  }
}
