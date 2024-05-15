import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sbkprj/itempage.dart';
import 'billhistory.dart';
import 'login.dart';

class Screen2 extends StatefulWidget {
  const Screen2({Key? key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Current Stock"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async{
              await FirebaseAuth.instance.signOut();
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return LoginPage();
                  },
                ),
                    (_) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Bill History'),
              onTap: () {
                // Navigate to Bill History screen and pass the current user's ID to fetch their bills
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BillHistoryScreen()),
                );
              },

            ),
            ListTile(
              title: Text('Today\'s Sales'),
              onTap: () {
                // Navigate to Today's Sales screen
                // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => TodaysSalesScreen()));
              },
            ),
          ],
        ),
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
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection("Bakery").doc(data[index]).collection(data[index]).snapshots(),
                        builder: (context, snap) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData && snap.data != null) {
                            int co = 0;
                            List<DocumentSnapshot> datas = snap.data!.docs;

                            for (int i = 0; i < datas.length; i++) {
                              co += int.parse(datas[i].get("quantity").toString());
                            }

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
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Items(data: datas)));
                                },
                                child: Column(
                                  children: [
                                    Text("${data[index]}"),
                                    Text("Total : ${co}"),
                                    Text("No of products: ${datas.length}")
                                  ],
                                ),
                              ),
                            );
                          } else
                            return Container(width: 50, height: 50, child: CircularProgressIndicator());
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
