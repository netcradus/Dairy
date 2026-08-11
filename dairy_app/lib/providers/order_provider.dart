import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../repositories/product_repository.dart';

final _sampleAddress = const Address(
  id: 'addr_1',
  label: 'Home',
  fullName: 'Rahul Sharma',
  mobileNumber: '+91 9876543210',
  houseFlat: 'Flat 402, Sunshine Heights',
  streetArea: 'MG Road, Vijay Nagar',
  city: 'Indore',
  state: 'Madhya Pradesh',
  pinCode: '452010',
  isDefault: true,
);

List<Order> _getMockOrders() {
  final repo = ProductRepository();
  final allProducts = repo.getFreshDeals();
  final a2Products = repo.getA2MilkProducts();
  final bestSellers = repo.getBestSellers();

  return [
    Order(
      id: 'SD-9842',
      items: [
        CartItem(product: a2Products[0], quantity: 2),
        CartItem(product: allProducts[1], quantity: 1),
      ],
      subtotal: 740.0,
      deliveryCharge: 0.0,
      discount: 74.0,
      totalAmount: 666.0,
      status: OrderStatus.outForDelivery,
      orderDate: DateTime.now().subtract(const Duration(hours: 1)),
      deliveryAddress: _sampleAddress,
      paymentMethod: 'Cash on Delivery',
      estimatedDeliveryTime: 'Today by 7:30 AM',
    ),
    Order(
      id: 'SD-9810',
      items: [
        CartItem(product: allProducts[0], quantity: 2),
        CartItem(product: allProducts[2], quantity: 1),
      ],
      subtotal: 163.0,
      deliveryCharge: 30.0,
      discount: 0.0,
      totalAmount: 193.0,
      status: OrderStatus.preparing,
      orderDate: DateTime.now().subtract(const Duration(hours: 3)),
      deliveryAddress: _sampleAddress,
      paymentMethod: 'Online Payment (UPI)',
      estimatedDeliveryTime: 'Today by 8:00 AM',
    ),
    Order(
      id: 'SD-9745',
      items: [
        CartItem(product: allProducts[3], quantity: 2),
        CartItem(product: bestSellers[4], quantity: 1),
      ],
      subtotal: 150.0,
      deliveryCharge: 30.0,
      discount: 0.0,
      totalAmount: 180.0,
      status: OrderStatus.delivered,
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      deliveryAddress: _sampleAddress,
      paymentMethod: 'Online Payment (GPay)',
      estimatedDeliveryTime: 'Delivered yesterday at 7:15 AM',
    ),
    Order(
      id: 'SD-9602',
      items: [
        CartItem(product: bestSellers[5], quantity: 3),
      ],
      subtotal: 120.0,
      deliveryCharge: 30.0,
      discount: 0.0,
      totalAmount: 150.0,
      status: OrderStatus.cancelled,
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      deliveryAddress: _sampleAddress,
      paymentMethod: 'Cash on Delivery',
      estimatedDeliveryTime: 'Cancelled by customer',
    ),
  ];
}

class OrdersNotifier extends StateNotifier<List<Order>> {
  OrdersNotifier() : super(_getMockOrders());

  void cancelOrder(String orderId) {
    state = state.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: OrderStatus.cancelled);
      }
      return order;
    }).toList();
  }

  void addOrder(Order newOrder) {
    state = [newOrder, ...state];
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<Order>>((ref) {
  return OrdersNotifier();
});

final allOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider);
});

final upcomingOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider).where((o) => o.isUpcoming).toList();
});

final completedOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider).where((o) => o.isCompleted).toList();
});

final cancelledOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider).where((o) => o.isCancelled).toList();
});
