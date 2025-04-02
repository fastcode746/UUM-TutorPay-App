// ignore_for_file: use_build_context_synchronously

import 'package:fee_app/config/theme.dart';
import 'package:fee_app/config/utils.dart';
import 'package:fee_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/fee_service.dart';

class InputFeeScreen extends StatefulWidget {
  const InputFeeScreen({super.key});

  @override
  State<InputFeeScreen> createState() => _InputFeeScreenState();
}

class _InputFeeScreenState extends State<InputFeeScreen> {
  final FeeService _feeService = FeeService();
  final TextEditingController _feeAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _currentFee;
  final DatabaseService databaseService = DatabaseService();
  String? tutorName;
  @override
  void initState() {
    super.initState();
    _loadCurrentFee();
    getTutorName();

  }

  void getTutorName() async{
            var vari = await FirebaseFirestore.instance
            .collection("tutors")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    setState (() {
      tutorName = vari.data()?['fullName'];
      
    });
}

  Future<void> _loadCurrentFee() async {
    setState(() {
      _isLoading = true;
    });
    
    String? tutorId = FirebaseAuth.instance.currentUser?.uid;
    if (tutorId != null) {
      _currentFee = await _feeService.getTutorFee(tutorId);
      
      if (_currentFee != null) {
        _feeAmountController.text = _currentFee!['feeAmount'].toString();
        _descriptionController.text = _currentFee!['description'] ?? '';
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveFee() async {
    if (_feeAmountController.text.isEmpty) {
      showSnackbar(context, Colors.red, "Please enter a fee amount");
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool result = await _feeService.createOrUpdateTutorFee(
        tutorId: user.uid,
        tutorName: tutorName ?? 'Unknown Tutor',
        tutorEmail: user.email ?? '',
        feeAmount: double.parse(_feeAmountController.text),
        description: _descriptionController.text,
      );
      
      if (result) {
       showSnackbar(context, Colors.green, "Fee Saved Successfully !");
        _loadCurrentFee();
      } else {
        showSnackbar(context, Colors.red, "Failed to save fee !");
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: Icon(Icons.arrow_back,
        color: Colors.white,),),
        backgroundColor: AppColors().appNavyColor,
        title: Text('Manage Your Fee', style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Your Fee',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _feeAmountController,
                  decoration: InputDecoration(
                    labelText: 'Fee Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  
                  onPressed: _saveFee,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors().appYellowColor,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Save Fee', style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),),
                ),
                
                if (_currentFee != null) ...[
                  SizedBox(height: 30),
                  Text(
                    'Students Who Paid',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _feeService.getStudentsWhoPaidTutor(FirebaseAuth.instance.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      
                      final students = snapshot.data ?? [];
                      
                      if (students.isEmpty) {
                        return Text('No students have paid yet');
                      }
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(student['studentName'][0]),
                            ),
                            title: Text(student['studentName']),
                            subtitle: Text(student['studentEmail']),
                            trailing: Text(
                              'Paid on ${_formatTimestamp(student['paidAt'])}',
                              style: TextStyle(color: Colors.green),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
    );
  }
  
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}