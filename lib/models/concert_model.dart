import 'package:cloud_firestore/cloud_firestore.dart';

class ConcertModel {
  final String id;
  final String title;
  final String artistName;
  final String description;
  final String imageUrl;     // Firebase Storage URL
  final String venue;
  final double latitude;
  final double longitude;
  final DateTime date;
  final double ticketPrice;
  final int totalSeats;
  final int availableSeats;
  final String category;    // 'pop' | 'traditional' | 'gospel' | 'hiphop' etc.
  final bool isActive;
  final DateTime createdAt;

  const ConcertModel({
    required this.id,
    required this.title,
    required this.artistName,
    required this.description,
    required this.imageUrl,
    required this.venue,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.ticketPrice,
    required this.totalSeats,
    required this.availableSeats,
    required this.category,
    required this.isActive,
    required this.createdAt,
  });

  bool get isSoldOut    => availableSeats <= 0;
  bool get isUpcoming   => date.isAfter(DateTime.now());
  int  get soldSeats    => totalSeats - availableSeats;
  double get soldRatio  => totalSeats > 0 ? soldSeats / totalSeats : 0;

  // ── Firestore ──────────────────────────────────────

  factory ConcertModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ConcertModel(
      id:             doc.id,
      title:          d['title'] ?? '',
      artistName:     d['artistName'] ?? '',
      description:    d['description'] ?? '',
      imageUrl:       d['imageUrl'] ?? '',
      venue:          d['venue'] ?? '',
      latitude:       (d['latitude'] ?? 9.0054).toDouble(),
      longitude:      (d['longitude'] ?? 38.7636).toDouble(),
      date:           (d['date'] as Timestamp).toDate(),
      ticketPrice:    (d['ticketPrice'] ?? 0).toDouble(),
      totalSeats:     (d['totalSeats'] ?? 0) as int,
      availableSeats: (d['availableSeats'] ?? 0) as int,
      category:       d['category'] ?? 'pop',
      isActive:       d['isActive'] ?? true,
      createdAt:      (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'artistName': artistName,
    'description': description,
    'imageUrl': imageUrl,
    'venue': venue,
    'latitude': latitude,
    'longitude': longitude,
    'date': Timestamp.fromDate(date),
    'ticketPrice': ticketPrice,
    'totalSeats': totalSeats,
    'availableSeats': availableSeats,
    'category': category,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  ConcertModel copyWith({
    String? title, String? artistName, String? description,
    String? imageUrl, String? venue, double? latitude, double? longitude,
    DateTime? date, double? ticketPrice, int? totalSeats,
    int? availableSeats, String? category, bool? isActive,
  }) => ConcertModel(
    id: id, createdAt: createdAt,
    title: title ?? this.title,
    artistName: artistName ?? this.artistName,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    venue: venue ?? this.venue,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    date: date ?? this.date,
    ticketPrice: ticketPrice ?? this.ticketPrice,
    totalSeats: totalSeats ?? this.totalSeats,
    availableSeats: availableSeats ?? this.availableSeats,
    category: category ?? this.category,
    isActive: isActive ?? this.isActive,
  );
}
