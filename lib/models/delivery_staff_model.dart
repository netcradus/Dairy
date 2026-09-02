class DeliveryRider {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String vehicle;
  final String assignedZone;
  final int totalDeliveriesToday;
  final int pendingDeliveries;
  final double rating;
  final String status; // 'Active', 'Break', 'Completed', 'Offline'
  final bool isOnline;
  final String joinedDate;

  const DeliveryRider({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    required this.vehicle,
    required this.assignedZone,
    required this.totalDeliveriesToday,
    required this.pendingDeliveries,
    required this.rating,
    required this.status,
    this.isOnline = false,
    this.joinedDate = 'Active',
  });

  DeliveryRider copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? vehicle,
    String? assignedZone,
    int? totalDeliveriesToday,
    int? pendingDeliveries,
    double? rating,
    String? status,
    bool? isOnline,
    String? joinedDate,
  }) {
    return DeliveryRider(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      vehicle: vehicle ?? this.vehicle,
      assignedZone: assignedZone ?? this.assignedZone,
      totalDeliveriesToday:
          totalDeliveriesToday ?? this.totalDeliveriesToday,
      pendingDeliveries: pendingDeliveries ?? this.pendingDeliveries,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}
