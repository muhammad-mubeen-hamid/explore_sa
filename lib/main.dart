import 'dart:async';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:explore_sa/customMap.dart';
import 'package:explore_sa/testItem.dart';
import 'package:explore_sa/userLogReg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:explore_sa/MyColors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'application_bloc.dart';


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
  //variables
  List<Marker> markers = [];
  Completer<GoogleMapController> _controller = Completer();
  bool traffic = false;

  bool isDrawerOpen = false;
  var googlePlace = GooglePlace("AIzaSyB0POtgaIRmp1NhRH3PGPcQ14Uo6MQ1OJI");
  final appBloc = new ApplicationBloc();
  var result;
  List<AutocompletePrediction> acp = [];
  Completer<GoogleMapController> _mapController = Completer();
  final searchTextField = TextEditingController();
  List<SearchResult> nearbySearchResult = [];
  String firstImage = "";
  String secImage = "";
  String thirdImage = "";
  String fourthImage = "";
  String fifthImage = "";
  // Marker _origin;
  // Marker _destination;
  // Directions _info;

  int _page = 0;
  final CustomMap mapWidget = CustomMap();
  final Test testWidget = Test();

  Widget _showPage = new CustomMap();

  Widget _pagePicker(int page){
    switch (page) {
      case 0:
        return testWidget;
        break;
      case 1:
        return mapWidget;
        break;
      default:
        return testWidget;
        break;
    }
  }

  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return FirebaseAuth.instance.currentUser != null ?
      Scaffold(
          bottomNavigationBar: CurvedNavigationBar(
            color: MyColors.xLightTeal,
            backgroundColor: MyColors.darkTeal,
            index: 1,
            height: 60,
            key: _bottomNavigationKey,
            items: <Widget>[
              Icon(Icons.location_on, size: 40),
              Icon(Icons.map_rounded, size: 40),
              Icon(Icons.house_rounded, size: 40),
            ],
            onTap: (int tappedIndex) {
              setState(() {
                _showPage = _pagePicker(tappedIndex);
              });
            },
          ),
          body: Center(
              child: Stack(
                children: [
                  _showPage,
                ],
              )
          ))
          : Scaffold(
        body: LoginScreen(),
      );
  }
}

