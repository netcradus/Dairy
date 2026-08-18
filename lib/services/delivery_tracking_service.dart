import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Backend service for real-time delivery tracking backed by Cloud Firestore.
///
/// Data model in Firestore:
///   collection('delivery_agents').doc(<agentId>)
///     {
///       'location':   GeoPoint(lat, lng),  // live position
///       'orderId':    String?,              // order currently being delivered
///       'isOnline':   bool,                 // duty status
///       'updatedAt':  Timestamp,            // server time of last update
///     }
class DeliveryTrackingService {
  final FirebaseFirestore _firestore;

  DeliveryTrackingService([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Pushes the delivery agent's live [position] to Firestore. Use [merge: true]
  /// so non-location fields are preserved across updates.
  Future<void> updateAgentLocation(
    String agentId,
    LatLng position, {
    String? orderId,
    bool isOnline = true,
  }) async {
    await _firestore.collection('delivery_agents').doc(agentId).set(
      {
        'location': GeoPoint(position.latitude, position.longitude),
        'orderId': orderId,
        'isOnline': isOnline,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Streams the agent's live [LatLng] (emits `null` when no location yet).
  Stream<LatLng?> agentLocationStream(String agentId) {
    return _firestore
        .collection('delivery_agents')
        .doc(agentId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      final geo = data?['location'] as GeoPoint?;
      if (geo == null) return null;
      return LatLng(geo.latitude, geo.longitude);
    });
  }

  /// Convenience stream for tracking a specific order's assigned agent, given
  /// the agent id that owns that order.
  Stream<LatLng?> orderLocationStream(String agentId) =>
      agentLocationStream(agentId);
}

/// Provides a singleton [DeliveryTrackingService].
final deliveryTrackingServiceProvider = Provider<DeliveryTrackingService>(
  (ref) => DeliveryTrackingService(),
);
