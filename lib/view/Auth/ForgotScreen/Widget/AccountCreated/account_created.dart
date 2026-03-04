import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imagifyai/Core/Constants/app_assets.dart';
import 'package:imagifyai/Core/Constants/app_colors.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/custom_button.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/viewModel/account_created_view_model.dart';
import 'package:provider/provider.dart';

class AccountCreated extends StatelessWidget {
  const AccountCreated({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountCreatedViewModel>(
      builder: (context, viewModel, _) => Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(AppAssets.starLogo),
            SvgPicture.asset(AppAssets.imagifyaiLogo),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: context.h(8)),
                child: IconButton(
                  onPressed: () => viewModel.navigateBack(context),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).iconTheme.color,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  splashRadius: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: context.h(20)),
          children: [
            SizedBox(height: context.h(233)),
            Image.asset(
              AppAssets.tickIcon,
              height: context.h(100),
              width: context.w(100),
              fit: BoxFit.contain,
            ),
            SizedBox(height: context.h(24)),
            Text(
              "You are all done!👏🏻",
              style: context.appTextStyles?.authTitleWhite,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(253)),
            CustomButton(
              onPressed: () => viewModel.navigateToSignIn(context),
              gradient: AppColors.gradient,
              text: 'Login',
            ),
          ],
        ),
      ),
    ),
    );
  }
}
