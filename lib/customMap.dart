import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'MyColors.dart';
import 'application_bloc.dart';
import 'package:map_polyline_draw/map_polyline_draw.dart';
import 'package:location/location.dart';


class CustomMap extends StatefulWidget {
  const CustomMap({Key? key}) : super(key: key);

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {

  //polylines declaration
  Set<Polyline> polylines = Set<Polyline>();
  List<LatLng> polineCoordinates = [];
  late PolylinePoints polylinePoints;
  late LatLng destination;

  //other declarationns
  Completer<GoogleMapController> _controller = Completer();
  var googlePlace = GooglePlace("AIzaSyB0POtgaIRmp1NhRH3PGPcQ14Uo6MQ1OJI");
  final appBloc = new ApplicationBloc();
  var result;
  List<AutocompletePrediction> acp = [];
  final searchTextField = TextEditingController();
  List<SearchResult> nearbySearchResult = [];

  late LatLng currentLatLng = new LatLng(109, 109);

  @override
  void initState(){
    super.initState();
    polylinePoints = PolylinePoints();
    Geolocator.getCurrentPosition().then((currLocation){
      setState((){
        currentLatLng = new LatLng(currLocation.latitude, currLocation.longitude);
      });
    });
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
                    width: 250,
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
                            DetailsResponse? endResult = await googlePlace
                                .details.get(acp[index].placeId!);
                            DetailsResponse? startResult = await googlePlace
                                .details.get(acp[index].placeId!);
                            LatLng latLng = destination = new LatLng(
                                endResult!.result!.geometry!.location!.lat!,
                                endResult!.result!.geometry!.location!.lng!);
                            final GoogleMapController controller = await _controller
                                .future;
                            controller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    CameraPosition(target: latLng,
                                        zoom: 15)
                                )
                            );
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
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.my_location, color: Colors.white,),
        backgroundColor: MyColors.darkTeal,
        onPressed: () => _currentPositionFAB(),
      ) ,
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
          width: 10,
          polylineId: PolylineId('polyLine'),
          color: MyColors.darkTeal,
          points: polineCoordinates
        )
      );
    });
  }



}
