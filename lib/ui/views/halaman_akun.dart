import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../view_models/app_view_model.dart';

class HalamanAkun extends StatelessWidget {
  final AppViewModel viewModel;

  const HalamanAkun({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final bcaBalance = viewModel.bcaBalance;
        final gopayBalance = viewModel.gopayBalance;
        final cashBalance = viewModel.cashBalance;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dompet & Rekening',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildAccountCard(
                  'BCA',
                  'Tabungan Utama',
                  _formatRupiah(bcaBalance),
                  '•••• 8821',
                  Colors.blue.shade800,
                  Icons.account_balance,
                  () => _showAdjustBalanceDialog(context, 'BCA', bcaBalance),
                ),
                _buildAccountCard(
                  'GoPay',
                  'E-Wallet',
                  _formatRupiah(gopayBalance),
                  '0812-3456-7890',
                  Colors.green.shade700,
                  Icons.wallet_rounded,
                  () => _showAdjustBalanceDialog(context, 'GoPay', gopayBalance),
                ),
                _buildAccountCard(
                  'Cash (Tunai)',
                  'Uang di Dompet',
                  _formatRupiah(cashBalance),
                  'Kantong Utama',
                  Colors.amber.shade800,
                  Icons.payments_rounded,
                  () => _showAdjustBalanceDialog(context, 'Cash', cashBalance),
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

  // Widget Pembuat Kartu Rekening
  Widget _buildAccountCard(
    String name,
    String type,
    String balance,
    String number,
    Color color,
    IconData icon,
    VoidCallback onAdjust,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: Colors.white70, size: 22),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: onAdjust,
                    tooltip: 'Sesuaikan Saldo',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(type, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 20),
              Text(
                balance,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(height: 30),
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog untuk memasukkan saldo baru dan menghitung selisih penyesuaian secara otomatis
  void _showAdjustBalanceDialog(BuildContext context, String accountName, double currentBalance) {
    final controller = TextEditingController(
      text: NumberFormat.decimalPattern('id').format(currentBalance),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Sesuaikan Saldo $accountName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo Saat Ini: ${_formatRupiah(currentBalance)}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [RibuanInputFormatter()],
                decoration: InputDecoration(
                  labelText: 'Saldo Baru (Rp)',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final cleanText = controller.text.replaceAll('.', '');
                final newBalance = double.tryParse(cleanText) ?? 0.0;
                
                if (newBalance != currentBalance) {
                  final difference = newBalance - currentBalance;
                  viewModel.tambahTransaksi(
                    title: 'Penyesuaian Saldo $accountName',
                    amount: difference.abs(),
                    category: 'Penyesuaian',
                    date: DateTime.now(),
                    isExpense: difference < 0,
                    account: accountName,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}

// Formatter kustom pecahan ribuan Indonesia
class RibuanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final numValue = double.tryParse(cleanText) ?? 0.0;

    final formatter = NumberFormat.decimalPattern('id');
    final formattedText = formatter.format(numValue);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
