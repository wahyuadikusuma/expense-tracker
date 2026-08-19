import 'package:isar/isar.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  late String title;
  late double amount;
  late String category;
  late DateTime date;
  late bool isExpense;
  String account = 'Cash'; // Sumber dana: BCA, GoPay, atau Cash
}
