import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:explore_sa/models/userModel.dart';

class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  // Future<UserModel> getUser() {
  //   return _db
  //       .collection('users')
  //       .get()
  // }
}