import '../utils/formatters.dart';

extension NumX on num {
  String get inr => KcFormatters.currency(this);
  String get inrCompact => KcFormatters.inrCompact(this);
}
