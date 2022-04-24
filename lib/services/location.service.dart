import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LocationService {

  final String key = 'AIzaSyC3zcupcUwNOtWH-Q6mlbgMH36lSffOgT0';

  Future<String> getPlaceId(String input) async {

    final String url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.json.decode(response.body);
    var placeId= json['candidates'][0]['place_id'] as String;

    if (kDebugMode) {
      print("placeId : " + placeId);
    }

    return placeId;
  }
  Future<Map<String, dynamic>> getPlace(String input) async {
    final placeId = await getPlaceId(input);
    final String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&inputtype=textquery&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.json.decode(response.body);
    var results = json['result'] as Map<String, dynamic>;

    if (kDebugMode) {
      print(results);
    }

    return results;
  }

  Future<Map<String, dynamic>> getPlaceCoordonate(String input) async {
    final placeId = await getPlaceId(input);
    final String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&inputtype=textquery&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.json.decode(response.body);
    var results = json['result']['geometry']['location'];

    if (kDebugMode) {
      print(results);
    }

    return results;
  }

  Future<Map<String, dynamic>> getDirections(String origin, String destination) async {

    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.json.decode(response.body);
    if (kDebugMode) {
      print(json);
    }
    var results = {
      'bounds_ne' : json['routes'][0]['bounds']['northeast'],
      'bounds_sw' : json['routes'][0]['bounds']['southwest'],
      'start_location' : json['routes'][0]['legs'][0]['start_location'],
      'end_location' : json['routes'][0]['legs'][0]['end_location'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'polyline_decoded': PolylinePoints().decodePolyline(json['routes'][0]['overview_polyline']['points']),
    };
    return results;
  }

  Future<Map<String, dynamic>> getArrets(String searchPlace) async {

    final place = await getPlaceCoordonate(searchPlace);
    var lat = place['lat'];
    var lng = place['lng'];
    final String url = 'https://open.tan.fr/ewp/arrets.json/$lat/$lng';

    var response = await http.get(Uri.parse(url));
    var json = convert.json.decode(response.body);

    var results = {
      'codeLieu1' : json[0]['codeLieu'],
      'libelle1' : json[0]['libelle'],
      'distance1' : json[0]['distance'],
      'ligne1' : json[0]['ligne'],
      'codeLieu2' : json[1]['codeLieu'],
      'libelle2' : json[1]['libelle'],
      'distance2' : json[1]['distance'],
      'ligne2' : json[1]['ligne'],
      'codeLieu3' : json[2]['codeLieu'],
      'libelle3' : json[2]['libelle'],
      'distance3' : json[2]['distance'],
      'ligne3' : json[2]['ligne'],
    };

    if (kDebugMode) {
      print(results);
    }
    return results;
  }
}
