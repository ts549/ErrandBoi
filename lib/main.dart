import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/errand_form.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'errand_form.dart';
import 'errand_provider.dart';

import 'errand_map.dart';
import 'errand_form.dart';

void main() {
  // runApp(MyApp());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ErrandMap());
  }
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {

    switch (settings.name) {
      case '/map':
        return MaterialPageRoute(builder: (_) => ErrandMap());
      case '/errand_form':
        return MaterialPageRoute(builder: (_) => ErrandForm());
    }

    return MaterialPageRoute(builder: (_) => Placeholder());
    
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Scaffold(
      body: Column(
        children: [
          Text('A random idea:'),
          BigCard(pair: pair),
          ElevatedButton(
            onPressed: () {
              appState.getNext();
            },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _currentAddress;
  Position? _currentPosition;

  static const LatLng center = LatLng(-33.86711, 151.1947171);
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{}; //list of markers
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(37.773972, -122.431297),
    zoom: 11.5,
  );

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  MarkerId? selectedMarker;
  int _markerIdCounter = 1;
  LatLng? markerPosition;

  void _printMarkers() async {
    Position? _currentPosition = await Geolocator.getLastKnownPosition();

    if (_currentPosition == null) {
      return;
    } else {
      var result = await ErrandProvider()
          .getErrandByLocation(
              _currentPosition.latitude, _currentPosition.longitude, 5000)
          .then(
        (value) {
          // value.map((errand) => {_add(LatLng(errand.locLat!, errand.locLng!))});
          value.forEach((element) {
            print(element.locLng);
            if (element.locLng != null && element.locLng != null) {
              print(element);
              populate(element);
            }
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext build) {
    return Scaffold(
      body: GoogleMap(
        myLocationButtonEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onLongPress: _add,
        markers: Set<Marker>.of(markers.values),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getCurrentPosition();
          _printMarkers();
        },
        child: Icon(Icons.center_focus_strong),
      ),
    );
  }

  void populate(Errand errand) {
    final int markerCount = markers.length;
    LatLng pos = LatLng(errand.locLat!, errand.locLng!);
    if (markerCount == 12) {
      return;
    }

    final String markerIdVal = errand.title!;
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(errand.errandId!);

    final Marker marker = Marker(
      markerId: markerId,
      position: pos,
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () => {
        _onMarkerTapped(markerId),
        showModalBottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            context: context,
            builder: (builder) {
              return Container(
                child: _buildBottonNavigationMethod(
                    errand.description!,
                    errand.reward!,
                    errand.requestor!,
                    errand.title!,
                    errand.errandId!,
                    markerId),
              );
            })
      },
      onDragEnd: (LatLng position) => _onMarkerDragEnd(markerId, position),
      onDrag: (LatLng position) => _onMarkerDrag(markerId, position),
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  void _add(LatLng pos) {
    final int markerCount = markers.length;
    print(pos);
    if (markerCount == 12) {
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => Home(pos: pos)));
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: pos,
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () => {
        _onMarkerTapped(markerId),
        showModalBottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            context: context,
            builder: (builder) {
              return Container(
                  //child: _buildBottonNavigationMethod(),
                  );
            })
      },
      onDragEnd: (LatLng position) => _onMarkerDragEnd(markerId, position),
      onDrag: (LatLng position) => _onMarkerDrag(markerId, position),
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  SizedBox _buildBottonNavigationMethod(String desc, double reward,
      String requestor, String title, String id, MarkerId markerId) {
    return SizedBox(
        height: 300,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
            color: Colors.lightBlue,
            height: 40.0,
            child: Center(
                child: Text(
              title,
              style: TextStyle(fontSize: 30),
            ) // Your desired title
                ),
          ),
          Form(
              child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      icon: Icon(Icons.description), labelText: desc),
                ),
              ),
            ],
          )),
          ListTile(
            leading: Icon(Icons.check),
            title: Text('Take Errand'),
            onTap: () =>
                _takeErrand(id, "Girvinn Fernandez", markerId), //change later
            //onTap Save errand to the database, otherwise it will not save
          ),
        ]));
  }

  void _takeErrand(String id, String username, MarkerId markerid) {
    ErrandProvider().takeErrand(username, id);
    _remove(markerid);
  }

  void _remove(MarkerId markerId) {
    setState(() {
      if (markers.containsKey(markerId)) {
        markers.remove(markerId);
      }
    });
  }

  void _onMarkerTapped(MarkerId markerId) {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        final MarkerId? previousMarkerId = selectedMarker;
        if (previousMarkerId != null && markers.containsKey(previousMarkerId)) {
          final Marker resetOld = markers[previousMarkerId]!
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[previousMarkerId] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;

        markerPosition = null;
      });
    }
  }

  Future<void> _onMarkerDrag(MarkerId markerId, LatLng newPosition) async {
    setState(() {
      markerPosition = newPosition;
    });
  }

  Future<void> _onMarkerDragEnd(MarkerId markerId, LatLng newPosition) async {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        markerPosition = null;
      });
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
                content: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 66),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Old position: ${tappedMarker.position}'),
                        Text('New position: $newPosition'),
                      ],
                    )));
          });
    }
  }

  Future<void> _goCurrent(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15,
    )));
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _goCurrent(position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(pair.asLowerCase, style: style),
      ),
    );
  }
}