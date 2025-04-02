import 'package:flutter/foundation.dart';

import 'fee_service.dart';

class StripeService {
  final FeeService _feeService = FeeService();

  // Process payment using Stripe paymentIntent ID
  Future<Map<String, dynamic>> processPayment({
    required String tutorId,
    required String studentId,
    required String studentName,
    required String studentEmail,
    required String paymentIntentId,
  }) async {
    try {
      // Get the tutor's fee details
      Map<String, dynamic>? feeDetails = await _feeService.getTutorFee(tutorId);
      
      if (feeDetails == null) {
        return {
          'success': false,
          'message': 'Tutor fee not found',
        };
      }

      // Check if student has already paid this tutor
      bool alreadyPaid = await _feeService.hasStudentPaidTutor(
        tutorId: tutorId,
        studentId: studentId,
      );
      
      if (alreadyPaid) {
        return {
          'success': false,
          'message': 'You have already paid this tutor',
        };
      }

      // Record the payment in Firebase
      bool paymentRecorded = await _feeService.recordFeePayment(
        tutorId: tutorId,
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        amount: feeDetails['feeAmount'],
        paymentIntentId: paymentIntentId,
      );
      
      if (paymentRecorded) {
        return {
          'success': true,
          'message': 'Payment successful',
          'tutorName': feeDetails['tutorName'],
          'amount': feeDetails['feeAmount'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to record payment',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing payment: $e');
      }
      return {
        'success': false,
        'message': 'Payment processing error: ${e.toString()}',
      };
    }
  }
}