import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syathiby/core/constants/color_constants.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Syathiby",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: ColorConstants.lightPrimaryText, 
      ),
    );
  }
}
