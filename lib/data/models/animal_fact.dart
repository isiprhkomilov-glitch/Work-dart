/// Животное из /v1/animals.
class AnimalFact {
  const AnimalFact({
    required this.name,
    required this.taxonomy,
    required this.locations,
    required this.characteristics,
  });

  final String name;

  /// Систематика: kingdom, phylum, class, order, family, genus, scientific_name.
  final Map<String, String> taxonomy;

  final List<String> locations;

  /// Интересные характеристики: срок жизни, вес, питание и т. д.
  final Map<String, String> characteristics;

  factory AnimalFact.fromJson(Map<String, dynamic> json) {
    return AnimalFact(
      name: _text(json['name']),
      taxonomy: _stringMap(json['taxonomy']),
      locations: (json['locations'] is List)
          ? (json['locations'] as List).map((e) => _text(e)).where((e) => e.isNotEmpty).toList()
          : const <String>[],
      characteristics: _stringMap(json['characteristics']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'taxonomy': taxonomy,
        'locations': locations,
        'characteristics': characteristics,
      };

  static String _text(dynamic value) => value == null ? '' : value.toString();

  static Map<String, String> _stringMap(dynamic value) {
    if (value is! Map) return <String, String>{};
    final result = <String, String>{};
    value.forEach((key, raw) {
      if (raw == null) return;
      final text = raw.toString().trim();
      if (text.isEmpty) return;
      result[key.toString()] = text;
    });
    return result;
  }
}
