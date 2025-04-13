// cart_item.dart
class CartItem {
  final String name;
  final String category;
  final double price;

  CartItem({required this.name, required this.category, required this.price});

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'price': price,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        name: json['name'],
        category: json['category'],
        price: json['price'],
      );
}

// discount.dart
