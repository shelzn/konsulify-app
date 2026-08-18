import 'package:intl/intl.dart';

final _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp',
  decimalDigits: 0,
);
final _date = DateFormat('d MMMM yyyy', 'id_ID');

String formatRupiah(num value) => _rupiah.format(value);

String formatDateIndonesia(DateTime value) => _date.format(value);
