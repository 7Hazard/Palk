import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/screens/new_chat_screen.dart';
import 'package:flutter_chat_ui/screens/scan_code_screen.dart';
import 'package:flutter_chat_ui/widgets/category_selector.dart';
import 'package:flutter_chat_ui/widgets/recent_chats.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: Icon(Icons.menu),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {},
          ),
          title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'Palk ',
              style: TextStyle(
                fontFamily: 'OpenSansBold',
                fontSize: 26.0,
              ),
            ),
            Image.asset(
              'assets/images/palk_icon.png',
              height: 25,
              width: 25,
            )
          ]),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            CategorySelector(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    RecentChats(),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                print("New Chat");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewChatScreen(),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),

            SizedBox(width: 10), // Padding

            FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                print("Scan Code");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScanCodeScreen(),
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
              ),
            )
          ],
        ));
  }
}
