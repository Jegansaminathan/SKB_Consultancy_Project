import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';


class Cart1 extends StatefulWidget {
  @override
  _Cart1State createState() => _Cart1State();
}

class _Cart1State extends State<Cart1> {
  late List<DocumentSnapshot> cartItems;
  int critical = 0;
  bool generatingBill = false;
  bool loading = false; // Added loading state
  late String imageUrl;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
    fetchImageUrl();
  }

  Future<void> fetchCartItems() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection("Tocart").get();
    setState(() {
      cartItems = querySnapshot.docs;
    });
  }

  Future<void> fetchImageUrl() async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage
          .instance
          .ref()
          .child('IMG-20240505-WA0006.jpg');
      imageUrl = await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching image URL: $e');
    }
  }

  void incrementCount(String docId, int currentCount) async {
    await FirebaseFirestore.instance.collection("Tocart").doc(docId).update({
      'count': currentCount + 1,
    });
  }

  void decrementCount(String docId, int currentCount) async {
    if (currentCount > 0) {
      int updatedCount = currentCount - 1;
      if (updatedCount == 0) {
        await FirebaseFirestore.instance
            .collection("Tocart")
            .doc(docId)
            .delete();
      } else {
        await FirebaseFirestore.instance.collection("Tocart").doc(docId).update({
          'count': updatedCount,
        });
      }
    }
  }

  Future<void> generateBill() async {
    if (cartItems == null) {
      await fetchCartItems();
    }

    if (cartItems.isNotEmpty) {
      setState(() {
        generatingBill = true;
        loading = true;
      });

      try {
        final pdf = pw.Document();
        String bino = DateTime.now().millisecondsSinceEpoch.toString();
        if (imageUrl != null) {
          final image = pw.MemoryImage(
            (await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl)).buffer.asUint8List(),
          );
          pdf.addPage(
            pw.MultiPage(
              build: (pw.Context context) => [
                pw.Container(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 147.2, // width
                            height: 188.6, // height
                            child: pw.Image(image),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.only(top: 10),
                        child: pw.Text(
                          'SRI KANDHAN BAKERY\nNH-67, Trichy Bye Pass, Emoor Pudhur,\nKarur-639007.\nPh: 86673 71048, 93636 41048\n\nCASH BILL',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Divider(),
                      pw.Row(
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Bill No: ${bino}'), // Generate random bill number
                              pw.SizedBox(height: 0.5), // Add some space between bill number and date
                              pw.Text('\nDate: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'), // Current date
                            ],
                          ),
                        ],
                      ),
                      pw.Table.fromTextArray(context: context, data: <List<String>>[
                        <String>['Item', 'Price', 'Count', 'Unit Price'],
                        for (var item in cartItems)
                          [
                            item["name"].toString(),
                            '\$${item["Price"].toString()}',
                            item["count"].toString(),
                            '\$${(item["count"] * item["Price"]).toStringAsFixed(2)}', // Calculate and format unit price
                          ]
                      ]),

                      pw.Divider(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }



        final output = await getTemporaryDirectory();
        final file = File("${output.path}/bill.pdf");
        await file.writeAsBytes(await pdf.save());

        String fileName = "bill:${bino}.pdf";
        String storagePath = "billpdf/$fileName";
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage
            .instance
            .ref()
            .child(storagePath);
        await ref.putFile(file);

        String downloadURL = await ref.getDownloadURL();

        DateTime now = DateTime.now();
        String formattedDate = "${now.year}-${now.month}-${now.day}";

        final billsCollectionRef =
        FirebaseFirestore.instance.collection("bills");

        await billsCollectionRef.add({
          'fileName': fileName,
          'url': downloadURL,
          'timestamp': FieldValue.serverTimestamp(),
        });

        OpenFile.open(file.path);

        for (var item in cartItems) {
          var itemName = item['name'];
          var bakeryRef =
          FirebaseFirestore.instance.collection('Bakery').doc(itemName);
          var bakeryDoc = await bakeryRef.get();
          if (bakeryDoc.exists) {
            var bakeryData =
            bakeryDoc.data() as Map<String, dynamic>;
            var quantity = bakeryData['quantity'];
            var count = item['count'];
            var updatedQuantity = quantity - count;
            await bakeryRef.update({'quantity': updatedQuantity});
          }
        }

        for (var item in cartItems) {
          await FirebaseFirestore.instance
              .collection("Tocart")
              .doc(item.id)
              .delete();
        }
      } catch (e) {
        print("Error generating bill: $e");
      } finally {
        setState(() {
          generatingBill = false;
          loading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cart is empty!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = 0;

    if (cartItems != null) {
      for (var item in cartItems) {
        var data = item.data() as Map<String, dynamic>;
        totalPrice += data["count"] * data["Price"];
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Cart'),
        actions: [
          IconButton(
            onPressed: () {
              if (cartItems.isNotEmpty) {
                setState(() {
                  generatingBill = true;
                  loading = true;
                });
                generateBill().then((_) {
                  setState(() {
                    loading = false;
                  });
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cart is empty!'),
                  ),
                );
              }
            },
            icon: Icon(Icons.playlist_add_check),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
              FirebaseFirestore.instance.collection("Tocart").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  cartItems = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      var item = cartItems[index].data() as Map<String, dynamic>;
                      double unitPrice = item["count"] * item["Price"];

                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(item["imagepath"]),
                              minRadius: 30,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${item["name"]}"),
                                Text("RS:${item["Price"]}"),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Count"),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          decrementCount(cartItems[index].id, item["count"]);
                                        });
                                      },
                                    ),
                                    Text(" ${item["count"]} "),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          incrementCount(cartItems[index].id, item["count"]);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Price"),
                                Text("$unitPrice"),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              },
            ),
          ),
          SizedBox(height: 20),
          if (loading)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      'Bill generating...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          if (!loading)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Text("Total Price: $totalPrice"),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
