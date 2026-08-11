class DeliveryRider {
  final String id;
  final String name;
  final String phone;
  final String vehicle;
  final String assignedZone;
  final int totalDeliveriesToday;
  final int pendingDeliveries;
  final double rating;
  final String status; // 'Active', 'Break', 'Completed'

  const DeliveryRider({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.assignedZone,
    required this.totalDeliveriesToday,
    required this.pendingDeliveries,
    required this.rating,
    required this.status,
  });
}
