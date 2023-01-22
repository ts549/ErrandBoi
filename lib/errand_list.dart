import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<http.Response> fetchAlbum() {
  return http.get(Uri.parse('https://localhost'));
}

class ErrandForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Current Errands'),
          centerTitle: true,
        ),
      ),
    );
  }
}