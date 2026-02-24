import 'package:flutter/material.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  final int _currentNavIndex = 1;
  final Color _navyColor = const Color(0xFF0C1C46);
  final Color _orangeColor = const Color(0xFFFF9800);
  
  int _selectedPeriod = 2; // 0: Hôm nay, 1: Tuần này, 2: Tháng này, 3: Tùy chỉnh
  
  final List<String> _periods = ['Hôm nay', 'Tuần này', 'Tháng này', 'Tùy chỉnh'];
  
  final List<Map<String, dynamic>> _sportRevenue = [
    {
      'name': 'Bóng đá',
      'icon': Icons.sports_soccer,
      'revenue': '85.5tr',
      'percentage': 58,
      'description': '58% doanh thu',
    },
    {
      'name': 'Cầu lông',
      'icon': Icons.sports_tennis,
      'revenue': '42.1tr',
      'percentage': 29,
      'description': '29% doanh thu',
    },
    {
      'name': 'Pickleball',
      'icon': Icons.sports_baseball,
      'revenue': '17.6tr',
      'percentage': 13,
      'description': '13% doanh thu',
    },
  ];
  
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'title': 'Sân 7 - Bóng đá',
      'time': '14:00 - 15:30',
      'date': 'Hôm nay',
      'amount': '+450k',
    },
    {
      'title': 'Sân 2 - Cầu lông',
      'time': '10:00 - 11:00',
      'date': 'Hôm nay',
      'amount': '+120k',
    },
    {
      'title': 'Sân 1 - Pickleball',
      'time': '18:00 - 20:00',
      'date': 'Hôm qua',
      'amount': '+500k',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodTabs(),
                  const SizedBox(height: 16),
                  _buildTotalRevenueCard(),
                  const SizedBox(height: 32),
                  _buildRevenueChart(),
                  const SizedBox(height: 32),
                  _buildSportAnalysis(),
                  const SizedBox(height: 32),
                  _buildRecentTransactions(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNav(currentIndex: _currentNavIndex),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.chevron_left, size: 28, color: Color(0xFF0C1C46)),
                ),
              ),
              const Expanded(
                child: Text(
                  'Báo Cáo Doanh Thu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0C1C46),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Padding(
            padding: EdgeInsets.only(right: index < _periods.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _navyColor : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? _navyColor : Colors.grey.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: _navyColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                      ),
                  ],
                ),
                child: Text(
                  _periods[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[500],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTotalRevenueCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: _orangeColor.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -32,
            left: -32,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng doanh thu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange[50],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    '145.200.000',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'đ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange[100],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        size: 14,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '+15%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'so với tháng trước',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[50],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _navyColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Biểu đồ doanh thu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CustomPaint(
                    painter: RevenueChartPainter(orangeColor: _orangeColor),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TUẦN 1',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[400],
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'TUẦN 2',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[400],
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'TUẦN 3',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[400],
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'TUẦN 4',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[400],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportAnalysis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _navyColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Phân tích theo bộ môn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _navyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: List.generate(_sportRevenue.length, (index) {
                final sport = _sportRevenue[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: index < _sportRevenue.length - 1 ? 20 : 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              sport['icon'] as IconData,
                              color: Colors.orange[600],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            sport['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                sport['revenue'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _navyColor,
                                ),
                              ),
                              Text(
                                sport['description'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (sport['percentage'] as int) / 100,
                          backgroundColor: Colors.grey[100],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _orangeColor,
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _navyColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Giao dịch gần đây',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _navyColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _orangeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(_recentTransactions.length, (index) {
              final transaction = _recentTransactions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green[100]!),
                        ),
                        child: Icon(
                          Icons.payments,
                          size: 20,
                          color: Colors.green[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _navyColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${transaction['time']} • ${transaction['date']}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          transaction['amount'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Custom painter for revenue chart
class RevenueChartPainter extends CustomPainter {
  final Color orangeColor;

  RevenueChartPainter({required this.orangeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    final dashedGridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Horizontal grid lines
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), gridPaint);
    
    for (int i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), dashedGridPaint);
    }

    // Create path for chart
    final path = Path();
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.33, size.height * 0.47),
      Offset(size.width * 0.73, size.height * 0.33),
      Offset(size.width, size.height * 0.067),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cp = Offset(
        p0.dx + (p1.dx - p0.dx) * 0.5,
        p0.dy,
      );
      path.quadraticBezierTo(cp.dx, cp.dy, p1.dx, p1.dy);
    }

    // Draw gradient fill
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          orangeColor.withValues(alpha: 0.3),
          orangeColor.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, gradientPaint);

    // Draw line
    paint.color = orangeColor;
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = orangeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (int i = 1; i < points.length; i++) {
      canvas.drawCircle(points[i], 4, pointPaint);
      canvas.drawCircle(points[i], 4, borderPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4;
    const dashSpace = 4;
    double distance = (end - start).distance;
    double drawn = 0;

    while (drawn < distance) {
      final drawStart = start + (end - start) * (drawn / distance);
      final drawEnd = start + (end - start) * ((drawn + dashWidth) / distance);
      canvas.drawLine(drawStart, drawEnd, paint);
      drawn += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

