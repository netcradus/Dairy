class DeliveryBatch {
  final String deliveryId;
  final String staffName;
  final int assignedCount;
  final int completedCount;
  final String status;
  final String zone;

  const DeliveryBatch({
    required this.deliveryId,
    required this.staffName,
    required this.assignedCount,
    required this.completedCount,
    required this.status,
    required this.zone,
  });

  double get completionPercentage =>
      assignedCount == 0 ? 0.0 : (completedCount / assignedCount).clamp(0.0, 1.0);
}

class DeliveryCorridor {
  final String routeName;
  final String zone;
  final String riderName;
  final int subscribersCount;
  final String timing;
  final String vehicleType;

  const DeliveryCorridor({
    required this.routeName,
    required this.zone,
    required this.riderName,
    required this.subscribersCount,
    required this.timing,
    required this.vehicleType,
  });
}
