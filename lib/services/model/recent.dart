class RRecent {
  final String name;
  final String address;
  final double longitude;
  final double latitude;

  RRecent(
      {required this.name,
      required this.address,
      required this.longitude,
      required this.latitude});

  factory RRecent.fromJson(Map<String, dynamic> json) {
    return RRecent(
      name: json['name'],
      address: json['address'],
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }

  static List<RRecent> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => RRecent.fromJson(json)).toList();
  }
}
