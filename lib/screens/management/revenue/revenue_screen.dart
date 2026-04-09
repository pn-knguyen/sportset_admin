import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sportset_admin/widgets/common_bottom_nav.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  static const _primary = Color(0xFF4CAF50);
  static const _darkGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _secondary = Color(0xFF00696B);
  static const _tertiary = Color(0xFF994700);
  static const _onSurface = Color(0xFF1A1C1C);
  static const _onSurfaceVariant = Color(0xFF5C615A);

  int _selectedPeriod = 2; // 0: Hôm nay, 1: Tuần này, 2: Tháng này

  final List<String> _periods = ['Hôm nay', 'Tuần này', 'Tháng này'];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // â”€â”€ helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  DateTimeRange _periodRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 0: // today
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case 1: // this week (Monâ€“Sun)
        final mon = now.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(
          start: DateTime(mon.year, mon.month, mon.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      default: // this month
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
    }
  }

  bool _inRange(Map<String, dynamic> booking, DateTimeRange range) {
    final raw = booking['selectedDate'];
    if (raw is Map) {
      final day = int.tryParse(raw['date']?.toString() ?? '') ?? 0;
      final month = int.tryParse(raw['month']?.toString() ?? '') ?? 0;
      final year = int.tryParse(raw['year']?.toString() ?? '') ??
          DateTime.now().year;
      if (day == 0 || month == 0) return false;
      final d = DateTime(year, month, day);
      return !d.isBefore(range.start) && !d.isAfter(range.end);
    }
    final ts = booking['createdAt'];
    if (ts is Timestamp) {
      final d = ts.toDate();
      return !d.isBefore(range.start) && !d.isAfter(range.end);
    }
    return false;
  }

  int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  String _fmt(int amount) {
    if (amount == 0) return '0đ';
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return '${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}Mđ';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '${amount}đ';
  }

  String _fmtFull(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf}đ';
  }

  Future<Map<String, dynamic>> _loadRevenue() async {
    final snap = await _firestore.collection('bookings').get();
    final all = snap.docs.map((d) => d.data()).toList();

    // completed / confirmed only
    final paid = all
        .where((b) =>
            b['status'] == 'completed' || b['status'] == 'confirmed')
        .toList();

    final range = _periodRange();
    final inPeriod =
        paid.where((b) => _inRange(b, range)).toList();

    // sort by createdAt desc for recent transactions
    final sorted = List<Map<String, dynamic>>.from(inPeriod)
      ..sort((a, b) {
        final aTs = a['createdAt'];
        final bTs = b['createdAt'];
        if (aTs is Timestamp && bTs is Timestamp) {
          return bTs.compareTo(aTs);
        }
        return 0;
      });

    // total
    final total = inPeriod.fold<int>(
        0, (acc, b) => acc + _toInt(b['totalPrice']));

    // previous period for comparison
    final prev = _prevPeriodRange();
    final prevPaid =
        paid.where((b) => _inRange(b, prev)).toList();
    final prevTotal = prevPaid.fold<int>(
        0, (acc, b) => acc + _toInt(b['totalPrice']));
    final growth = prevTotal == 0
        ? null
        : ((total - prevTotal) / prevTotal * 100).round();

    // group by court
    final Map<String, int> courtRevenue = {};
    for (final b in inPeriod) {
      final name = b['courtName']?.toString() ?? 'Khác';
      courtRevenue[name] =
          (courtRevenue[name] ?? 0) + _toInt(b['totalPrice']);
    }
    final sortedCourts = courtRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // bar chart: revenue per day-slot depending on period
    final chartData = _buildChartData(inPeriod, range);

    return {
      'total': total,
      'count': inPeriod.length,
      'growth': growth,
      'courts': sortedCourts,
      'recent': sorted.take(10).toList(),
      'chart': chartData,
    };
  }

  DateTimeRange _prevPeriodRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 0:
        final y = now.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: DateTime(y.year, y.month, y.day),
          end: DateTime(y.year, y.month, y.day, 23, 59, 59),
        );
      case 1:
        final mon = now.subtract(Duration(days: now.weekday - 1 + 7));
        final sun = mon.add(const Duration(days: 6));
        return DateTimeRange(
          start: DateTime(mon.year, mon.month, mon.day),
          end: DateTime(sun.year, sun.month, sun.day, 23, 59, 59),
        );
      default:
        final pm = DateTime(now.year, now.month - 1, 1);
        final lastDay =
            DateTime(now.year, now.month, 0);
        return DateTimeRange(
          start: pm,
          end: DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59),
        );
    }
  }

  List<Map<String, dynamic>> _buildChartData(
      List<Map<String, dynamic>> bookings, DateTimeRange range) {
    if (_selectedPeriod == 0) {
      // hourly buckets 6h, 9h, 12h, 15h, 18h, 21h
      final hours = [6, 9, 12, 15, 18, 21];
      final buckets = {for (final h in hours) h: 0};
      for (final b in bookings) {
        final ts = b['createdAt'];
        if (ts is Timestamp) {
          final dt = ts.toDate();
          final h = hours.lastWhere((x) => dt.hour >= x,
              orElse: () => hours.first);
          buckets[h] = (buckets[h] ?? 0) + _toInt(b['totalPrice']);
        }
      }
      return hours
          .map((h) => {'label': '$h h', 'value': buckets[h] ?? 0})
          .toList();
    } else if (_selectedPeriod == 1) {
      final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      final buckets = {for (int i = 0; i < 7; i++) i: 0};
      for (final b in bookings) {
        final raw = b['selectedDate'];
        if (raw is Map) {
          final day = int.tryParse(raw['date']?.toString() ?? '') ?? 0;
          final month =
              int.tryParse(raw['month']?.toString() ?? '') ?? 0;
          final year = int.tryParse(raw['year']?.toString() ?? '') ??
              DateTime.now().year;
          if (day > 0 && month > 0) {
            final dt = DateTime(year, month, day);
            final wd = dt.weekday - 1; // 0=Mon
            buckets[wd] =
                (buckets[wd] ?? 0) + _toInt(b['totalPrice']);
          }
        }
      }
      return List.generate(7,
          (i) => {'label': days[i], 'value': buckets[i] ?? 0});
    } else {
      // weekly buckets: W1–W4
      final weeks = ['Tuần 1', 'Tuần 2', 'Tuần 3', 'Tuần 4'];
      final buckets = {for (int i = 0; i < 4; i++) i: 0};
      for (final b in bookings) {
        final raw = b['selectedDate'];
        if (raw is Map) {
          final day =
              int.tryParse(raw['date']?.toString() ?? '') ?? 1;
          final w = ((day - 1) ~/ 7).clamp(0, 3);
          buckets[w] =
              (buckets[w] ?? 0) + _toInt(b['totalPrice']);
        }
      }
      return List.generate(4,
          (i) => {'label': weeks[i], 'value': buckets[i] ?? 0});
    }
  }

  // â”€â”€ build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_lightGreen, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: _darkGreen),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Báo cáo doanh thu',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _darkGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _loadRevenue(),
                  builder: (context, snapshot) {
                    final loading = snapshot.connectionState ==
                        ConnectionState.waiting;
                    final data = snapshot.data ?? {};
                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildPeriodTabs(),
                          const SizedBox(height: 20),
                          _buildTotalRevenueCard(data, loading),
                          const SizedBox(height: 20),
                          _buildRevenueChart(data, loading),
                          const SizedBox(height: 20),
                          _buildTopCourts(data, loading),
                          const SizedBox(height: 20),
                          _buildRecentTransactions(data, loading),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }

  Widget _buildPeriodTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: List.generate(_periods.length, (index) {
            final isSelected = _selectedPeriod == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPeriod = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    _periods[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? _primary : _onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTotalRevenueCard(
      Map<String, dynamic> data, bool loading) {
    final total = data['total'] as int? ?? 0;
    final count = data['count'] as int? ?? 0;
    final growth = data['growth'] as int?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primary, _darkGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TỔNG DOANH THU',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                loading
                    ? const SizedBox(
                        height: 40,
                        child: LinearProgressIndicator(
                            color: Colors.white70,
                            backgroundColor: Colors.transparent))
                    : Text(
                        _fmtFull(total),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            growth == null
                                ? Icons.receipt_long
                                : (growth >= 0
                                    ? Icons.trending_up
                                    : Icons.trending_down),
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            growth == null
                                ? '$count đơn'
                                : '${growth >= 0 ? '+' : ''}$growth% so với kỳ trước',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (growth != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.receipt_long,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$count đơn',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(
      Map<String, dynamic> data, bool loading) {
    final chartData =
        data['chart'] as List<Map<String, dynamic>>? ?? [];

    final maxVal = chartData.isEmpty
        ? 1
        : chartData
            .map((e) => e['value'] as int)
            .reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biểu đồ doanh thu',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _onSurface,
              ),
            ),
            const SizedBox(height: 20),
            loading
                ? const SizedBox(
                    height: 120,
                    child: Center(
                        child:
                            CircularProgressIndicator(color: _primary)))
                : SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: chartData.map((item) {
                        final val = item['value'] as int;
                        final ratio =
                            maxVal == 0 ? 0.0 : val / maxVal;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (val > 0)
                                  Text(
                                    _fmt(val),
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: _primary,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 4),
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 400),
                                  height: 80 * ratio.toDouble(),
                                  decoration: BoxDecoration(
                                    color: ratio > 0.7
                                        ? _darkGreen
                                        : ratio > 0.3
                                            ? _primary
                                            : _lightGreen,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6)),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['label'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCourts(Map<String, dynamic> data, bool loading) {
    final courts = data['courts']
            as List<MapEntry<String, int>>? ??
        [];
    final total = data['total'] as int? ?? 1;

    final colors = [_primary, _secondary, _tertiary,
        const Color(0xFF7B61FF), const Color(0xFFE91E63)];
    final bgColors = [
      const Color(0xFFE8F5E9),
      const Color(0xFFE0F7FA),
      const Color(0xFFFFF3E0),
      const Color(0xFFF3F0FF),
      const Color(0xFFFCE4EC),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doanh thu theo sân',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (loading)
            const Center(
                child: CircularProgressIndicator(color: _primary))
          else if (courts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Chưa có dữ liệu trong kỳ này',
                  style: TextStyle(
                      color: _onSurfaceVariant.withValues(alpha: 0.7)),
                ),
              ),
            )
          else
            ...courts.take(5).toList().asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final pct = total == 0
                  ? 0.0
                  : (e.value / total).clamp(0.0, 1.0);
              final pctInt = (pct * 100).round();
              final color = colors[i % colors.length];
              final bgColor = bgColors[i % bgColors.length];

              return Padding(
                padding: EdgeInsets.only(
                    bottom: i < courts.length - 1 ? 12 : 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.sports,
                                color: color, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.key,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _onSurface,
                                  ),
                                ),
                                Text(
                                  _fmtFull(e.value),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '$pctInt%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.grey[100],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(
      Map<String, dynamic> data, bool loading) {
    final recent = data['recent']
            as List<Map<String, dynamic>>? ??
        [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Giao dịch gần đây',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _onSurface,
                ),
              ),
              Text(
                '${recent.length} đơn',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (loading)
            const Center(
                child: CircularProgressIndicator(color: _primary))
          else if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Chưa có giao dịch trong kỳ này',
                  style: TextStyle(
                      color: _onSurfaceVariant.withValues(alpha: 0.7)),
                ),
              ),
            )
          else
            ...recent.map((b) {
              final court =
                  b['courtName']?.toString() ?? 'Sân thể thao';
              final sub = b['subCourtName']?.toString() ?? '';
              final title =
                  sub.isNotEmpty ? '$court - $sub' : court;
              final price = _toInt(b['totalPrice']);

              final raw = b['selectedDate'];
              String dateStr = '';
              if (raw is Map) {
                final d = raw['date']?.toString() ?? '';
                final m = raw['month']?.toString() ?? '';
                if (d.isNotEmpty && m.isNotEmpty) dateStr = '$d/$m';
              }
              final ts = b['createdAt'];
              String timeStr = '';
              if (ts is Timestamp) {
                final dt = ts.toDate();
                timeStr =
                    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _lightGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sports,
                            size: 22, color: _primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              [timeStr, dateStr]
                                  .where((s) => s.isNotEmpty)
                                  .join(' • '),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '+${_fmt(price)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: _darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}



