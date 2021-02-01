import 'dart:ui';

import 'package:flutter/material.dart';

/// createSmoothDialog requires context, String title, List<Widget> actions.
///
/// As optional, leading icon and preventBackgroundDismiss.
///
/// leadingIcon should be type of Icon or null,
/// preventBackgroundDismiss should be type of bool
void createSmoothDialog(
    dynamic context, String title, String content, List<Widget> actions,
    [dynamic leadingIcon, bool allowBackgroundDismiss = true]) {
  showDialog(
    context: context,
    barrierDismissible: allowBackgroundDismiss,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: leadingIcon is Icon
                ? <Widget>[
                    leadingIcon,
                    new Text(" $title"), // For space between icon and title
                  ]
                : <Widget>[
                    new Text(title), // For space between icon and title
                  ],
          ),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                content,
              ),
            ],
          ),
          actions: actions,
        ),
      );
    },
  );
}
