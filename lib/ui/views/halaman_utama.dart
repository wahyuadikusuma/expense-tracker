import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../view_models/app_view_model.dart';
import '../../domain/models/transaction.dart';
import 'halaman_catatan.dart';
import 'halaman_ringkasan.dart';
import 'halaman_anggaran.dart';
import 'halaman_akun.dart';

class HalamanUtama extends StatefulWidget {
  final AppViewModel viewModel;

  const HalamanUtama({super.key, required this.viewModel});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi memunculkan Bottom Sheet input transaksi dengan Pilihan Kategori & Tipe (Mendukung Edit & Input Pemasukan/Pengeluaran dinamis)
  void _showAddTransactionBottomSheet(BuildContext context, {Transaction? existingTx}) {
    String selectedCategory = existingTx?.category ?? 'Makanan';
    bool isExpense = existingTx?.isExpense ?? true;
    String selectedAccount = existingTx?.account ?? 'Cash';
    final titleController = TextEditingController(text: existingTx?.title);
    final amountController = TextEditingController(
      text: existingTx != null
          ? NumberFormat.decimalPattern('id').format(existingTx.amount)
          : '',
    );
    DateTime selectedDate = existingTx?.date ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    existingTx != null ? 'Edit Transaksi' : 'Tambah Transaksi',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pilihan Tipe Transaksi (Pengeluaran / Pemasukan)
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Pengeluaran'),
                        selected: isExpense,
                        selectedColor: Colors.red.shade100,
                        labelStyle: TextStyle(
                          color: isExpense ? Colors.red.shade800 : Colors.black87,
                          fontWeight: isExpense ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              isExpense = true;
                              selectedCategory = 'Makanan'; // Reset ke default pengeluaran
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Pemasukan'),
                        selected: !isExpense,
                        selectedColor: Colors.green.shade100,
                        labelStyle: TextStyle(
                          color: !isExpense ? Colors.green.shade800 : Colors.black87,
                          fontWeight: !isExpense ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              isExpense = false;
                              selectedCategory = 'Pendapatan';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Input Nama Transaksi
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: isExpense ? 'Nama Pengeluaran' : 'Nama Pemasukan',
                      hintText: isExpense ? 'Misal: Makan Siang Bakso' : 'Misal: Gaji Bulanan',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Input Nominal Uang
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [RibuanInputFormatter()],
                    decoration: InputDecoration(
                      labelText: 'Nominal (Rp)',
                      hintText: '0',
                      prefixText: 'Rp ',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pilihan Tanggal Transaksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tanggal Transaksi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today_rounded, size: 18),
                        label: Text(
                          DateFormat('dd MMM yyyy').format(selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (pickedDate != null) {
                            setModalState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Label Sumber Dana
                  const Text(
                    'Sumber Dana',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Pilihan Sumber Dana dengan Choice Chips
                  Row(
                    children: ['BCA', 'GoPay', 'Cash'].map((acc) {
                      final isSelected = selectedAccount == acc;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(acc),
                          selected: isSelected,
                          selectedColor: Colors.blue.shade100,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blue.shade800 : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (bool selected) {
                            if (selected) {
                              setModalState(() {
                                selectedAccount = acc;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  if (isExpense) ...[
                    // Label Kategori
                    const Text(
                      'Pilih Kategori',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Pilihan Kategori dengan Choice Chips
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: ['Makanan', 'Belanja', 'Transportasi', 'Tagihan'].map((category) {
                        final isSelected = selectedCategory == category;
                        return ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: Colors.blue.shade100,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blue.shade800 : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (bool selected) {
                            if (selected) {
                              setModalState(() {
                                selectedCategory = category;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                  ],
                  
                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        // Hapus pemisah ribuan titik (.) sebelum diparse
                        final cleanAmountText = amountController.text.replaceAll('.', '');
                        final amount = double.tryParse(cleanAmountText) ?? 0.0;
                        
                        if (title.isNotEmpty && amount > 0) {
                          widget.viewModel.tambahTransaksi(
                            id: existingTx?.id, // Gunakan ID transaksi lama jika dalam mode edit
                            title: title,
                            amount: amount,
                            category: selectedCategory,
                            date: selectedDate,
                            isExpense: isExpense,
                            account: selectedAccount,
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mohon isi semua data dengan benar!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        existingTx != null ? 'Perbarui Transaksi' : 'Simpan Transaksi',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper untuk membuat item navigasi bawah dengan ikon + teks keterangan
  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? Colors.blue.shade700 : Colors.grey.shade400;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> halaman = [
      HalamanCatatan(
        viewModel: widget.viewModel,
        onEditTransaction: (tx) {
          _showAddTransactionBottomSheet(context, existingTx: tx);
        },
      ),
      HalamanRingkasan(viewModel: widget.viewModel),
      HalamanAnggaran(viewModel: widget.viewModel),
      HalamanAkun(viewModel: widget.viewModel),
    ];

    return Scaffold(
      // AppBar dinamis: null untuk Home (0), dan tampilkan AppBar untuk halaman lainnya
      appBar: _selectedIndex == 0
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.widgets_rounded),
                tooltip: 'Menu Utama',
                onPressed: () {
                  // TODO: Tampilkan Sidebar
                },
              ),
              title: Text(
                _selectedIndex == 1
                    ? 'Ringkasan Laporan'
                    : _selectedIndex == 2
                        ? 'Anggaran'
                        : 'Akun & Dompet',
              ),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
            ),

      // Body halaman aktif
      body: halaman[_selectedIndex],

      // --- FLOATING ACTION BUTTON (Tombol Tambah Tengah) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionBottomSheet(context);
        },
        shape: const CircleBorder(), // Membuat bulat sempurna
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      // Letak FAB pas di tengah menempel pada BottomAppBar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- BOTTOM NAVIGATION BAR DENGAN CEKUNGAN & KETERANGAN ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Membuat cekungan melingkar
        notchMargin: 8.0, // Jarak/ruang antara cekungan dengan tombol FAB
        color: Colors.white,
        elevation: 8,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.receipt_long_rounded, 'Catatan'),
              _buildBottomNavItem(1, Icons.pie_chart_rounded, 'Ringkasan'),
              const SizedBox(width: 40), // Ruang kosong untuk FAB di tengah
              _buildBottomNavItem(2, Icons.savings_rounded, 'Anggaran'),
              _buildBottomNavItem(3, Icons.credit_card_rounded, 'Akun'),
            ],
          ),
        ),
      ),
    );
  }
}

// Formatter kustom untuk memformat input angka menjadi format ribuan Indonesia (contoh: 1.500.000)
class RibuanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Bersihkan semua karakter selain angka
    final cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final numValue = double.tryParse(cleanText) ?? 0.0;

    // Format angka ke pecahan ribuan Indonesia
    final formatter = NumberFormat.decimalPattern('id');
    final formattedText = formatter.format(numValue);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
