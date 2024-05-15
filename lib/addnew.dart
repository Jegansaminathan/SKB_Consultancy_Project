import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:quickalert/quickalert.dart';

class Product {
  final String rootname;
  final String name;
  final double price;
  final String quantity ;
  late String imagepath;

  Product({
    required this.rootname,
    required this.imagepath,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class Addnew extends StatefulWidget {
  const Addnew({Key? key}) : super(key: key);

  @override
  _AddnewState createState() => _AddnewState();
}

class _AddnewState extends State<Addnew> {
  late TextEditingController _rootnameContoller;
  late ImageController _imageController;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  final _picker = ImagePicker();
  File? _imageFile;
  CroppedFile? _croppedFile;
  @override
  void initState() {
    super.initState();
    _rootnameContoller = TextEditingController();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _quantityController = TextEditingController();
    _imageController = ImageController();
  }

  @override
  void dispose() {
    _rootnameContoller.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<File?> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (error) {
      print('Error picking image: $error');
    }
    return null;
  }

  Future<void> _cropImage(File imageFile) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
      aspectRatioPresets: [CropAspectRatioPreset.square],
       uiSettings: [AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      )]
    ) ;
    setState(() {
      _croppedFile = croppedImage ;
    });
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      // Upload image to Firebase Cloud Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = FirebaseStorage.instance.ref().child('images/$fileName.jpg');
      UploadTask uploadTask = reference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (error) {
      print('Error uploading image: $error');
      return ''; // Return empty string if upload fails
    }
  }

  void _saveProduct() async {
    // Retrieve product details from text fields
    String rootname = _rootnameContoller.text;
    String name = _nameController.text;
    double price = double.tryParse(_priceController.text) ?? 0.0;
    String quantity = _quantityController.text; // Get expected sellout date

    // Create a new Product object
    Product newProduct = Product(
      rootname: rootname,
      name: name,
      price: price,
      quantity: quantity,
      imagepath: _imageController.image!.toString(),
    );

    // Upload image and save product details to Firestore
    if (_imageFile != null) {
      String imageUrl = await _uploadImageToFirebase(_imageFile!);
      if (imageUrl.isNotEmpty) {
        newProduct.imagepath = imageUrl;

        DocumentSnapshot data=await FirebaseFirestore.instance.collection("Items").doc("Item").get();
        List<dynamic> list=data.get("data");
        Set<dynamic> set = Set<dynamic>.from(list);
        set.add(_rootnameContoller.text);

        await FirebaseFirestore.instance.collection("Items").doc("Item").
        update({
          "data": set
          });

        await FirebaseFirestore.instance.collection("Bakery").doc(_rootnameContoller.text).
        collection(_rootnameContoller.text).doc().set({
          "rootname": newProduct.rootname,
          "Name": newProduct.name,
          "Price": newProduct.price,
          "quantity":0,
          "imagepath": newProduct.imagepath,
        }).then((_) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Product added successfully!',
          );
          Navigator.pop(context, newProduct);
        }).catchError((error) {
          print("Failed to add product: $error");
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: 'Failed to add product',
          );
        });
      }
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: 'Please select an image',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context, false),

        ),
        title: Text('Add Product'),
        backgroundColor: Colors.blue,
      ),
      body:Padding(
          padding: const EdgeInsets.all(16.0),
          child:SingleChildScrollView(
            child: Column(

              children: [
                TextField(
                  controller: _rootnameContoller,
                  decoration: InputDecoration(labelText: 'General Name'),
                ),
                SizedBox(height: 16.0),
                SizedBox(height: 20),
                Container(
                  child:GestureDetector(
                        onTap: () async {
                          File? imageFile = await _pickImage(ImageSource.gallery);

                            await _cropImage(imageFile!);
                            if (_croppedFile != null) {
                              setState(() {
                                _imageFile = File(_croppedFile!.path);
                                _imageController.image = FileImage(_imageFile!);
                              });
                            }

                        },
                        child: (_imageFile!=null)?Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ):Text("New"),
                      ),


                ),
                SizedBox(height: 20),
                Center(
                  child: _imageController.image != null
                      ? Image(image: _imageController.image!)
                      : Container(),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _saveProduct,
                  child: Text('Add Product'),
                ),
              ],
            )
          ),
        ),

    );
  }
}

class ImageController {
  ImageProvider? _image;

  set image(ImageProvider? value) {
    _image = value;
  }

  ImageProvider? get image => _image;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductListPage(),
    );
  }
}

class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Navigate to add product page and collect new product details
            final newProduct = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Addnew()),
            );

            // Handle the new product data
            if (newProduct != null && newProduct is Product) {
              print('New Product Added:');
              print('Name: ${newProduct.name}');
              print('Price: ${newProduct.price}');
              print('IN_date: ${newProduct.quantity}');
              // You can add the logic to save the new product to a list or database here
            }
          },
          child: Text('Add Product'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
