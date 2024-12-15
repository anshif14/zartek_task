import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zartek_task/common/local%20variables.dart';
import 'package:zartek_task/views/screens/login_screen.dart';
import '../../controllers/auth_controller.dart';
import '../../models/restaurantData.dart';
import '../../services/apiServices.dart';
import '../../services/cart_service.dart';
import '../../models/cart_item.dart';
import 'cart_screen.dart';

final restaurantDataProvider = FutureProvider<RestaurantData>((ref) async {
  final apiService = ApiServices();
  return apiService.fetchRestaurantData();
});

final currentUserIdProvider = StateProvider<String>((ref) {
  // final user = ref.watch(authControllerProvider).currentUser;
  return currentUserModel?.id ?? '';
});

final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<List<CartItem>>>((ref) {
  final userId = currentUserModel!.id;
  print('Cart provider rebuilding for userId: ${currentUserModel!.id}'); // Debug log

  // Force recreate CartNotifier when user changes
  return CartNotifier(CartService(), userId);
});

class CartNotifier extends StateNotifier<AsyncValue<List<CartItem>>> {
  final CartService _cartService;
  final String _userId;
  StreamSubscription<List<CartItem>>? _cartSubscription;

  CartNotifier(this._cartService, this._userId) : super(const AsyncValue.loading()) {
    print('CartNotifier initialized with userId: $_userId'); // Debug log
    _initializeCart();
  }

  void _initializeCart() {
    _cartSubscription?.cancel();
    if (_userId.isEmpty) {
      print('Empty user ID, setting empty cart'); // Debug log
      state = const AsyncValue.data([]);
      return;
    }

    print('Initializing cart subscription for user: $_userId'); // Debug log
    _cartSubscription = _cartService.watchCart(_userId).listen(
          (items) {
            print('Received ${items.length} items for user: $_userId'); // Debug log
            if (mounted) {  // Check if notifier is still active
              state = AsyncValue.data(items);
            }
          },
          onError: (error) {
            print('Error watching cart for user $_userId: $error'); // Debug log
            if (mounted) {  // Check if notifier is still active
              state = AsyncValue.error(error, StackTrace.current);
            }
          },
          cancelOnError: false, // Don't cancel subscription on error
        );
  }

  @override
  void dispose() {
    print('Disposing cart notifier for user: $_userId'); // Debug log
    _cartSubscription?.cancel();
    super.dispose();
  }

