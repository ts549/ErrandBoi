import 'dart:convert';
import 'package:flutter/material.dart';
import 'errand_form.dart';
import 'package:http/http.dart' as http;

class ErrandProvider with ChangeNotifier {
  List<Errand> _items = [];
  final url = 'http://localhost:5000/errands/create';

  List<Errand> errandFromJson(String str) =>
      List<Errand>.from(json.decode(str).map((x) => Errand.fromJson(x)));

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

  void addErrand(String? title, String? description, String requestor,
      double locLat, double locLng, int duration, double? reward) async {
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
      //return Errand.fromJson(jsonDecode(json));
    } else {
      throw Exception('Failed to add errand.');
    }
  }

  Future<List<Errand>> getErrandByLocation(
      double locLat, double locLng, int radius) async {
    var client = http.Client();
    final queryParameters = {
      'locLat': locLat.toString(),
      'locLng': locLng.toString(),
      'radius': radius.toString(),
    };
    final uri =
        Uri.http('127.0.0.1:5000', '/errands/get_by_location', queryParameters);
    final http.Response response = await client.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      String jsonStr = response.body;
      //print(jsonStr);
      var json = jsonDecode(jsonStr);
      Iterable i = jsonDecode(jsonStr)["results"];
      List<Errand> errands =
          List<Errand>.from(i.map((model) => Errand.fromJson(model)));
      return errands;
    } else {
      print(response.statusCode);
      throw Exception('Failed to add errand.');
    }
  }

  void takeErrand(String username, String id) async {
    var client = http.Client();
    final queryParameters = {
      'username': username,
      'errandId': id,
    };
    final uri = Uri.http('127.0.0.1:5000', '/errands/accept', queryParameters);
    final http.Response response = await client.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print(response.statusCode);
      throw Exception('Failed to add errand.');
    }
  }
}
