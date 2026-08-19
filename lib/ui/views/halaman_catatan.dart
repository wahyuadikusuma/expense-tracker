import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Digunakan untuk memformat tanggal & nominal uang jika diperlukan
import '../view_models/app_view_model.dart';
import '../../domain/models/transaction.dart';

class HalamanCatatan extends StatelessWidget {
  final AppViewModel viewModel;
  final Function(Transaction) onEditTransaction;

  const HalamanCatatan({
    super.key,
    required this.viewModel,
    required this.onEditTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final transactions = viewModel.transactions;

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. HEADER (Hello, Wahyu & Profil) ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.widgets_rounded, color: Colors.blue.shade700, size: 26),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          // TODO: Tampilkan Sidebar
                        },
                        tooltip: 'Menu Utama',
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Hello,',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Wahyu',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.person,
                          color: Colors.blue.shade800,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- 2. CARD DASHBOARD SALDO (INFORMASI OVERVIEW UTAMA) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Saldo Aktif',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatRupiah(viewModel.totalSaldoAktif),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Pemasukan
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_downward_rounded, color: Colors.greenAccent, size: 18),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Pemasukan Bulan Ini', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatRupiah(viewModel.pemasukanBulanIni),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            // Pengeluaran
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_upward_rounded, color: Colors.redAccent, size: 18),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Pengeluaran Bulan Ini', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatRupiah(viewModel.pengeluaranBulanIni),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),



                // --- 3. DAFTAR TRANSAKSI TERAKHIR ---
                const Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 24.0, bottom: 12.0),
                  child: Text(
                    'Transaksi Terakhir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                transactions.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text('Belum ada transaksi.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            return _buildTransactionItem(context, tx);
                          },
                        ),
                      ),
                const SizedBox(height: 100), // Spasi agar tidak tertimbun BottomAppBar
              ],
            ),
          ),
        );
      },
    );
  }

  // Format angka double ke Rupiah
  String _formatRupiah(double val) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(val);
  }

  // Format tanggal ke tulisan manusiawi
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'Hari ini';
    }
    if (date.day == now.subtract(const Duration(days: 1)).day && date.month == now.month && date.year == now.year) {
      return 'Kemarin';
    }
    return DateFormat('dd MMM').format(date);
  }

  // Ikon & warna dinamis sesuai kategori
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan':
        return Icons.fastfood_rounded;
      case 'Transportasi':
        return Icons.directions_car_rounded;
      case 'Belanja':
        return Icons.shopping_bag_rounded;
      case 'Tagihan':
        return Icons.wifi_rounded;
      case 'Pendapatan':
        return Icons.payments_rounded;
      case 'Penyesuaian':
        return Icons.sync_alt_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Makanan':
        return Colors.orange;
      case 'Transportasi':
        return Colors.blue;
      case 'Belanja':
        return Colors.purple;
      case 'Tagihan':
        return Colors.red;
      case 'Pendapatan':
        return Colors.green;
      case 'Penyesuaian':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }



  // Widget List Item Transaksi
  Widget _buildTransactionItem(BuildContext context, Transaction tx) {
    final color = _getCategoryColor(tx.category);
    final icon = _getCategoryIcon(tx.category);

    return GestureDetector(
      onTap: () => onEditTransaction(tx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tx.category} • ${tx.account} • ${_formatDate(tx.date)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${tx.isExpense ? "-" : "+"} ${_formatRupiah(tx.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: tx.isExpense ? Colors.redAccent : Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          // Tombol Hapus Transaksi (Action untuk mendemokan delete data lokal)
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.grey.shade400, size: 20),
            onPressed: () {
              // Dialog konfirmasi hapus
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Transaksi'),
                  content: Text('Apakah Anda yakin ingin menghapus "${tx.title}"?'),
                  actions: [
                    TextButton(
                      child: const Text('Batal'),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    TextButton(
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        viewModel.hapusTransaksi(tx.id);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
}


