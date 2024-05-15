import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'delete_items_all.dart';

class EditItemsPage extends StatefulWidget {
  EditItemsPage({Key? key, required this.item}) : super(key: key);
  final String item;

  @override
  State<EditItemsPage> createState() => _EditItemsPageState();
}

class _EditItemsPageState extends State<EditItemsPage> {
  TextEditingController add = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Items'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Access the specific document snapshot
              FirebaseFirestore.instance
                  .collection("Bakery")
                  .get()
                  // .doc()
                  .then((QuerySnapshot snapshot) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeletePage(itemSnapshot: snapshot)),
                );
              });

            },
          ),
        ],
      ),
    body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Bakery")
                .doc(widget.item)
                .collection(widget.item)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                List<DocumentSnapshot> data = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: data.length,
                  shrinkWrap: true,
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
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  data[index]["imagepath"],
                                ),
                                minRadius: 30,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Name ${data[index]["Name"]}"),
                                  Text("${data[index]["Price"]}"),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Center(child: Text('Remove Product')),
                                        content: Container(
                                          height: 100,
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                decoration: InputDecoration(labelText: 'Qty to remove'),
                                                controller: add,
                                              )
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () async {
                                              int quantityToRemove = int.parse(add.text);
                                              int currentQuantity = data[index]["quantity"];
                                              if (quantityToRemove > currentQuantity) {
                                                // Show alert if remove quantity is greater than available quantity
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text('Error'),
                                                      content: Text('Remove Qty is Greater than Available Qty'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text('OK'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                try {
                                                  await FirebaseFirestore.instance.collection("Bakery").
                                                  doc(widget.item).collection(widget.item).doc(data[index].id).update({
                                                    "quantity": currentQuantity - quantityToRemove,
                                                    "product_updatedate": DateTime.now()
                                                  });
                                                  Navigator.pop(context);
                                                } catch(e) {
                                                  // Handle error
                                                  print(e.toString());
                                                }
                                              }
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Icon(Icons.remove),
                                    Text("remove")
                                    // (va==0)?Text("Remove"):IconButton(onPressed:(){
                                    //
                                    // } , icon: Icon(Icons.check_box_outline_blank)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(child: Text('No data available'));
              }
            },
          )
        ],
      ),
    );
  }
}

class Items extends StatefulWidget {
  Items({super.key,required this.data});
  List<DocumentSnapshot> data;
  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          ListView.builder(
            itemCount: widget.data.length,
            shrinkWrap: true,

            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(10), // Optional: Adds rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3), // Shadow color
                        spreadRadius: 3, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: Offset(0, 3), // Offset position of shadow
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(


                          backgroundImage: NetworkImage(
                              widget.data[index]["imagepath"]
                          ),
                          minRadius: 30,
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text("Name: ${widget.data[index]["Name"]}"),
                            Text("${widget.data[index]["quantity"]}"),



                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
