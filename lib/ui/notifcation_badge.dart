import 'package:flutter/material.dart';

/// The widget for displaying the total number of
/// notifications recieved
class NotificationBadge extends StatelessWidget {
  final int totalNotification;
  const NotificationBadge({Key? key, required this.totalNotification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '$totalNotification',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      )),
    );
  }
}
