import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemsPage extends StatefulWidget {
  ItemsPage({super.key,required this.item});
  String item;
  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  TextEditingController add = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("Bakery").doc(widget.item).collection(widget.item).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                List<DocumentSnapshot> data = snapshot.data!.docs;
                print(data);
                return ListView.builder(
                  itemCount: data.length,
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
                                    data[index]["imagepath"]
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
                              TextButton(onPressed: (){

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Center(child: Text('Add Product')),
                                        content: Container(
                                          height: 100,
                                          child: Column(
                                            children: [

                                              TextFormField(
                                                decoration: InputDecoration(labelText: 'Qty'),
                                                controller: add,
                                              )
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () async{
                                              try{
                                                if(data[index]["quantity"]==null){
                                                  print(data);
                                                }
                                                await FirebaseFirestore.instance.collection("Bakery").
                                                doc(widget.item).collection(widget.item).doc(data[index].id).update({
                                                  "quantity":data[index]["quantity"]+int.parse(add.text),
                                                  "product_updatedate":DateTime.now()
                                                });

                                                Navigator.pop(context);
                                              }catch(e){
                                                await FirebaseFirestore.instance.collection("Bakery").
                                                doc(widget.item).collection(widget.item).doc(data[index].id).update({
                                                  "quantity":int.parse(add.text),
                                                  "product_updatedate":DateTime.now()
                                                });
                                                Navigator.pop(context);
                                              }

                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );});

                              }, child: const Row(
                                children: [
                                  Icon(Icons.edit),
                                  Text("Add"),
                                ],
                              ))
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
