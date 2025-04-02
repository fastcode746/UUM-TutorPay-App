import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create or update fee for a tutor
  Future<bool> createOrUpdateTutorFee({
    required String tutorId,
    required String tutorName,
    required String tutorEmail,
    required double feeAmount,
    String? description,
  }) async {
    try {
      await _firestore.collection('fees').doc(tutorId).set({
        'tutorId': tutorId,
        'tutorName': tutorName,
        'tutorEmail': tutorEmail,
        'feeAmount': feeAmount,
        'description': description ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating/updating fee: $e');
      }
      return false;
    }
  }

  // Get fee for a specific tutor
  Future<Map<String, dynamic>?> getTutorFee(String tutorId) async {
    try {
      DocumentSnapshot feeDoc = await _firestore.collection('fees').doc(tutorId).get();
      
      if (feeDoc.exists) {
        return feeDoc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tutor fee: $e');
      }
      return null;
    }
  }

  // Get all tutors with their fees (for students to browse)
  Future<List<Map<String, dynamic>>> getAllTutorFees() async {
    try {
      QuerySnapshot feesSnapshot = await _firestore.collection('fees').get();
      
      return feesSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all tutor fees: $e');
      }
      return [];
    }
  }

  // Record a payment from a student to a tutor
  Future<bool> recordFeePayment({
    required String tutorId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    required double amount,
    required String paymentIntentId,
  }) async {
    try {
      // Create a new payment document
      await _firestore.collection('payments').add({
        'tutorId': tutorId,
        'studentId': studentId,
        'studentName': studentName,
        'studentEmail': studentEmail,
        'amount': amount,
        'paymentIntentId': paymentIntentId,
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Add this student to the list of students who have paid this tutor
      await _firestore.collection('fees').doc(tutorId).update({
        'paidStudents': FieldValue.arrayUnion([
          {
            'studentId': studentId,
            'studentName': studentName,
            'studentEmail': studentEmail,
            'paidAt': Timestamp.now(),
          }
        ])
      });
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error recording payment: $e');
      }
      return false;
    }
  }

  // Check if a student has paid a specific tutor
  Future<bool> hasStudentPaidTutor({
    required String tutorId,
    required String studentId,
  }) async {
    try {
      DocumentSnapshot feeDoc = await _firestore.collection('fees').doc(tutorId).get();
      
      if (!feeDoc.exists) return false;
      
      List<dynamic> paidStudents = (feeDoc.data() as Map<String, dynamic>)['paidStudents'] ?? [];
      
      return paidStudents.any((student) => student['studentId'] == studentId);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking student payment status: $e');
      }
      return false;
    }
  }

  // Get all tutors that a student has paid
  Future<List<Map<String, dynamic>>> getTutorsPaidByStudent(String studentId) async {
    try {
      QuerySnapshot paymentsSnapshot = await _firestore
          .collection('payments')
          .where('studentId', isEqualTo: studentId)
          .get();
      
      // Extract unique tutorIds
      Set<String> tutorIds = {};
      for (var doc in paymentsSnapshot.docs) {
        tutorIds.add((doc.data() as Map<String, dynamic>)['tutorId']);
      }
      
      // Get tutor details
      List<Map<String, dynamic>> tutors = [];
      for (String tutorId in tutorIds) {
        DocumentSnapshot tutorFee = await _firestore.collection('fees').doc(tutorId).get();
        if (tutorFee.exists) {
          Map<String, dynamic> data = tutorFee.data() as Map<String, dynamic>;
          data['id'] = tutorFee.id;
          tutors.add(data);
        }
      }
      
      return tutors;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tutors paid by student: $e');
      }
      return [];
    }
  }

  // Get all students who have paid a specific tutor
  Future<List<Map<String, dynamic>>> getStudentsWhoPaidTutor(String tutorId) async {
    try {
      DocumentSnapshot feeDoc = await _firestore.collection('fees').doc(tutorId).get();
      
      if (!feeDoc.exists) return [];
      
      List<dynamic> paidStudents = (feeDoc.data() as Map<String, dynamic>)['paidStudents'] ?? [];
      return List<Map<String, dynamic>>.from(paidStudents);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting students who paid tutor: $e');
      }
      return [];
    }
  }
}