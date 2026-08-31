import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../models/category_model.dart';
import '../models/customer_model.dart';
import '../models/delivery_model.dart';
import '../models/delivery_staff_model.dart';
import '../models/kpi_data.dart';
import '../models/order.dart' as order;
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../repositories/firestore_product_repository.dart';
import '../services/order_service.dart';

class AdminProvider extends ChangeNotifier {
  final FirestoreProductRepository _repo;
  final OrderService _orderService;

  int _selectedNavIndex = 0;
  String _searchQuery = '';
  String _orderStatusTimeFilter = 'Today';
  int _unreadNotifications = 5;
  bool _isDarkMode = false;

  List<DairyProduct> _products = [];
  List<DairyCategory> _categories = [];
  bool _isLoading = true;
  String? _error;

  List<DairyOrder> _orders = [];
  bool _ordersLoading = true;
  String? _ordersError;

  StreamSubscription<List<Map<String, dynamic>>>? _productsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _categoriesSub;
  StreamSubscription<List<order.Order>>? _ordersSub;

  int get selectedNavIndex => _selectedNavIndex;
  String get searchQuery => _searchQuery;
  String get orderStatusTimeFilter => _orderStatusTimeFilter;
  int get unreadNotifications => _unreadNotifications;
  bool get isDarkMode => _isDarkMode;
  List<DairyProduct> get products => _products;
  List<DairyCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get ordersLoading => _ordersLoading;
  String? get ordersError => _ordersError;

  List<DairyProduct> get topSellingProducts =>
      _products.where((p) => p.isBestSeller).toList().take(5).toList();

  AdminProvider({FirestoreProductRepository? repo, OrderService? orderService})
      : _repo = repo ?? FirestoreProductRepository(),
        _orderService = orderService ?? OrderService() {
    _listenToProducts();
    _listenToCategories();
    _listenToOrders();
  }

  // ─── Firestore listeners ───────────────────────────────────────────────

