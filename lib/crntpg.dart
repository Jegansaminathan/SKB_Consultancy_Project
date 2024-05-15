import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sbkprj/itempage.dart';
import 'package:sbkprj/screen2.dart';
import 'addnew.dart';
import 'billing.dart';
import 'crnt_edit.dart';
import 'note.dart';
class Crntpg extends StatefulWidget {
  const Crntpg({super.key});

  @override
  State<Crntpg> createState() => _CrntpgState();
}

class _CrntpgState extends State<Crntpg> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavBar(),
    );
  }
}
class BottomNavBar extends StatefulWidget{
  const BottomNavBar({Key?key}):super(key :key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  get cartModel => null;

  @override
  Widget build(BuildContext context) {
    List<Widget> _buildScreens() {
      return [
        const Screen1(),
        const Screen2(),
        const Screen3(),
        Screen4(),
      ];
    }
    List<PersistentBottomNavBarItem> _navBarsItems() {
      return [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.receipt),

          title: ("BILL"),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
          iconSize: 30,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.layers),
          title: ("AVAILABLE"),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.inventory),
          title: ("REFILL"),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.note_alt),
          title: ("NOTE"),
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Colors.grey,
        ),
      ];
    }
    PersistentTabController _controller;

    _controller = PersistentTabController(initialIndex: 0);
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: const ItemAnimationProperties( // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style1, // Choose the nav bar style with this property.
    );
  }}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body:Center(child: Text('screen1',style: TextStyle(fontSize: 30),) ,),
    );

  }


class Screen3 extends StatefulWidget {
  const Screen3({Key? key}) : super(key: key);

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body:  Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20,left: 110),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context,MaterialPageRoute(builder: (context) =>  Crntedit()) );
                      },
                      label: const Text('EDIT'),
                      icon: const Icon(Icons.edit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20,left: 10),
                    child: ElevatedButton.icon(
                     onPressed: () async{
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => Addnew()),
                       );
                     },
                         label: const Text('NEW'),
                          icon: const Icon(Icons.add),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,)
                  ),),

            ],
            ),
                  ),


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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>ItemsPage(item: data[index])));
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

          ],
        ),
      ),
    );


  }
}



