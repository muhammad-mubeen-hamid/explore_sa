import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Globals{
  static bool showSpinner = false;
  static String usersName = "non";
  static String usersPref = "non";
  static String measureSystem = "non";
  static String progressStatusMessage = "";
  static StreamController<LatLng> streamController = StreamController();
  static bool enRoute = false;
}
