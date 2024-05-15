import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeletePage extends StatefulWidget {
  DeletePage({Key? key, required this.itemSnapshot}) : super(key: key);
  final QuerySnapshot itemSnapshot;

  @override
  _DeletePageState createState() => _DeletePageState();
}

class _DeletePageState extends State<DeletePage> {
  late List<bool> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List<bool>.filled(widget.itemSnapshot.docs.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Items'),
      ),
      body: ListView.builder(
        itemCount: widget.itemSnapshot.docs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.itemSnapshot.docs[index]['imagepath']),
            ),
            title: Text(widget.itemSnapshot.docs[index]['Name']),
            subtitle: Text("${widget.itemSnapshot.docs[index]['Price']}"),
            trailing: Checkbox(
              value: _selectedItems[index],
              onChanged: (value) {
                setState(() {
                  _selectedItems[index] = value!;
                });
              },
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show confirmation dialog to delete selected items
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confirm Delete'),
                content: Text('Are you sure you want to delete the selected items?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      // Cancel delete operation
                      Navigator.of(context).pop();
                    },
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Confirm delete operation
                      List<int> indexesToDelete = [];
                      for (int i = 0; i < _selectedItems.length; i++) {
                        if (_selectedItems[i]) {
                          indexesToDelete.add(i);
                        }
                      }
                      if (indexesToDelete.isNotEmpty) {
                        // Delete items from Firestore
                        for (int index in indexesToDelete) {
                          await FirebaseFirestore.instance
                              .collection("Bakery")
                              .doc(widget.itemSnapshot.docs[index].id)
                              .delete();
                        }
                      }
                      // Close dialog
                      Navigator.of(context).pop();
                    },
                    child: Text('Yes'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.delete),
      ),
    );
  }
}

