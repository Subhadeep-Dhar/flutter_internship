import '../../domain/entities/category.dart';

/// Concrete DTO model representing a [Category] serialized from the DummyJSON API.
class CategoryModel extends Category {
  const CategoryModel({required super.slug, required super.name, super.url});

  /// Factory deserializer handling both object format `{"slug": "...", "name": "..."}`
  /// and plain string format `"beauty"`.
  factory CategoryModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final slug = (json['slug'] as String?)?.trim() ?? '';
      final name = (json['name'] as String?)?.trim() ?? _formatSlugToName(slug);
      final url = (json['url'] as String?)?.trim();
      return CategoryModel(slug: slug, name: name, url: url);
    } else if (json is String) {
      final slug = json.trim();
      return CategoryModel(slug: slug, name: _formatSlugToName(slug));
    } else {
      return const CategoryModel(slug: '', name: 'Unknown');
    }
  }

  static String _formatSlugToName(String slug) {
    if (slug.isEmpty) return 'General';
    return slug
        .replaceAll('-', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  /// Converts this [CategoryModel] to a JSON Map.
  Map<String, dynamic> toJson() {
    return {'slug': slug, 'name': name, if (url != null) 'url': url};
  }
}
