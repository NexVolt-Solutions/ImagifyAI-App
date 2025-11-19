import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomListView extends StatelessWidget {
  final image;
  const CustomListView({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: SizedBox(
        height: 130.h,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemCount: 9,
          itemBuilder: (context, index) {
            return Container(
              height: 130.h,
              width: 110.w,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white, width: 2),
              ),
              clipBehavior: Clip.hardEdge,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.asset(image, fit: BoxFit.contain),
              ),
            );
          },
        ),
      ),
    );
  }
}
