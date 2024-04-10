import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shop_ease_user/config/configuration.dart';
import 'package:shop_ease_user/config/routes.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController searchController = TextEditingController();
  bool _showSearchBar = false;
  List<DocumentSnapshot>? filteredproducts;
  List<DocumentSnapshot>? products;

  @override
  void initState() {
    super.initState();
    Provider.of<WhishListProvider>(context, listen: false).initializeWishlistStates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        toolbarHeight: MyConstants.screenHeight(context) * 0.08,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading:  LottieBuilder.asset("assets/Animation - 1708494702546.json"),
        title: Text("SHOP EASE"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
              });
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(MyConstants.screenHeight(context) * 0.01),
        child: Column(
          children: [
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _showSearchBar ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "Search...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    filteredproducts = fllteredproducts(value);
                  });
                },
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("products").snapshots(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No data found.'));
                }

                products = snapshot.data?.docs;
                List<DocumentSnapshot> displayproducts =
                    searchController.text.isEmpty ? products! : filteredproducts ?? products!;

                return Consumer<WhishListProvider>(
                  builder: (context, data, _) {
                    return Expanded(
                      child: GridView.builder(
                        itemCount: displayproducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.73,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final userDoc = displayproducts[index];
                          final documentId = userDoc.id;
                          final Map<String, dynamic> userMap = userDoc.data() as Map<String, dynamic>;
                          final String image = userMap["imageUrls"]?[0] ?? '';
                          final String name = userMap["productName"] ?? '';
                          final double price = userMap["price"] ?? '';
                          final bool isLiked = data.whishList[documentId] ?? false;

                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, Routes.viewproduct, arguments: {
                                "id": userMap["productid"],
                                "email": userMap["userEmail"],
                              });
                            },
                            child: SizedBox(
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      SizedBox(
                                        height: MyConstants.screenHeight(context) * 0.25,
                                        child: Image.network(image, fit: BoxFit.contain),
                                      ),
                                      Positioned(
                                        top: MyConstants.screenHeight(context) * 0.01,
                                        right: MyConstants.screenHeight(context) * 0.01,
                                        child: IconButton(
                                          onPressed: () {
                                            data.updateWishlist(FirebaseAuth.instance.currentUser!.email, documentId);
                                          },
                                          icon: isLiked ? const Icon(Icons.favorite, color: Colors.red) : const Icon(Icons.favorite_outline, color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      name,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "₹ $price",
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<DocumentSnapshot> fllteredproducts(String query) {
    if (query.isEmpty) {
      return [];
    } else {
      List<DocumentSnapshot> filteredList = [];
      for (var product in products!) {
        String productnamename = product["productName"].toLowerCase();
        if (productnamename.contains(query.toLowerCase())) {
          filteredList.add(product);
        }
      }
      return filteredList;
    }
  }
}

class WhishListProvider extends ChangeNotifier {
  Map<String, dynamic> wishListTemp = {};

  Map<String, dynamic> get whishList => wishListTemp;

  void updateWishlist(String? userEmail, String productId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("products").where("email", isEqualTo: userEmail).get();
    var doc = snapshot.docs.first;
    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

    List<dynamic> wishlist = userData["wishlist"];

    if (wishlist.contains(productId)) {
      wishlist.remove(productId);
    } else {
      wishlist.add(productId);
    }

    await doc.reference.update({"wishlist": wishlist});

    wishListTemp[productId] = wishlist.contains(productId);
    notifyListeners();
  }

  void initializeWishlistStates() async {
    final userEmail = FirebaseAuth.instance.currentUser!.email;

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("products").where("email", isEqualTo: userEmail).get();
    var doc = snapshot.docs.first;
    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
    List<dynamic> wishlist = userData["wishlist"] ?? [];
    for (var productId in wishlist) {
      wishListTemp[productId] = true;
    }
    notifyListeners();
  }
}
