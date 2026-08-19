import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'dart:math';
import '../view_models/app_view_model.dart';
import '../../domain/models/transaction.dart';

class HalamanDetailKategori extends StatefulWidget {
  final AppViewModel viewModel;
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;

  const HalamanDetailKategori({
    super.key,
    required this.viewModel,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  State<HalamanDetailKategori> createState() => _HalamanDetailKategoriState();
}

class _HalamanDetailKategoriState extends State<HalamanDetailKategori> {
  String _selectedTimeframe = 'Harian'; // Harian, Mingguan, Bulanan

  @override
  Widget build(BuildContext context) {
    // Ambil semua transaksi kategori ini (khusus Pengeluaran)
    final categoryTxs = widget.viewModel.transactions
        .where((tx) => tx.category == widget.categoryName && tx.isExpense)
        .toList();

    // Urutkan berdasarkan tanggal terbaru
    categoryTxs.sort((a, b) => b.date.compareTo(a.date));

    // Siapkan data tren grafik
    final trendData = _getTrendData(categoryTxs);
    final maxVal = trendData.isNotEmpty ? trendData.map((d) => d.value).reduce(max) : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Rincian Kategori'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card Ringkasan Total
              _buildHeaderCard(categoryTxs),
              const SizedBox(height: 24),

              // Bagian Grafik Tren
              const Text(
                'Tren Pengeluaran',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              // Filter Periode Grafik
              _buildTimeframeSelector(),
              const SizedBox(height: 16),

              // Box Grafik Tren Custom
              _buildTrendChartBox(trendData, maxVal),
              const SizedBox(height: 28),

              // Riwayat Transaksi Terkait
              const Text(
                'Riwayat Transaksi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),

              _buildTransactionList(categoryTxs),
            ],
          ),
        ),
      ),
    );
  }

  // Menghitung data tren harian/mingguan/bulanan
  List<TrendPoint> _getTrendData(List<Transaction> txs) {
    final now = DateTime.now();
    final points = <TrendPoint>[];

    if (_selectedTimeframe == 'Harian') {
      // 7 Hari Terakhir
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final total = txs.where((tx) {
          final localTxDate = tx.date.toLocal();
          return localTxDate.day == date.day &&
              localTxDate.month == date.month &&
              localTxDate.year == date.year;
        }).fold(0.0, (sum, tx) => sum + tx.amount);

        final rawDay = DateFormat('E').format(date);
        final label = _translateDay(rawDay);
        points.add(TrendPoint(label, total));
      }
    } else if (_selectedTimeframe == 'Mingguan') {
      // 4 Minggu Terakhir
      for (int i = 3; i >= 0; i--) {
        final dateStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: (i + 1) * 7 - 1));
        final dateEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).subtract(Duration(days: i * 7));

        final total = txs.where((tx) {
          final localTxDate = tx.date.toLocal();
          return !localTxDate.isBefore(dateStart) && !localTxDate.isAfter(dateEnd);
        }).fold(0.0, (sum, tx) => sum + tx.amount);

        points.add(TrendPoint('Mng ${4 - i}', total));
      }
    } else {
      // 6 Bulan Terakhir
      for (int i = 5; i >= 0; i--) {
        int year = now.year;
        int month = now.month - i;
        if (month <= 0) {
          month += 12;
          year -= 1;
        }

        final total = txs.where((tx) {
          final localTxDate = tx.date.toLocal();
          return localTxDate.month == month && localTxDate.year == year;
        }).fold(0.0, (sum, tx) => sum + tx.amount);

        final dummyDate = DateTime(year, month, 1);
        final label = DateFormat('MMM').format(dummyDate);
        points.add(TrendPoint(label, total));
      }
    }
    return points;
  }

  String _translateDay(String englishDay) {
    switch (englishDay) {
      case 'Mon': return 'Sen';
      case 'Tue': return 'Sel';
      case 'Wed': return 'Rab';
      case 'Thu': return 'Kam';
      case 'Fri': return 'Jum';
      case 'Sat': return 'Sab';
      case 'Sun': return 'Min';
      default: return englishDay;
    }
  }

  String _formatRupiah(double val) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(val);
  }

  Widget _buildHeaderCard(List<Transaction> txs) {
    final total = txs.fold(0.0, (sum, tx) => sum + tx.amount);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.categoryColor,
            widget.categoryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.categoryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Icon(widget.categoryIcon, color: Colors.white),
              ),
              Text(
                '${txs.length} Transaksi',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Total Pengeluaran Kategori',
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            _formatRupiah(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ['Harian', 'Mingguan', 'Bulanan'].map((timeframe) {
          final isSelected = _selectedTimeframe == timeframe;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeframe = timeframe;
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
                    timeframe,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? widget.categoryColor : Colors.grey.shade600,
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

  Widget _buildTrendChartBox(List<TrendPoint> trendData, double maxVal) {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: trendData.isEmpty || maxVal == 0
          ? const Center(
              child: Text(
                'Belum ada transaksi di periode ini',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: TrendChartPainter(
                      points: trendData,
                      color: widget.categoryColor,
                      maxValue: maxVal,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: trendData.map((d) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          d.label,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  Widget _buildTransactionList(List<Transaction> txs) {
    if (txs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text('Tidak ada transaksi', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: txs.length,
      itemBuilder: (context, index) {
        final tx = txs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: widget.categoryColor.withValues(alpha: 0.1),
              child: Icon(widget.categoryIcon, color: widget.categoryColor),
            ),
            title: Text(
              tx.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              '${tx.account} • ${DateFormat('dd MMM yyyy').format(tx.date)}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            trailing: Text(
              _formatRupiah(tx.amount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }
}

// Data point untuk penampung nilai trend
class TrendPoint {
  final String label;
  final double value;
  TrendPoint(this.label, this.value);
}

// Painter grafik garis melengkung custom native
// Painter Grafik Batang Kustom yang super bersih dan mudah dibaca
class TrendChartPainter extends CustomPainter {
  final List<TrendPoint> points;
  final Color color;
  final double maxValue;

  TrendChartPainter({
    required this.points,
    required this.color,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final numBars = points.length;

    // Hitung jarak (spacing) antar batang
    final stepWidth = width / numBars;
    // Ketebalan batang (45% dari stepWidth agar proporsional)
    final barWidth = stepWidth * 0.45;

    // Paint untuk Grid Line horizontal
    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Gambar grid horizontal (3 baris)
    for (int i = 0; i <= 3; i++) {
      final y = height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Paint untuk batang dengan gradien vertikal
    for (int i = 0; i < numBars; i++) {
      final val = points[i].value;
      if (val == 0) continue; // Jangan gambar batang jika nilainya nol

      // Posisikan x di tengah stepWidth
      final x = (i * stepWidth) + (stepWidth - barWidth) / 2;

      // Hitung tinggi batang (sisakan 15% padding atas untuk teks nominal)
      final barHeight = maxValue == 0
          ? 0.0
          : (val / maxValue) * (height * 0.75);

      final y = height - barHeight;

      // Definisikan area persegi batang dengan sudut membulat di atas (RRect)
      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero,
      );

      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            color.withValues(alpha: 0.3),
          ],
        ).createShader(rect);

      // Gambar batang
      canvas.drawRRect(rrect, barPaint);

      // --- CETAK TEKS NOMINAL DI ATAS BATANG ---
      final textSpan = TextSpan(
        text: _formatShortAmount(val),
        style: TextStyle(
          color: color.withValues(alpha: 0.95),
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      );

      textPainter.layout();
      // Posisikan teks tepat di tengah atas batang
      final textX = x + (barWidth - textPainter.width) / 2;
      final textY = y - textPainter.height - 4; // Beri sedikit jarak di atas batang

      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  // Singkatan nominal uang (contoh: 35.000 menjadi 35rb, 1.500.000 menjadi 1.5jt)
  String _formatShortAmount(double value) {
    if (value >= 1000000) {
      double val = value / 1000000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}jt';
    } else if (value >= 1000) {
      double val = value / 1000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}rb';
    } else if (value > 0) {
      return value.toStringAsFixed(0);
    }
    return '';
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
