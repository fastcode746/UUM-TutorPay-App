import 'package:flutter/material.dart';
import '../config/theme.dart';

class LogoContainer extends StatelessWidget {
  final double height; 
   const LogoContainer({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors().appNavyColor,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Image.asset(AppImages.mainLogo,),
             Text('UUM TutorPay', style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
             ),)
          ]
          ),
      ),
    );
  }
}