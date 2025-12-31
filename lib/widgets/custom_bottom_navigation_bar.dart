import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_base_project_mvvm/core/extensions/double.dart';
import 'package:flutter_base_project_mvvm/core/extensions/int.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/view_constants.dart';
import '../viewmodels/providers/theme_provider.dart';
import 'translated_text.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key, required this.onChanged});

  final Function(int) onChanged;

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final int _numberOfItems = 3;
  final _animationDuration = const Duration(milliseconds: 150);

  late final List<AnimationController> _animationControllers = List.generate(
      _numberOfItems,
      (index) =>
          AnimationController(vsync: this, duration: _animationDuration));

  @override
  void initState() {
    super.initState();
    _animationControllers.first.forward();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      color: themeProvider.baseTheme.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: 98.h,
          color: themeProvider.baseTheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navigationItem(
                  themeProvider, 0, ViewConstants.home, AppAssets.home,
                  isSelected: _selectedIndex == 0),
              navigationItem(
                  themeProvider, 1, ViewConstants.search, AppAssets.search,
                  isSelected: _selectedIndex == 1),
              navigationItem(
                  themeProvider, 2, ViewConstants.more, AppAssets.more,
                  isSelected: _selectedIndex == 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget navigationItem(
      ThemeProvider themeProvider, int index, String title, String icon,
      {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => onNavigationItemTapped(index),
      child: AnimatedContainer(
        duration: _animationDuration,
        height: 75.h,
        width: 63.h,
        decoration: BoxDecoration(
            color: isSelected
                ? themeProvider.baseTheme.bottomNavBar.background
                : null,
            borderRadius: const BorderRadius.all(Radius.circular(12))),
        child: Column(
          children: [
            Gap((AppConstants.gap14Px + 1).h),
            SvgPicture.asset(
              icon,
              height: 24.h,
              color: isSelected
                  ? themeProvider.baseTheme.bottomNavBar.foreground
                  : themeProvider.baseTheme.onSurface,
            )
                .animate(
                    controller: _animationControllers[index], autoPlay: false)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1667, 1.1667),
                ),
            if (isSelected)
              Gap(AppConstants.gap10Px.h)
            else
              Gap(AppConstants.gap14Px.h),
            TranslatedText(
              title,
              style: TextStyle(
                  height: 1,
                  color: isSelected
                      ? themeProvider.baseTheme.bottomNavBar.foreground
                      : themeProvider.baseTheme.onSurface,
                  fontSize: AppConstants.font10Px,
                  fontWeight: FontWeight.w500),
            ),
            Gap(AppConstants.gap6Px.h),
            indicator(themeProvider)
                .animate(
                    controller: _animationControllers[index], autoPlay: false)
                .fade()
          ],
        ),
      ),
    );
  }

  Container indicator(ThemeProvider themeProvider) {
    return Container(
      height: 2.5.h,
      width: 15.h,
      decoration: BoxDecoration(
          color: themeProvider.baseTheme.bottomNavBar.indicator,
          borderRadius: const BorderRadius.all(Radius.circular(50))),
    );
  }

  void onNavigationItemTapped(int index) {
    widget.onChanged(index);
    _selectedIndex = index;
    for (final (i, c) in _animationControllers.indexed) {
      if (i == index) {
        c.forward();
      } else {
        c.animateTo(0.0);
      }
    }

    setState(() {});
  }
}
