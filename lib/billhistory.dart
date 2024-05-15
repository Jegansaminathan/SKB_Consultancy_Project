import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sbkprj/showpdf.dart';
import 'package:url_launcher/url_launcher.dart';

class BillHistoryScreen extends StatefulWidget {
  @override
  _BillHistoryScreenState createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {





Future<File> createFileOfPdfUrl(String url) async {
  Completer<File> completer = Completer();
  print("Start download file from internet!");
  try {

    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    var dir = await getApplicationDocumentsDirectory();
    print("Download files");
    print("${dir.path}/$filename");
    File file = File("${dir.path}/$filename");

    await file.writeAsBytes(bytes, flush: true);
    completer.complete(file);
  } catch (e) {
    throw Exception('Error parsing asset file!');
  }

  return completer.future;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bill History"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bills").orderBy("timestamp",descending: true)// Replace "2024-5-4" with the appropriate date
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

            if (documents.isEmpty) {
              return Center(
                child: Text("No bills found."),
              );
            }

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['fileName']),
                  onTap: () async{
                    String url= "";
                    await createFileOfPdfUrl(data['url']).then((f) {
                      setState(() {
                        url = f.path;
                      });
                    });
                    print(data["url"]);
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>PdfViewerPage(pdf: url))); // Open PDF when tapped
                  },
                );
              },
            );
          } else {
            return Center(
              child: Text("No data available."),
            );
          }
        },
      ),
    );
  }

  // Function to launch URL
  void _launchURL(String url) async {
    if (await canLaunchUrl(url as Uri)) {
      await launchUrl(url as Uri); // Replace launch with launchUrl
    } else {
      throw 'Could not launch $url';
    }
  }
}
