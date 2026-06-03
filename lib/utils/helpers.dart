import 'package:intl/intl.dart';

class Helpers {
  /// Format: "Sat, Jan 18 · 7:00 PM"
  static String formatEventDate(DateTime dt) {
    return DateFormat('EEE, MMM d · h:mm a').format(dt);
  }

  /// Format: "Jan 18, 2025"
  static String formatDate(DateTime dt) {
    return DateFormat('MMM d, y').format(dt);
  }

  /// Format: "7:00 PM"
  static String formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  /// Format: "ETB 1,200.00"
  static String formatCurrency(double amount) {
    return 'ETB ${NumberFormat('#,##0.00').format(amount)}';
  }

  /// Relative time: "2 hours ago", "3 days ago"
  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dt);
  }

  /// Is the event in the future?
  static bool isUpcoming(DateTime dt) => dt.isAfter(DateTime.now());
}
