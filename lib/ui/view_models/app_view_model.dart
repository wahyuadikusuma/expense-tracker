import 'package:flutter/material.dart';
import '../../data/services/isar_service.dart';
import '../../domain/models/transaction.dart';

class AppViewModel extends ChangeNotifier {
  final IsarService _isarService = IsarService();

  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  AppViewModel() {
    loadTransactions();
  }

  // --- MEMUAT DATA ---
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _isarService.getTransactions();

      // Jika database masih kosong, isi dengan data tiruan (mock data) untuk demo pertama
      if (_transactions.isEmpty) {
        final now = DateTime.now();
        final mockData = [
          Transaction()
            ..title = 'Gaji Bulanan'
            ..amount = 5000000
            ..category = 'Pendapatan'
            ..date = now.subtract(const Duration(days: 5))
            ..isExpense = false
            ..account = 'BCA',
          Transaction()
            ..title = 'Makan Siang Bakso'
            ..amount = 35000
            ..category = 'Makanan'
            ..date = now
            ..isExpense = true
            ..account = 'Cash',
          Transaction()
            ..title = 'Grab Car ke Kantor'
            ..amount = 45000
            ..category = 'Transportasi'
            ..date = now
            ..isExpense = true
            ..account = 'GoPay',
          Transaction()
            ..title = 'Beli Kemeja Baru'
            ..amount = 150000
            ..category = 'Belanja'
            ..date = now.subtract(const Duration(days: 1))
            ..isExpense = true
            ..account = 'BCA',
          Transaction()
            ..title = 'Langganan Wi-Fi'
            ..amount = 350000
            ..category = 'Tagihan'
            ..date = now.subtract(const Duration(days: 4))
            ..isExpense = true
            ..account = 'BCA',
        ];

        for (final tx in mockData) {
          await _isarService.addTransaction(tx);
        }

        // Ambil kembali data setelah diisi
        _transactions = await _isarService.getTransactions();
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- OPERASI CRUD ---
  
  // Menambah atau mengedit transaksi
  Future<void> tambahTransaksi({
    int? id,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required bool isExpense,
    required String account,
  }) async {
    final tx = Transaction()
      ..title = title
      ..amount = amount
      ..category = category
      ..date = date
      ..isExpense = isExpense
      ..account = account;

    if (id != null) {
      tx.id = id;
    }

    await _isarService.addTransaction(tx);
    await loadTransactions(); // Refresh data dari DB
  }

  // Menghapus transaksi
  Future<void> hapusTransaksi(int id) async {
    await _isarService.deleteTransaction(id);
    await loadTransactions(); // Refresh data dari DB
  }

  // --- KALKULASI & GETTER DATA UNTUK UI ---

  // Saldo BCA (Awal: Rp 5.000.000)
  double get bcaBalance {
    double balance = 5000000.0;
    for (final tx in _transactions) {
      if (tx.account == 'BCA') {
        if (tx.isExpense) {
          balance -= tx.amount;
        } else {
          balance += tx.amount;
        }
      }
    }
    return balance;
  }

  // Saldo GoPay (Awal: Rp 500.000)
  double get gopayBalance {
    double balance = 500000.0;
    for (final tx in _transactions) {
      if (tx.account == 'GoPay') {
        if (tx.isExpense) {
          balance -= tx.amount;
        } else {
          balance += tx.amount;
        }
      }
    }
    return balance;
  }

  // Saldo Cash/Tunai (Awal: Rp 300.000)
  double get cashBalance {
    double balance = 300000.0;
    for (final tx in _transactions) {
      if (tx.account == 'Cash') {
        if (tx.isExpense) {
          balance -= tx.amount;
        } else {
          balance += tx.amount;
        }
      }
    }
    return balance;
  }

  // Total Saldo Aktif keseluruhan
  double get totalSaldoAktif => bcaBalance + gopayBalance + cashBalance;

  // Total pengeluaran (isExpense = true)
  double get totalPengeluaran {
    return _transactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Total pemasukan (isExpense = false)
  double get totalPemasukan {
    return _transactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Total pengeluaran bulan ini (bulan berjalan)
  double get pengeluaranBulanIni {
    final now = DateTime.now();
    return _transactions
        .where((tx) => tx.isExpense && tx.date.month == now.month && tx.date.year == now.year)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Total pemasukan bulan ini (bulan berjalan)
  double get pemasukanBulanIni {
    final now = DateTime.now();
    return _transactions
        .where((tx) => !tx.isExpense && tx.date.month == now.month && tx.date.year == now.year)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Total Nominal per Kategori
  Map<String, double> get categoryTotals {
    final totals = {
      'Makanan': 0.0,
      'Belanja': 0.0,
      'Transportasi': 0.0,
      'Tagihan': 0.0,
    };

    for (final tx in _transactions) {
      if (tx.isExpense && totals.containsKey(tx.category)) {
        totals[tx.category] = totals[tx.category]! + tx.amount;
      }
    }

    return totals;
  }

  // Persentase per Kategori (0.0 - 1.0) untuk Progress Bar
  double getCategoryPercentage(String category) {
    final total = totalPengeluaran;
    if (total == 0) return 0.0;
    
    final categoryAmount = categoryTotals[category] ?? 0.0;
    return categoryAmount / total;
  }

  // Total pengeluaran per hari dalam 7 hari terakhir (Senin-Minggu)
  List<double> get weeklyDayTotals {
    final totals = List<double>.filled(7, 0.0);
    
    for (final tx in _transactions) {
      if (tx.isExpense) {
        // Ambil indeks hari (1 = Senin, 7 = Minggu di Dart)
        final weekday = tx.date.weekday;
        totals[weekday - 1] += tx.amount;
      }
    }
    return totals;
  }

  // Persentase tinggi grafik batang (0.0 - 1.0) untuk hari tertentu
  double getDayPercentage(int weekdayIndex) {
    final totals = weeklyDayTotals;
    final maxExpense = totals.reduce((curr, next) => curr > next ? curr : next);
    if (maxExpense == 0) return 0.0;
    
    return totals[weekdayIndex] / maxExpense;
  }
}
