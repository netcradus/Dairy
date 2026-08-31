import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

/// Backend service for real-time delivery tracking backed by Cloud Firestore.
///
/// Data model in Firestore:
///   collection('delivery_agents').doc(<agentId>)
///     {
///       'location':   [latitude, longitude], // live position as a 2-element array
///       'orderId':    String?,               // order currently being delivered
///       'isOnline':   bool,                  // duty status
///       'updatedAt':  Timestamp,             // server time of last update
///     }
class DeliveryTrackingService {
  final FirebaseFirestore _firestore;

  DeliveryTrackingService([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Pushes the delivery agent's live position to Firestore as a `[latitude,
  /// longitude]` array, stamping `updatedAt`. Use [merge: true] so non-location
  /// fields (e.g. `isOnline`) are preserved across updates.
  Future<void> updateAgentLocation(
    String agentId,
    double latitude,
    double longitude, {
    String? orderId,
  }) async {
    await _firestore.collection('delivery_agents').doc(agentId).set(
      {
        'location': [latitude, longitude],
        'orderId': orderId ?? FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Updates only the agent's duty/online status in Firestore. Used when the
  /// agent toggles online/offline so the stored `isOnline` flag always reflects
  /// the current dynamic state rather than a stale value.
  Future<void> updateAgentOnlineStatus(
    String agentId,
    bool isOnline,
  ) async {
    await _firestore.collection('delivery_agents').doc(agentId).set(
      {
        'isOnline': isOnline,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Clears the agent's active orderId from Firestore.
  Future<void> clearActiveOrder(String agentId) async {
    await _firestore.collection('delivery_agents').doc(agentId).update({
      'orderId': FieldValue.delete(),
    });
  }

  /// Streams the agent's live [LatLng] (emits `null` when no location yet).
  /// The stored `location` is a `[latitude, longitude]` array.
  Stream<LatLng?> agentLocationStream(String agentId) {
    return _firestore
        .collection('delivery_agents')
        .doc(agentId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      final location = data?['location'];
      if (location is! List || location.length < 2) return null;
      final lat = (location[0] as num?)?.toDouble();
      final lng = (location[1] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
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
