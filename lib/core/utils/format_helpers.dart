
import 'package:intl/intl.dart';

class FormatHelpers {
  static String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('EEEE d MMMM yyyy', 'id_ID').format(date); // Specify 'en_US' for English
  }

  static String formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
  }
}