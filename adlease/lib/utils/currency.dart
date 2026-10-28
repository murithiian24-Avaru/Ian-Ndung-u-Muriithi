import 'package:intl/intl.dart';

/// Formats an amount in Kenyan shillings, for example `KSh 1,250.50`.
///
/// Every amount in this app is demo data: no real money is held, earned or
/// paid out.
String formatKsh(num amount, {int decimals = 2}) {
  return NumberFormat.currency(
    locale: 'en',
    symbol: 'KSh ',
    decimalDigits: decimals,
  ).format(amount);
}
