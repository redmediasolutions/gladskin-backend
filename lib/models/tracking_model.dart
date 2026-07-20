class TrackingInfo {
  final String courier;
  final String trackingNumber;
  final String? trackingUrl;
  final String? notes;

  TrackingInfo({
    required this.courier,
    required this.trackingNumber,
    this.trackingUrl,
    this.notes,
  });

  factory TrackingInfo.fromMap(
    Map<String, dynamic> map,
  ) {
    return TrackingInfo(
      courier: map["courier"] ?? "",
      trackingNumber:
          map["trackingNumber"] ?? "",
      trackingUrl:
          map["trackingUrl"],
      notes: map["notes"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "courier": courier,
      "trackingNumber":
          trackingNumber,
      "trackingUrl":
          trackingUrl,
      "notes": notes,
    };
  }
}