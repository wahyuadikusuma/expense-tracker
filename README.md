# 📊 Expense Tracker App (Pelacak Keuangan Pribadi)

Aplikasi **Expense Tracker** adalah asisten keuangan pribadi modern yang dirancang untuk membantu pengguna melacak pemasukan, pengeluaran, anggaran bulanan, serta saldo kas/bank secara praktis dan aman. Aplikasi ini dibangun menggunakan **Flutter** dan **Isar Database (NoSQL)** untuk penyimpanan data lokal berkinerja tinggi.

Aplikasi ini dirancang dengan prinsip **Layered Architecture (MVVM)** untuk memastikan kode program modular, bersih, mudah dibaca, serta ramah untuk dikembangkan lebih lanjut.

---

## ✨ Fitur Utama

1. **Dashboard Utama (Halaman Catatan)**
   - Menampilkan total saldo gabungan secara dinamis.
   - Daftar transaksi terakhir yang intuitif dengan indikator warna kategori dan sumber rekening/akun.
   - Fitur ketuk transaksi untuk mengedit nominal, kategori, rekening, maupun tanggal secara langsung (_Tap to Edit_).

2. **Proporsi Kategori & Ringkasan Laporan**
   - **Diagram Donat Kustom (Donut Chart)** yang digambar _native_ di Canvas (`CustomPainter`) untuk visualisasi persentase pengeluaran per kategori secara interaktif.
   - **Navigasi Geser Periode**: Filter periode waktu (Harian, Bulanan, Tahunan) dilengkapi tombol panah kiri-kanan (`chevron_left` & `chevron_right`) untuk menjelajahi riwayat keuangan kemarin dan besok dengan proteksi batas hari ini.

3. **Grafik Tren Batang di Rincian Kategori (Drill-down Chart)**
   - Ketuk kategori pengeluaran apa saja untuk masuk ke halaman rincian.
   - Menampilkan **Bar Chart (Grafik Batang) Vertikal** kustom yang merepresentasikan tren pengeluaran harian, mingguan, maupun bulanan.
   - Cetak nilai nominal mata uang ringkas (contoh: `32rb`, `158.3rb`, `1.5jt`) tepat di atas batang grafik untuk memudahkan pembacaan data.

4. **Multi-Rekening / Sumber Dana Riil**
   - Dukungan pencatatan transaksi terintegrasi ke berbagai dompet digital & rekening bank (misal: BCA, GoPay, Cash).
   - Perhitungan saldo tiap akun berubah secara dinamis setiap kali ada transaksi baru atau modifikasi data.

5. **Balancing Akun (Penyesuaian Saldo)**
   - Menyesuaikan saldo rekening dompet secara instan jika ada ketidakcocokan jumlah uang fisik dengan catatan aplikasi.
   - Sistem otomatis menghitung selisih saldo dan menyimpannya sebagai transaksi khusus berkategori `"Penyesuaian"` (ditandai dengan ikon sync teal).

6. **Anggaran Bulanan (Budget Tracker)**
   - Tentukan batas anggaran pengeluaran bulanan Anda.
   - Dilengkapi indikator sisa limit anggaran dan bar progres visual berwarna dinamis untuk mencegah pemborosan.

---

## 🛠️ Stack Teknologi & Package

- **Flutter SDK**: SDK UI lintas platform.
- **Isar Database**: Database NoSQL lokal super cepat yang dirancang khusus untuk Flutter (menggantikan SQLite/Hive).
- **Path Provider**: Menemukan lokasi folder dokumen aman di perangkat untuk penyimpanan file Isar.
- **Intl**: Memformat tanggal, bulan, hari, serta nominal mata uang Rupiah secara lokal (`id_ID`).
- **Dart UI**: Menggambar diagram donat dan grafik batang menggunakan Canvas kustom native.

---

## 🏗️ Arsitektur Proyek (MVVM)

Struktur folder dibuat secara modular agar memisahkan tanggung jawab logika bisnis, manajemen data, dan antarmuka pengguna:

```text
lib/
├── data/
│   └── services/
│       └── isar_service.dart      # Mengelola inisialisasi Isar & operasi CRUD database
├── domain/
│   └── models/
│       └── transaction.dart       # Model data & Skema Isar untuk entitas Transaksi
├── ui/
│   ├── view_models/
│   │   └── app_view_model.dart    # State Management & Logika Bisnis aplikasi
│   └── views/
│       ├── halaman_akun.dart      # Tampilan visual rekening & Balancing Saldo
│       ├── halaman_anggaran.dart  # Tampilan pelacakan budget limit bulanan
│       ├── halaman_catatan.dart   # Dashboard Home & daftar riwayat transaksi terakhir
│       ├── halaman_detail_kategori.dart # Grafik tren batang & rincian per kategori
│       ├── halaman_ringkasan.dart # Diagram Donat & Navigasi geser periode waktu
│       └── halaman_utama.dart     # Shell Navigasi utama dengan BottomAppBar cekung
└── main.dart                      # Entrypoint utama inisialisasi aplikasi
```

---

## 🚀 Cara Menjalankan Project

Ikuti langkah-langkah berikut untuk menjalankan project di perangkat lokal Anda:

### 1. Prasyarat

- Pastikan Anda sudah menginstal **Flutter SDK** (versi stabil terbaru disarankan).
- Pastikan Emulator Android, Simulator iOS, atau perangkat fisik sudah terhubung.

### 2. Kloning Repositori

```bash
git clone https://github.com/username/expense_tracker.git
cd expense_tracker
```

### 3. Dapatkan Dependensi

Unduh semua paket library yang dibutuhkan:

```bash
flutter pub get
```

### 4. Jalankan Code Generator (Isar Schema)

Isar memerlukan _code generation_ untuk membuat skema database (`transaction.g.dart`). Jalankan perintah berikut:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Jalankan Aplikasi

Jalankan aplikasi ke emulator atau HP Anda:

```bash
flutter run
```

---

## 🔒 Privasi Data & Penyimpanan Lokal

Anda:

```bash
flutter run
```

---

## 🔒 Privasi Data & Penyimpanan Lokal

Semua data keuangan Anda disimpan **100% lokal** di memori internal perangkat Anda melalui database terenkripsi Isar. Data transaksi **tidak akan pernah** diunggah ke internet atau ke repositori GitHub ketika Anda mengunggah kode program ini, sehingga menjamin privasi dan kerahasiaan penuh keuangan Anda.
