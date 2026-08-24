import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_colors.dart';
import '../../models/delivery_boy_model.dart';
import '../../providers/delivery_live_location_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../services/delivery_tracking_service.dart';

/// Static demo coordinates around Indore (Vijay Nagar area) used because the
/// delivery models do not yet carry lat/lng. The pickup hub and customer drop
/// points stay here; the agent's live position is streamed from Firestore.
class _Geo {
  static const LatLng indoreCenter = LatLng(22.7255, 75.8800);
  static const LatLng pickupHub = LatLng(22.7255, 75.8800);
  static const LatLng fallbackAgent = LatLng(22.7320, 75.8745);

  /// Approximate drop coordinates for the mock active orders, keyed by order id.
  static const Map<String, LatLng> dropPoints = {
    'DO-001': LatLng(22.7180, 75.8720),
    'DO-002': LatLng(22.7410, 75.8920),
  };

  static LatLng locationForOrder(DeliveryOrder order) {
    return dropPoints[order.id] ??
        LatLng(
          indoreCenter.latitude + (order.id.hashCode % 20) * 0.0008,
          indoreCenter.longitude + (order.id.hashCode % 15) * 0.0009,
        );
  }
}

/// Live delivery tracking map built on OpenStreetMap tiles (free, no API key).
/// The delivery agent's position is streamed from Firestore in real time.
class DeliveryMapScreen extends ConsumerStatefulWidget {
  const DeliveryMapScreen({super.key});

  @override
  ConsumerState<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends ConsumerState<DeliveryMapScreen> {
  final MapController _mapController = MapController();
  DeliveryOrder? _selectedOrder;
  LatLng _agentPosition = _Geo.fallbackAgent;

  /// Stable stream of the agent's live position (subscribed once).
  late final Stream<LatLng?> _locationStream;

  bool _followAgent = false;

  @override
  void initState() {
    super.initState();
    final agentId = ref.read(deliveryAgentProvider).id;
    _locationStream =
        ref.read(deliveryTrackingServiceProvider).agentLocationStream(agentId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _focusOn(LatLng point, {double zoom = 14}) {
    _mapController.move(point, zoom);
  }

  void _selectOrder(DeliveryOrder order) {
    setState(() => _selectedOrder = order);
    _focusOn(_Geo.locationForOrder(order));
  }

  void _toggleLiveLocation() {
    ref.read(agentLiveLocationProvider.notifier).toggle();
  }

  List<Marker> _buildMarkers(List<DeliveryOrder> orders, LatLng agentPos) {
    final markers = <Marker>[
      Marker(
        point: _Geo.pickupHub,
        width: 40,
        height: 40,
        child: _MapPin(
          color: AppColors.primaryBlue,
          icon: Icons.store_rounded,
          label: 'Hub',
        ),
      ),
      Marker(
        point: agentPos,
        width: 44,
        height: 44,
        child: _MapPin(
          color: AppColors.freshGreen,
          icon: Icons.delivery_dining_rounded,
          label: 'Live',
        ),
      ),
    ];

    for (final order in orders) {
      final isSelected = order.id == _selectedOrder?.id;
      markers.add(
        Marker(
          point: _Geo.locationForOrder(order),
          width: isSelected ? 46 : 38,
          height: isSelected ? 46 : 38,
          child: GestureDetector(
            onTap: () => _selectOrder(order),
            child: _MapPin(
              color: order.status.statusColor,
              icon: Icons.location_on_rounded,
              label: order.orderId,
              highlighted: isSelected,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final agent = ref.watch(deliveryAgentProvider);
    final sharing = ref.watch(agentLiveLocationProvider);
    final ordersAsync = ref.watch(deliveryActiveOrdersStreamProvider);

    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Live Delivery Map'),
          elevation: 0,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          actions: [
            IconButton(
              tooltip: sharing ? 'Stop live location' : 'Share live location',
              icon: Icon(sharing
                  ? Icons.pause_circle_rounded
                  : Icons.play_circle_rounded),
              onPressed: _toggleLiveLocation,
            ),
            IconButton(
              tooltip: 'Recenter on Indore',
              icon: const Icon(Icons.my_location_rounded),
              onPressed: () => _focusOn(_Geo.indoreCenter, zoom: 13),
            ),
          ],
        ),
        body: ordersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Center(
            child: Text('Could not load active orders'),
          ),
          data: (orders) {
            final activeOrders = orders
                .where((o) =>
                    o.status != DeliveryOrderStatus.delivered &&
                    o.status != DeliveryOrderStatus.cancelled &&
                    o.status != DeliveryOrderStatus.declined)
                .toList();

            return StreamBuilder<LatLng?>(
              stream: _locationStream,
              builder: (context, snapshot) {
                final agentPos = snapshot.data ?? _Geo.fallbackAgent;
                _agentPosition = agentPos;

                // Optional auto-follow: keep the agent centered as they move.
                if (_followAgent && snapshot.hasData) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _mapController.move(agentPos, _mapController.camera.zoom);
                  });
                }

                final route = <LatLng>[];
                if (_selectedOrder != null) {
                  route
                    ..add(_Geo.pickupHub)
                    ..add(agentPos)
                    ..add(_Geo.locationForOrder(_selectedOrder!));
                }

                return Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _Geo.indoreCenter,
                        initialZoom: 13,
                        minZoom: 4,
                        maxZoom: 18,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.dairy_app',
                          // Attribution is rendered automatically by flutter_map.
                        ),
                        if (route.length >= 2)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: route,
                                strokeWidth: 4,
                                color: AppColors.primaryBlue
                                    .withValues(alpha: 0.7),
                              ),
                            ],
                          ),
                        MarkerLayer(
                            markers: _buildMarkers(activeOrders, agentPos)),
                      ],
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: _AgentStatusCard(
                          agent: agent, isLive: snapshot.hasData),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: FloatingActionButton.small(
                        tooltip: _followAgent
                            ? 'Stop following agent'
                            : 'Follow agent',
                        backgroundColor: _followAgent
                            ? AppColors.primaryBlue
                            : AppColors.surface,
                        foregroundColor:
                            _followAgent ? Colors.white : AppColors.primaryBlue,
                        onPressed: () =>
                            setState(() => _followAgent = !_followAgent),
                        child: const Icon(Icons.gps_fixed_rounded),
                      ),
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: 0.32,
                      minChildSize: 0.18,
                      maxChildSize: 0.7,
                      builder: (context, scrollController) =>
                          _DeliveryListSheet(
                        scrollController: scrollController,
                        orders: activeOrders,
                        selectedOrder: _selectedOrder,
                        onTap: _selectOrder,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ));
  }
}

class _AgentStatusCard extends StatelessWidget {
  final DeliveryAgent agent;
  final bool isLive;

