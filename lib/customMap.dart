import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_sa/customFloatingActionButton.dart';
import 'package:explore_sa/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as GooglePlace;
import 'MyColors.dart';
import 'application_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:scrollable_panel/scrollable_panel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'locationServices.dart';

class CustomMap extends StatefulWidget {
  final Stream<LatLng> stream;
  const CustomMap({Key? key, required this.stream}) : super(key: key);

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {

  //config declaration
  bool refreshView = false;
  bool showFloatinActionButton = true;
  bool destinationMarkerAdded = false;

  //scrollable panel declarations
  PanelController _panelController = PanelController();

  //other declarationns
  Completer<GoogleMapController> _controller = Completer();
  var googlePlace = GooglePlace.GooglePlace("AIzaSyB0POtgaIRmp1NhRH3PGPcQ14Uo6MQ1OJI");
  final appBloc = new ApplicationBloc();
  var result;
  List<GooglePlace.AutocompletePrediction> acp = [];
  final searchTextField = TextEditingController();

  //user
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  List<String> favLocations = [];


  @override
  void initState() {
    super.initState();
    setState(() {
      Globals.showSpinner = true;
      Globals.progressStatusMessage = "Loading \nLocation Data";
    });
    LocationServices.getUserAddress().then((value) {
      print("USER ADDRESS FOUND IN INIT ==================> ${value.streetAddress}");
    });
    LocationServices.polylinePoints = PolylinePoints();
    setState(() {
      Globals.progressStatusMessage = "Locating \nNearby Preferences";
    });
    LocationServices.processNearbyPlaces().then((value) {
      LocationServices.nearbySearchResult = value;
      setState(() {
        Globals.showSpinner = false;
      });
    });

    widget.stream.listen((latlng) {
      navigate(latlng);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
        body: Container(
          child: Globals.showSpinner ? Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: MyColors.darkTeal,
            child: Center(
              child: Wrap(
                direction: Axis.vertical,
                alignment: WrapAlignment.center,
                children: [
                  Center(child: CircularProgressIndicator(color: MyColors.xLightTeal,)),
                  SizedBox(height: size.height * 0.1,),
                  Center(child: Text(Globals.progressStatusMessage, style: TextStyle(color: MyColors.xLightTeal), softWrap: true, textAlign: TextAlign.center,)),
                ],
              ),
            ),
          ):
          Stack(
            children: [
              LocationServices.currentLatLng == new LatLng(109, 109) ?
              Center(child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                color: MyColors.darkTeal,
                child: Center(
                  child: Wrap(
                    direction: Axis.vertical,
                    alignment: WrapAlignment.center,
                    children: [
                      Center(child: CircularProgressIndicator(color: MyColors.xLightTeal,)),
                      SizedBox(height: size.height * 0.1,),
                      Center(child: Text(Globals.progressStatusMessage, style: TextStyle(color: MyColors.xLightTeal), softWrap: true, textAlign: TextAlign.center,)),
                    ],
                  ),
                ),
              )
              ) :
              Container(
                child: GoogleMap(
                  markers: LocationServices.markers.length <= 2 ? Set<Marker>.from(LocationServices.markers) : Set<Marker>.from(LocationServices.multipleMarkers),
                  polylines: LocationServices.getPolylines(),
                  trafficEnabled: false,
                  rotateGesturesEnabled: true,
                  buildingsEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(target: LocationServices.currentLatLng, zoom: 15),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    LocationServices.setPolylines();
                  },
                ),
              ),
              Container(
                width: size.width * 1,
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04, vertical: size.height * 0.01),
                margin: EdgeInsets.symmetric(
                    vertical: size.height * 0.07, horizontal: size.width * 0.04),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.search),
                    Container(
                      width: size.width * 0.7,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(
                              color: MyColors.darkTeal))
                      ),
                      child: TextField(
                          controller: searchTextField,
                          decoration: InputDecoration(
                              hintText: "Search for destination",
                              hintStyle: TextStyle(
                                  color: Colors.grey),
                              border: InputBorder.none
                          ),
                          onChanged: (value) async {
                            result =
                            await googlePlace.autocomplete.get(
                                value, radius: 0);
                            setState(() {
                              appBloc.searchPlace(value);
                              acp = result.predictions.toList();
                            });
                          }
                      ),
                    ),
                    Icon(Icons.settings)
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(size.width * 0.05, size.width * 0.3, 0, 0),
                width: size.width * 0.8,
                child: Row(
                  children: [
                    GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: MyColors.darkTeal,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: MyColors.xLightTeal,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                          child: Row(
                            children: [
                              Icon(Icons.restaurant_rounded, color: MyColors.darkTeal, size: 18,), Text(" Restaurants", style: TextStyle(color: MyColors.darkTeal, fontSize: 12, fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                        onTap: () async {
                          _panelController.open();
                          LocationServices.addMultipleMarkers(LocationServices.getNearbySearchResult());
                          //nearbySearchResult = await this.getNearbyPlaces().then((value) => value);
                          getPhoto();
                        }
                    ),
                    SizedBox(width: 5,),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: MyColors.darkTeal,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: MyColors.xLightTeal,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                      child: Row(
                        children: [
                          Icon(Icons.shopping_cart_outlined, color: MyColors.darkTeal, size: 18,), Text(" Groceries", style: TextStyle(color: MyColors.darkTeal, fontSize: 12, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    )

                  ],
                ),
              ),
              Column(
                children: [
                  Container(height: size.height * 0.08,),
                  acp.isEmpty || acp.length == 0
                      ? Container()
                      : Container(
                    margin: EdgeInsets.fromLTRB(0, size.height * 0.05, 0, 0),
                    height: size.height * 0.5,
                    child: ListView.builder(
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              //LocationServices.resetMap();
                              GooglePlace.DetailsResponse? endResult = await googlePlace
                                  .details.get(acp[index].placeId!);
                              GooglePlace.DetailsResponse? startResult = await googlePlace
                                  .details.get(acp[index].placeId!);
                              LatLng targetLatLng = LocationServices.destinationLatLng = new LatLng(
                                  endResult!.result!.geometry!.location!.lat!,
                                  endResult.result!.geometry!.location!.lng!);
                              final GoogleMapController controller = await _controller.future;
                              controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LocationServices.destinationLatLng, zoom: 15)
                              )
                              );
                              _panelController.close();
                              Globals.progressStatusMessage = "Calculating Route\nInformation";
                              LocationServices.destinationLatLng = targetLatLng;
                              setState(() {
                                Globals.showSpinner = true;
                              });

                              await LocationServices.addMarkers(LocationServices.currentLatLng, LocationServices.destinationLatLng).then((value) {
                                setState(() {
                                  searchTextField.text = "";
                                  acp = [];
                                  setState(() {
                                    Globals.showSpinner = false;
                                  });
                                });
                              });
                              await LocationServices.setPolylines().then((value) {
                                setState(() {
                                  searchTextField.text = "";
                                  acp = [];
                                  showFloatinActionButton = true;
                                  Globals.showSpinner = false;
                                });
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on),
                                          Container(
                                              width: size.width * 0.7,
                                              child: Text("  " + acp[index].description!,)
                                          )
                                        ]
                                        ,),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20),
                                      margin: EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 20),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius
                                              .circular(20)
                                      )
                                  ),
                                )
                              ],
                            ),
                          );
                        }, itemCount: acp.length),
                  ),
                ],
              ),
              ScrollablePanel(
                controller: _panelController,
                defaultPanelState: PanelState.close,
                onOpen: () => {
                  setState(() {
                    showFloatinActionButton = false;
                  })
                },
                onClose: () => {
                  setState(() {
                    showFloatinActionButton = true;
                  })
                },
                onExpand: () => print("Panel has been expanded"),
                builder: (context, controller) {
                  return SingleChildScrollView(
                    controller: controller,
                    child: _PanelView(nearbySearchResult: LocationServices.getNearbySearchResult()),
                  );
                },
              )
            ],
          ),
        ),
        floatingActionButton: showFloatinActionButton ? CustomFloatingActionButton(
          currentLatLng: LocationServices.currentLatLng,
          destinationLatLng: LocationServices.destinationLatLng,
          currentPositionFAB: _currentPositionFAB,
          context: context,
          polylineCoordinates: LocationServices.polineCoordinates,
          resetMap: LocationServices.resetMap,
          resetView: refreshViewF,
        ) : FloatingActionButton(onPressed: () => print(""), foregroundColor: MyColors.darkTeal, backgroundColor: MyColors.darkTeal,)
    );
  }

  Future<void> _currentPositionFAB() async {
    print("ANIMATING TO CURRENT LOCATION ===========================> " + LocationServices.currentLatLng.toString());
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LocationServices.currentLatLng, zoom: 15)));
  }

  Future<Map<String, Uint8List>> getPhoto() async {
    Map<String, Uint8List> data = new Map<String, Uint8List>();

    LocationServices.getNearbySearchResult().forEach((i1) {
      i1.photos!.forEach((i2) async {
        http.Response result = await http.get(Uri.parse("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=&key=AIzaSyB0POtgaIRmp1NhRH3PGPcQ14Uo6MQ1OJI"));
        if (result != null && mounted) {
          print(result.body);
          //data.putIfAbsent('${i1.placeId}', () => result);
        }
      });
    });

    return data;
  }

  refreshViewF(){
    setState(() {
      refreshView = !refreshView;
      _currentPositionFAB();
    });
  }

  void navigate(LatLng targetLatLng) async {
    bool val = true;
    LocationServices.resetMap();
    setState(() {
      _panelController.close();
      Globals.showSpinner = true;
      Globals.progressStatusMessage = "Calculating Route\nInformation";
      LocationServices.destinationLatLng = targetLatLng;
    });

    await LocationServices.addMarkers(LocationServices.currentLatLng, targetLatLng).then((value) {
      setState(() {
        searchTextField.text = "";
        acp = [];
      });
    });

    await LocationServices.setPolylines().then((value) {
      setState(() {
        Globals.enRoute = true;
        val = !val;
        searchTextField.text = "";
        acp = [];
        showFloatinActionButton = true;
        Globals.showSpinner = false;
      });
    });
  }
}

