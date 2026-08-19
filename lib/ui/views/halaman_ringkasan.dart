import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../view_models/app_view_model.dart';
import '../../domain/models/transaction.dart';
import 'halaman_detail_kategori.dart';

class HalamanRingkasan extends StatefulWidget {
  final AppViewModel viewModel;

  const HalamanRingkasan({super.key, required this.viewModel});

  @override
  State<HalamanRingkasan> createState() => _HalamanRingkasanState();
}

class _HalamanRingkasanState extends State<HalamanRingkasan> {
  String _selectedPeriod = 'Bulanan'; // Harian, Bulanan, Tahunan
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        List<Transaction> filteredTxs;

        // Filter transaksi berdasarkan Periode & Tanggal Fokus
        if (_selectedPeriod == 'Harian') {
          filteredTxs = widget.viewModel.transactions.where((tx) {
            final localTxDate = tx.date.toLocal();
            return localTxDate.day == _focusedDate.day &&
                localTxDate.month == _focusedDate.month &&
                localTxDate.year == _focusedDate.year;
          }).toList();
        } else if (_selectedPeriod == 'Bulanan') {
          filteredTxs = widget.viewModel.transactions.where((tx) {
            final localTxDate = tx.date.toLocal();
            return localTxDate.month == _focusedDate.month &&
                localTxDate.year == _focusedDate.year;
          }).toList();
        } else {
          filteredTxs = widget.viewModel.transactions.where((tx) {
            final localTxDate = tx.date.toLocal();
            return localTxDate.year == _focusedDate.year;
          }).toList();
        }

        // Total pengeluaran (khusus isExpense = true)
        final totalExpense = filteredTxs
            .where((tx) => tx.isExpense)
            .fold(0.0, (sum, tx) => sum + tx.amount);

        // Kategori total kalkulasi pengeluaran
        final totals = {
          'Makanan': 0.0,
          'Belanja': 0.0,
          'Transportasi': 0.0,
          'Tagihan': 0.0,
        };

