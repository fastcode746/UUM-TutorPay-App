import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference tutorCollection =
      FirebaseFirestore.instance.collection("tutors");

      final CollectionReference studentCollection =
      FirebaseFirestore.instance.collection("students");

  // saving the userdata
  Future savingTutorData(String fullName, String email, String userType) async {
    return await tutorCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "uid": uid,
      'userType': userType,
    });
  }

    Future savingStudentData(String fullName, String email, String userType) async {
    return await studentCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "uid": uid,
      'userType': userType,
    });
  }

  // getting user data
  Future gettingTutorData(String email) async {
    QuerySnapshot snapshot =
        await tutorCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  Future gettingStudentData(String email) async {
    QuerySnapshot snapshot =
        await studentCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }
}
