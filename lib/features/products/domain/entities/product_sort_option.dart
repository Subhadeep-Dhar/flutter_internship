/// Pure Dart enumeration representing catalogue sorting criteria.
enum ProductSortOption {
  none(label: 'Featured', sortBy: null, order: null),
  priceAsc(label: 'Price: Low to High', sortBy: 'price', order: 'asc'),
  priceDesc(label: 'Price: High to Low', sortBy: 'price', order: 'desc'),
  ratingDesc(label: 'Highest Rated', sortBy: 'rating', order: 'desc');

  final String label;
  final String? sortBy;
  final String? order;

  const ProductSortOption({
    required this.label,
    required this.sortBy,
    required this.order,
  });

  bool get isNone => this == ProductSortOption.none;
}
