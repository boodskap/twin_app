import 'package:intl/intl.dart';

String currencyToSymbol(String currency) {
  return NumberFormat.simpleCurrency(name: currency).currencySymbol;
  //int code = int.tryParse(symbol, radix: 16) ?? 0;
  //return String.fromCharCode(code);
}
