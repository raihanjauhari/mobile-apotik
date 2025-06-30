import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import untuk FL Chart

class ApotikChartCardFlutter extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  const ApotikChartCardFlutter({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  // Data dan Options dari React.js chart
  final List<Color> gradientColors = const [
    Color(0xff0f172a), // Dark Blue (for "Pasien Baru")
    Color(0xff67E8F9), // Light Blue (for "Pasien Lama")
  ];

  final List<FlSpot> pasienBaruData = const [
    FlSpot(0, 50),
    FlSpot(1, 250),
    FlSpot(2, 300),
    FlSpot(3, 260),
    FlSpot(4, 150),
    FlSpot(5, 200),
    FlSpot(6, 280),
    FlSpot(7, 320),
    FlSpot(8, 250),
    FlSpot(9, 300),
    FlSpot(10, 400),
    FlSpot(11, 500),
  ];

  final List<FlSpot> pasienLamaData = const [
    FlSpot(0, 100),
    FlSpot(1, 500),
    FlSpot(2, 350),
    FlSpot(3, 120),
    FlSpot(4, 400),
    FlSpot(5, 350),
    FlSpot(6, 390),
    FlSpot(7, 370),
    FlSpot(8, 280),
    FlSpot(9, 210),
    FlSpot(10, 100),
    FlSpot(11, 30),
  ];

  final List<String> months = const [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
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
            'Survei Apotik',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jumlah pasien per bulan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.2, // Rasio aspek sedikit lebih tinggi untuk mobile
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false, // Hilangkan garis vertikal
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2), // Kurangi opasitas
                      strokeWidth: 0.5, // Kurangi ketebalan
                      dashArray: [2, 2], // Garis putus-putus
                    );
                  },
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
                      reservedSize: 25, // Lebih kecil
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4.0, // Kurangi spasi
                          child: Text(
                            months[value.toInt()],
                            style: TextStyle(
                              fontSize: 10, // Font lebih kecil
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
                      reservedSize: 30, // Lebih kecil
                      interval: 100,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10, // Font lebih kecil
                            color: Colors.grey[700],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border:
                      Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                ),
                minX: 0,
                maxX: 11, // 12 months (0-11)
                minY: 0,
                maxY: 600, // Adjust based on max data value
                lineBarsData: [
                  LineChartBarData(
                    spots: pasienBaruData,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [gradientColors[0], gradientColors[0]],
                    ),
                    barWidth: 3, // Kurangi ketebalan garis
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          gradientColors[0].withOpacity(0.3),
                          gradientColors[0].withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: pasienLamaData,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [gradientColors[1], gradientColors[1]],
                    ),
                    barWidth: 3, // Kurangi ketebalan garis
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          gradientColors[1].withOpacity(0.3),
                          gradientColors[1].withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem(color: gradientColors[0], label: 'Pasien Baru'),
              const SizedBox(width: 16),
              _buildLegendItem(color: gradientColors[1], label: 'Pasien Lama'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
