import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tan_project/services/location.service.dart';
import 'package:tan_project/views/widgets/arret_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}


class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final Set<Marker> _markers = <Marker>{};
  final Set<Polygon> _polygons = <Polygon>{};
  final Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polygonLatLngs = <LatLng>[];
  var _arrets;
  var _arrets2;
  int _polygonIdCounter = 1;
  final int _polylineIdCounter = 1;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(47.2186371, -1.5541362),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
  }

  void _setMarker(LatLng point){
    setState(() {
      _markers.add(
        Marker(
            markerId:  const MarkerId('marker'),
            position: point,
        ),
      );
    });
  }

  void _setPolygon(){
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(
        Polygon(
          polygonId: PolygonId(polygonIdVal),
          points: polygonLatLngs,
          strokeWidth: 2,
          fillColor: Colors.transparent,
        ),
    );
  }

  void _setPolyline(List<PointLatLng> points){
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    //_polylineIdCounter++;
    _polylines.add(
      Polyline(polylineId: PolylineId(polylineIdVal),
        width: 2,
        color:  Colors.blue,
        points:  points.map(
            (point) => LatLng(point.latitude, point.longitude),
        ).toList()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TanProject'),),
      body: Column(
        children: [
        Row (
          children: [
          Expanded (
            child: Column(
              children : [
                TextFormField (
                  controller: _originController,
                  decoration: const InputDecoration(hintText: 'Lieu de Départ'),
                  onChanged: (value) {
                    if (kDebugMode) {
                      print(value);
                    }
                  },
                ),
                TextFormField(
                  controller: _destinationController,
                  decoration: const InputDecoration(hintText: 'Destination'),
                  onChanged: (value) {
                    if (kDebugMode) {
                      print(value);
                    }
                  },
                ),
              ],
            ),
          ),
            IconButton(
            onPressed: () async {
              var directions = await LocationService().getDirections(_originController.text, _destinationController.text);
              _goToTheSearchPlace(directions['end_location']['lat'], directions['end_location']['lng'], directions['bounds_sw'], directions['bounds_ne']);
              _setPolyline(directions['polyline_decoded']);
            },
            icon: const Icon(Icons.search),
            ),
          ],),
          Expanded (
            child: GoogleMap(
              mapType: MapType.normal,
              markers: _markers,
              polygons:  _polygons,
              polylines: _polylines,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToTheSearchPlace(double lat, double lng, Map<String, dynamic> boundsSw, Map<String, dynamic> boundsNe) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition
      (
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      )
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
          northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
        ),
        25),
    );
    _setMarker(LatLng(lat, lng));
  }
}