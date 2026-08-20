import 'package:cloud_firestore/cloud_firestore.dart';

/// Lifecycle of an agent's earning / payout record.
enum EarningStatus {
  pending,
  processed,
  paid,
}

extension EarningStatusExtension on EarningStatus {
  String get label {
    switch (this) {
      case EarningStatus.pending:
        return 'Pending';
      case EarningStatus.processed:
        return 'Processed';
      case EarningStatus.paid:
        return 'Paid';
    }
  }
}

/// A single earnings / payout entry for a delivery agent.
///
/// One record is created per delivered order (typically keyed by the order id
/// so a redelivery can't create duplicates).
class EarningModel {
  final String id;
  final String agentId;
  final String orderId;
  final double amountEarned;
  final double tipAmount;
  final double deliveryFee;
  final DateTime timestamp;
  final EarningStatus status;

  const EarningModel({
    required this.id,
    required this.agentId,
    required this.orderId,
    this.amountEarned = 0.0,
    this.tipAmount = 0.0,
    this.deliveryFee = 0.0,
    required this.timestamp,
    this.status = EarningStatus.pending,
  });

  EarningModel copyWith({
    String? id,
    String? agentId,
    String? orderId,
    double? amountEarned,
    double? tipAmount,
    double? deliveryFee,
    DateTime? timestamp,
    EarningStatus? status,
  }) {
    return EarningModel(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      orderId: orderId ?? this.orderId,
      amountEarned: amountEarned ?? this.amountEarned,
      tipAmount: tipAmount ?? this.tipAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  /// Serializes this record for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'agentId': agentId,
      'orderId': orderId,
      'amountEarned': amountEarned,
      'tipAmount': tipAmount,
      'deliveryFee': deliveryFee,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': earningStatusToString(status),
    };
  }

  /// Creates an [EarningModel] from a Firestore document map.
  factory EarningModel.fromFirestore(Map<String, dynamic> data, String id) {
    final ts = data['timestamp'];
    final timestamp = ts is Timestamp ? ts.toDate() : DateTime.now();

    return EarningModel(
      id: id,
      agentId: (data['agentId'] as String?) ?? '',
      orderId: (data['orderId'] as String?) ?? '',
      amountEarned: (data['amountEarned'] as num?)?.toDouble() ?? 0.0,
      tipAmount: (data['tipAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      timestamp: timestamp,
      status: earningStatusFromString((data['status'] as String?) ?? 'pending'),
    );
  }
}

/// Maps a stored status string to an [EarningStatus].
EarningStatus earningStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return EarningStatus.paid;
    case 'processed':
      return EarningStatus.processed;
    case 'pending':
    default:
      return EarningStatus.pending;
  }
}

/// Maps an [EarningStatus] to the string stored in Firestore.
String earningStatusToString(EarningStatus status) {
  switch (status) {
    case EarningStatus.pending:
      return 'pending';
    case EarningStatus.processed:
      return 'processed';
    case EarningStatus.paid:
      return 'paid';
  }
}
