class CartItem {
  final String dishId;
  final String name;
  final String price;
  final String currency;
  final int calories;
  final String imageUrl;
  final int quantity;
  final List<CartAddon>? addons;

  CartItem({
    required this.dishId,
    required this.name,
    required this.price,
    required this.currency,
    required this.calories,
    required this.imageUrl,
    required this.quantity,
    this.addons,
  });

  Map<String, dynamic> toJson() => {
        'dishId': dishId,
        'name': name,
        'price': price,
        'currency': currency,
        'calories': calories,
        'imageUrl': imageUrl,
        'quantity': quantity,
        'addons': addons?.map((addon) => addon.toJson()).toList(),
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        dishId: json['dishId'].toString(),
        name: json['name'].toString(),
        price: json['price'].toString(),
        currency: json['currency'].toString(),
        calories: json['calories'],
        imageUrl: json['imageUrl'].toString(),
        quantity: json['quantity'],
        addons: json['addons'] != null
            ? (json['addons'] as List)
                .map((addon) => CartAddon.fromJson(addon))
                .toList()
            : null,
      );
}

class CartAddon {
  final String id;
  final String name;
  final String price;

  CartAddon({
    required this.id,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };

  factory CartAddon.fromJson(Map<String, dynamic> json) => CartAddon(
        id: json['id'].toString(),
        name: json['name'],
        price: json['price'].toString(),
      );
}