  Future<void> addToCart(CartItem item) async {
    if (_userId.isEmpty) {
      print('Cannot add to cart: No user logged in'); // Debug log
      return;
    }

    print('Adding to cart for user: $_userId'); // Debug log
    try {
      await _cartService.addToCart(_userId, item);
    } catch (e, stack) {
      print('Error adding to cart: $e'); // Debug log
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateQuantity(String dishId, int newQuantity) async {
    if (_userId.isEmpty) {
      print('Cannot update quantity: No user logged in'); // Debug log
      return;
    }

    print('Updating quantity for user: $_userId, dish: $dishId'); // Debug log
    try {
      await _cartService.updateQuantity(_userId, dishId, newQuantity);
    } catch (e, stack) {
      print('Error updating quantity: $e'); // Debug log
      state = AsyncValue.error(e, stack);
    }
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
@override
  void initState() {
  if(currentUserModel != null){
    setState(() {

    });
  }

  // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
@override
  void didChangeDependencies() {

  // ref.read(currentUserIdProvider.notifier).state =currentUserModel!.id;

  // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).currentUser;
    final restaurantData = ref.watch(restaurantDataProvider);
    final cartState = ref.watch(cartProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        width: width*0.95,
        child: Column(
          children: [

            Container(
              height: height*0.3,
              width: width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                  gradient: LinearGradient(colors: [Color(0xff4cb050),Color(0xff4cb050),Color(0xff7dd857)])
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 35,
                      backgroundColor: Colors.orange,

                      backgroundImage: currentUserModel!.profilePic ==''||currentUserModel!.profilePic =='null'?
                  NetworkImage('url'):
                          NetworkImage(currentUserModel!.profilePic)
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                      currentUserModel?.name ==''?"User":   currentUserModel?.name ?? user?.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                      'ID: ${currentUserModel?.id ??  ''}',
                      style: const TextStyle(fontSize: 14),
                    ),
              ),
                ],
              ),
            ),

            // UserAccountsDrawerHeader(
            //
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
            // gradient: LinearGradient(colors: [Color(0xff4cb050),Color(0xff4cb050),Color(0xff7dd857)])
            //   ),
            //   accountName: Text(
            //     currentUserModel?.name ==''?"User":   currentUserModel?.name ?? user?.displayName ?? 'User',
            //     style: const TextStyle(
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            //   accountEmail: Text(
            //     'ID: ${currentUserModel?.id ??  ''}',
            //     style: const TextStyle(fontSize: 14),
            //   ),
            //   currentAccountPicture: CircleAvatar(
            //     backgroundColor: Colors.orange,
            //     child: Text(
            //  currentUserModel!.name == ''?"User":     (currentUserModel?.name ?? user?.displayName ?? 'U')[0].toUpperCase(),
            //       style: const TextStyle(fontSize: 24, color: Colors.white),
            //     ),
            //   ),
            // ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () {
                ref.read(authControllerProvider).signOut().then((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                });
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(shadowColor: Colors.black,
elevation: 2,
surfaceTintColor: Colors.white,
backgroundColor: Colors.white,
        actions: [
          Consumer(
            builder: (context, ref, child) {

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cartState.hasValue && cartState.value!.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartState.value!.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

        ],
        bottom: restaurantData.when(
          data: (data) {
            if (_tabController == null ||
                _tabController!.length != data.categories.length) {
              _tabController?.dispose();
              _tabController = TabController(
                length: data.categories.length,
                vsync: this,
              );
            }
            return TabBar(
              controller: _tabController,
              labelColor: Color(0xffe05a74),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xffe05a74),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
              tabs: data.categories
                  .map((menu) => Tab(text: menu.name))
                  .toList(),
            );
          },
          error: (error, stack) {
            print('Error in TabBar: $error');
            return null;
          },
          loading: () => null,
        ),
      ),
      body: user != null
          ? restaurantData.when(
              data: (data) {
                if (_tabController == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TabBarView(
                  controller: _tabController,
                  children: data.categories.map((menu) {
                    return SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: menu.dishes.length,
                        itemBuilder: (context, index) {
                          final dish = menu.dishes[index];
                          return MenuCard(
                            imageUrl: dish.imageUrl,
                            title: dish.name,
                            price:dish.price.toString(),
                            calories: dish.calories,
                            description: dish.description,
                            isCustomizable: dish.customizationsAvailable,
                            currency: dish.currency,
                            addons: dish.addons,
                            screenWidth: MediaQuery.of(context).size.width,
                            dishId: dish.id.toString(),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (kDebugMode)
                      ElevatedButton(
                        onPressed: () {
                          ApiServices().fetchRestaurantData();
                        },
                        child: const Text('Retry'),
                      ),
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading menu: ${stack.toString()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : const Center(child: Text('Please login')),
    );
  }
}

class MenuCard extends ConsumerWidget {
  final String imageUrl;
  final String title;
  final String price;
  final int calories;
  final String description;
  final bool isCustomizable;
  final Currency currency;
  final List<Addon> addons;
  final double screenWidth;
  final String dishId;

  const MenuCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.calories,
    required this.description,
    required this.isCustomizable,
    required this.currency,
    required this.addons,
    required this.screenWidth,
    required this.dishId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
print(cartItems);
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
checkNonVeg(title)?Padding(
  padding: const EdgeInsets.all(8.0),
  child: Image.asset('assets/icons/nonveg.png',height: 015,),
):Padding(
  padding: const EdgeInsets.all(8.0),
  child: Image.asset('assets/icons/veg.png',height: 15),
),
           // Icon(CupertinoIcons.dot_square_fill,color: Colors.red,),
            // Info Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${currency.name} ${price} -',
                          style: const TextStyle(              fontWeight: FontWeight.bold, fontSize: 14),
                        ), Text(
                          "$calories calories  ",
                          style: const TextStyle(              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    Text(
                      description,
                      style: const TextStyle(color: Color(0xff7a7b7d)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // if (isCustomizable) ...[
                    //   const Padding(
                    //     padding: EdgeInsets.only(top: 5),
                    //     child: Text(
                    //       'Customizations Available',
                    //       style: TextStyle(color: Colors.red, fontSize: 12),
                    //     ),
                    //   ),
                    //   if (addons.isNotEmpty)
                    //     Padding(
                    //       padding: const EdgeInsets.only(top: 5),
                    //       child: Wrap(
                    //         spacing: 8,
                    //         children: addons.map((addon) => Chip(
                    //           label: Text(
                    //             '${addon.name} (+${addon.price})',
                    //             style: const TextStyle(fontSize: 12),
                    //           ),
                    //         )).toList(),
                    //       ),
                    //     ),
                    // ],
                    // const SizedBox(height: 10),
                    // Add Quantity Section
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color:Color(0xff4daf50),
                              borderRadius: BorderRadius.circular(30)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10.0,0,10,0),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      final currentItem = cartItems.value?.firstWhere(
                                        (item) => item.dishId == dishId,
                                        orElse: () => CartItem(

                                          dishId: dishId.toString(),
                                          name: title,
                                          price: price,
                                          currency: currency.name,
                                          calories: calories,
                                          imageUrl: imageUrl,
                                          quantity: 0,
                                        ),
                                      );

                                      if (currentItem != null && currentItem.quantity > 0) {
                                        cartNotifier.updateQuantity(
                                          dishId.toString(),
                                          currentItem.quantity - 1,
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.remove, color:Colors.white),
                                  ),
                                  Text(
                                    '${cartItems.value?.firstWhere(
                                      (item) => item.dishId == dishId,
                                      orElse: () => CartItem(
                                        dishId: dishId.toString(),
                                        name: title,
                                        price: price.toString(),
                                        currency: currency.name,
                                        calories: calories,
                                        imageUrl: imageUrl,
                                        quantity: 0,
                                      ),
                                    ).quantity ?? 0}',



                                    style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                                  ),
                                  IconButton(
                                    onPressed: () {

                                      List<CartAddon> cartAddons= [];
                                      if(addons.isNotEmpty){
                                        for(var docs in addons){

                              cartAddons.add(CartAddon.fromJson(docs.toJson()));
                                        }
                                      }

                                      final currentItem = cartItems.value?.firstWhere(
                                        (item) => item.dishId == dishId,
                                        orElse: () => CartItem(
                                          dishId: dishId.toString(),
                                          name: title,
                                          price: price,
                                          currency: currency.name,
                                          calories: calories,
                                          imageUrl: imageUrl,
                                          quantity: 0,
                                          addons: cartAddons
                                        ),
                                      );


                                      print(currentItem!.toJson());

                                      cartNotifier.addToCart(
                                        CartItem(
                                          dishId: dishId.toString(),
                                          name: title,
                                          price: price,
                                          currency: currency.name,
                                          calories: calories,
                                          imageUrl: imageUrl,
                                          quantity: (currentItem?.quantity ?? 0) + 1,
                                          addons: cartAddons

                                        ),
                                      );

                                    },
                                    icon: const Icon(Icons.add, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    isCustomizable?
                        Text('Customizations Available',style: TextStyle(color: Color(0xffca5c65),fontWeight: FontWeight.w500),):SizedBox()
                  ],
                ),
              ),
            ),
            Image.network(
              imageUrl,
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant),
                );
              },
            ),
            const SizedBox(width: 10),

          ],
        ),
      ),
    );
  }
  bool checkNonVeg(String dishName) {
    // Keywords indicating non-veg dishes
    List<String> nonVegKeywords = [
      "chicken",
      "lamb",
      "beef",
      "pork",
      "seafood",
      "shrimp",
      "fish",
      "crab",
      "steak",
      "chowder",
      "ribs",
      "mutton"
    ];

    // Check if any non-veg keyword is found in the dish name
    for (var keyword in nonVegKeywords) {
      if (dishName.toLowerCase().contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}