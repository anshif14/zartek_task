import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zartek_task/common/local%20variables.dart';
import '../models/cart_item.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  Stream<List<CartItem>> watchCart(String userId) {
    userId = currentUserModel!.id;
    print('Starting watchCart for user: $userId'); // Debug log
    if (userId.isEmpty) {
      print('Empty userId, returning empty cart stream'); // Debug log
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .distinct() // Only emit when data actually changes
        .map((snapshot) {
      print('Received cart snapshot for user: $userId'); // Debug log
      if (!snapshot.exists) {
        print('User document does not exist for: $userId'); // Debug log
        return [];
      }
      
      try {
        final data = snapshot.data();
        if (data == null || !data.containsKey('cart')) {
          print('No cart data found for user: $userId'); // Debug log
          return [];
        }

        final List<dynamic> cartData = data['cart'] as List<dynamic>;
        final List<CartItem> cartItems = cartData
            .map((item) {
              try {
                return CartItem.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing cart item: $e'); // Debug log
                return null;
              }
            })
            .whereType<CartItem>() // Filter out any null items from parsing errors
            .toList();

        print('Parsed ${cartItems.length} items for user: $userId'); // Debug log
        return cartItems;
      } catch (e) {
        print('Error processing cart data for user $userId: $e'); // Debug log
        return [];
      }
    });
  }
  Stream<List<dynamic>> getCartStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      return data?['cart'] as List<dynamic>? ?? []; // Return the cart array
    });
  }

  // Stream for a specific dish in cart
  Stream<Map<String, dynamic>?> dishStream(String dishId) {
    Map data = jsonDecode(dishId);
    return _firestore.collection('users').doc(data['userId']).snapshots().map((snapshot) {

      // for (var doc in snapshot.data()!['cart']) {
        final cartItems = List<Map<String, dynamic>>.from(snapshot['cart']);
        for (var item in cartItems) {
          if (item['dishId'] == data['dishId']) {
            return item; // Return the matching dish
          }
        // }
      }
      return null; // If no match found
    });
  }
  Future<void> addToCart(String userId, CartItem item) async {
    print('Adding item to cart for user: $userId'); // Debug log
    if (userId.isEmpty) {
      throw Exception('Cannot add to cart: No user logged in');
    }

    try {
      final userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();

      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        await userRef.set({
          'cart': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        userDoc = await userRef.get(); // Get fresh snapshot
        print('Created new user document for: $userId'); // Debug log
      }

      // Get cart data with proper type casting
      final List<dynamic> existingItems = (userDoc.data() as Map<String, dynamic>)?['cart'] ?? [];
      print('Found ${existingItems.length} existing items for user: $userId'); // Debug log

      // Convert to CartItem objects for proper comparison
      final List<CartItem> cartItems = existingItems
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();

      // Find existing item
      final existingItemIndex = cartItems.indexWhere((cartItem) => cartItem.dishId == item.dishId);

      if (existingItemIndex != -1) {
        // Update existing item
        final existingItem = cartItems[existingItemIndex];
        cartItems[existingItemIndex] = CartItem(
          dishId: existingItem.dishId,
          name: existingItem.name,
          price: existingItem.price,
          currency: existingItem.currency,
          calories: existingItem.calories,
          imageUrl: existingItem.imageUrl,
          quantity: existingItem.quantity + 1,
          addons: existingItem.addons,
        );
        print('Updated existing item quantity for user: $userId'); // Debug log
      } else {
        // Add new item
        cartItems.add(item);
        print('Added new item to cart for user: $userId'); // Debug log
      }

      // Convert back to JSON for storage
      final cartData = cartItems.map((item) => item.toJson()).toList();

      await userRef.update({
        'cart': cartData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Successfully updated cart for user: $userId'); // Debug log
    } catch (e) {
      print('Error adding to cart for user $userId: $e'); // Debug log
      throw Exception('Failed to add item to cart: $e');
    }
  }

  Future<void> updateQuantity(String userId, String dishId, int newQuantity) async {
    print('Updating quantity for user: $userId, dishId: $dishId'); // Debug log
    if (userId.isEmpty) {
      throw Exception('Cannot update quantity: No user logged in');
    }

    try {
      final userRef = _firestore.collection('users').doc(currentUserModel!.id);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw Exception('User document does not exist');
      }

      // Get cart data with proper type casting
      final List<dynamic> existingItems = (userDoc.data() as Map<String, dynamic>)?['cart'] ?? [];
      
      // Convert to CartItem objects
      final List<CartItem> cartItems = existingItems
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();

      final itemIndex = cartItems.indexWhere((item) => item.dishId == dishId);

      if (itemIndex != -1) {
        final item = cartItems[itemIndex];
        if (newQuantity < 0) {
          throw Exception('Quantity cannot be negative');
        } else if (newQuantity == 0) {
          // Remove the item if quantity is explicitly set to 0
          cartItems.removeAt(itemIndex);
        } else {
          cartItems[itemIndex] = CartItem(
            dishId: item.dishId,
            name: item.name,
            price: item.price,
            currency: item.currency,
            calories: item.calories,
            imageUrl: item.imageUrl,
            quantity: newQuantity,
            addons: item.addons,
          );
        }

        // Convert back to JSON for storage
        final cartData = cartItems.map((item) => item.toJson()).toList();

        await userRef.update({
          'cart': cartData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Successfully updated quantity for user: $userId, dishId: $dishId'); // Debug log
      } else {
        // If item not found, throw an exception
        throw Exception('Item not found in cart');
      }
    } catch (e) {
      print('Error updating quantity for user $userId: $e'); // Debug log
      throw Exception('Failed to update quantity: $e');
    }
  }

  Future<void> clearCart(String userId) async {
    print('Clearing cart for user: $userId'); // Debug log
    if (userId.isEmpty) {
      throw Exception('Cannot clear cart: No user logged in');
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'cart': [],
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Successfully cleared cart for user: $userId'); // Debug log
    } catch (e) {
      print('Error clearing cart for user $userId: $e'); // Debug log
      throw Exception('Failed to clear cart: $e');
    }
  }
}
