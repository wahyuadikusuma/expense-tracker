import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/view_models/app_view_model.dart';
import 'ui/views/halaman_utama.dart';

void main() {
  // Wajib dipanggil untuk memastikan interaksi native (Isar & path_provider) terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengatur status bar global agar ikon dan teksnya berwarna gelap
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparan
        statusBarIconBrightness: Brightness.dark, // Android (ikon gelap)
        statusBarBrightness: Brightness.light, // iOS (ikon gelap)
      ),
    );

    // Inisialisasi ViewModel tunggal untuk mengatur State & Database Isar
    final appViewModel = AppViewModel();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue.shade700,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      home: HalamanUtama(viewModel: appViewModel),
    );
  }
}
