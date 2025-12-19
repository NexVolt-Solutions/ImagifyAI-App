import 'package:flutter/material.dart';
import 'package:genwalls/Core/Constants/app_colors.dart';
import 'package:genwalls/Core/Constants/size_extension.dart';

class CustomListView extends StatelessWidget {
  final String? image;
  const CustomListView({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.h(10)),
      child: SizedBox(
        height: context.h(131),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 9,
          itemBuilder: (context, index) {
            return Container(
              height: context.h(131),
              width: context.w(100),
              margin: context.padSym(h: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.radius(8)),
                border: Border.all(color: AppColors.whiteColor),
              ),
              clipBehavior: Clip.hardEdge,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.radius(8)),
                child: image != null && image!.isNotEmpty
                    ? Image.asset(image!, fit: BoxFit.contain)
                    : Container(
                        color: Colors.grey[900],
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[600],
                          size: 40,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
