import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../view_models/app_view_model.dart';

class HalamanAnggaran extends StatelessWidget {
  final AppViewModel viewModel;

  const HalamanAnggaran({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    const double totalLimitBulanan = 3000000.0; // Limit anggaran bulanan global

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final totalTerpakai = viewModel.totalPengeluaran;
        final sisaAnggaran = totalLimitBulanan - totalTerpakai;
        final percentage = (totalTerpakai / totalLimitBulanan).clamp(0.0, 1.0);
        final totals = viewModel.categoryTotals;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Limit Anggaran Bulanan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Card Anggaran Utama
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Limit Anggaran',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatRupiah(totalLimitBulanan),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Terpakai', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatRupiah(totalTerpakai)} (${(percentage * 100).toStringAsFixed(0)}%)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Sisa Anggaran', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                _formatRupiah(sisaAnggaran),
                                style: TextStyle(
                                  color: sisaAnggaran < 0 ? Colors.redAccent : Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.white24,
                          color: sisaAnggaran < 0 ? Colors.redAccent : Colors.greenAccent,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                const Text(
                  'Anggaran Per Kategori',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                _buildBudgetCategoryItem(
                  'Makanan & Minuman',
                  totals['Makanan'] ?? 0.0,
                  1000000.0,
                  Colors.orange,
                ),
                _buildBudgetCategoryItem(
                  'Belanja Bulanan',
                  totals['Belanja'] ?? 0.0,
                  800000.0,
                  Colors.purple,
                ),
                _buildBudgetCategoryItem(
                  'Transportasi Harian',
                  totals['Transportasi'] ?? 0.0,
                  500000.0,
                  Colors.blue,
                ),
                const SizedBox(height: 80),
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

  // Widget Pembuat Baris Kategori Anggaran
  Widget _buildBudgetCategoryItem(String title, double current, double limit, Color color) {
    final progress = (current / limit).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                '${_formatRupiah(current)} / ${_formatRupiah(limit)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              color: current > limit ? Colors.redAccent : color,
              backgroundColor: Colors.grey.shade100,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
