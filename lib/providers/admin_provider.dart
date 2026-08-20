import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/category_model.dart';
import '../models/customer_model.dart';
import '../models/delivery_model.dart';
import '../models/delivery_staff_model.dart';
import '../models/kpi_data.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class AdminProvider extends ChangeNotifier {
  int _selectedNavIndex = 0;
  String _searchQuery = '';
  String _orderStatusTimeFilter = 'Today';
  int _unreadNotifications = 5;
  bool _isDarkMode = false;

  int get selectedNavIndex => _selectedNavIndex;
  String get searchQuery => _searchQuery;
  String get orderStatusTimeFilter => _orderStatusTimeFilter;
  int get unreadNotifications => _unreadNotifications;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool val) {
    _isDarkMode = val;
    notifyListeners();
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setOrderStatusTimeFilter(String filter) {
    _orderStatusTimeFilter = filter;
    notifyListeners();
  }

  void clearNotifications() {
    _unreadNotifications = 0;
    notifyListeners();
  }

  // --- KPI Metrics ---
  List<KpiMetric> get kpiMetrics => [
    const KpiMetric(
      title: "Today's Revenue",
      value: '₹4,85,240',
      growthText: '↑ 12.5% vs Yesterday',
      isPositive: true,
      icon: Icons.currency_rupee_rounded,
      themeColor: AppColors.revenueGreen,
      themeBgColor: AppColors.revenueGreenBg,
    ),
    const KpiMetric(
      title: "Today's Orders",
      value: '524',
      growthText: '↑ 8.7% vs Yesterday',
      isPositive: true,
      icon: Icons.shopping_bag_outlined,
      themeColor: AppColors.ordersBlue,
      themeBgColor: AppColors.ordersBlueBg,
    ),
    const KpiMetric(
      title: 'Total Customers',
      value: '4,821',
      growthText: '↑ 15.3% vs Last Month',
      isPositive: true,
      icon: Icons.people_outline_rounded,
      themeColor: AppColors.customersOrange,
      themeBgColor: AppColors.customersOrangeBg,
    ),
  ];

  // --- Products Data ---
  final List<DairyProduct> _products = [
    const DairyProduct(
      id: 'PRD-001',
      name: 'Cow Milk (1L)',
      subtitle: '3.5% Fat (Pure & Fresh)',
      category: 'Milk & Creams',
      unit: '1 Litre',
      price: 64.0,
      ordersCount: 245,
      totalRevenue: 15680.0,
      stockQuantity: 420,
      fatContent: '3.5% Fat',
      packaging: 'Pouches / Glass Bottle',
      emoji: '🥛',
    ),
    const DairyProduct(
      id: 'PRD-002',
      name: 'Paneer (200g)',
      subtitle: 'Soft Malai Paneer',
      category: 'Paneer & Curd',
      unit: '200 grams',
      price: 85.0,
      ordersCount: 182,
      totalRevenue: 13450.0,
      stockQuantity: 190,
      fatContent: '50% Dry Fat',
      packaging: 'Vacuum Sealed Pack',
      emoji: '🧀',
    ),
    const DairyProduct(
      id: 'PRD-003',
      name: 'Curd (500g)',
      subtitle: 'Thick Probiotic Dahi',
      category: 'Paneer & Curd',
      unit: '500 grams',
      price: 50.0,
      ordersCount: 168,
      totalRevenue: 8400.0,
      stockQuantity: 280,
      fatContent: '3.0% Fat',
      packaging: 'Hygienic Tub',
      emoji: '🥣',
    ),
    const DairyProduct(
      id: 'PRD-004',
      name: 'Ghee (500ml)',
      subtitle: 'Traditional Bilona Cow Ghee',
      category: 'Ghee & Butter',
      unit: '500 ml',
      price: 550.0,
      ordersCount: 96,
      totalRevenue: 12720.0,
      stockQuantity: 75,
      fatContent: '99.7% Milk Fat',
      packaging: 'Glass Jar',
      emoji: '🍯',
    ),
    const DairyProduct(
      id: 'PRD-005',
      name: 'Butter (100g)',
      subtitle: 'Salted Table Butter',
      category: 'Ghee & Butter',
      unit: '100 grams',
      price: 58.0,
      ordersCount: 74,
      totalRevenue: 5550.0,
      stockQuantity: 110,
      fatContent: '80% Butter Fat',
      packaging: 'Foil Wrap',
      emoji: '🧈',
    ),
    const DairyProduct(
      id: 'PRD-006',
      name: 'Buffalo Milk (1L)',
      subtitle: '6.5% Rich Cream Milk',
      category: 'Milk & Creams',
      unit: '1 Litre',
      price: 76.0,
      ordersCount: 130,
      totalRevenue: 9880.0,
      stockQuantity: 310,
      fatContent: '6.5% Fat',
      packaging: 'Pouch',
      emoji: '🥛',
    ),
    const DairyProduct(
      id: 'PRD-007',
      name: 'Fresh Chaas (500ml)',
      subtitle: 'Masala Spiced Buttermilk',
      category: 'Beverages',
      unit: '500 ml',
      price: 25.0,
      ordersCount: 112,
      totalRevenue: 2800.0,
      stockQuantity: 220,
      fatContent: '1.5% Fat',
      packaging: 'Bottle',
      emoji: '🥤',
    ),
  ];

  List<DairyProduct> get products => _products;
  List<DairyProduct> get topSellingProducts => _products.take(5).toList();

  void addProduct(DairyProduct product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void updateProduct(DairyProduct product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void toggleProductStock(String id) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(inStock: !_products[index].inStock);
      notifyListeners();
    }
  }

  // --- Orders Data ---
  final List<DairyOrder> _orders = [
    const DairyOrder(
      id: '#ORD10284',
      customerName: 'Rahul Sharma',
      customerPhone: '+91 98765 43210',
      itemsSummary: 'Cow Milk (2L), Malai Paneer (200g)',
      amount: 163.0,
      status: OrderStatus.outForDelivery,
      deliverySlot: 'Morning (5:30 AM - 7:00 AM)',
      address: 'Flat 402, Lotus Greens, Sector 78',
      time: '05:42 AM',
      paymentMode: 'Online Prepaid',
    ),
    const DairyOrder(
      id: '#ORD10283',
      customerName: 'Priya Verma',
      customerPhone: '+91 98112 34567',
      itemsSummary: 'Cow Milk (1L), Curd (500g)',
      amount: 114.0,
      status: OrderStatus.delivered,
      deliverySlot: 'Morning (5:30 AM - 7:00 AM)',
      address: 'B-14, ATS Greens, Sector 50',
      time: '06:10 AM',
      paymentMode: 'Wallet Auto-Debit',
    ),
    const DairyOrder(
      id: '#ORD10282',
      customerName: 'Anil Gupta',
      customerPhone: '+91 97123 45678',
      itemsSummary: 'Bilona Ghee (500ml), Butter (100g)',
      amount: 608.0,
      status: OrderStatus.delivered,
      deliverySlot: 'Morning (6:00 AM - 7:30 AM)',
      address: 'Villa 21, Jaypee Greens, Greater Noida',
      time: '06:25 AM',
      paymentMode: 'UPI',
    ),
    const DairyOrder(
      id: '#ORD10281',
      customerName: 'Sneha Patel',
      customerPhone: '+91 99887 76655',
      itemsSummary: 'Buffalo Milk (2L)',
      amount: 152.0,
      status: OrderStatus.preparing,
      deliverySlot: 'Evening (5:00 PM - 7:00 PM)',
      address: 'Tower 4, Apex Golf Avenue, Sector 1',
      time: '07:15 AM',
      paymentMode: 'Online Prepaid',
    ),
    const DairyOrder(
      id: '#ORD10280',
      customerName: 'Vikas Malhotra',
      customerPhone: '+91 94567 89012',
      itemsSummary: 'Cow Milk (3L), Paneer (400g)',
      amount: 362.0,
      status: OrderStatus.confirmed,
      deliverySlot: 'Evening (5:00 PM - 7:00 PM)',
      address: 'A-201, Supertech Capetown, Sector 74',
      time: '07:45 AM',
      paymentMode: 'Cash On Delivery',
    ),
    const DairyOrder(
      id: '#ORD10279',
      customerName: 'Meenakshi Iyer',
      customerPhone: '+91 93456 78901',
      itemsSummary: 'Curd (1kg), Cow Milk (1L)',
      amount: 164.0,
      status: OrderStatus.pending,
      deliverySlot: 'Morning (6:00 AM - 7:30 AM)',
      address: 'Flat 903, Mahagun Moderne, Sector 78',
      time: '08:00 AM',
      paymentMode: 'Wallet Auto-Debit',
    ),
  ];

  List<DairyOrder> get orders => _orders;
  List<DairyOrder> get recentOrders => _orders.take(5).toList();

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  // --- Today's Deliveries Data ---
  final List<DeliveryBatch> _deliveryBatches = [
    const DeliveryBatch(
      deliveryId: '#DLV1021',
      staffName: 'Amit Kumar',
      assignedCount: 82,
      completedCount: 76,
      status: 'On Route',
      zone: 'Sector 74 - 78 Hub',
    ),
    const DeliveryBatch(
      deliveryId: '#DLV1022',
      staffName: 'Rajesh Sharma',
      assignedCount: 95,
      completedCount: 95,
      status: 'Completed',
      zone: 'Sector 50 - 52 Hub',
    ),
    const DeliveryBatch(
      deliveryId: '#DLV1023',
      staffName: 'Vikram Singh',
      assignedCount: 88,
      completedCount: 81,
      status: 'On Route',
      zone: 'Expressway Corridors',
    ),
    const DeliveryBatch(
      deliveryId: '#DLV1024',
      staffName: 'Suresh Verma',
      assignedCount: 75,
      completedCount: 70,
      status: 'On Route',
      zone: 'Greater Noida West',
    ),
    const DeliveryBatch(
      deliveryId: '#DLV1025',
      staffName: 'Manoj Tiwari',
      assignedCount: 65,
      completedCount: 65,
      status: 'Completed',
      zone: 'Indirapuram Core',
    ),
  ];

  List<DeliveryBatch> get deliveryBatches => _deliveryBatches;

  // --- Delivery Corridors Data ---
  final List<DeliveryCorridor> _corridors = [
    const DeliveryCorridor(
      routeName: 'Route 1 — Noida Express Zone',
      zone: 'Sector 128 to 137',
      riderName: 'Amit Kumar',
      subscribersCount: 142,
      timing: '05:00 AM - 06:45 AM',
      vehicleType: 'Electric Cargo Van',
    ),
    const DeliveryCorridor(
      routeName: 'Route 2 — Sector 7x Highrise Belt',
      zone: 'Sector 74, 76, 78, 79',
      riderName: 'Vikram Singh',
      subscribersCount: 185,
      timing: '05:15 AM - 07:00 AM',
      vehicleType: 'EV Bike 3-Wheeler',
    ),
    const DeliveryCorridor(
      routeName: 'Route 3 — Central Noida Hub',
      zone: 'Sector 50, 51, 52',
      riderName: 'Rajesh Sharma',
      subscribersCount: 128,
      timing: '05:30 AM - 07:15 AM',
      vehicleType: 'Cargo Bike',
    ),
    const DeliveryCorridor(
      routeName: 'Route 4 — Greater Noida West',
      zone: 'Gaur City 1 & 2',
      riderName: 'Suresh Verma',
      subscribersCount: 164,
      timing: '05:00 AM - 07:00 AM',
      vehicleType: 'Electric Mini Van',
    ),
  ];

  List<DeliveryCorridor> get corridors => _corridors;

  // --- Customers Data ---
  final List<DairyCustomer> _customers = [
    const DairyCustomer(
      id: 'CUST-1001',
      name: 'Rahul Sharma',
      phone: '+91 98765 43210',
      email: 'rahul.sharma@example.com',
      address: 'Flat 402, Lotus Greens, Sector 78, Noida',
      deliveryZone: 'Sector 7x Highrise Belt',
      subscriptionPlan: 'Daily Morning (2 Litres)',
      milkPreference: 'Pure A2 Cow Milk',
      walletBalance: 1240.0,
      status: 'Active',
      joinedDate: '12 Jan 2024',
    ),
    const DairyCustomer(
      id: 'CUST-1002',
      name: 'Priya Verma',
      phone: '+91 98112 34567',
      email: 'priya.v@example.com',
      address: 'B-14, ATS Greens, Sector 50, Noida',
      deliveryZone: 'Central Noida Hub',
      subscriptionPlan: 'Daily (1 Litre Cow Milk + Curd 500g)',
      milkPreference: 'Standard Cow Milk',
      walletBalance: 860.0,
      status: 'Active',
      joinedDate: '04 Feb 2024',
    ),
    const DairyCustomer(
      id: 'CUST-1003',
      name: 'Anil Gupta',
      phone: '+91 97123 45678',
      email: 'anil.gupta@enterprise.in',
      address: 'Villa 21, Jaypee Greens, Greater Noida',
      deliveryZone: 'Noida Express Zone',
      subscriptionPlan: 'Alternate Days (3 Litres)',
      milkPreference: 'Full Cream Buffalo Milk',
      walletBalance: 2450.0,
      status: 'Active',
      joinedDate: '18 Nov 2023',
    ),
    const DairyCustomer(
      id: 'CUST-1004',
      name: 'Sneha Patel',
      phone: '+91 99887 76655',
      email: 'sneha.patel@gmail.com',
      address: 'Tower 4, Apex Golf Avenue, Sector 1',
      deliveryZone: 'Greater Noida West',
      subscriptionPlan: 'Daily (2 Litres)',
      milkPreference: 'Pure A2 Cow Milk',
      walletBalance: -45.0,
      status: 'Low Balance',
      joinedDate: '28 Mar 2024',
    ),
    const DairyCustomer(
      id: 'CUST-1005',
      name: 'Meenakshi Iyer',
      phone: '+91 93456 78901',
      email: 'm.iyer@chennai.org',
      address: 'Flat 903, Mahagun Moderne, Sector 78',
      deliveryZone: 'Sector 7x Highrise Belt',
      subscriptionPlan: 'Daily Morning (1.5 Litres)',
      milkPreference: 'Pure Cow Milk',
      walletBalance: 520.0,
      status: 'Active',
      joinedDate: '15 Apr 2024',
    ),
  ];

  List<DairyCustomer> get customers => _customers;

  void addCustomer(DairyCustomer customer) {
    _customers.insert(0, customer);
    notifyListeners();
  }

  void updateCustomer(DairyCustomer customer) {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
      notifyListeners();
    }
  }

  void deleteCustomer(String id) {
    _customers.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // --- Categories Data ---
  final List<DairyCategory> _categories = [
    const DairyCategory(
      id: 'CAT-01',
      name: 'Milk & Creams',
      description: 'Farm-fresh pure cow milk, buffalo milk & pasteurized full cream',
      productCount: 6,
      icon: Icons.local_drink_rounded,
      color: Color(0xFF1E6BFF),
      emoji: '🥛',
    ),
    const DairyCategory(
      id: 'CAT-02',
      name: 'Paneer & Curd',
      description: 'Artisanal malai paneer, probiotic curd and Greek dahi',
      productCount: 4,
      icon: Icons.grain_rounded,
      color: Color(0xFF10B981),
      emoji: '🧀',
    ),
    const DairyCategory(
      id: 'CAT-03',
      name: 'Ghee & Butter',
      description: 'Traditional Vedic Bilona Cow Ghee & table churned butter',
      productCount: 5,
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFF97316),
      emoji: '🍯',
    ),
  ];

  List<DairyCategory> get categories => _categories;

  void addCategory(DairyCategory category) {
    _categories.insert(0, category);
    notifyListeners();
  }

  void updateCategory(DairyCategory category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // --- Delivery Staff Riders ---
  final List<DeliveryRider> _riders = [
    const DeliveryRider(
      id: 'RDR-101',
      name: 'Amit Kumar',
      phone: '+91 98765 11223',
      vehicle: 'Hero Electric Nyx (UP-16-DE-4412)',
      assignedZone: 'Noida Express Zone',
      totalDeliveriesToday: 82,
      pendingDeliveries: 6,
      rating: 4.9,
      status: 'Active',
    ),
    const DeliveryRider(
      id: 'RDR-102',
      name: 'Rajesh Sharma',
      phone: '+91 98112 55667',
      vehicle: 'TVS iQube EV (UP-16-AX-8910)',
      assignedZone: 'Central Noida Hub',
      totalDeliveriesToday: 95,
      pendingDeliveries: 0,
      rating: 4.8,
      status: 'Completed',
    ),
    const DeliveryRider(
      id: 'RDR-103',
      name: 'Vikram Singh',
      phone: '+91 97123 99881',
      vehicle: 'Euler HiLoad EV (UP-16-EM-3021)',
      assignedZone: 'Sector 7x Highrise Belt',
      totalDeliveriesToday: 88,
      pendingDeliveries: 7,
      rating: 4.95,
      status: 'Active',
    ),
    const DeliveryRider(
      id: 'RDR-104',
      name: 'Suresh Verma',
      phone: '+91 94567 22334',
      vehicle: 'Mahindra Zor Grand (UP-16-TR-7721)',
      assignedZone: 'Greater Noida West',
      totalDeliveriesToday: 75,
      pendingDeliveries: 5,
      rating: 4.7,
      status: 'Active',
    ),
  ];

  List<DeliveryRider> get riders => _riders;

  // --- Payments Data ---
  final List<DairyPayment> _payments = [
    const DairyPayment(
      id: 'TXN-99812',
      customerName: 'Rahul Sharma',
      orderOrWalletId: '#ORD10284',
      amount: 163.0,
      method: 'Online (UPI)',
      status: 'Success',
      timestamp: 'Today, 05:42 AM',
    ),
    const DairyPayment(
      id: 'TXN-99811',
      customerName: 'Priya Verma',
      orderOrWalletId: 'Wallet Auto-Debit',
      amount: 114.0,
      method: 'Prepaid Wallet',
      status: 'Success',
      timestamp: 'Today, 06:10 AM',
    ),
    const DairyPayment(
      id: 'TXN-99810',
      customerName: 'Anil Gupta',
      orderOrWalletId: '#ORD10282',
      amount: 608.0,
      method: 'Razorpay PG',
      status: 'Success',
      timestamp: 'Today, 06:25 AM',
    ),
    const DairyPayment(
      id: 'TXN-99809',
      customerName: 'Vikas Malhotra',
      orderOrWalletId: '#ORD10280',
      amount: 362.0,
      method: 'Cash On Delivery',
      status: 'Pending',
      timestamp: 'Today, 07:45 AM',
    ),
  ];

  List<DairyPayment> get payments => _payments;

  // --- Support Complaints Data ---
  final List<CustomerComplaint> _complaints = [
    const CustomerComplaint(
      id: 'CMP-301',
      customerName: 'Sneha Patel',
      phone: '+91 99887 76655',
      issueType: 'Late Delivery',
      description: 'Morning milk reached at 7:45 AM instead of committed 6:30 AM slot.',
      priority: 'Medium',
      status: 'In Progress',
      createdAt: 'Today, 08:00 AM',
    ),
    const CustomerComplaint(
      id: 'CMP-302',
      customerName: 'Ramesh Chawla',
      phone: '+91 98112 00998',
      issueType: 'Damaged Seal',
      description: 'Pouch corner was slightly punctured upon arrival. Requesting replacement.',
      priority: 'High',
      status: 'Resolved',
      createdAt: 'Yesterday, 07:15 AM',
    ),
  ];

  List<CustomerComplaint> get complaints => _complaints;
}
