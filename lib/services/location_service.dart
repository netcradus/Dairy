import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Wraps the `geolocator` plugin to provide high-accuracy device GPS access:
/// permission handling plus a live stream of position updates.
///
/// Keeping this behind a small service class makes it easy to mock for tests
/// and keeps the UI/providers free of raw platform calls.
class LocationService {
  /// Whether location services are enabled on the device.
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  /// Requests location permission (if not already granted) and returns `true`
  /// only when the app is allowed to access location ("while in use" or
  /// "always"). Returns `false` if services are disabled or permission is
  /// denied/permanently denied.
  Future<bool> requestLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// A high-accuracy stream of device positions. Callers should first await
  /// [requestLocationPermission]; if permission was denied the stream simply
  /// emits an error, which subscribers handle gracefully.
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(locationSettings: _locationSettings);
  }

  /// Returns a single fresh high-accuracy fix, or `null` if location is
  /// unavailable.
  Future<Position?> getCurrentPosition() async {
    if (!await requestLocationPermission()) return null;
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  /// Platform-appropriate [LocationSettings]. Uses valid geolocator enums and
  /// named parameters only.
  LocationSettings get _locationSettings {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        intervalDuration: const Duration(seconds: 5),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        activityType: ActivityType.otherNavigation,
        pauseLocationUpdatesAutomatically: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
  }
}

/// Provides a singleton [LocationService].
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
