import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';
import 'user_provider.dart';

/// Provider for the [ComplaintService] singleton.
final complaintServiceProvider = Provider<ComplaintService>((ref) {
  return ComplaintService();
});

/// Live Firestore stream of complaints for the logged-in customer.
final customerComplaintsStreamProvider =
    StreamProvider.autoDispose<List<CustomerComplaint>>((ref) {
  final user = ref.watch(userProvider);
  if (user.id.isEmpty) {
    return const Stream.empty();
  }
  final service = ref.watch(complaintServiceProvider);
  return service.streamComplaintsForCustomer(user.id);
});
