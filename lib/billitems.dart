import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart.dart';

class ItemsPageBill extends StatefulWidget {
  ItemsPageBill({Key? key, required this.item});
  final String item;

  @override
  State<ItemsPageBill> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPageBill> {
  late List<int> itemCounts = [];
  late List<int> availableQuantities = [];
  late List<DocumentSnapshot> data = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for accessing the ScaffoldState

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Bakery")
        .doc(widget.item)
        .collection(widget.item)
        .get();
    setState(() {
      data = querySnapshot.docs;
      itemCounts = List.filled(data.length, 0);
      availableQuantities =
          data.map<int>((doc) => doc['quantity'] as int).toList();
    });
  }

  void updateItemCount(int index, int newValue) async {
    if (newValue >= 0 && newValue <= availableQuantities[index]) {
      if (newValue == 0) {
        bool confirmRemove = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Remove from Cart?"),
              content: Text("Are you sure you want to remove this item from the cart?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // No, do not remove
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Yes, remove
                  },
                  child: Text("Remove"),
                ),
              ],
            );
          },
        );

        if (!confirmRemove!) return; // If user cancels, do not remove the item
      }

      await FirebaseFirestore.instance
          .collection("Bakery")
          .doc(widget.item)
          .collection(widget.item)
          .doc(data[index].id)
          .update({'count': newValue});

      setState(() {
        itemCounts[index] = newValue;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Invalid Quantity"),
            content: Text("Please enter a valid quantity within available stock."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> addToCart(DocumentSnapshot document, int count) async {
    if (count > 0) {
      await FirebaseFirestore.instance.collection("Tocart").add({
        'name': document["Name"],
        'count': count,
        'imagepath': document["imagepath"],
        'Price': document["Price"],
        'rootname': widget.item, // Add the rootname here
      });

      // Show success message as a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully added to cart."),
          duration: Duration(seconds: 2), // Adjust duration as needed
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to Scaffold
      body: (data.isNotEmpty)
          ? ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                          NetworkImage(data[index]["imagepath"]),
                          minRadius: 30,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name ${data[index]["Name"]}"),
                            Text("${data[index]["Price"]}"),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (itemCounts[index] > 0) {
                                    updateItemCount(
                                        index, itemCounts[index] - 1);
                                  }
                                });
                              },
                              icon: Icon(Icons.remove),
                            ),
                            Text("${itemCounts[index]}"),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  updateItemCount(
                                      index, itemCounts[index] + 1);
                                });
                              },
                              icon: Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      addToCart(data[index], itemCounts[index]);
                    },
                    child: Text("ToCart"),
                  ),
                ],
              ),
            ),
          );
        },
      )
          : CircularProgressIndicator(),
    );
  }
}
