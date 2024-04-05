import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_ease_user/widgets/mytimetile.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id == null) {
      return Scaffold(
        body: Center(
          child: Text('No order ID provided.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          "O R D E R  D E T I A L S",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .where("id", isEqualTo: id)
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final ordersData = snapshot.data!.docs;
          if (ordersData.isEmpty) {
            return const Center(child: Text('No Orders data found.'));
          }

          final orderMap = ordersData.first.data() as Map<String, dynamic>;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    orderMap["product name"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "₹ ${orderMap["price"]} ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Image.network(orderMap["image"]),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      Mytimetile(
                        isfirst: true,
                        islast: false,
                        ispast: orderMap["order placed"],
                        text: 'order placed',
                      ),
                      Mytimetile(
                        isfirst: false,
                        islast: false,
                        ispast: orderMap["order shipped"],
                        text: 'shipped',
                      ),
                      Mytimetile(
                        isfirst: false,
                        islast: false,
                        ispast: orderMap["out for delivery"],
                        text: 'out for delivery',
                      ),
                      Mytimetile(
                        isfirst: false,
                        islast: true,
                        ispast: orderMap["order delivered"],
                        text: 'order delivered',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
