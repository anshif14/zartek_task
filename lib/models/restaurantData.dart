// To parse this JSON data, do
//
//     final restaurantData = restaurantDataFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

RestaurantData restaurantDataFromJson(String str) => RestaurantData.fromJson(json.decode(str));

String restaurantDataToJson(RestaurantData data) => json.encode(data.toJson());

class RestaurantData {
  final List<Category> categories;

  RestaurantData({
    required this.categories,
  });

  RestaurantData copyWith({
    List<Category>? categories,
  }) =>
      RestaurantData(
        categories: categories ?? this.categories,
      );

  factory RestaurantData.fromJson(Map<String, dynamic> json) => RestaurantData(
    categories: List<Category>.from(json["categories"].map((x) => Category.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
  };
}

class Category {
  final int id;
  final String name;
  final List<Dish> dishes;

  Category({
    required this.id,
    required this.name,
    required this.dishes,
  });

  Category copyWith({
    int? id,
    String? name,
    List<Dish>? dishes,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        dishes: dishes ?? this.dishes,
      );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    dishes: List<Dish>.from(json["dishes"].map((x) => Dish.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "dishes": List<dynamic>.from(dishes.map((x) => x.toJson())),
  };
}

class Dish {
  final int id;
  final String name;
  final String price;
  final Currency currency;
  final int calories;
  final String description;
  final List<Addon> addons;
  final String imageUrl;
  final bool customizationsAvailable;

  Dish({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.calories,
    required this.description,
    required this.addons,
    required this.imageUrl,
    required this.customizationsAvailable,
  });

  Dish copyWith({
    int? id,
    String? name,
    String? price,
    Currency? currency,
    int? calories,
    String? description,
    List<Addon>? addons,
    String? imageUrl,
    bool? customizationsAvailable,
  }) =>
      Dish(
        id: id ?? this.id,
        name: name ?? this.name,
        price: price ?? this.price,
        currency: currency ?? this.currency,
        calories: calories ?? this.calories,
        description: description ?? this.description,
        addons: addons ?? this.addons,
        imageUrl: imageUrl ?? this.imageUrl,
        customizationsAvailable: customizationsAvailable ?? this.customizationsAvailable,
      );

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
    id: json["id"],
    name: json["name"],
    price: json["price"],
    currency: currencyValues.map[json["currency"]]!,
    calories: json["calories"],
    description: json["description"],
    addons: List<Addon>.from(json["addons"].map((x) => Addon.fromJson(x))),
    imageUrl: json["image_url"],
    customizationsAvailable: json["customizations_available"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "currency": currencyValues.reverse[currency],
    "calories": calories,
    "description": description,
    "addons": List<dynamic>.from(addons.map((x) => x.toJson())),
    "image_url": imageUrl,
    "customizations_available": customizationsAvailable,
  };
}

class Addon {
  final int id;
  final String name;
  final String price;

  Addon({
    required this.id,
    required this.name,
    required this.price,
  });

  Addon copyWith({
    int? id,
    String? name,
    String? price,
  }) =>
      Addon(
        id: id ?? this.id,
        name: name ?? this.name,
        price: price ?? this.price,
      );

  factory Addon.fromJson(Map<String, dynamic> json) => Addon(
    id: json["id"],
    name: json["name"],
    price: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
  };
}

enum Currency {
  INR
}

final currencyValues = EnumValues({
  "INR": Currency.INR
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
