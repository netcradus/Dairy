import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/charts/order_status_donut_chart.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/top_selling_products_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: KPI Metrics
          _buildKpiMetrics(context, provider, isDesktop, isTablet),
          const SizedBox(height: 20),
          // Row 2: Charts & Top Selling Products
          _buildMiddleSection(context, isDesktop),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildKpiMetrics(
      BuildContext context, AdminProvider provider, bool isDesktop, bool isTablet) {
    final metrics = provider.kpiMetrics;

    if (isDesktop) {
      return Row(
        children: metrics.map((metric) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: KpiCard(metric: metric),
            ),
          );
        }).toList(),
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: KpiCard(metric: metrics[0])),
              const SizedBox(width: 12),
              Expanded(child: KpiCard(metric: metrics[1])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: KpiCard(metric: metrics[2])),
              const SizedBox(width: 12),
              Expanded(child: KpiCard(metric: metrics[3])),
            ],
          ),
        ],
      );
    } else {
      // Mobile Single Column
      return Column(
        children: metrics.map((metric) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: KpiCard(metric: metric),
          );
        }).toList(),
      );
    }
  }

  Widget _buildMiddleSection(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return const IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: OrderStatusDonutChart(),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: TopSellingProductsCard(),
            ),
          ],
        ),
      );
    } else {
      // Stack for tablet and mobile
      return const Column(
        children: [
          SizedBox(height: 320, child: OrderStatusDonutChart()),
          SizedBox(height: 16),
          TopSellingProductsCard(),
        ],
      );
    }
  }
}

