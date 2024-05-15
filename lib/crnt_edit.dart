
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'edititems.dart';

class Crntedit extends StatelessWidget {
  const Crntedit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back),
          onPressed:() {
          Navigator.pop(context);
        }, ),
        title: Text("EDIT"),
      ),
        body:StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection("Items").doc("Item").snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              List<dynamic> data = snapshot.data?.get("data");

              return GridView.builder(
                itemCount: data.length,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  return Container(
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
                    child: TextButton(

                      onPressed: () {
                        print(data[index]);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>EditItemsPage(item: data[index])));
                      },
                      child: Text("${data[index]}"),
                    ),
                  );
                },
              );
            } else {
              return Text('No data available');
            }
          },
        )

    );
  }
}
