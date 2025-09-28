import 'package:flutter/material.dart';
import 'chat_helpers.dart';

Widget authorAvatar(String name, {double? radius}) {
  return Tooltip(
    message: name,
    child: CircleAvatar(
      radius: radius,
      backgroundColor: colorForName(name),
      child: Text(
        getInitials(name),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
