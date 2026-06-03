import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus { pending, confirmed, cancelled, used }
enum PaymentStatus { unpaid, paid, refunded }

class BookingModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String concertId;
  final String concertTitle;
  final String concertImageUrl;
  final DateTime concertDate;
  final String venue;
  final int ticketCount;
  final double totalAmount;
  final String qrCode;          // Unique string — used by qr_flutter
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentTxRef;   // Transaction ref from Chapa
  final DateTime bookedAt;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.concertId,
    required this.concertTitle,
    required this.concertImageUrl,
    required this.concertDate,
    required this.venue,
    required this.ticketCount,
    required this.totalAmount,
    required this.qrCode,
    required this.status,
    required this.paymentStatus,
    this.paymentTxRef,
    required this.bookedAt,
  });

  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isPaid      => paymentStatus == PaymentStatus.paid;
  bool get isUsed      => status == BookingStatus.used;

  // ── Firestore ──────────────────────────────────────

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id:               doc.id,
      userId:           d['userId'] ?? '',
      userEmail:        d['userEmail'] ?? '',
      userName:         d['userName'] ?? '',
      concertId:        d['concertId'] ?? '',
      concertTitle:     d['concertTitle'] ?? '',
      concertImageUrl:  d['concertImageUrl'] ?? '',
      concertDate:      (d['concertDate'] as Timestamp).toDate(),
      venue:            d['venue'] ?? '',
      ticketCount:      (d['ticketCount'] ?? 1) as int,
      totalAmount:      (d['totalAmount'] ?? 0).toDouble(),
      qrCode:           d['qrCode'] ?? '',
      status:           BookingStatus.values.firstWhere(
        (e) => e.name == d['status'], orElse: () => BookingStatus.pending),
      paymentStatus:    PaymentStatus.values.firstWhere(
        (e) => e.name == d['paymentStatus'], orElse: () => PaymentStatus.unpaid),
      paymentTxRef:     d['paymentTxRef'],
      bookedAt:         (d['bookedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId':           userId,
    'userEmail':        userEmail,
    'userName':         userName,
    'concertId':        concertId,
    'concertTitle':     concertTitle,
    'concertImageUrl':  concertImageUrl,
    'concertDate':      Timestamp.fromDate(concertDate),
    'venue':            venue,
    'ticketCount':      ticketCount,
    'totalAmount':      totalAmount,
    'qrCode':           qrCode,
    'status':           status.name,
    'paymentStatus':    paymentStatus.name,
    'paymentTxRef':     paymentTxRef,
    'bookedAt':         Timestamp.fromDate(bookedAt),
  };

  BookingModel copyWith({
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentTxRef,
  }) => BookingModel(
    id: id, userId: userId, userEmail: userEmail, userName: userName,
    concertId: concertId, concertTitle: concertTitle,
    concertImageUrl: concertImageUrl, concertDate: concertDate,
    venue: venue, ticketCount: ticketCount, totalAmount: totalAmount,
    qrCode: qrCode, bookedAt: bookedAt,
    status:        status        ?? this.status,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    paymentTxRef:  paymentTxRef  ?? this.paymentTxRef,
  );
}