Widget showNearbyData(List<GooglePlace.SearchResult> nearbySearchResult) {
  String userPref = "All";
  Globals.placeTypes.forEach((key, value) {
    if (Globals.usersPref == key){
      userPref = value;
    }
  });

  return Container(
      child: CarouselSlider(
        options: CarouselOptions(height: 170),
        items: nearbySearchResult.map((i) {
          return Builder(
            builder: (BuildContext context) {
            //if (i.types?.contains(userPref) == true){
            return Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 30),
              child: _boxes(
                  "https://maps.googleapis.com/maps/api/place/photo?maxwidth=195&photoreference=${i.photos?.first.photoReference}&key=AIzaSyB0POtgaIRmp1NhRH3PGPcQ14Uo6MQ1OJI",
                  i.name!,
                  i.rating!,
                  i.geometry?.location?.lat,
                  i.geometry?.location?.lng,
                  i.types,
                  i.placeId
                )
              );
             }
              // else {
            //   return Container();
            // }
             // }
              );
          }
        ).toList(),
      )
  );
}

Widget _boxes(String _image, String placeName, double rating, double? lat, double? lng, List<String>? types, String? placeId) {
  return  GestureDetector(
    child: Container(
      child: new FittedBox(
        child: Material(
            color: MyColors.xLightTeal,
            borderRadius: BorderRadius.circular(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 300,
                  height: 250,
                  child: ClipRRect(
                    borderRadius: new BorderRadius.circular(24.0),
                    child: Image(
                      fit: BoxFit.fill,
                      image: NetworkImage(_image),
                    ),
                  ),),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: myDetailsContainer1(placeName, rating, types, lat, lng, placeId),
                  ),
                ),

              ],)
        ),
      ),
    ),
  );
}

