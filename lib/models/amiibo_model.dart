class Amiibo {
  final String name;
  final String amiiboSeries;
  final String character;
  final String gameSeries;
  final String head;
  final String tail;
  final String type;
  final String image;
  final Map<String, dynamic>? release;

  Amiibo({
    required this.name,
    required this.amiiboSeries,
    required this.character,
    required this.gameSeries,
    required this.head,
    required this.tail,
    required this.type,
    required this.image,
    this.release,
  });

  factory Amiibo.fromJson(Map<String, dynamic> json) {
    return Amiibo(
      name: json['name'] ?? '',
      amiiboSeries: json['amiiboSeries'] ?? '',
      character: json['character'] ?? '',
      gameSeries: json['gameSeries'] ?? '',
      head: json['head'] ?? '',
      tail: json['tail'] ?? '',
      type: json['type'] ?? '',
      image: json['image'] ?? '',
      release: json['release'],
    );
  }
}
