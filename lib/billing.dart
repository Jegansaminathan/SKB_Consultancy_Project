import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart' as Badges;
import 'billitems.dart';
import 'cart.dart';

class Screen1 extends StatefulWidget {
  const Screen1({Key? key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  late Stream<QuerySnapshot> _cartStream; // Stream to listen for changes in Tocart collection

  @override
  void initState() {
    super.initState();
    _cartStream = FirebaseFirestore.instance.collection("Tocart").snapshots(); // Initialize the stream
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BILLING PRODUCTS', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: StreamBuilder<QuerySnapshot>(
              stream: _cartStream, // Listen to changes in Tocart collection
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  int totalItemsInCart = snapshot.data!.size; // Get the count of documents in Tocart collection
                  return Badges.Badge(
                    badgeContent: Text(totalItemsInCart.toString()),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Cart1()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: Icon(Icons.shopping_bag_outlined, size: 30, color: Colors.black),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection("Items").doc("Item").snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  List<dynamic>? data = snapshot.data?.get("data");

                  return GridView.builder(
                    itemCount: data?.length ?? 0,
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection("Bakery").doc(data![index]).collection(data[index]).snapshots(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snap.hasError) {
                            return Text('Error: ${snap.error}');
                          } else if (snap.hasData && snap.data != null) {
                            int co = 0;
                            List<DocumentSnapshot> datas = snap.data!.docs;

                            for (int i = 0; i < datas.length; i++) {
                              co -= int.parse(datas[i].get("quantity").toString());
                            }

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                color: Colors.white,
                              ),
                              child: TextButton(
                                onPressed: () {
                                  print(data[index]);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ItemsPageBill(item: data[index])),
                                  );
                                },
                                child: Text("${data[index]}"),
                              ),
                            );
                          } else {
                            return Container(
                              height: 10,
                              width: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                                strokeAlign: 10,
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                } else {
                  return Text('No data available');
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
