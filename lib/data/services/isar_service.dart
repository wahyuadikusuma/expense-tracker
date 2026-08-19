import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/models/transaction.dart';

class IsarService {
  Isar? _isar;

  // Mendapatkan instance Isar yang aktif atau membukanya jika belum ada
  Future<Isar> get db async {
    if (_isar != null) return _isar!;
    _isar = await _openDB();
    return _isar!;
  }

  // Fungsi internal untuk membuka koneksi ke Isar Database
  Future<Isar> _openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    
    // Cek jika sudah ada instance Isar yang terbuka dengan nama 'default'
    final existingIsar = Isar.getInstance();
    if (existingIsar != null) return existingIsar;

    return await Isar.open(
      [TransactionSchema],
      directory: dir.path,
    );
  }

  // --- OPERASI CRUD ---

  // Ambil semua transaksi, urutkan dari tanggal terbaru ke terlama
  Future<List<Transaction>> getTransactions() async {
    final isar = await db;
    return await isar.transactions.where().sortByDateDesc().findAll();
  }

  // Tambah atau perbarui data transaksi
  Future<void> addTransaction(Transaction transaction) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.transactions.put(transaction);
    });
  }

  // Hapus transaksi berdasarkan ID
  Future<void> deleteTransaction(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.transactions.delete(id);
    });
  }

  // Bersihkan semua data transaksi (jika diperlukan)
  Future<void> clearAll() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.transactions.clear();
    });
  }
}
