import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _parseDateTime(dynamic val) {
  if (val == null) return DateTime.now();
  if (val is Timestamp) return val.toDate();
  if (val is DateTime) return val;
  if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
  if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
  return DateTime.now();
}

/// Customer complaint / support ticket model for Sawariya Dairy
class CustomerComplaint {
  final String id;
  final String ticketId;
  final String customerId;
  final String customerName;
  final String phone;
  final String email;
  final String subject;
  final String issueType; // e.g. 'Late Delivery', 'Damaged Pouch', 'Wrong Quantity', 'Quality Concern', etc.
  final String description;
  final String? orderId;
  final String priority; // 'High', 'Medium', 'Low'
  final String status; // 'Open', 'In Progress', 'Resolved', 'Closed'
  final String? adminReply;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CustomerComplaint({
    required this.id,
    this.ticketId = '',
    this.customerId = '',
    required this.customerName,
    required this.phone,
    this.email = '',
    this.subject = '',
    required this.issueType,
    required this.description,
    this.orderId,
    this.priority = 'Medium',
    this.status = 'Open',
    this.adminReply,
    required this.createdAt,
    this.updatedAt,
  });

  String get category => issueType;

  String get displayTicketId {
    if (ticketId.isNotEmpty) return ticketId;
    if (id.isNotEmpty) {
      final sub = id.length > 6 ? id.substring(0, 6).toUpperCase() : id.toUpperCase();
      return 'CMP-$sub';
    }
    return 'CMP-TICKET';
  }

  String get formattedCreatedAt {
    final hour = createdAt.hour > 12
        ? createdAt.hour - 12
        : (createdAt.hour == 0 ? 12 : createdAt.hour);
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    final min = createdAt.minute.toString().padLeft(2, '0');
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    return '$day/$month/${createdAt.year} $hour:$min $period';
  }

  CustomerComplaint copyWith({
    String? id,
    String? ticketId,
    String? customerId,
    String? customerName,
    String? phone,
    String? email,
    String? subject,
    String? issueType,
    String? description,
    String? orderId,
    String? priority,
    String? status,
    String? adminReply,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerComplaint(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      subject: subject ?? this.subject,
      issueType: issueType ?? this.issueType,
      description: description ?? this.description,
      orderId: orderId ?? this.orderId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      adminReply: adminReply ?? this.adminReply,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticketId': ticketId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': phone,
      'customerEmail': email,
      'subject': subject,
      'category': issueType,
      'issueType': issueType,
      'description': description,
      if (orderId != null && orderId!.isNotEmpty) 'orderId': orderId,
      'priority': priority,
      'status': status,
      if (adminReply != null && adminReply!.isNotEmpty) 'adminReply': adminReply,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  factory CustomerComplaint.fromMap(Map<String, dynamic> map, [String docId = '']) {
    final rawCategory = map['category'] ?? map['issueType'] ?? 'Other';
    final rawStatus = map['status'] ?? 'Open';
    final rawPriority = map['priority'] ?? 'Medium';

    return CustomerComplaint(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      ticketId: map['ticketId'] ?? '',
      customerId: map['customerId'] ?? map['userId'] ?? '',
      customerName: map['customerName'] ?? map['name'] ?? 'Customer',
      phone: map['customerPhone'] ?? map['phone'] ?? '',
      email: map['customerEmail'] ?? map['email'] ?? '',
      subject: map['subject'] ?? map['title'] ?? '',
      issueType: rawCategory.toString(),
      description: map['description'] ?? map['message'] ?? '',
      orderId: map['orderId'],
      priority: rawPriority.toString(),
      status: rawStatus.toString(),
      adminReply: map['adminReply'] ?? map['adminResponse'],
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? _parseDateTime(map['updatedAt']) : null,
    );
  }

  factory CustomerComplaint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CustomerComplaint.fromMap(data, doc.id);
  }
}
