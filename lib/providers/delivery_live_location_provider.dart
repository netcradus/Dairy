import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/delivery_boy_model.dart';
import '../services/delivery_tracking_service.dart';
import 'delivery_provider.dart';

/// Toggles the delivery agent's live location sharing. While active, the
/// agent's (simulated) position is written to Firestore every few seconds so
/// that the customer tracking map and the delivery map reflect it in real time.
///
/// Replace the simulated movement with real GPS (e.g. `geolocator`) for
/// production use.
final agentLiveLocationProvider =
    StateNotifierProvider<AgentLiveLocationNotifier, bool>((ref) {
  return AgentLiveLocationNotifier(ref);
});

class AgentLiveLocationNotifier extends StateNotifier<bool> {
  final Ref _ref;
  Timer? _timer;
  LatLng _pos = const LatLng(22.7255, 75.8800); // Sawariya Dairy Hub, Indore

  static const LatLng _hub = LatLng(22.7255, 75.8800);

  AgentLiveLocationNotifier(this._ref) : super(false);

  void toggle() {
    if (state) {
      _stop();
    } else {
      _start();
    }
    state = !state;
  }

  void _start() {
    _pos = _hub;
    _write(online: true);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      // Drift along a small loop so the marker visibly moves.
      _pos = LatLng(
        _hub.latitude + 0.004 * _triangle(_t += 0.4),
        _hub.longitude + 0.004 * _triangle(_t + 1.57),
      );
      _write(online: true);
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _write(online: false);
  }

  void _write({required bool online}) {
    final agentId = _ref.read(deliveryAgentProvider).id;
    _ref
        .read(deliveryTrackingServiceProvider)
        .updateAgentLocation(agentId, _pos, isOnline: online);
  }

  double _t = 0;
  double _triangle(double x) => (x % (2 * 3.14159)) / 3.14159 - 1;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
