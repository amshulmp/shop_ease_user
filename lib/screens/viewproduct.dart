import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_ease_user/config/configuration.dart';
import 'package:shop_ease_user/config/routes.dart';


class ViewProduct extends StatefulWidget {
  const ViewProduct({super.key});

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;
   final id=data["id"];
  //  final email=data["email"];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("products")
            .where("productid", isEqualTo: id)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final productData = snapshot.data!.docs;
          final productDoc = productData.first;
          final documentId = productDoc.id;
          final productMap = productData.first.data() as Map<String, dynamic>;
          return ListView(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: MyConstants.screenHeight(context) * 0.01),
                child: CarouselSlider.builder(
                  itemCount: productMap["imageUrls"].length,
                  options: CarouselOptions(
                    enlargeCenterPage: true,
                    autoPlay: true,
                    viewportFraction: 1,
                    height: MyConstants.screenHeight(context) * 0.5,
                  ),
                  itemBuilder: (BuildContext context, int index, _) {
                    return Image.network(
                      productMap["imageUrls"][index],
                      fit: BoxFit.scaleDown,
                    );
                  },
                ),
              ),
              const Divider(),
              ProductAndDescription(
                productName: productMap["productName"],
                description: productMap["description"],
                price: productMap["price"],
                stock: productMap["stock"],
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("products")
                      .doc(documentId)
                      .update({"stock": productMap["stock"] + 1});
                },
              )
            ],
          );
        },
      ),
      bottomNavigationBar: SizedBox(
        height: MyConstants.screenHeight(context) * 0.07,
        child: Row(
          children: [
            Expanded(
                child: GestureDetector(
              onTap:   ()  {
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  
    updatecart(userEmail, id,context);
    
 
},
              child: Container(
                color: Colors.green.shade100,
                child: Center(
                  child: Text(
                    "add to cart",
                    style: TextStyle(
                        fontSize: MyConstants.screenHeight(context) * 0.026,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )),
            Expanded(
                child: GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, Routes.odrsumm,arguments:[id]);
                  },
              child: Container(
                color: Colors.green,
                child: Center(
                  child: Text(
                    "Buy now",
                    style: TextStyle(
                        fontSize: MyConstants.screenHeight(context) * 0.026,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class ProductAndDescription extends StatelessWidget {
  final String productName;
  final String description;
  final dynamic price;
  final dynamic stock;
  final dynamic onPressed;
  const ProductAndDescription(
      {super.key,
      required this.productName,
      required this.description,
      required this.price,
      required this.stock,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₹ $price",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
void updatecart(String? userEmail, String productId,BuildContext context) async {

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: userEmail)
        .get();
    var doc = snapshot.docs.first;
    Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

    List<dynamic> cart = userData["cart"] ?? [];

if (cart.contains(productId)) {
   
    return  showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            color: Theme.of(context).colorScheme.secondary,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text("Product already exists in the cart.")],
            ),
          ),
        );
      },
    );
  }
 else{
   cart.add(productId);

      await doc.reference.update({"cart": cart});
      print("Product added to cart: $productId");
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            color: Theme.of(context).colorScheme.secondary,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text("Product added to cart")],
            ),
          ),
        );
      },
    );
 }
  
     
  }
