import 'package:intl/intl.dart';

abstract final class KcFormatters {
  static final NumberFormat _inrCurrency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String currency(num amount) => _inrCurrency.format(amount);
  static String inr(num amount) => currency(amount);

  static String inrCompact(num amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)} k';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  static String date(DateTime dt) => DateFormat('d MMM yyyy').format(dt);
  static String dateTime(DateTime dt) => DateFormat('d MMM yyyy, h:mm a').format(dt);

  static String relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return date(dt);
  }
}
