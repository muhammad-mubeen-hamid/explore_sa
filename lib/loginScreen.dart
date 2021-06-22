// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:explore_sa/Animations/animationOne.dart';
// import 'package:explore_sa/mapScreen.dart';
// import 'package:explore_sa/services/authService.dart';
// import 'package:explore_sa/signup.dart';
// import 'package:flutter/material.dart';
// import 'package:explore_sa/MyColors.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import 'package:form_field_validator/form_field_validator.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
//
//
// class Login extends StatefulWidget {
//
//   @override
//   _LoginState createState() => _LoginState();
// }
//
// class _LoginState extends State<Login> {
//
//   var _loginFormKey = GlobalKey<FormState>();
//   final username = TextEditingController();
//   final password = TextEditingController();
//   final usernameValidator = MultiValidator([
//     RequiredValidator(errorText: 'Username is required'),
//     MaxLengthValidator(30, errorText: 'Email can not be longer then 30 characters'),
//   ]);
//   final passwordValidator = MultiValidator([
//     RequiredValidator(errorText: 'Password is required'),
//     MinLengthValidator(8, errorText: 'Password must be at least 8 digits long'),
//     PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'Password must have at least one special character')
//   ]);
//   final CollectionReference users = FirebaseFirestore.instance.collection('users');
//
//   bool loading = false;
//
//   //spinner initialisation
//   final spinkit = SpinKitRotatingCircle(
//     color: Colors.black,
//     size: 50.0,
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     FirebaseAuth auth = FirebaseAuth.instance;
//     final mediaQuery = MediaQuery.of(context);
//
//     return Scaffold(
//       body: loading ? Container(child: Center(child: spinkit,), padding: EdgeInsets.all(160),) : Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   MyColors.darkTeal,
//                   MyColors.mediumTeal,
//                   MyColors.xLightTeal
//                 ]
//             )
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             SizedBox(height: 80,),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: mediaQuery.size.height * 0.01, horizontal: mediaQuery.size.width * 0.1),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   FadeAnimation(1, Text("Login", style: TextStyle(color: Colors.white, fontSize: 40),)),
//                   SizedBox(height: 10,),
//                   FadeAnimation(1.3, Text("Welcome back", style: TextStyle(color: Colors.white, fontSize: 18),)),
//                 ],
//               ),
//             ),
//             SizedBox(height: mediaQuery.size.height * 0.01),
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))
//                 ),
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(vertical: mediaQuery.size.height * 0.01, horizontal: mediaQuery.size.width * 0.05),
//                     child: Container(
//                       child: Column(
//                         children: <Widget>[
//                           SizedBox(height: mediaQuery.size.height * 0.05,),
//                           FadeAnimation(1.4, Container(
//                             decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                                 boxShadow: [BoxShadow(
//                                     color: Color.fromRGBO(225, 95, 27, .3),
//                                     blurRadius: 20,
//                                     offset: Offset(0, 10)
//                                 )]
//                             ),
//                             child: Form(
//                               key: _loginFormKey,
//                               child: Column(
//                                 children: <Widget>[
//                                   Container(
//                                     padding: EdgeInsets.symmetric(vertical: mediaQuery.size.height * 0.01, horizontal: 0.01),
//                                     decoration: BoxDecoration(
//                                         border: Border(bottom: BorderSide(color: MyColors.darkTeal))
//                                     ),
//                                     child: TextFormField(
//                                       controller: username,
//                                       decoration: InputDecoration(
//                                           contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: mediaQuery.size.width * 0.05),
//                                           hintText: "Email or Phone number",
//                                           hintStyle: TextStyle(color: Colors.grey),
//                                           border: InputBorder.none
//                                       ),
//                                       validator: usernameValidator,
//                                     ),
//                                   ),
//                                   Container(
//                                     padding: EdgeInsets.symmetric(vertical: mediaQuery.size.height * 0.01, horizontal: 0.01),
//                                     decoration: BoxDecoration(
//                                         border: Border(bottom: BorderSide(color: MyColors.darkTeal))
//                                     ),
//                                     child: TextFormField(
//                                       controller: password,
//                                       decoration: InputDecoration(
//                                           contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: mediaQuery.size.width * 0.05),
//                                           hintText: "Password",
//                                           hintStyle: TextStyle(color: Colors.grey),
//                                           border: InputBorder.none
//                                       ),
//                                       validator: passwordValidator,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )),
//                           SizedBox(height: mediaQuery.size.height * 0.05,),
//                           FadeAnimation(1.5, Text("Forgot Password?", style: TextStyle(color: Colors.grey),)),
//                           SizedBox(height: mediaQuery.size.height * 0.01,),
//                           FadeAnimation(1.6, GestureDetector(
//                             onTap: () {
//                               if (_loginFormKey.currentState!.validate()) {
//                                 setState(() {
//                                   loading = true;
//                                 });
//                                 Future<String> val = context.read<AuthService>().signIn(context, username.text, password.text);
//                                 Navigator.push(context, MaterialPageRoute(builder: (context)=>Map()));
//                                 val.then((data) {
//                                   if (data == "false"){
//                                     setState(() {
//                                       loading = false;
//                                     });
//                                   }
//                                 });
//                                 // setState(() {
//                                 //   loading = false;
//                                 // });
//                               }
//                             },
//                             child: Container(
//                               height: mediaQuery.size.height * 0.07,
//                               margin: EdgeInsets.symmetric(vertical: 0, horizontal: mediaQuery.size.width * 0.2),
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(50),
//                                   color: MyColors.darkTeal
//                               ),
//                               child: Center(
//                                 child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
//                               ),
//                             ),
//                           )),
//                           SizedBox(height: mediaQuery.size.height * 0.01,),
//                           FadeAnimation(1.6, GestureDetector(
//                             onTap: () {
//                               Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup()));
//                             },
//                             child: Container(
//                               height: mediaQuery.size.height * 0.04,
//                               margin: EdgeInsets.symmetric(vertical: 0, horizontal: mediaQuery.size.width * 0.3),
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: Colors.blueGrey
//                               ),
//                               child: Center(
//                                 child: Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
//                               ),
//                             ),
//                           )),
//                           SizedBox(height: mediaQuery.size.height * 0.1,),
//                           FadeAnimation(1.7, Text("Continue with social media", style: TextStyle(color: Colors.grey),)),
//                           SizedBox(height: 30,),
//                           Row(
//                             children: <Widget>[
//                               Expanded(
//                                 child: FadeAnimation(1.8, Container(
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(50),
//                                       color: Colors.blue
//                                   ),
//                                   child: Center(
//                                     child: Text("Facebook", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
//                                   ),
//                                 )),
//                               ),
//                               SizedBox(width: mediaQuery.size.width * 0.2,),
//                               Expanded(
//                                 child: FadeAnimation(1.9, Container(
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(50),
//                                       color: Colors.black
//                                   ),
//                                   child: Center(
//                                     child: Text("Github", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
//                                   ),
//                                 )),
//                               )
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
// }
