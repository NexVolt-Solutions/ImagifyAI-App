import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomRow extends StatefulWidget {
  final String text1;
  final String text2;
  final String iconImag1;
  final VoidCallback? OnPressed;

  final bool showSwitch;
  final bool? rightIcon;
  const CustomRow({
    super.key,
    required this.text1,
    required this.text2,
    required this.iconImag1,
    required this.showSwitch,
    required this.rightIcon,
    this.OnPressed,
  });

  @override
  State<CustomRow> createState() => _CustomRowState();
}

class _CustomRowState extends State<CustomRow> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          GestureDetector(
            onTap: widget.OnPressed,
            child: Row(
              children: [
                Image.asset(widget.iconImag1, height: 24.h, width: 24.w),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.text1,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.text2,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          widget.showSwitch
              ? Switch(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                  activeColor: Colors.purple,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                )
              : widget.rightIcon == true
              ? Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp)
              : SizedBox(),
        ],
      ),
    );
  }
}
