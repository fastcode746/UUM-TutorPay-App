// ignore_for_file: unnecessary_null_comparison

import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';
import 'helper_service.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String? _name;
  String? get name => _name;
  // loging in the user with email and password
  Future loginWithUserNameandPassword(String email, String password) async {
    try {
      User user =
          (await firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          )).user!;

      if (user != null) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future registerUserWithEmailandPassword(
    String fullName,
    String email,
    String password,
    String userType,
    String userId, 
  ) async {
    try {
      User user =
          (await firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          )).user!;

      if (user != null) {
        // call our database service to update the user data.
        if (userType == "Tutor") {
          await DatabaseService(
            uid: user.uid,
          ).savingTutorData(fullName, email, userType, userId);
          return true;
        } else if (userType == "Student") {
          await DatabaseService(
            uid: user.uid,
          ).savingStudentData(fullName, email, userType, userId);
          return true;
        }
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // signout
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF("");
      await HelperFunctions.saveUserNameSF("");
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}