  void _listenToProducts() {
    _productsSub = _repo.streamRawProducts().listen(
      (docs) {
        _products = docs.map(_rawToDairyProduct).toList();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load products: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _listenToCategories() {
    _categoriesSub = _repo.streamRawCategories().listen(
      (docs) {
        _categories = docs.map(_rawToDairyCategory).toList();
        notifyListeners();
      },
      onError: (e) {
        debugPrint('AdminProvider: category stream error: $e');
      },
    );
  }

  void _listenToOrders() {
    _ordersSub = _orderService.streamAllDeliveryOrders().listen(
      (orders) {
        _orders = orders.map(_dairyOrderFromOrder).toList();
        _ordersLoading = false;
        _ordersError = null;
        notifyListeners();
      },
      onError: (e) {
        _ordersError = 'Failed to load orders: $e';
        _ordersLoading = false;
        notifyListeners();
      },
    );
  }

  /// Maps a Firestore-backed [order.Order] onto the admin-facing
  /// [DairyOrder] used by the Orders screen, tolerating missing fields.
  DairyOrder _dairyOrderFromOrder(order.Order o) {
    final itemsSummary = o.items
        .map((it) {
          final title = it.product.title.trim();
          if (title.isEmpty) return '';
          final unit = it.product.unit.trim();
          return it.quantity > 1
              ? '$title (${it.quantity}${unit.isEmpty ? '' : ' $unit'})'
              : title;
        })
        .where((s) => s.isNotEmpty)
        .join(', ');

    return DairyOrder(
      id: o.id,
      customerName: o.deliveryAddress.fullName.trim().isNotEmpty
          ? o.deliveryAddress.fullName
          : 'Customer',
      customerPhone: o.deliveryAddress.mobileNumber,
      itemsSummary: itemsSummary,
      amount: o.totalAmount,
      status: _mapFromServiceStatus(o.status),
      deliverySlot: o.estimatedDeliveryTime,
      address: o.deliveryAddress.fullAddressText,
      time: DateFormat('hh:mm a').format(o.orderDate),
      paymentMode: o.paymentMethod,
    );
  }

  /// App-side [order.OrderStatus] -> admin [OrderStatus].
  OrderStatus _mapFromServiceStatus(order.OrderStatus s) {
    switch (s) {
      case order.OrderStatus.placed:
        return OrderStatus.pending;
      case order.OrderStatus.confirmed:
        return OrderStatus.confirmed;
      case order.OrderStatus.preparing:
        return OrderStatus.preparing;
      case order.OrderStatus.outForDelivery:
        return OrderStatus.outForDelivery;
      case order.OrderStatus.delivered:
        return OrderStatus.delivered;
      case order.OrderStatus.cancelled:
        return OrderStatus.cancelled;
    }
  }

  /// Admin [OrderStatus] -> app-side [order.OrderStatus] for the service.
  order.OrderStatus _mapToServiceStatus(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return order.OrderStatus.placed;
      case OrderStatus.confirmed:
        return order.OrderStatus.confirmed;
      case OrderStatus.preparing:
        return order.OrderStatus.preparing;
      case OrderStatus.outForDelivery:
        return order.OrderStatus.outForDelivery;
      case OrderStatus.delivered:
        return order.OrderStatus.delivered;
      case OrderStatus.cancelled:
        return order.OrderStatus.cancelled;
    }
  }

  // ─── Mapping helpers ──────────────────────────────────────────────────

  static const Map<String, String> _categoryNameToId = {
    'Milk & Creams': 'cat_milk',
    'Paneer & Curd': 'cat_paneer',
    'Ghee & Butter': 'cat_ghee',
    'Beverages': 'cat_lassi',
    'Lassi': 'cat_lassi',
    'Makhan': 'cat_makhan',
  };

  static String _categoryIdForName(String name) {
    return _categoryNameToId[name] ??
        name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }

  DairyProduct _rawToDairyProduct(Map<String, dynamic> raw) {
    return DairyProduct(
      id: raw['id'] as String? ?? '',
      name: (raw['title'] as String?) ?? '',
      subtitle: (raw['description'] as String?) ?? '',
      category: (raw['categoryName'] as String?) ?? '',
      unit: (raw['unit'] as String?) ?? '',
      price: (raw['price'] as num?)?.toDouble() ?? 0.0,
      ordersCount: (raw['ordersCount'] as num?)?.toInt() ?? 0,
      totalRevenue: (raw['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: (raw['stockQuantity'] as num?)?.toInt() ?? 0,
      fatContent: (raw['fatContent'] as String?) ?? '',
      packaging: (raw['packaging'] as String?) ?? '',
      inStock: (raw['inStock'] as bool?) ?? true,
      emoji: (raw['emoji'] as String?) ?? '🥛',
      isBestSeller: (raw['isBestSeller'] as bool?) ?? false,
      imageUrl: (raw['imageUrl'] as String?) ?? '',
    );
  }

  Map<String, dynamic> _dairyProductToFirestore(DairyProduct p) {
    return {
      'title': p.name,
      'description': p.subtitle,
      'categoryName': p.category,
      'categoryId': _categoryIdForName(p.category),
      'price': p.price,
      'originalPrice': null,
      'unit': p.unit,
      'imageUrl': p.imageUrl,
      'rating': 4.8,
      'reviewCount': 0,
      'isFreshDeal': false,
      'isBestSeller': p.isBestSeller,
      'isA2CowMilk': false,
      'inStock': p.inStock,
      'fatContent': p.fatContent,
      'packaging': p.packaging,
      'emoji': p.emoji,
      'stockQuantity': p.stockQuantity,
      'ordersCount': p.ordersCount,
      'totalRevenue': p.totalRevenue,
    };
  }

  DairyCategory _rawToDairyCategory(Map<String, dynamic> raw) {
    final colorValue = raw['colorValue'] as int?;
    return DairyCategory(
      id: raw['id'] as String? ?? '',
      name: (raw['name'] as String?) ?? (raw['title'] as String?) ?? '',
      description:
          (raw['description'] as String?) ?? (raw['subtitle'] as String?) ?? '',
      productCount: (raw['productCount'] as num?)?.toInt() ??
          (raw['itemCount'] as num?)?.toInt() ??
          0,
      icon: Icons.category_rounded,
      color: colorValue != null ? Color(colorValue) : AppColors.primary,
      emoji: (raw['emoji'] as String?) ?? '🥛',
    );
  }

  Map<String, dynamic> _dairyCategoryToFirestore(DairyCategory c) {
    return {
      'title': c.name,
      'subtitle': c.description,
      'imageUrl': '',
      'iconName': null,
      'colorValue': c.color.value,
      'itemCount': c.productCount,
      'name': c.name,
      'description': c.description,
      'productCount': c.productCount,
      'emoji': c.emoji,
    };
  }

  // ─── Product CRUD (Firestore) ─────────────────────────────────────────

  Future<void> addProduct(DairyProduct product) async {
    try {
      final data = _dairyProductToFirestore(product);
      await _repo.setProductRaw(product.id, data);
    } catch (e) {
      _error = 'Failed to add product: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduct(DairyProduct product) async {
    try {
      final data = _dairyProductToFirestore(product);
      await _repo.setProductRaw(product.id, data);
    } catch (e) {
      _error = 'Failed to update product: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repo.deleteProduct(id);
    } catch (e) {
      _error = 'Failed to delete product: $e';
      notifyListeners();
    }
  }

  Future<void> toggleProductStock(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) return;
    try {
      final product = _products[index];
      final toggled = product.copyWith(inStock: !product.inStock);
      await updateProduct(toggled);
    } catch (e) {
      _error = 'Failed to toggle stock: $e';
      notifyListeners();
    }
  }

  Future<void> toggleBestSeller(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) return;
    try {
      final product = _products[index];
      final toggled = product.copyWith(isBestSeller: !product.isBestSeller);
      await updateProduct(toggled);
    } catch (e) {
      _error = 'Failed to toggle best seller: $e';
      notifyListeners();
    }
  }

  // ─── Category CRUD (Firestore) ────────────────────────────────────────

  Future<void> addCategory(DairyCategory category) async {
    try {
      final data = _dairyCategoryToFirestore(category);
      await _repo.setCategoryRaw(category.id, data);
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
    }
  }

  Future<void> updateCategory(DairyCategory category) async {
    try {
      final data = _dairyCategoryToFirestore(category);
      await _repo.setCategoryRaw(category.id, data);
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repo.deleteCategory(id);
    } catch (e) {
      _error = 'Failed to delete category: $e';
      notifyListeners();
    }
  }

  // ─── Navigation & search ──────────────────────────────────────────────

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

  // ─── KPI Metrics (hardcoded) ──────────────────────────────────────────

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

  // ─── Orders (Firestore-backed via OrderService) ───────────────────────

  List<DairyOrder> get orders => _orders;
  List<DairyOrder> get recentOrders => _orders.take(5).toList();

  /// Updates an order's status in the shared Firestore `orders` document using
  /// the existing [OrderService], so customers and delivery agents see the same
  /// change. The UI is refreshed by the live orders stream (no optimistic
  /// update), so a failed write leaves the status unchanged in the UI.
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _orderService.updateOrderStatus(
      orderId,
      _mapToServiceStatus(newStatus),
    );
  }

  // ─── Today's Deliveries Data (hardcoded) ──────────────────────────────

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

  // ─── Delivery Corridors Data (hardcoded) ──────────────────────────────

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

  // ─── Customers Data (hardcoded) ───────────────────────────────────────

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

  // ─── Delivery Staff Riders (hardcoded) ────────────────────────────────

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

  // ─── Payments Data (hardcoded) ────────────────────────────────────────

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

  // ─── Support Complaints Data (hardcoded) ──────────────────────────────

  final List<CustomerComplaint> _complaints = [
    const CustomerComplaint(
      id: 'CMP-301',
      customerName: 'Sneha Patel',
      phone: '+91 99887 76655',
      issueType: 'Late Delivery',
      description:
          'Morning milk reached at 7:45 AM instead of committed 6:30 AM slot.',
      priority: 'Medium',
      status: 'In Progress',
      createdAt: 'Today, 08:00 AM',
    ),
    const CustomerComplaint(
      id: 'CMP-302',
      customerName: 'Ramesh Chawla',
      phone: '+91 98112 00998',
      issueType: 'Damaged Seal',
      description:
          'Pouch corner was slightly punctured upon arrival. Requesting replacement.',
      priority: 'High',
      status: 'Resolved',
      createdAt: 'Yesterday, 07:15 AM',
    ),
  ];

  List<CustomerComplaint> get complaints => _complaints;

  // ─── Cleanup ──────────────────────────────────────────────────────────

  @override
  void dispose() {
    _productsSub?.cancel();
    _categoriesSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }
}
