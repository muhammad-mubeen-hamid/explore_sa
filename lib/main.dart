import 'dart:async';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:explore_sa/customMap.dart';
import 'package:explore_sa/customPlaces.dart';
import 'package:explore_sa/navigation.dart';
import 'package:explore_sa/neabyPlaces.dart';
import 'package:explore_sa/services/authService.dart';
import 'package:explore_sa/userLogReg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:explore_sa/MyColors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'application_bloc.dart';
import 'customSettings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mapbox_navigation/library.dart';

import 'globals.dart';


const users = const {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(
    primaryColor: MyColors.darkTeal,
  ),
    home: Main(),
  ));
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService(FirebaseAuth.instance),),
        StreamProvider(create: (context) => context.read<AuthService>().authStateChanges, initialData: null,)
      ],
      child: AuthenticationWrapper(),
    );
  }
}


//return either the Home Page or Login Page
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {

  //variables
  final appBloc = new ApplicationBloc();
  late MapBoxNavigation _directions;


  int _page = 0;
  late final CustomMap mapWidget;
  final CustomPlaces places = CustomPlaces();
  final CustomSettings settings = CustomSettings();
  final CustomNavigation navigation = CustomNavigation();

  late Widget _showPage = CustomSettings();

  Widget _pagePicker(int page){
    switch (page) {
      case 0:
        return places;
        break;
      case 1:
        return mapWidget;
        break;
      case 2:
        return settings;
        break;
      default:
        return mapWidget;
        break;
    }
  }

  @override
  void initState(){
    super.initState();
    mapWidget = CustomMap(stream: Globals.streamController.stream,);
    _directions = MapBoxNavigation();
  }

  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  int defaultPage = 1;

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return Scaffold(
          bottomNavigationBar: CurvedNavigationBar(
            color: MyColors.xLightTeal,
            backgroundColor: MyColors.darkTeal,
            buttonBackgroundColor: MyColors.xLightTeal,
            index: 2,
            height: 50,
            key: _bottomNavigationKey,
            items: <Widget>[
              Icon(Icons.location_on, size: 40),
              Icon(Icons.map_rounded, size: 40),
              Icon(Icons.house_rounded, size: 40),
            ],
            onTap: (int tappedIndex) => changeView(tappedIndex),
          ),
          body: Center(
              child: Stack(
                children: [
                  _showPage,
                ],
              )
          ));
    } else {
      return Scaffold(
        body: LoginScreen(),
      );
    }
  }
  
  changeView(int tappedIndex){
    setState(() {
      _showPage = _pagePicker(tappedIndex);
    });
  }

  navigate() async {
    MapBoxOptions _options = MapBoxOptions(
        initialLatitude: 36.1175275,
        initialLongitude: -115.1839524,
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        mapStyleUrlDay: "https://url_to_day_style",
        mapStyleUrlNight: "https://url_to_night_style",
        units: VoiceUnits.imperial,
        simulateRoute: true,
        language: "en");

    final origin = WayPoint(name: "Durban", latitude: -29.858681, longitude: 31.021839);
    final stop = WayPoint(name: "Ballito", latitude: -29.547177, longitude: 31.178887);

    List<WayPoint> wayPoints = [];
    wayPoints.add(origin);
    wayPoints.add(stop);

    await _directions.startNavigation(wayPoints: wayPoints, options: _options);
  }

  Future<void> _onRouteEvent(e) async {

    double _distanceRemaining = await _directions.distanceRemaining;
    double _durationRemaining = await _directions.durationRemaining;
    bool? _routeBuilt, _isNavigating, _arrived;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived;
        if (progressEvent.currentStepInstruction != null)
         String? _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _routeBuilt = false;
        _isNavigating = false;
        break;
      default:
        break;
    }
    //refresh UI
    setState(() {});
  }
}

