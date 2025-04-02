import 'dart:io';
import 'package:fee_app/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class StudentPaymentHistoryScreen extends StatefulWidget {
  const StudentPaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<StudentPaymentHistoryScreen> createState() =>
      _StudentPaymentHistoryScreenState();
}

class _StudentPaymentHistoryScreenState
    extends State<StudentPaymentHistoryScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> paymentsList = [];
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    loadStudentPayments();
  }

  Future<void> loadStudentPayments() async {
    if (currentUserId == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Query all fees where this student has paid
      final querySnapshot =
          await FirebaseFirestore.instance.collection('fees').get();

      List<Map<String, dynamic>> payments = [];

      for (var doc in querySnapshot.docs) {
        final feeData = doc.data();
        final feeId = doc.id;

        // Check if the current student ID is in paidStudents array
        final paidStudents = List<Map<String, dynamic>>.from(
          feeData['paidStudents'] ?? [],
        );

        for (var studentPayment in paidStudents) {
          if (studentPayment['studentId'] == currentUserId) {
            // Get the tutor data using tutorId
            String tutorId = feeData['tutorId'] ?? '';
            String tutorName = feeData['tutorName'] ?? 'Unknown Tutor';
            String tutorEmail = feeData['tutorEmail'] ?? '';

            // If tutorId exists but name/email not in feeData, fetch it from tutors collection
            if (tutorId.isNotEmpty &&
                (tutorName == 'Unknown Tutor' || tutorEmail.isEmpty)) {
              try {
                final tutorDoc =
                    await FirebaseFirestore.instance
                        .collection('tutors')
                        .doc(tutorId)
                        .get();

                if (tutorDoc.exists) {
                  final tutorData = tutorDoc.data();
                  tutorName = tutorData?['tutorName'] ?? tutorName;
                  tutorEmail = tutorData?['tutorEmail'] ?? tutorEmail;
                }
              } catch (e) {
                print('Error fetching tutor data: $e');
              }
            }

            // Get student name from the payment data or fetch if needed
            String studentName = studentPayment['studentName'] ?? '';
            if (studentName.isEmpty) {
              // Try to get from current user
              studentName =
                  FirebaseAuth.instance.currentUser?.displayName ?? 'Student';

              // If still empty and we have studentId, try to fetch from students collection
              if (studentName == 'Student') {
                try {
                  final studentDoc =
                      await FirebaseFirestore.instance
                          .collection('students')
                          .doc(currentUserId)
                          .get();

                  if (studentDoc.exists) {
                    studentName =
                        studentDoc.data()?['studentName'] ?? 'Student';
                  }
                } catch (e) {
                  print('Error fetching student data: $e');
                }
              }
            }

            Map<String, dynamic> paymentData = {
              'feeId': feeId,
              'feeDescription': feeData['description'],
              'feeAmount': feeData['feeAmount'],
              'tutorName': tutorName,
              'tutorEmail': tutorEmail,
              'studentName': studentName,
              'paidAt': studentPayment['paidAt'],
            };

            payments.add(paymentData);
            break;
          }
        }
      }

      // Sort payments by date (newest first)
      payments.sort((a, b) {
        final aDate = (a['paidAt'] as Timestamp).toDate();
        final bDate = (b['paidAt'] as Timestamp).toDate();
        return bDate.compareTo(aDate);
      });

      setState(() {
        paymentsList = payments;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading payments: $e')));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> generateReceipt(Map<String, dynamic> paymentData) async {
    setState(() {
      isLoading = true;
    });

    try {
      final pdf = pw.Document();
      final formatter = DateFormat('MMM d, yyyy hh:mm a');
      final receiptId =
          '${paymentData['feeId'].substring(0, 6)}-${currentUserId!.substring(0, 6)}';

      final paidAt = (paymentData['paidAt'] as Timestamp).toDate();
      final formattedPaidDate = formatter.format(paidAt);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'PAYMENT RECEIPT',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(10),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Receipt No: $receiptId',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text('Date: $formattedPaidDate'),
                        ],
                      ),
                      pw.Divider(),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Student Details:',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text('Name: ${paymentData['studentName']}'),
                              pw.Text('Email: ${currentUserEmail ?? ""}'),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Tutor Details:',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              pw.Text('Name: ${paymentData['tutorName']}'),
                              pw.Text('Email: ${paymentData['tutorEmail']}'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(10),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Center(
                        child: pw.Text(
                          'Payment Details',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Table(
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Text(
                                'Fee Description:',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(paymentData['feeDescription']),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Text(
                                'Amount Paid:',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text('\$${paymentData['feeAmount']}'),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Text(
                                'Payment Date:',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(formattedPaidDate),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Divider(),
                pw.Text('This is an electronically generated receipt.'),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Generated on: ${formatter.format(DateTime.now())}',
                    ),
                    pw.Text(
                      'Valid Receipt',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/payment_receipt_${receiptId}.pdf');
      await file.writeAsBytes(await pdf.save());

      setState(() {
        isLoading = false;
      });

      await Share.shareXFiles([XFile(file.path)], text: 'Payment Receipt');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating receipt: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your payment history')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().appNavyColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Payment History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : paymentsList.isEmpty
              ? const Center(child: Text('No payment history available'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: paymentsList.length,
                itemBuilder: (context, index) {
                  final payment = paymentsList[index];
                  final paidAt = (payment['paidAt'] as Timestamp).toDate();

                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      side: BorderSide(
                        width: 1,
                        color: AppColors().appYellowColor,
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                payment['feeDescription'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${payment['feeAmount']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Tutor: ${payment['tutorName']}'),
                          Text(
                            'Paid on: ${DateFormat('MMM d, yyyy').format(paidAt)}',
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors().appYellowColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.receipt_long,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Download Receipt',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () => generateReceipt(payment),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
