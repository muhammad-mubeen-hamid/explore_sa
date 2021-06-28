import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as GooglePlace;
import 'customSettings.dart';

class Globals{
  static bool showSpinner = false;
  static String usersName = "non";
  static String usersPref = "non";
  static String measureSystem = "non";
  static String progressStatusMessage = "";
  static StreamController<LatLng> cusMapStreamController = StreamController();
  static StreamController<LatLng> cusPlacesStreamController = StreamController();
  static GooglePlace.DetailsResult? inFocusPlaceResult;
  static List<GooglePlace.DetailsResult?> favPlacesDetailResult = [];
  static List<String?> favPlacesImages = [];
  static GooglePlace.DetailsResult? infoOfSelectedPlace;
  static List<GooglePlace.Review> reviewsOfSelectedPlace = [];
  static bool enRoute = false;
  static Widget showPage = CustomSettings();

  //only being used for favourites section map routing navigation process
  static double? lat = 0;
  static double? lng = 0;

  static Map<String, String> placeTypes = {
    "Finance": "finance",
    "Restaurant": "food",
    "Health": "health",
    "Landmark": "landmark",
    "Nature": "natural_feature",
    "Holy Places": "place_of_worship",
    "Interests": "point_of_interest",
    "Political": "political",
  };

}
