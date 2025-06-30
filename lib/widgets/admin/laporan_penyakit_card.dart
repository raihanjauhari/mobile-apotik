// lib/widgets/admin/laporan_penyakit_card.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LaporanPenyakitCardFlutter extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  const LaporanPenyakitCardFlutter({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  final List<Color> barColors = const [
    Color(0xfff87171), // Demam (Red)
    Color(0xff3b82f6), // Batuk (Blue)
    Color(0xff0ea5e9), // Diare (Light Blue)
    Color(0xff93c5fd), // Covid-19 (Lighter Blue)
  ];

  final List<String> weekDays = const [
    "Sen",
    "Sel",
    "Rab",
    "Kam",
    "Jum",
    "Sab"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan Penyakit',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Laporan Penyakit dalam 1 Bulan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.5, // Disesuaikan agar lebih ringkas vertikal
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  enabled: true, // Aktifkan touch agar bisa menampilkan tooltip
                  touchTooltipData: BarTouchTooltipData(
                    // FIX: Use getTooltipColor instead of tooltipBgColor
                    getTooltipColor: (group) => primaryColor
                        .withOpacity(0.9), // Set tooltip background color here
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String disease;
                      switch (rodIndex) {
                        case 0:
                          disease = 'Demam';
                          break;
                        case 1:
                          disease = 'Batuk';
                          break;
                        case 2:
                          disease = 'Diare';
                          break;
                        case 3:
                          disease = 'Covid-19';
                          break;
                        default:
                          return null;
                      }
                      return BarTooltipItem(
                        '${rod.toY.toInt()}', // Hanya menampilkan nilai angka
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                '\n${disease}', // Tambahkan nama penyakit di baris baru
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22, // Lebih ringkas
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4.0,
                          child: Text(
                            weekDays[value.toInt()],
                            style: TextStyle(
                              fontSize: 9, // Lebih kecil
                              color: Colors.grey[700],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28, // Lebih ringkas
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 9, // Lebih kecil
                            color: Colors.grey[700],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 0.5), // Lebih tipis
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false, // Tetap hilangkan garis vertikal
                  horizontalInterval: 10, // Sesuaikan interval
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1), // Lebih transparan
                      strokeWidth: 0.3, // Sangat tipis
                      dashArray: [2, 2],
                    );
                  },
                ),
                barGroups: [
                  // Data tetap sama, hanya tampilan barRod yang diubah
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        toY: 30,
                        color: barColors[0],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 10,
                        color: barColors[1],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 5,
                        color: barColors[2],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 20,
                        color: barColors[3],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        toY: 15,
                        color: barColors[0],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 20,
                        color: barColors[1],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 10,
                        color: barColors[2],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 15,
                        color: barColors[3],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                        toY: 30,
                        color: barColors[0],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 5,
                        color: barColors[1],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 0,
                        color: barColors[2],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 15,
                        color: barColors[3],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(
                        toY: 15,
                        color: barColors[0],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 10,
                        color: barColors[1],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 5,
                        color: barColors[2],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 14,
                        color: barColors[3],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                  ]),
                  BarChartGroupData(x: 4, barRods: [
                    BarChartRodData(
                        toY: 20,
                        color: barColors[0],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 10,
                        color: barColors[1],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 8,
                        color: barColors[2],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 15,
                        color: barColors[3],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                  ]),
                  BarChartGroupData(x: 5, barRods: [
                    BarChartRodData(
                        toY: 30,
                        color: barColors[0],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 8,
                        color: barColors[1],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 6,
                        color: barColors[2],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                    BarChartRodData(
                        toY: 20,
                        color: barColors[3],
                        width: 7,
                        borderRadius: BorderRadius.circular(2)),
                  ]),
                ],
              ),
              swapAnimationDuration: const Duration(milliseconds: 150),
              swapAnimationCurve: Curves.linear,
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 12.0,
              runSpacing: 4.0,
              children: [
                _buildLegendItem(color: barColors[0], label: 'Demam'),
                _buildLegendItem(color: barColors[1], label: 'Batuk'),
                _buildLegendItem(color: barColors[2], label: 'Diare'),
                _buildLegendItem(color: barColors[3], label: 'Covid-19'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
