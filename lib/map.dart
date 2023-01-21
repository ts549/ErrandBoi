import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'errand_form.dart';

class Map extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Location'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add_location),
              title: Text('Errands'),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
            ),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.bottomRight,
        child: ChangeNotifierProvider(
          create: (context) => MyAppState(),
          child: MaterialApp(
            title: 'ErrandBoi',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: Colors.white,
            ),
            home: MapScreen(),
          ),
        ),
        // IconButton(
        //   onPressed: () {
        //     Navigator.of(context).push(MaterialPageRoute(builder: (_) => RequestErrand()));
        //   },
        //   icon: Icon(Icons.add_location),
        //   iconSize: 50,
        // ),
      )
    )
   );
  }
}