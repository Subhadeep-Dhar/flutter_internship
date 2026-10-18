/// Pure Dart domain entity representing a product category.
class Category {
  final String slug;
  final String name;
  final String? url;

  const Category({required this.slug, required this.name, this.url});

  /// Factory for the synthetic "All" category filter chip.
  static const Category all = Category(slug: 'all', name: 'All');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          slug == other.slug;

  @override
  int get hashCode => slug.hashCode;

  @override
  String toString() => 'Category(slug: $slug, name: $name)';
}
