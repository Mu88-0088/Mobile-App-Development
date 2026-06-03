class AppRoutes {
  // Auth
  static const String splash       = '/';
  static const String login        = '/login';
  static const String register     = '/register';
  static const String forgotPass   = '/forgot-password';

  // User
  static const String userHome     = '/home';
  static const String concertDetail= '/concert-detail';
  static const String booking      = '/booking';
  static const String payment      = '/payment';
  static const String myTickets    = '/my-tickets';
  static const String ticketQr     = '/ticket-qr';
  static const String profile      = '/profile';

  // Admin
  static const String adminDash    = '/admin-dashboard';
  static const String adminConcerts= '/admin-concerts';
  static const String adminUsers   = '/admin-users';
  static const String adminUserDetail = '/admin-user-detail';
  static const String adminBookings= '/admin-bookings';
  static const String adminQrScan  = '/admin-qr-scan';
  static const String addEditConcert = '/add-edit-concert';
}

class AppStrings {
  static const String appName      = 'ConcertEth';
  static const String currency     = 'ETB';
  static const String adminEmail   = 'admin@concerteth.com'; // Change to your admin email
}
