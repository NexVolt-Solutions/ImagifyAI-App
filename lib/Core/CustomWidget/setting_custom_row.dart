// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:genwalls/Core/Constants/app_assets.dart';
// import 'package:google_fonts/google_fonts.dart';

// class SettingCustomRow extends StatefulWidget {
//   final icon1;
//   final textTitle;
//   final textSubTitle;
//   final icon2;
//    SettingCustomRow({super.key, this.icon1, this.textTitle, this.textSubTitle, this.icon2});

//   @override
//   State<SettingCustomRow> createState() => _SettingCustomRowState();
// }

// class _SettingCustomRowState extends State<SettingCustomRow> {
//   @override
//   Widget build(BuildContext context) {
//     bool isSwitched = false; // initial state

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Image.asset(AppAssets.themeIcon),
//               SizedBox(width: 32.w),

//               Column(
//                 children: [
//                   Text(
//                     textTitle,
//                     style: GoogleFonts.poppins(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Text(
//                     'Light Dark',
//                     style: GoogleFonts.poppins(
//                       color: Colors.white,
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Switch(
//             value: isSwitched,
//             onChanged: (value) {
//               setState(() {
//                 isSwitched = value;
//               });
//             },
//             activeColor: Colors.purple,
//             inactiveThumbColor: Colors.grey,
//             inactiveTrackColor: Colors.grey[300],
//           ),
//         ],
//       ),
//     );
//   }
// }
