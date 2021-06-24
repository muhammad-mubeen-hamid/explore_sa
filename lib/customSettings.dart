import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_sa/MyColors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';


class CustomSettings extends StatefulWidget {
  const CustomSettings({Key? key}) : super(key: key);

  @override
  _CustomSettingsState createState() => _CustomSettingsState();
}

class _CustomSettingsState extends State<CustomSettings> {

  TextEditingController nameTextField = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  String userDetails = "non";
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    extractUserName().then((value) {
      userDetails = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userDetails == "non") {
      return CircularProgressIndicator();
    } else {
      double width = MediaQuery
          .of(context)
          .size
          .width;
      double height = MediaQuery
          .of(context)
          .size
          .height;
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: MyColors.darkTeal,
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 50),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          AntDesign.arrowleft,
                          color: MyColors.darkTeal,
                        ),
                        Icon(
                          AntDesign.logout,
                          color: MyColors.xLightTeal,
                        ),
                      ],
                    ),
                    Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: height * 0.50,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double innerHeight = constraints.maxHeight;
                          double innerWidth = constraints.maxWidth;
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Positioned(
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(
                                      0, height * 0.08, 0, 0),
                                  height: innerHeight * 0.50,
                                  width: innerWidth,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: MyColors.xLightTeal,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 45,
                                      ),
                                      Flexible(
                                          child: Text(
                                            '$userDetails',
                                            style: TextStyle(
                                              color: MyColors.darkTeal,
                                              fontFamily: 'Nunito',
                                              fontSize: 22,
                                            ),
                                          ),
                                      ),
                                      Container(
                                        width: width * 0.8,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.04,
                                            vertical: height * 0.01),
                                        margin: EdgeInsets.symmetric(
                                            vertical: height * 0.07,
                                            horizontal: width * 0.01),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                                20)
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Icon(Icons
                                                .drive_file_rename_outline),
                                            Container(
                                              width: width * 0.55,
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color: MyColors
                                                              .darkTeal))
                                              ),
                                              child: TextField(
                                                controller: nameTextField,
                                                decoration: InputDecoration(
                                                    hintText: '$userDetails',
                                                    hintStyle: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey),
                                                    border: InputBorder.none
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              child: Icon(
                                                  Icons.done_outline_rounded),
                                              onTap: () {
                                                usersRef.doc(getCurrentUserUID()).set(
                                                    {'displayName': nameTextField.text, 'uid': getCurrentUserUID()}
                                                ).catchError((onError) =>
                                                    print(onError));

                                                setState(() {
                                                  changeDisplayName();
                                                  extractUserName();
                                                  nameTextField.clear();
                                                });
                                                //printData();

                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 110,
                                right: 20,
                                child: Icon(
                                  AntDesign.setting,
                                  color: Colors.grey[700],
                                  size: 30,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    child: Image.asset(
                                      'assets/images/user.png',
                                      width: innerWidth * 0.30,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: height * 0.5,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: MyColors.xLightTeal,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Preference',
                              style: TextStyle(
                                color: MyColors.darkTeal,
                                fontSize: 22,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            Divider(
                              thickness: 2.5,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: height * 0.15,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: height * 0.1,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      );
    }
  }

  String getCurrentUserUID(){
    final User? user = auth.currentUser;
    return user!.uid;
  }


  void changeDisplayName() async {
    showSpinner = true;
    if (showSpinner) CircularProgressIndicator();
    await usersRef.doc(getCurrentUserUID()).get().then((value) {
      setState(() {
        userDetails = value['displayName'];
      });
    });
  }

  Future<String> extractUserName() async {

    var result;
    await usersRef.doc(getCurrentUserUID()).get().then((value) {
      result = value.data();
      return value.data();
    });
    setState(() {
      userDetails = result['displayName'];
    });
    print("EXTRACTED USER DETAILS ================> ${result['displayName']}");
    return result['displayName'];
  }
}