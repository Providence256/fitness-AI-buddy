import 'package:fitness_app/utility/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppLoaders {
  static hideSnackBar() =>
      ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();

  static successSnackBar({required title, message = '', duration = 3}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      colorText: Colors.white,
      backgroundColor: AppColors.primaryBlue,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: EdgeInsets.all(10),
      icon: Icon(Icons.check, color: Colors.white),
    );
  }
}
