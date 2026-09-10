import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';
import 'user_provider.dart';

/// Provider for the [ComplaintService] singleton.
final complaintServiceProvider = Provider<ComplaintService>((ref) {
  return ComplaintService();
});

/// Live Firestore stream of complaints for the logged-in customer.
/// Resolves current authenticated UID to prevent permission denied errors on guest/unauthenticated states.
final customerComplaintsStreamProvider =
    StreamProvider.autoDispose<List<CustomerComplaint>>((ref) {
  final user = ref.watch(userProvider);
  final authUid = FirebaseAuth.instance.currentUser?.uid;
  final effectiveUid = (authUid != null && authUid.isNotEmpty)
      ? authUid
      : (user.id.isNotEmpty ? user.id : '');

  if (effectiveUid.isEmpty) {
    return const Stream.empty();
  }
  final service = ref.watch(complaintServiceProvider);
  return service.streamComplaintsForCustomer(effectiveUid);
});