        for (final tx in filteredTxs) {
          if (tx.isExpense && totals.containsKey(tx.category)) {
            totals[tx.category] = totals[tx.category]! + tx.amount;
          }
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                // Tab Filter Periode
                _buildPeriodFilter(),
                const SizedBox(height: 16),

                // Navigator Periode (Panah Kiri / Kanan & Tanggal/Bulan/Tahun Fokus)
                _buildPeriodNavigator(),
                const SizedBox(height: 24),

                // Card Pie/Donut Chart (Hasil Filter Periode Terpilih)
                _buildDonutChartCard(totals),
                const SizedBox(height: 24),

                // Judul List Kategori
                const Text(
                  'Rincian Pengeluaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // List Kategori yang bisa di-Tap
                _buildCategoryOverviewItem(
                  context: context,
                  categoryKey: 'Makanan',
                  icon: Icons.fastfood_rounded,
                  color: Colors.orange,
                  name: 'Makanan & Minuman',
                  amount: _formatRupiah(totals['Makanan'] ?? 0.0),
                  percentage: totalExpense == 0 ? 0.0 : (totals['Makanan'] ?? 0.0) / totalExpense,
                ),
                _buildCategoryOverviewItem(
                  context: context,
                  categoryKey: 'Belanja',
                  icon: Icons.shopping_bag_rounded,
                  color: Colors.purple,
                  name: 'Belanja',
                  amount: _formatRupiah(totals['Belanja'] ?? 0.0),
                  percentage: totalExpense == 0 ? 0.0 : (totals['Belanja'] ?? 0.0) / totalExpense,
                ),
                _buildCategoryOverviewItem(
                  context: context,
                  categoryKey: 'Transportasi',
                  icon: Icons.directions_car_rounded,
                  color: Colors.blue,
                  name: 'Transportasi',
                  amount: _formatRupiah(totals['Transportasi'] ?? 0.0),
                  percentage: totalExpense == 0 ? 0.0 : (totals['Transportasi'] ?? 0.0) / totalExpense,
                ),
                _buildCategoryOverviewItem(
                  context: context,
                  categoryKey: 'Tagihan',
                  icon: Icons.wifi_rounded,
                  color: Colors.red,
                  name: 'Tagihan & Listrik',
                  amount: _formatRupiah(totals['Tagihan'] ?? 0.0),
                  percentage: totalExpense == 0 ? 0.0 : (totals['Tagihan'] ?? 0.0) / totalExpense,
                ),
                const SizedBox(height: 80), // Menghindari ketutup bottom bar
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatRupiah(double val) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(val);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Makanan': return Colors.orange;
      case 'Transportasi': return Colors.blue;
      case 'Belanja': return Colors.purple;
      case 'Tagihan': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildPeriodFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ['Harian', 'Bulanan', 'Tahunan'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                  _focusedDate = DateTime.now(); // Reset ke hari ini saat ganti tipe filter
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue.shade800 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Bar Navigasi untuk mengganti Tanggal/Bulan/Tahun Fokus
  Widget _buildPeriodNavigator() {
    final canGoNext = _canGoForward();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => _shiftPeriod(-1),
        ),
        Text(
          _getPeriodLabel(),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right_rounded,
            size: 28,
            color: canGoNext ? Colors.black87 : Colors.grey.shade300,
          ),
          onPressed: canGoNext ? () => _shiftPeriod(1) : null,
        ),
      ],
    );
  }

  void _shiftPeriod(int offset) {
    setState(() {
      if (_selectedPeriod == 'Harian') {
        _focusedDate = _focusedDate.add(Duration(days: offset));
      } else if (_selectedPeriod == 'Bulanan') {
        int nextMonth = _focusedDate.month + offset;
        int nextYear = _focusedDate.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear += 1;
        } else if (nextMonth < 1) {
          nextMonth = 12;
          nextYear -= 1;
        }
        _focusedDate = DateTime(nextYear, nextMonth, 1);
      } else {
        _focusedDate = DateTime(_focusedDate.year + offset, _focusedDate.month, 1);
      }
    });
  }

  bool _canGoForward() {
    final now = DateTime.now();
    if (_selectedPeriod == 'Harian') {
      return _focusedDate.isBefore(DateTime(now.year, now.month, now.day));
    } else if (_selectedPeriod == 'Bulanan') {
      return _focusedDate.year < now.year || (_focusedDate.year == now.year && _focusedDate.month < now.month);
    } else {
      return _focusedDate.year < now.year;
    }
  }

  String _getPeriodLabel() {
    final now = DateTime.now();
    if (_selectedPeriod == 'Harian') {
      final formattedDate = DateFormat('dd MMM yyyy').format(_focusedDate);
      if (_focusedDate.day == now.day && _focusedDate.month == now.month && _focusedDate.year == now.year) {
        return 'Hari Ini ($formattedDate)';
      }
      final yesterday = now.subtract(const Duration(days: 1));
      if (_focusedDate.day == yesterday.day && _focusedDate.month == yesterday.month && _focusedDate.year == yesterday.year) {
        return 'Kemarin ($formattedDate)';
      }
      final rawDay = DateFormat('EEEE').format(_focusedDate);
      final dayStr = _translateFullDay(rawDay);
      return '$dayStr, $formattedDate';
    } else if (_selectedPeriod == 'Bulanan') {
      final rawMonth = DateFormat('MMMM').format(_focusedDate);
      final monthStr = _translateFullMonth(rawMonth);
      return '$monthStr ${DateFormat('yyyy').format(_focusedDate)}';
    } else {
      return DateFormat('yyyy').format(_focusedDate);
    }
  }

  String _translateFullDay(String day) {
    switch (day) {
      case 'Monday': return 'Senin';
      case 'Tuesday': return 'Selasa';
      case 'Wednesday': return 'Rabu';
      case 'Thursday': return 'Kamis';
      case 'Friday': return 'Jumat';
      case 'Saturday': return 'Sabtu';
      case 'Sunday': return 'Minggu';
      default: return day;
    }
  }

  String _translateFullMonth(String month) {
    switch (month) {
      case 'January': return 'Januari';
      case 'February': return 'Februari';
      case 'March': return 'Maret';
      case 'April': return 'April';
      case 'May': return 'Mei';
      case 'June': return 'Juni';
      case 'July': return 'Juli';
      case 'August': return 'Agustus';
      case 'September': return 'September';
      case 'October': return 'Oktober';
      case 'November': return 'November';
      case 'December': return 'Desember';
      default: return month;
    }
  }

  // Card Box untuk visualisasi Donut Chart
  Widget _buildDonutChartCard(Map<String, double> totals) {
    final total = totals.values.fold(0.0, (sum, val) => sum + val);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proporsi Pengeluaran',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildDonutChart(totals, total),
        ],
      ),
    );
  }

  Widget _buildDonutChart(Map<String, double> categoryTotals, double total) {
    if (total == 0) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'Tidak ada pengeluaran di periode ini',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

    return Row(
      children: [
        // Donut Chart Painter
        SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: DonutChartPainter(
              categoryTotals: categoryTotals,
              getCategoryColor: _getCategoryColor,
              total: total,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Legend Keterangan
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: categoryTotals.keys.map((cat) {
              final val = categoryTotals[cat] ?? 0.0;
              final pct = total > 0 ? (val / total * 100) : 0.0;
              if (val == 0) return const SizedBox.shrink(); // Sembunyikan kategori kosong

              final color = _getCategoryColor(cat);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$cat (${pct.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Widget Pembuat Baris Kategori Ringkasan yang bisa di-tap
  Widget _buildCategoryOverviewItem({
    required BuildContext context,
    required String categoryKey,
    required IconData icon,
    required Color color,
    required String name,
    required String amount,
    required double percentage,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HalamanDetailKategori(
              viewModel: widget.viewModel,
              categoryName: categoryKey,
              categoryColor: color,
              categoryIcon: icon,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Ketuk untuk detail tren ➔',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '${(percentage * 100).toStringAsFixed(0)}%',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade100,
                color: color,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter Kustom untuk menggambar Donut Chart secara native di Canvas
class DonutChartPainter extends CustomPainter {
  final Map<String, double> categoryTotals;
  final Color Function(String category) getCategoryColor;
  final double total;

  DonutChartPainter({
    required this.categoryTotals,
    required this.getCategoryColor,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    // Stroke width untuk ketebalan donut (35% dari radius)
    final strokeWidth = radius * 0.35;
    final paintRadius = radius - (strokeWidth / 2);

    final rect = Rect.fromCircle(center: center, radius: paintRadius);
    double startAngle = -pi / 2; // Mulai dari posisi jam 12 atas

    for (final cat in categoryTotals.keys) {
      final value = categoryTotals[cat] ?? 0.0;
      if (value == 0) continue;

      final sweepAngle = (value / total) * 2 * pi;
      final paint = Paint()
        ..color = getCategoryColor(cat)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt; // Irisan lingkaran rata

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
