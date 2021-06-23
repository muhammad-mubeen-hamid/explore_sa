import 'package:explore_sa/MyColors.dart';
import 'package:flutter/material.dart';


class CustomPlaces extends StatefulWidget {
  const CustomPlaces({Key? key}) : super(key: key);

  @override
  _CustomPlacesState createState() => _CustomPlacesState();
}

class _CustomPlacesState extends State<CustomPlaces> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyColors.darkTeal,
    );
  }
}
