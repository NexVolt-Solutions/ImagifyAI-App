import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String validatorType;

  final String? hintText;
  final TextEditingController? controller;
  final String? keyboard;
  final icon;
  const CustomTextField({
    super.key,
    this.hintText,
    this.controller,
    this.keyboard,
    this.icon,
    required this.validatorType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "This field is required";
          }
          if (validatorType == "name") {
            if (value.length < 3) {
              return "Enter a valid name";
            }
          }
          if (validatorType == "phone") {
            if (!RegExp(r'^[0-9]{10,13}$').hasMatch(value)) {
              return "Enter a valid phone number";
            }
          }
          if (validatorType == "email") {
            if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(value)) {
              return "Enter a valid email";
            }
          }

          return null;
        },
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: icon,
          hintText: hintText,
          filled: true,
          fillColor: Colors.black,
          hintStyle: const TextStyle(color: Colors.white54),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
