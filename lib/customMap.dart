import 'dart:async';
import 'dart:convert' as convert;
import 'dart:typed_data';
import 'package:explore_sa/customFloatingActionButton.dart';
import 'package:explore_sa/models/nearby_places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart' as GooglePlace;
import 'package:google_place/google_place.dart';
import 'MyColors.dart';
import 'application_bloc.dart';
import 'package:geocode/geocode.dart';
import 'package:http/http.dart' as http;
import 'package:scrollable_panel/scrollable_panel.dart';
import 'package:carousel_slider/carousel_slider.dart';


class CustomMap extends StatefulWidget {
  const CustomMap({Key? key}) : super(key: key);

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {

  //config declaration
  bool showFloatinActionButton = true;

  //scrollable panel declarations
  PanelController _panelController = PanelController();

  //polylines declaration
  Set<Polyline> polylines = Set<Polyline>();
  List<LatLng> polineCoordinates = [];
  late PolylinePoints polylinePoints;
  late LatLng destination = new LatLng(109, 109);

  //markers declaration
  Set<Marker> markers = {};

  //nearby places declaration
  late List<GooglePlace.SearchResult> nearbySearchResult = [];
  late Map<String, String> nearbyPlacesImages = new Map<String, String>();
  List<String> imgURLs = [];

  //other declarationns
  Completer<GoogleMapController> _controller = Completer();
  var googlePlace = GooglePlace.GooglePlace("AIzaSyB0POtgaIRmp1NhRH3PGPcQ14Uo6MQ1OJI");
  final appBloc = new ApplicationBloc();
  var result;
  List<GooglePlace.AutocompletePrediction> acp = [];
  final searchTextField = TextEditingController();

  late LatLng currentLatLng = new LatLng(109, 109);

  @override
  void initState(){
    super.initState();
    getUserAddress();
    polylinePoints = PolylinePoints();
    Geolocator.getCurrentPosition().then((currLocation){
      setState((){
        currentLatLng = new LatLng(currLocation.latitude, currLocation.longitude);
      });
    });
    getNearbyPlaces();
    getPhoto();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return new Scaffold(
      body: Container(
        child: Stack(
          children: [
            currentLatLng == new LatLng(109, 109) ?
            Center(child: CircularProgressIndicator(),) :
            Container(
              child: GoogleMap(
                markers: Set<Marker>.from(markers),
                polylines: polylines,
                trafficEnabled: false,
                rotateGesturesEnabled: true,
                buildingsEnabled: true,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(target:currentLatLng, zoom: 15),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  setPolylines();
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
                      nearbySearchResult = await this.getNearbyPlaces().then((value) => value);
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
                            resetMap();
                            GooglePlace.DetailsResponse? endResult = await googlePlace
                                .details.get(acp[index].placeId!);
                            GooglePlace.DetailsResponse? startResult = await googlePlace
                                .details.get(acp[index].placeId!);
                            LatLng targetLatLng = destination = new LatLng(
                                endResult!.result!.geometry!.location!.lat!,
                                endResult!.result!.geometry!.location!.lng!);
                            final GoogleMapController controller = await _controller
                                .future;
                            controller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    CameraPosition(target: targetLatLng,
                                        zoom: 15)
                                )
                            );
                            addMarkers(currentLatLng, targetLatLng);
                            setState(() {
                              setPolylines();
                              searchTextField.text = "";
                              acp = [];
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
                    child: _PanelView(nearbySearchResult: nearbySearchResult,),
                  );
                },
            )
          ],
        ),
      ),
       floatingActionButton: showFloatinActionButton ? CustomFloatingActionButton(
        currentLatLng: currentLatLng,
        destinationLatLng: destination,
        currentPositionFAB: _currentPositionFAB,
        context: context,
        polylineCoordinates: polineCoordinates,
        resetMap: resetMap
       ) : FloatingActionButton(onPressed: () => print(""), foregroundColor: MyColors.darkTeal, backgroundColor: MyColors.darkTeal,)
    );
  }

