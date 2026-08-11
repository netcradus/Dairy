import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';

class RevenueLineChart extends StatelessWidget {
  const RevenueLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.cardBgOf(context);
    final cardBorder = AppColors.cardBorderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);
    final textMuted = AppColors.textMutedOf(context);
    final gridLineColor = isDark ? const Color(0xFF222F4E) : AppColors.divider;

    final List<FlSpot> weekSpots = const [
      FlSpot(0, 24000),
      FlSpot(1, 58000),
      FlSpot(2, 44000),
      FlSpot(3, 62000),
      FlSpot(4, 50000),
      FlSpot(5, 74000),
      FlSpot(6, 88000),
    ];

    final days = ['4 May', '5 May', '6 May', '7 May', '8 May', '9 May', '10 May'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Revenue Overview',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.revenueTimeFilter,
                    dropdownColor: cardBg,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: textSecondary),
                    isDense: true,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Today', child: Text('Today')),
                      DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                      DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                      DropdownMenuItem(value: 'This Year', child: Text('This Year')),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.setRevenueTimeFilter(val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          SizedBox(
            height: 230,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100000,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: gridLineColor.withValues(alpha: 0.8),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      interval: 20000,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        if (value == 0) {
                          text = '₹0';
                        } else if (value == 20000) {
                          text = '₹20k';
                        } else if (value == 40000) {
                          text = '₹40k';
                        } else if (value == 60000) {
                          text = '₹60k';
                        } else if (value == 80000) {
                          text = '₹80k';
                        } else if (value == 100000) {
                          text = '₹100k';
                        }
                        return Text(
                          text,
                          style: GoogleFonts.plusJakartaSans(
                            color: textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[idx],
                              style: GoogleFonts.plusJakartaSans(
                                color: textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weekSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: isDark ? AppColors.darkCardBg : Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.25),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: AppColors.sidebarBgDarker,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final day = days[spot.x.toInt()];
                        return LineTooltipItem(
                          '$day\n₹${spot.y.toInt()}',
                          GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
