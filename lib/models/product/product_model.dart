/// Modelo de produto
class ProductModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final List<String> indications;
  final String? composition;
  final List<String>? usageForms;
  final List<String>? cannabinoids;
  final String? concentration;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.indications,
    this.composition,
    this.usageForms,
    this.cannabinoids,
    this.concentration,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      indications: (json['indications'] as List).cast<String>(),
      composition: json['composition'] as String?,
      usageForms: json['usageForms'] != null
          ? (json['usageForms'] as List).cast<String>()
          : null,
      cannabinoids: json['cannabinoids'] != null
          ? (json['cannabinoids'] as List).cast<String>()
          : null,
      concentration: json['concentration'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'indications': indications,
      'composition': composition,
      'usageForms': usageForms,
      'cannabinoids': cannabinoids,
      'concentration': concentration,
    };
  }
}