  Future<void> _currentPositionFAB() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentLatLng, zoom: 15)));
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyB0POtgaIRmp1NhRH3PGPcQ14Uo6MQ1OJI",
        PointLatLng(currentLatLng.latitude, currentLatLng.longitude),
        PointLatLng(destination.latitude, destination.longitude)
    );

    if (result.status == 'OK'){
      result.points.forEach((PointLatLng point) {
        polineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    setState(() {
      polylines.add(
        Polyline(
          width: 3,
          polylineId: PolylineId('polyLine'),
          color: MyColors.darkTeal,
          points: polineCoordinates,
        )
      );
    });
  }

  addMarkers(LatLng origin, LatLng destination) async {

    String? originSnippet = "";
    getUserAddress().then((value) => print("============================================> ADDRESSES 1 - " + value.streetAddress.toString()));
    String? destinationSnippet = "";
    getDestinationAddress().then((value) => print("============================================> ADDRESSES 2 - " + value.streetAddress.toString()));

    Marker startMarker = Marker(
      markerId: MarkerId(origin.toString()),
      position: LatLng(
        origin.latitude,
        origin.longitude,
      ),
      infoWindow: InfoWindow(
        title: 'Origin',
        snippet: "originSnippet"
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

// Destination Location Marker
    Marker destinationMarker = Marker(
      markerId: MarkerId(destination.toString()),
      position: LatLng(
        destination.latitude,
        destination.longitude,
      ),
      infoWindow: InfoWindow(
        title: "Destination",
        snippet: "destinationSnippet"
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    markers.add(startMarker);
    markers.add(destinationMarker);

  }

  resetMap() {
    setState(() {
      polineCoordinates.clear();
      polylines.clear();
      polylinePoints = PolylinePoints();
      markers.clear();
      markers = {};
      _currentPositionFAB();
    });
  }

  Future<Address> getUserAddress() async {//call this async method from whereever you need
    final geoCode = new GeoCode();
    Address address = new Address();
    try {
      address = await geoCode.reverseGeocoding(latitude: currentLatLng.latitude, longitude: currentLatLng.longitude);
    } catch (e) {
      print(e);
    }
    return address;
  }

  Future<Address> getDestinationAddress() async {//call this async method from whereever you need
    final geoCode = new GeoCode();
    Address address = new Address();
    try {
      address = await geoCode.reverseGeocoding(latitude: destination.latitude, longitude: destination.longitude);
    } catch (e) {
      print(e);
    }
    return address;
  }

  Future<List<GooglePlace.SearchResult>>getNearbyPlaces() async {

    late List<GooglePlace.SearchResult> temp = [];
    var googlePlace = GooglePlace.GooglePlace("AIzaSyB0POtgaIRmp1NhRH3PGPcQ14Uo6MQ1OJI");
    var result = await googlePlace.search.getNearBySearch(GooglePlace.Location(lat: currentLatLng.latitude, lng: currentLatLng.longitude), 1500);
    temp = result!.results!;

    return temp;
  }

  Future<Map<String, Uint8List>> getPhoto() async {
    Map<String, Uint8List> data = new Map<String, Uint8List>();

    nearbySearchResult.forEach((i1) {
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
}

Widget showNearbyData(List<GooglePlace.SearchResult> nearbySearchResult){
  var googlePlace = GooglePlace.GooglePlace("AIzaSyB0POtgaIRmp1NhRH3PGPcQ14Uo6MQ1OJI");
  List<Uint8List> img = [];

  return Container(
      child: CarouselSlider(
        options: CarouselOptions(height: 150),
        items: nearbySearchResult.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: MyColors.xLightTeal,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: MyColors.xLightTeal,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.network(
                                "https://maps.googleapis.com/maps/api/place/photo?maxwidth=195&photoreference=${i.photos!.first.photoReference}&key=AIzaSyB0POtgaIRmp1NhRH3PGPcQ14Uo6MQ1OJI",
                              fit: BoxFit.fill,
                            ),
                          ),
                          Flexible(child: new Text('${i.name}'), fit: FlexFit.loose,),
                        ],),
                      Column(
                        children: [
                          Flexible(child: Text("${i.types!.first}", softWrap: true,))
                        ],
                      )
                    ],
                  )
              );
            },
          );
        }).toList(),
      )
  );
}

class _PanelView extends StatelessWidget {
  List<GooglePlace.SearchResult> nearbySearchResult;

  _PanelView({required this.nearbySearchResult,});

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
            child: showNearbyData(nearbySearchResult,),
          ),
        );
      },
    );
  }
}