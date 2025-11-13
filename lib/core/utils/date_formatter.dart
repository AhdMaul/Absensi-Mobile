import 'package:intl/intl.dart';

/// Utility class untuk format tanggal yang aman dari LocaleDataException
class DateFormatter {
  /// Format tanggal ke string dengan pattern tertentu
  /// Jika locale tidak tersedia, akan fallback ke format default
  static String format(DateTime date, String pattern, {String locale = 'id_ID'}) {
    try {
      return DateFormat(pattern, locale).format(date);
    } catch (e) {
      // Fallback: gunakan format tanpa locale
      try {
        return DateFormat(pattern).format(date);
      } catch (e2) {
        // Last resort: gunakan toString
        return date.toString();
      }
    }
  }

  /// Format waktu standar HH:mm:ss
  static String formatTime(DateTime dateTime) {
    return format(dateTime, 'HH:mm:ss');
  }

  /// Format tanggal standar dd MMMM yyyy (bahasa Indonesia)
  static String formatDate(DateTime dateTime) {
    return format(dateTime, 'dd MMMM yyyy', locale: 'id_ID');
  }

  /// Format tanggal panjang EEEE, dd MMMM yyyy (bahasa Indonesia)
  static String formatFullDate(DateTime dateTime) {
    return format(dateTime, 'EEEE, dd MMMM yyyy', locale: 'id_ID');
  }

  /// Format custom dengan pattern dan locale pilihan
  static String formatCustom(DateTime dateTime, String pattern) {
    return format(dateTime, pattern, locale: 'id_ID');
  }

  /// Format untuk display yang aman (tanpa locale)
  static String formatSafe(DateTime dateTime, String pattern) {
    try {
      return DateFormat(pattern).format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }
}
