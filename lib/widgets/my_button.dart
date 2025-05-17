import 'package:aicaremanagermob/configs/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  const MyButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.fontWeight});
  final String text;
  final void Function() onPressed;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mainBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 15,
          fontWeight: fontWeight ?? FontWeight.w600,
        ),
      ),
    );
  }
}
