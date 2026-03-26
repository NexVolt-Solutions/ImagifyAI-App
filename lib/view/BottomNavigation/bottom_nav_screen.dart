import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imagifyai/Core/Constants/size_extension.dart';
import 'package:imagifyai/Core/CustomWidget/logo_app_bar.dart';
import 'package:imagifyai/Core/theme/theme_extensions.dart';
import 'package:imagifyai/view/BottomNavigation/widgets/bottom_nav_bar.dart';
import 'package:imagifyai/viewModel/bottom_nav_screen_view_model.dart';
import 'package:provider/provider.dart';

class BottomNavScreen extends StatefulWidget {
  final int selectedIndex;
  const BottomNavScreen({super.key, this.selectedIndex = 0});
  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the bottom nav index if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bottomNavScreenViewModel = Provider.of<BottomNavScreenViewModel>(
        context,
        listen: false,
      );
      if (widget.selectedIndex != bottomNavScreenViewModel.currentIndex) {
        bottomNavScreenViewModel.updateIndex(widget.selectedIndex);
      }
    });
  }

  Future<void> _handlePopInvoked(bool didPop) async {
    if (didPop) return;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Exit App',
          style: TextStyle(
            color: context.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to exit the app?',
          style: TextStyle(color: context.textColor),
        ),
        backgroundColor: context.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.radius(12)),
          side: BorderSide(color: context.primaryColor, width: 2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.subtitleColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Exit',
              style: TextStyle(
                color: context.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavScreenViewModel = Provider.of<BottomNavScreenViewModel>(
      context,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _handlePopInvoked(didPop),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: LogoAppBar(),
        body: SafeArea(
          child: Stack(
            children: [
              IndexedStack(
                index: bottomNavScreenViewModel.currentIndex,
                children: bottomNavScreenViewModel.screens,
              ),
              BottomNavBar(
                bottomData: bottomNavScreenViewModel.bottomData,
                currentIndex: bottomNavScreenViewModel.currentIndex,
                onTap: bottomNavScreenViewModel.updateIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
