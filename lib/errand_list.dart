import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:expandable/expandable.dart';

// Future<List<Errand>> getAllErrands() async {
//   final response = await http.get(Uri.parse('http://localhost:5000/errands/get_all'));
  
//   if (response.statusCode == 200) {
//     // If the server did return a 200 OK response,
//     // then parse the JSON.
//     List<Errand> errands = [];

//     List errandsJson = jsonDecode(response.body);

//     for (int i = 0; i < errandsJson.length; i++) {
//       errands.add(Errand.fromJson(errandsJson[i]));
//     }

//     return errands;
//   } else {
//     // If the server did not return a 200 OK response,
//     // then throw an exception.
//     throw Exception('Failed to load errands');
//   }
// }

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
      locLat: json['location']['coordinates'][1],
      locLng: json['location']['coordinates'][0],
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

  Future<List<Errand>> GetJson() async {
    Uri url = Uri.parse('http://localhost:5000/errands/get_all');
    var data = await http.get(url);
    Iterable jsonData = json.decode(data.body)['results'];

    print(jsonData);

    // List<Errand> items = [];
    List<Errand> items = List<Errand>.from(jsonData.map((model) => Errand.fromJson(model)));
    // for (var ma in jsonData) {
    //   Errand m = Errand.fromJson(ma);
    //   items.add(m);
    // }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List of Errands"),
      ),
      body: Container(
        child: FutureBuilder(
          future: GetJson(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(
                  child: Text("Loading....."),
                ),
              );
            } else {
              return ListView.builder(
                itemExtent: 200.0,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                    ),
                    title: Text(snapshot.data[index].title),
                    subtitle: ListView(
                      padding: const EdgeInsets.fromLTRB(20,30,0,0),
                      children: <Widget>[
                        Container(
                          height: 30,
                          child: Text("Requestor: " + snapshot.data[index].requestor),
                        ),
                        Container(
                          height: 30,
                          child: Text("Description: " + snapshot.data[index].desc),
                        ),
                        Container(
                          height: 30,
                          child: Text("Duration: " + snapshot.data[index].duration.toString()),
                        ),
                        Container(
                          height: 30,
                          child: Text("Reward: " + snapshot.data[index].reward.toString()),
                        ),
                        // Text(snapshot.data[index].desc),
                        // Text(snapshot.data[index].duration.toString()),
                        // Text(snapshot.data[index].reward.toString()),
                      ],
                    ),
                  );
                }
              );

              // return ExpansionPanelList (
              //   expansionCallback: (int index, bool isExpanded) {},
              //   children: [
              //     ExpansionPanel(
              //       headerBuilder: (BuildContext context, bool isExpanded) {
              //         return ListTile(
              //           title: Text('Item 1'),
              //         );
              //       },
              //       body: ListTile(
              //         title: Text('Item 1 child'),
              //         subtitle: Text('Details goes here'),
              //       ),
              //       isExpanded: true,
              //     ),
              //     ExpansionPanel(
              //       headerBuilder: (BuildContext context, bool isExpanded) {
              //         return ListTile(
              //           title: Text('Item 2'),
              //         );
              //       },
              //       body: ListTile(
              //         title: Text('Item 2 child'),
              //         subtitle: Text('Details goes here'),
              //       ),
              //       isExpanded: false,
              //     ),
              //   ],
              //   // expanded: ListView.builder(
              //   //   itemCount: snapshot.data.length,
              //   //   itemBuilder: (BuildContext context, int index) {
              //   //     return ListTile(
              //   //       leading: CircleAvatar(
              //   //       ),
              //   //       title: Text(snapshot.data[index].title),
              //   //       subtitle: Text(
              //   //         snapshot.data[index].requestor,
              //   //       )
              //   //     );
              //   //   }
              //   // ),
              //   // collapsed: ListView.builder(
              //   //   itemCount: snapshot.data.length,
              //   //   itemBuilder: (BuildContext context, int index) {
              //   //     return ListTile(
              //   //       leading: CircleAvatar(
              //   //       ),
              //   //       title: Text(snapshot.data[index].title),
              //   //     );
              //   //   }
              //   // ),
              // );
            }
          },
        ),
      ),
    );
  }
}