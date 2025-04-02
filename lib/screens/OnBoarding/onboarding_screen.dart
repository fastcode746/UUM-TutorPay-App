import 'package:fee_app/config/theme.dart';
import 'package:fee_app/screens/auth/login_screen.dart';
import 'package:fee_app/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';

import '../../widgets/logo_container.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Main Logo Container
              LogoContainer(height: MediaQuery.of(context).size.height / 2),
              // Heading
              SizedBox(height: 20),
              Text(
                'Easy Tutor Payment',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
              // Subheading
              SizedBox(height: 10),
              Text(
                "Make your payment experience more\nbetter today. Direct to your tutor",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              // Login Button
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
                  backgroundColor: AppColors().appYellowColor,
                   shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  overlayColor: Colors.transparent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          
              // SignUp Button
              SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10),),
                  ),
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 60),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  overlayColor: Colors.transparent,
                  side: BorderSide(width: 2,
                  color: AppColors().appYellowColor,),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                },
                child: Text(
                  'Signup',
                  style: TextStyle(
                    color: AppColors().appYellowColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
