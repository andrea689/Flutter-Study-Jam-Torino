// To parse this JSON data, do
//
//     final geoData = geoDataFromJson(jsonString);

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

GeoData geoDataFromJson(String str) => GeoData.fromJson(json.decode(str));

String geoDataToJson(GeoData data) => json.encode(data.toJson());

class GeoData {
  List<Polygon> polygons;
  List<Point> points;

  GeoData({
    this.polygons,
    this.points,
  });

  factory GeoData.fromJson(Map<String, dynamic> json) => GeoData(
        polygons: List<Polygon>.from(
            json["polygons"].map((x) => Polygon.fromJson(x))),
        points: List<Point>.from(json["points"].map((x) => Point.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "polygons": List<dynamic>.from(polygons.map((x) => x.toJson())),
        "points": List<dynamic>.from(points.map((x) => x.toJson())),
      };
}

class Point {
  String id;
  Coordinate coordinate;

  Point({
    this.id,
    this.coordinate,
  });

  factory Point.fromJson(Map<String, dynamic> json) => Point(
        id: json["id"],
        coordinate: Coordinate.fromJson(json["coordinate"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "coordinate": coordinate.toJson(),
      };
}

class Coordinate {
  double lat;
  double lng;

  Coordinate({
    this.lat,
    this.lng,
  });

  factory Coordinate.fromJson(Map<String, dynamic> json) => Coordinate(
        lat: json["lat"].toDouble(),
        lng: json["lng"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };
}

class Polygon {
  String id;
  List<Coordinate> coordinates;

  Polygon({
    this.id,
    this.coordinates,
  });

  factory Polygon.fromJson(Map<String, dynamic> json) => Polygon(
        id: json["id"],
        coordinates: List<Coordinate>.from(
            json["coordinates"].map((x) => Coordinate.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "coordinates": List<dynamic>.from(coordinates.map((x) => x.toJson())),
      };
}

Future<GeoData> getGeoData() async {
  const url = 'http://bit.ly/geodata-torino';

  // Retrieve the locations of Google offices
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return GeoData.fromJson(json.decode(response.body));
  } else {
    throw HttpException(
        'Unexpected status code ${response.statusCode}:'
        ' ${response.reasonPhrase}',
        uri: Uri.parse(url));
  }
}
