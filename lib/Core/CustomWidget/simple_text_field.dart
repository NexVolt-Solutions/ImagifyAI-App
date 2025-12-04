import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class SimpleTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String validatorType;

  const SimpleTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.validatorType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: TextFormField(
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
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
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
