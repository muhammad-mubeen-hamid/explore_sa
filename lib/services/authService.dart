// import 'package:explore_sa/login.dart';
// import 'package:explore_sa/signup.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class AuthService {
//   final FirebaseAuth _firebaseAuth;
//   AuthService(this._firebaseAuth);
//
//   Stream<User> get authStateChanges {
//     return _firebaseAuth.authStateChanges();
//   }
//
//   String getCurrentUserUID(){
//     final User user = _firebaseAuth.currentUser;
//     return user.uid;
//   }
//
//   Future<String> signIn(BuildContext context, String username, String password) async {
//     try {
//       UserCredential val = await _firebaseAuth.signInWithEmailAndPassword(email: username, password: password);
//       if (val.user.email == username){
//         return "true";
//       } else {
//         return "false";
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == "user-not-found"){
//         showDialog(context: context, builder: (_) {
//           return AlertDialog(
//             title: Text("Login Error!"),
//             content: Text("This user is not yet registered. \nProceed to sign up."),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => Signup()
//                       ),
//                           (route) => false
//                   );
//                 },
//                 child: const Text('OK'),
//               )
//             ],
//           );
//         });
//       }
//       return "false";
//     }
//   }
//
//   Future<String> signUp(String name, String username, String password, BuildContext context) async {
//     CollectionReference users = FirebaseFirestore.instance.collection('users');
//     try {
//       UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(email: username, password: password);
//       users.add({'displayName': name, 'uid': getCurrentUserUID()});
//       if (user.user.email == username){
//         return "true";
//       } else {
//         return "false";
//       }
//
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         print('The password provided is too weak.');
//       } else if (e.code == 'email-already-in-use') {
//         showDialog(context: context, builder: (_) {
//           return AlertDialog(
//             title: Text("Registration Error!"),
//             content: Text("This email is already in use. \nProceed to log in."),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => Login()
//                       ),
//                       (route) => false
//                   );
//                 },
//                 child: const Text('OK'),
//               )
//             ],
//           );
//         });
//       }
//       return "false";
//     }
//   }
//
//   Future<void> signOut() async {
//     await _firebaseAuth.signOut();
//   }
// }
