import 'package:flutter/material.dart';

import '../config/theme.dart';

class CustomCard extends StatelessWidget {
  final VoidCallback onpress;
  final IconData icon;
  final String buttonTitle;
  const CustomCard({
    super.key,
    required this.onpress,
    required this.icon,
    required this.buttonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onpress,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(width: 2, color: AppColors().appYellowColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors().appNavyColor),
          SizedBox(height: 10),
          Text(
            buttonTitle,
            style: TextStyle(
              color: AppColors().appNavyColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
