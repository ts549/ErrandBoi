import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

import 'map.dart';
import 'errand_form.dart';

void main() {
  // runApp(MyApp());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Map());
  }
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {

    switch (settings.name) {
      case '/map':
        return MaterialPageRoute(builder: (_) => Map());
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

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(37.773972, -122.431297),
    zoom: 11.5,
  );

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

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
        onPressed: _getCurrentPosition,
        child: Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _add(LatLng pos) {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }

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
                child: _buildBottonNavigationMethod(),
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

  SizedBox _buildBottonNavigationMethod() {
    return SizedBox(
        height: 300,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
            color: Colors.lightBlue,
            height: 40.0,
            child: Center(
                child: Text(
              "Errand Details",
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
                      icon: Icon(Icons.description),
                      labelText:
                          "Here should be errand description, location, and payment"),
                ),
              ),
            ],
          )),
          ListTile(
            leading: Icon(Icons.check),
            title: Text('Take Errand'),
            //onTap Save errand to the database, otherwise it will not save
          ),
        ]));
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