  const _AgentStatusCard({required this.agent, this.isLive = false});

  @override
  Widget build(BuildContext context) {
    final onDuty = agent.status == DeliveryStatus.onDuty ||
        agent.status == DeliveryStatus.breakTime;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: onDuty ? AppColors.freshGreen : AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${agent.assignedZone} · ${agent.status.name.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isLive
                  ? AppColors.freshGreen.withValues(alpha: 0.12)
                  : AppColors.textMuted.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLive ? Icons.location_on_rounded : Icons.cloud_off_rounded,
                  size: 12,
                  color: isLive ? AppColors.freshGreen : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  isLive ? 'LIVE' : 'OFFLINE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isLive ? AppColors.freshGreen : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${agent.completedDeliveriesToday}/${agent.totalDeliveriesToday} done',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryListSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<DeliveryOrder> orders;
  final DeliveryOrder? selectedOrder;
  final void Function(DeliveryOrder) onTap;

  const _DeliveryListSheet({
    required this.scrollController,
    required this.orders,
    required this.selectedOrder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: AppColors.cardShadowLg,
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.route_rounded,
                    size: 18, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Active Deliveries (${orders.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: orders.isEmpty
                ? const Center(
                    child: Text(
                      'No active deliveries right now',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final selected = order.id == selectedOrder?.id;
                      return _DeliveryListItem(
                        order: order,
                        selected: selected,
                        onTap: () => onTap(order),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryListItem extends StatelessWidget {
  final DeliveryOrder order;
  final bool selected;
  final VoidCallback onTap;

  const _DeliveryListItem({
    required this.order,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: order.status.statusColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: order.status.statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.customerAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: order.status.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: order.status.statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.distance} · ${order.estimatedTime}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final bool highlighted;

  const _MapPin({
    required this.color,
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: color,
              width: highlighted ? 3 : 2,
            ),
            boxShadow: AppColors.cardShadowSm,
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 18),
        ),
        if (highlighted)
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
