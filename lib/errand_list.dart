import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<List<Errand>> getAllErrands() async {
  final response = await http.get(Uri.parse('localhost:5000/errands/get_all'));
  
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<Errand> errands = [];

    List errandsJson = jsonDecode(response.body);

    for (int i = 0; i < errandsJson.length; i++) {
      errands.add(Errand.fromJson(errandsJson[i]));
    }

    return errands;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load errands');
  }
}

class Errand {
  final String title;
  final String desc;
  final String requestor;
  final double locLat;
  final double locLng;
  final int duration;
  final double reward;

  const Errand({
    required this.title,
    required this.desc,
    required this.requestor,
    required this.locLat,
    required this.locLng,
    required this.duration,
    required this.reward,
  });

  factory Errand.fromJson(Map<String, dynamic> json) {
    return Errand(
      title: json['title'],
      desc: json['desc'],
      requestor: json['requestor'],
      locLat: json['locLat'],
      locLng: json['locLng'],
      duration: json['duration'],
      reward: json['reward'],
    );
  }

}

// class ErrandList extends StatelessWidget {

//   List<Errand> errandList = await getAllErrands();

//   @override
//   Widget build(BuildContext context) {

//     var errandListWidgets = [];

//     for (var i = 0; i < errandList.; i++) {

//       // add the ListTile to an array
//       errandListWidgets.add(new ListTile(title: new Text(value[i].name));

//     }

//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Current Errands'),
//           centerTitle: true,
//         ),
//         body: ListView(
//           children: errandList
//         ),
//       ),
//     );
//   }
// }

class ErrandList extends StatefulWidget {
  // ErrandList({Key key, this.title}) : super(key : key);

  // final String title;

  @override
  _ErrandListState createState() => _ErrandListState();
}

class _ErrandListState extends State<ErrandList> {

  Future<List<Errand>> errands = getAllErrands();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List of Errands"),
      ),
      body: Container(
        child: FutureBuilder(
          future: errands,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(
                  child: Text("Loading....."),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length(),
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(snapshot.data[index].imageUrl),
                    ),
                      title: Text(snapshot.data[index].title),
                  );
                }
              );
            }
          },
        ),
      ),
    );
  }
}