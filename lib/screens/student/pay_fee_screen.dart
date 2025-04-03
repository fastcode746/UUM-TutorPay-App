// ignore_for_file: unused_field, use_super_parameters

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fee_app/config/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/fee_service.dart';
import '../../services/payment_service.dart';

class StudentFeeScreen extends StatefulWidget {
  const StudentFeeScreen({Key? key}) : super(key: key);

  @override
  State<StudentFeeScreen> createState() => _StudentFeeScreenState();
}

class _StudentFeeScreenState extends State<StudentFeeScreen> {
  final FeeService _feeService = FeeService();
  final StripeService _stripeService = StripeService();
  bool _isLoading = false;
  String? studentName;

@override
  void initState() {
getStudentName();
    super.initState();
  }
  void getStudentName() async{
    var vari = await FirebaseFirestore.instance
            .collection("students")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    setState (() {
      studentName = vari.data()?['fullName'];
    });
}
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: (){
            Navigator.of(context).pop();
          }, icon: Icon(Icons.arrow_back,
          color: Colors.white,),),
          backgroundColor: AppColors().appNavyColor,
          title: Text('Pay your Fee', style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
            tabs: [
              Tab(text: 'Unpaid Fee', ),
              Tab(text: 'My Paid Fee'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Available Tutors Tab
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _feeService.getAllTutorFees(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final tutors = snapshot.data ?? [];
                
                if (tutors.isEmpty) {
                  return Center(child: Text('No tutors available'));
                }
                
                return ListView.builder(
                  itemCount: tutors.length,
                  itemBuilder: (context, index) {
                    final tutor = tutors[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10,),
                        
                        ),
                        side: BorderSide(
                          width: 1,
                          color: AppColors().appYellowColor,
                        )
                      ),
                    color: Colors.white,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(tutor['tutorName'], style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),),
                        subtitle: Text(tutor['description'] ?? 'No description'),
                        trailing: Text(
                          '\RM ${tutor['feeAmount'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black
                          ),
                        ),
                        onTap: () => _showPaymentDialog(tutor),
                      ),
                    );
                  },
                );
              },
            ),
            
            // My Paid Tutors Tab
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _feeService.getTutorsPaidByStudent(
                FirebaseAuth.instance.currentUser?.uid ?? '',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final paidTutors = snapshot.data ?? [];
                
                if (paidTutors.isEmpty) {
                  return Center(child: Text('You haven\'t paid any tutors yet'));
                }
                
                return ListView.builder(
                  itemCount: paidTutors.length,
                  itemBuilder: (context, index) {
                    final tutor = paidTutors[index];
                    return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10,),),
                      side: BorderSide(
                        color: AppColors().appYellowColor,
                        width: 1,

                      )
                    ),
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(tutor['tutorName'], style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),),
                        subtitle: Text(tutor['description'] ?? 'No description'),
                        trailing: Icon(Icons.check_circle, color: Colors.green),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPaymentDialog(Map<String, dynamic> tutor) async {
    bool hasAlreadyPaid = await _feeService.hasStudentPaidTutor(
      tutorId: tutor['tutorId'],
      studentId: FirebaseAuth.instance.currentUser?.uid ?? '',
    );
    
    if (hasAlreadyPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already paid this tutor')),
      );
      return;
    }
    
    showDialog(
      
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pay Tutor Fee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tutor: ${tutor['tutorName']}', style: TextStyle(
              fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 8),
            Text('Fee: \RM ${tutor['feeAmount'].toStringAsFixed(2)}'),
            if (tutor['description'] != null && tutor['description'].isNotEmpty) ...[
              SizedBox(height: 8),
              Text('Description: ${tutor['description']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(
              color: Colors.black
            ),),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors().appYellowColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10),),
              )
            ),
            onPressed: () => _processPayment(tutor),
            child: Text('Pay Now', style: TextStyle(
              color: Colors.white,
              
            ),),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(Map<String, dynamic> tutor) async {
    Navigator.pop(context); // Close the dialog
    
    setState(() {
      _isLoading = true;
    });
    
  
    String simulatedPaymentIntentId = 'pi_${DateTime.now().millisecondsSinceEpoch}';
    
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      Map<String, dynamic> result = await _stripeService.processPayment(
        tutorId: tutor['tutorId'],
        studentId: currentUser.uid,
        studentName: studentName ?? 'Unknown Student',
        studentEmail: currentUser.email ?? '',
        paymentIntentId: simulatedPaymentIntentId,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      
      if (result['success']) {
        // Refresh the UI to show the tutor in the "My Paid Tutors" tab
        setState(() {});
      }
    }
  }
}