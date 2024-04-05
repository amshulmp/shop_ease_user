

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_ease_user/config/configuration.dart';
import 'package:shop_ease_user/screens/homescreen.dart';


class Wishist extends StatefulWidget {
  const Wishist({super.key});

  @override
  State<Wishist> createState() => _WishistState();
}

class _WishistState extends State<Wishist> {

  TextEditingController searchcontroller = TextEditingController();
  Map<String, bool> wishlistStates = {}; 
  @override
  Widget build(BuildContext context) {
    Provider.of<WhishListProvider>(context,listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
       title: const Text(
          "W I S H L I S  T",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,      ),
      body: Padding(
        padding: EdgeInsets.all(MyConstants.screenHeight(context) * 0.01),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("products").orderBy("price" ,descending: false).snapshots(),
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
                return ListView.builder(
                  itemCount: userData.length,
                 
                  itemBuilder: (BuildContext context, int index) {
                    data.initializeWishlistStates();
                    final userDoc = userData[index];
                    final documentId = userDoc.id;
                    final Map<String, dynamic> userMap = userDoc.data() as Map<String, dynamic>;
                    final String image = userMap["imageUrls"]?[0] ?? '';
                    final String name = userMap["productName"] ?? '';
                    final double price = userMap["price"] ?? '';
                    final bool isLiked=data.whishList[documentId]??false;
                
                   if (isLiked) {
                      return ListTile(
                        leading:  Image.network(image, fit: BoxFit.contain),
                        title:  Text(
                                  name,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                        subtitle: Text(
                                  "₹ $price",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                trailing: IconButton(
                                      onPressed: () {
                                        data.updateWishlist(FirebaseAuth.instance.currentUser!.email, documentId);
                                      },
                                      icon: isLiked ? const Icon(Icons.favorite, color: Colors.red) : const Icon(Icons.favorite_outline, color: Colors.red),
                                    ),
                      );
                      
                    } else {
                      return const SizedBox(width: 0.0, height: 0.0);
                    }
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
