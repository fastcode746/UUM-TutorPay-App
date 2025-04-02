// ignore_for_file: use_build_context_synchronously

import 'package:fee_app/config/theme.dart';
import 'package:fee_app/screens/OnBoarding/onboarding_screen.dart';
import 'package:fee_app/screens/tutor/input_fee_screen.dart';
import 'package:fee_app/screens/tutor/report_screen.dart';
import 'package:fee_app/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_card.dart';

class TutorDashboardScreen extends StatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  State<TutorDashboardScreen> createState() => _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends State<TutorDashboardScreen> {
  final AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: ColoredBox(color: AppColors().appNavyColor),
          ),

          // Top Elements
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 10).copyWith(top: 40),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Notification Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                // Main Logo
                Image.asset(AppImages.mainLogo),
                SizedBox(height: 20),
                // Welcome Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Tutor',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      children: [
                        CustomCard(
                          onpress: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> InputFeeScreen(),),);
                          },
                          icon: Icons.add_circle_outline,
                          buttonTitle: "Input Fee",
                        ),
                        CustomCard(
                          onpress: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> TutorReportsScreen(),),);
                          },
                          icon: Icons.request_page_outlined,
                          buttonTitle: "Transaction Report",
                        ),
                        CustomCard(
                          onpress: () async {
                            await authService.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnBoardingScreen(),
                              ),
                            );
                          },
                          icon: Icons.logout,
                          buttonTitle: "Logout",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
