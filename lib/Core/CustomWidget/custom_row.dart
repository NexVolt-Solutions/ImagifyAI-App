import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomRow extends StatefulWidget {
  final String text1;
  final String text2;
  final String iconImag1;
  final VoidCallback? onPressed;

  final bool showSwitch;
  final bool? rightIcon;

  const CustomRow({
    super.key,
    required this.text1,
    required this.text2,
    required this.iconImag1,
    required this.showSwitch,
    required this.rightIcon,
    this.onPressed,
  });

  @override
  State<CustomRow> createState() => _CustomRowState();
}

class _CustomRowState extends State<CustomRow> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.h(20)),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  widget.iconImag1,
                  height: context.h(24),
                  width: context.w(24),
                ),
                SizedBox(width: context.w(10)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.text1,
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteColor,
                        fontSize: context.text(16),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.text2,
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteColor,
                        fontSize: context.text(12),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            widget.showSwitch
                ? Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                      });
                    },
                    activeThumbColor: AppColors.primeryColor,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey[300],
                  )
                : widget.rightIcon == true
                ? Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.whiteColor,
                    size: context.text(16),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
