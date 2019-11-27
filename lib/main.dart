import 'package:codelab_map/geodata.dart' as geodata;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/locations.dart' as locations;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleMapController mapController;
  final Map<String, Marker> _markers = {};
  Set<Polygon> _polygons;
  BitmapDescriptor _markerIcon;

  bool isNight = false;
  String night_style;

  final LatLng _center = const LatLng(45.08193200962874, 7.660238742828369);

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    final googleOffices = await locations.getGoogleOffices();
    final geoData = await geodata.getGeoData();
    night_style = await rootBundle.loadString('assets/map_style.json');
    //await controller.setMapStyle(night_style);
    setState(() {
      _polygons = geoData.polygons.map((polygon) {
        return Polygon(
            polygonId: PolygonId(polygon.id),
            fillColor: Colors.orange,
            strokeColor: Colors.orangeAccent,
            points: polygon.coordinates.map((point) {
              return LatLng(point.lat, point.lng);
            }).toList());
      }).toSet();
    });
    var point = geoData.points.first;
    Marker marker = Marker(
      markerId: MarkerId(point.id),
      position: LatLng(
        point.coordinate.lat,
        point.coordinate.lng,
      ),
      icon: _markerIcon,
    );

    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
      _markers[point.id] = marker;
    });
  }

  @override
  Widget build(BuildContext context) {
    _createMarkerImageFromAsset(context);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 16.0,
              ),
              markers: _markers.values.toSet(),
              polygons: _polygons,
            ),
            RaisedButton(
              child: Text('Change style'),
              onPressed: () {
                setState(() {
                  if (isNight) {
                    mapController.setMapStyle(null);
                    isNight = false;
                  } else {
                    mapController.setMapStyle(night_style);
                    isNight = true;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context);
      BitmapDescriptor bitmap = await BitmapDescriptor.fromAssetImage(
          imageConfiguration, 'assets/flutter.png');
      setState(() {
        _markerIcon = bitmap;
      });
    }
  }
}
