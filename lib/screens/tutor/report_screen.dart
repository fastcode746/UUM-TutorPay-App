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

class TutorReportsScreen extends StatefulWidget {
  const TutorReportsScreen({Key? key}) : super(key: key);

  @override
  State<TutorReportsScreen> createState() => _TutorReportsScreenState();
}

class _TutorReportsScreenState extends State<TutorReportsScreen> {
  bool isLoading = false;
  List<Map<String, dynamic>> feesList = [];
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  
  @override
  void initState() {
    super.initState();
    loadTutorFees();
  }
  
  Future<void> loadTutorFees() async {
    if (currentUserId == null) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      // Query all fees created by this tutor
      final querySnapshot = await FirebaseFirestore.instance
          .collection('fees')
          .where('tutorId', isEqualTo: currentUserId)
          .get();
          
      final fees = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
      
      setState(() {
        feesList = List<Map<String, dynamic>>.from(fees);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading fees: $e'))
      );
      setState(() {
        isLoading = false;
      });
    }
  }
  
  Future<void> generatePDF(Map<String, dynamic> feeData) async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final pdf = pw.Document();
      final paidStudents = List<Map<String, dynamic>>.from(feeData['paidStudents'] ?? []);
      
      final formatter = DateFormat('MMM d, yyyy hh:mm a');
      final feeCreatedAt = (feeData['createdAt'] as Timestamp).toDate();
      final formattedDate = formatter.format(feeCreatedAt);
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Fee Payment Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Fee Description: ${feeData['description']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Amount: \$${feeData['feeAmount']}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ]
                ),
                pw.SizedBox(height: 10),
                pw.Text('Created on: $formattedDate'),
                pw.SizedBox(height: 20),
                pw.Text('Students who paid the fee:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(4),
                    2: const pw.FlexColumnWidth(3),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Student Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Email', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Payment Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ]
                    ),
                    ...paidStudents.map((student) {
                      final paidAt = (student['paidAt'] as Timestamp).toDate();
                      final paymentDate = formatter.format(paidAt);
                      
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(student['studentName'] ?? 'Unknown'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(student['studentEmail'] ?? 'Unknown'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8.0),
                            child: pw.Text(paymentDate),
                          ),
                        ]
                      );
                    }).toList(),
                  ]
                ),
                pw.SizedBox(height: 20),
                pw.Text('Total Students: ${paidStudents.length}'),
                pw.Text('Total Revenue: \$${paidStudents.length * feeData['feeAmount']}'),
                pw.SizedBox(height: 30),
                pw.Footer(
                  title: pw.Text('Generated on ${formatter.format(DateTime.now())}')
                )
              ]
            );
          }
        )
      );
      
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/fee_report_${feeData['id']}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      setState(() {
        isLoading = false;
      });
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Fee Payment Report'
      );
      
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e'))
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your reports'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().appNavyColor,
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: Icon(Icons.arrow_back,
        color: Colors.white,)),
        title: const Text('Your Payment Reports', style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : feesList.isEmpty
          ? const Center(child: Text('No fees created yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feesList.length,
              itemBuilder: (context, index) {
                final fee = feesList[index];
                final paidStudents = List.from(fee['paidStudents'] ?? []);
                final totalRevenue = paidStudents.length * fee['feeAmount'];
                final createdAt = (fee['createdAt'] as Timestamp).toDate();
                
                return Card(
                  color: Colors.white,
                  
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  child: ExpansionTile(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10,),

                    ),
                    side: BorderSide(
                      width: 1,
                      color: AppColors().appYellowColor,
                    ),
                  ),
                    title: Text(fee['description'] ?? 'No description'),
                    subtitle: Text  ('Amount: \$${fee['feeAmount']} • ${DateFormat('MMM d, yyyy').format(createdAt)}'),
                    trailing: Text('${paidStudents.length} payments'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Revenue: \$${totalRevenue}', 
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors().appYellowColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10,),
                                    )
                                  ),
                                  icon: const Icon(Icons.download, color: Colors.white,),
                                  label: const Text('Download Report', style: TextStyle(
                                    color: Colors.white
                                  ),),
                                  onPressed: () => generatePDF(fee),
                                ),
                              ],
                            ),
                            const Divider(),
                            const Text('Students who paid:', 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: paidStudents.length,
                              itemBuilder: (context, i) {
                                final student = paidStudents[i];
                                final paidAt = (student['paidAt'] as Timestamp).toDate();
                                
                                return ListTile(
                                  dense: true,
                                  title: Text(student['studentName'] ?? 'Unknown'),
                                  subtitle: Text(student['studentEmail'] ?? 'Unknown'),
                                  trailing: Text(DateFormat('MMM d, yyyy').format(paidAt)),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}