Widget myDetailsContainer1(String placeName, double rating, List<String>? types, double? lat, double? lng, String? placeId) {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  List<String> fav = ["$placeId"];
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      Row(
        children: [
          GestureDetector(
            child: Icon(Icons.favorite_border_rounded, size: 70, color: MyColors.darkTeal,),
            onTap: () async {
              DocumentSnapshot result;

              await usersRef.doc(auth.currentUser?.uid).get().then((value) {
                result = value;
                try {
                  List<dynamic> data = result.get('favLocations');
                } catch (error){
                  List<String> initialField = [];
                  usersRef.doc(auth.currentUser?.uid).update({'favLocations': FieldValue.arrayUnion(initialField)});
                } finally {
                  usersRef.doc(auth.currentUser?.uid).update({'favLocations': FieldValue.arrayUnion(fav)});
                }
              });

            },
          ),
          GestureDetector(
            child: Container(
                child: Icon(Icons.navigation_outlined, size: 70, color: MyColors.darkTeal,)
            ),
            onTap: () async {
              Globals.cusMapStreamController.add(LatLng(lat!, lng!));
            },
          ),
        ],
      ),
      SizedBox(height: 10,),
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
            width: 250,
            child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              children: [
                Text(
                  placeName,
                  style: TextStyle(
                    color: MyColors.darkTeal,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,),
                  textAlign: TextAlign.center,
                )],
            )),
      ),
      SizedBox(height:5.0),
      Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                  child: Text(
                    rating.toString(),
                    style: TextStyle(
                      color: MyColors.darkTeal,
                      fontSize: 18.0,
                    ),
                  )),
              Container(
                child: Icon(
                  FontAwesomeIcons.solidStar,
                  color: Colors.amber,
                  size: 15.0,
                ),
              ),
              Container(
                child: Icon(
                  FontAwesomeIcons.solidStar,
                  color: Colors.amber,
                  size: 15.0,
                ),
              ),
              Container(
                child: Icon(
                  FontAwesomeIcons.solidStar,
                  color: Colors.amber,
                  size: 15.0,
                ),
              ),
              Container(
                child: Icon(
                  FontAwesomeIcons.solidStar,
                  color: Colors.amber,
                  size: 15.0,
                ),
              ),
              Container(
                child: Icon(
                  FontAwesomeIcons.solidStarHalf,
                  color: Colors.amber,
                  size: 15.0,
                ),
              ),
              Container(
                  child: Text(
                    "(946)",
                    style: TextStyle(
                      color: MyColors.darkTeal,
                      fontSize: 18.0,
                    ),
                  )),
            ],
          )),
      SizedBox(height:5.0),
      Container(
          child: Text(
            "American \u00B7 \u0024\u0024 \u00B7 1.6 mi",
            style: TextStyle(
              color: MyColors.darkTeal,
              fontSize: 18.0,
            ),
          )),
      SizedBox(height:5.0),
      Container(
          child: Text(
            "Closed \u00B7 Opens 17:00 Thu",
            style: TextStyle(
                color: MyColors.darkTeal,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          )),

    ],
  );
}

class _PanelView extends StatefulWidget {
  final List<GooglePlace.SearchResult> nearbySearchResult;
  const _PanelView({Key? key, required this.nearbySearchResult}) : super(key: key);

  @override
  _PanelViewState createState() => _PanelViewState(nearbySearchResult: nearbySearchResult);
}

class _PanelViewState extends State<_PanelView> {
  List<GooglePlace.SearchResult> nearbySearchResult;
  _PanelViewState({required this.nearbySearchResult});

  @override
  Widget build(BuildContext context) {
    const double circularBoxHeight = 18.0;
    final Size size = MediaQuery.of(context).size;
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: size.height + kToolbarHeight + 44.0,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 720),
            decoration: BoxDecoration(
              color: MyColors.darkTeal,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(circularBoxHeight), topRight: Radius.circular(circularBoxHeight)),
              border: Border.all(color: MyColors.darkTeal),
            ),
            child: showNearbyData(nearbySearchResult),
          ),
        );
      },
    );
  }
}
