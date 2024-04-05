

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_ease_user/config/configuration.dart';
import 'package:shop_ease_user/config/routes.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController searchcontroller = TextEditingController();
  Map<String, bool> wishlistStates = {}; 
  @override
  Widget build(BuildContext context) {
    Provider.of<WhishListProvider>(context,listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        toolbarHeight: MyConstants.screenHeight(context) * 0.08,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          Flexible(
            child: Padding(
              padding: EdgeInsets.all(MyConstants.screenHeight(context) * 0.004),
              child: TextFormField(
                controller: searchcontroller,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintStyle: const TextStyle(fontSize: 20),
                  hintText: "search",
                  errorBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(MyConstants.screenHeight(context) * 0.01),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("products").snapshots(),
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No  data found.'));
            }

            final userData = snapshot.data!.docs;

            return Consumer<WhishListProvider>(
              builder: (context,data,_) {
                return GridView.builder(
                  itemCount: userData.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.73),
                  itemBuilder: (BuildContext context, int index) {
                    data.initializeWishlistStates();
                    final userDoc = userData[index];
                    final documentId = userDoc.id;
                    final Map<String, dynamic> userMap = userDoc.data() as Map<String, dynamic>;
                    final String image = userMap["imageUrls"]?[0] ?? '';
                    final String name = userMap["productName"] ?? '';
                    final double price = userMap["price"] ?? '';
                    final bool isLiked=data.whishList[documentId]??false;
                
                    return GestureDetector(
                      onTap:() {
                        Navigator.pushNamed(context, Routes.viewproduct,arguments: {
                          "id":userMap["productid"],
                          "email":userMap["userEmail"]
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
                                  child: Consumer<WhishListProvider>(
                                    builder: (context,data,_) {
                                      return IconButton(
                                        onPressed: () {
                                          data.updateWishlist(FirebaseAuth.instance.currentUser!.email, documentId);
                                        },
                                        icon: isLiked ? const Icon(Icons.favorite, color: Colors.red) : const Icon(Icons.favorite_outline, color: Colors.red),
                                      );
                                    }
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
                );
              }
            );
          },
        ),
      ),
    );
  }
}

class WhishListProvider extends ChangeNotifier{
  Map<String,dynamic> whishListtemp={};

  Map<String,dynamic> get whishList=>whishListtemp;

  void updateWishlist(String? userEmail, String productId) async {
    
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("users").where("email", isEqualTo: userEmail).get();
      var doc = snapshot.docs.first;
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

      List<dynamic> wishlist = userData["wishlist"];

      if (wishlist.contains(productId)) {
        wishlist.remove(productId);
      } else {
        wishlist.add(productId);
      }

      await doc.reference.update({"wishlist": wishlist});

     
     
        whishListtemp[productId] = wishlist.contains(productId);

        notifyListeners();

  }

  void initializeWishlistStates() async {
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("users").where("email", isEqualTo: userEmail).get();
      var doc = snapshot.docs.first;
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      List<dynamic> wishlist = userData["wishlist"] ?? [];
      for (var productId in wishlist) {

          whishListtemp[productId] = true; 

      }
      notifyListeners();
  }

}

// updateWishlist(FirebaseAuth.instance.currentUser!.email, documentId);
