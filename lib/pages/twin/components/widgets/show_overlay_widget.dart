import 'package:flutter/material.dart';

class OverlayWidget {
  static void showOverlay({
    required BuildContext context,
    double? topPosition,
    double? leftPosition,
    double? rightPosition,
    double? bottomPosition,
    required String message,
  }) {
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPosition,
        left: leftPosition,
        right: rightPosition,
        bottom: bottomPosition,
        child: Material(
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(3.0),
            ),
            child: Text(message),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
