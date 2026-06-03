import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/concert_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // ════════════════════════════════════════════════════
  //  CONCERTS
  // ════════════════════════════════════════════════════

  /// Real-time stream of active concerts (sorted by date)
  Stream<List<ConcertModel>> concertsStream() {
    return _db
        .collection('concerts')
        .where('isActive', isEqualTo: true)
        .orderBy('date')
        .snapshots()
        .map((snap) => snap.docs.map(ConcertModel.fromFirestore).toList());
  }

  /// Admin: stream of ALL concerts including inactive
  Stream<List<ConcertModel>> allConcertsStream() {
    return _db
        .collection('concerts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ConcertModel.fromFirestore).toList());
  }

  /// Get single concert
  Future<ConcertModel?> getConcert(String id) async {
    final doc = await _db.collection('concerts').doc(id).get();
    if (!doc.exists) return null;
    return ConcertModel.fromFirestore(doc);
  }

  /// Admin: create concert
  Future<String> createConcert(ConcertModel concert) async {
    final ref = await _db.collection('concerts').add(concert.toMap());
    return ref.id;
  }

  /// Admin: update concert
  Future<void> updateConcert(String id, Map<String, dynamic> data) async {
    await _db.collection('concerts').doc(id).update(data);
  }

  /// Admin: delete concert
  Future<void> deleteConcert(String id) async {
    await _db.collection('concerts').doc(id).delete();
  }

  // ════════════════════════════════════════════════════
  //  BOOKINGS
  // ════════════════════════════════════════════════════

  /// Create a booking + decrement seats (atomic transaction)
  Future<BookingModel> createBooking({
    required String userId,
    required String userEmail,
    required String userName,
    required ConcertModel concert,
    required int ticketCount,
  }) async {
    final bookingId = _uuid.v4();
    final qrCode    = 'CONCERT-${concert.id}-$bookingId';

    await _db.runTransaction((txn) async {
      final concertRef = _db.collection('concerts').doc(concert.id);
      final snap = await txn.get(concertRef);
      final available = (snap.data()!['availableSeats'] as int);

      if (available < ticketCount) {
        throw Exception('Not enough seats available.');
      }

      final bookingRef = _db.collection('bookings').doc(bookingId);
      txn.set(bookingRef, {
        'userId':           userId,
        'userEmail':        userEmail,
        'userName':         userName,
        'concertId':        concert.id,
        'concertTitle':     concert.title,
        'concertImageUrl':  concert.imageUrl,
        'concertDate':      Timestamp.fromDate(concert.date),
        'venue':            concert.venue,
        'ticketCount':      ticketCount,
        'totalAmount':      concert.ticketPrice * ticketCount,
        'qrCode':           qrCode,
        'status':           'pending',
        'paymentStatus':    'unpaid',
        'paymentTxRef':     null,
        'bookedAt':         FieldValue.serverTimestamp(),
      });

      txn.update(concertRef, {
        'availableSeats': FieldValue.increment(-ticketCount),
      });
    });

    final doc = await _db.collection('bookings').doc(bookingId).get();
    return BookingModel.fromFirestore(doc);
  }

  /// Confirm payment on a booking
  Future<void> confirmPayment(String bookingId, String txRef) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status':        'confirmed',
      'paymentStatus': 'paid',
      'paymentTxRef':  txRef,
    });
  }

  /// Mark booking as "used" (at venue gate scan)
  Future<void> markTicketUsed(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'used',
    });
  }

  /// Cancel a booking + restore seats
  Future<void> cancelBooking(String bookingId, String concertId, int ticketCount) async {
    await _db.runTransaction((txn) async {
      final bookingRef = _db.collection('bookings').doc(bookingId);
      final concertRef = _db.collection('concerts').doc(concertId);
      txn.update(bookingRef, {'status': 'cancelled', 'paymentStatus': 'refunded'});
      txn.update(concertRef, {'availableSeats': FieldValue.increment(ticketCount)});
    });
  }

  /// User's own bookings stream
  Stream<List<BookingModel>> userBookingsStream(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('bookedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  /// Admin: all bookings stream
  Stream<List<BookingModel>> allBookingsStream() {
    return _db
        .collection('bookings')
        .orderBy('bookedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromFirestore).toList());
  }

  /// Lookup booking by QR code (for admin scanner)
  Future<BookingModel?> getBookingByQrCode(String qrCode) async {
    final snap = await _db
        .collection('bookings')
        .where('qrCode', isEqualTo: qrCode)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return BookingModel.fromFirestore(snap.docs.first);
  }

  // ════════════════════════════════════════════════════
  //  USERS (admin)
  // ════════════════════════════════════════════════════

  Stream<List<UserModel>> allUsersStream() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(UserModel.fromFirestore).toList());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> setUserActiveStatus(String uid, bool isActive) async {
    await _db.collection('users').doc(uid).update({'isActive': isActive});
  }

  /// Update own profile
  Future<void> updateProfile(String uid, {
    required String name,
    required String phone,
    String? profileImageUrl,
  }) async {
    final data = <String, dynamic>{'name': name, 'phone': phone};
    if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;
    await _db.collection('users').doc(uid).update(data);
  }
}
