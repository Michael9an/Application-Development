class EventModel {
  final String id;
  final String name;
  final String description;
  final String date;
  final String? bannerUrl;
  final String location;
  final String clubId;
  final String clubName;
  final String? clubImageUrl;
  final int maxAttendees;
  final double price;
  final bool isFree;
  final String? refundPolicy;
  final String? publishTime;
  final DateTime? createdAt;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    this.bannerUrl,
    required this.location,
    required this.clubId,
    required this.clubName,
    this.clubImageUrl,
    this.maxAttendees = 0,
    this.price = 0.0,
    this.isFree = true,
    this.refundPolicy,
    this.publishTime,
    this.createdAt,
  });

  factory EventModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      bannerUrl: data['bannerUrl'],
      location: data['location'] ?? '',
      clubId: data['clubId'] ?? '',
      clubName: data['clubName'] ?? '',
      clubImageUrl: data['clubImageUrl'],
      maxAttendees: data['maxAttendees'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
      isFree: data['isFree'] ?? true,
      refundPolicy: data['refundPolicy'],
      publishTime: data['publishTime'],
      createdAt: data['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'date': date,
      'bannerUrl': bannerUrl,
      'location': location,
      'clubId': clubId,
      'clubName': clubName,
      'clubImageUrl': clubImageUrl,
      'maxAttendees': maxAttendees,
      'price': price,
      'isFree': isFree,
      'refundPolicy': refundPolicy,
      'publishTime': publishTime,
      'createdAt': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  String get formattedDate {
    final timestamp = int.tryParse(date);
    if (timestamp == null) return 'Date not set';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String get formattedTime {
    final timestamp = int.tryParse(date);
    if (timestamp == null) return 'Time not set';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  DateTime get dateTime {
    final timestamp = int.tryParse(date);
    return timestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : DateTime.now();
  }

  /// Returns a new [EventModel] copying current values and replacing
  /// any provided fields. Useful for keeping the model immutable while
  /// updating a single field (for example, assigning an ID before save).
  EventModel copyWith({
    String? id,
    String? name,
    String? description,
    String? date,
    String? bannerUrl,
    String? location,
    String? clubId,
    String? clubName,
    String? clubImageUrl,
    int? maxAttendees,
    double? price,
    bool? isFree,
    String? refundPolicy,
    String? publishTime,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      location: location ?? this.location,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      clubImageUrl: clubImageUrl ?? this.clubImageUrl,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      refundPolicy: refundPolicy ?? this.refundPolicy,
      publishTime: publishTime ?? this.publishTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}