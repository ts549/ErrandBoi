import 'dart:convert';
import 'package:flutter/material.dart';
import 'errand_form.dart';
import 'package:http/http.dart' as http;

class ErrandProvider with ChangeNotifier {
  List<Errand> _items = [];
  final url = 'http://localhost:5000/errands/create';

  List<Errand> get items {
    return [..._items];
  }

  // Future<void> addErrand(String task) async {
  //     if(task.isEmpty){
  //     return;
  //   }

  //   Map<String, dynamic> request = {"name": task, "is_executed": false};
  //   final headers = {'Content-Type': 'application/json'};
  //   final response = await http.post(Uri.parse(url), headers: headers, body: json.encode(request));
  //   Map<String, dynamic> responsePayload = json.decode(response.body);
  //   final errand = Errand(
  //       id: responsePayload["id"],
  //       itemName: responsePayload["name"]);
  // }

  Future<Errand> addErrand(String? title, String? description, String requestor,
      double locLat, double locLng, int duration, int? reward) async {
    var client = http.Client();
    var uri = Uri.parse("http://127.0.0.1:5000/errands/create");
    final http.Response response = await client.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'title': title,
        'desc': description,
        'requestor': requestor,
        'locLat': locLat,
        'locLng': locLng,
        'duration': duration,
        'reward': reward
      }),
    );
    if (response.statusCode == 200) {
      var json = response.body;
      return Errand.fromJson(jsonDecode(json));
    } else {
      throw Exception('Failed to add errand.');
    }
  }
}
