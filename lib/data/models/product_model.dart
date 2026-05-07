class ProductModel {
  final String? id;
  final String name;
  final String price;
  final String category;
  final String description;
  final String imageUrl;
  final DateTime? createdAt;

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    this.imageUrl = '',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      price: map['price'] ?? '0',
      category: map['category'] ?? 'General',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  // Imagen de placeholder por categoria
  String get displayImage {
    if (imageUrl.isNotEmpty) return imageUrl;
    final Map<String, String> categoryImages = {
      'Electrónica': 'https://picsum.photos/seed/electronics/400/300',
      'Ropa': 'https://picsum.photos/seed/clothing/400/300',
      'Hogar': 'https://picsum.photos/seed/home/400/300',
      'Deportes': 'https://picsum.photos/seed/sports/400/300',
      'Libros': 'https://picsum.photos/seed/books/400/300',
    };
    return categoryImages[category] ??
      'https://picsum.photos/seed/${name.hashCode.abs()}/400/300';
  }


}