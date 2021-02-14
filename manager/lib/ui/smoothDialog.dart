import 'dart:ui';

import 'package:flutter/material.dart';

/// createSmoothDialog requires context, String title, Widget content, Widget actions.
///
/// As optional, leading icon and preventBackgroundDismiss.
///
/// leadingIcon should be type of Icon or null,
/// preventBackgroundDismiss should be type of bool
void createSmoothDialog(
    dynamic context, String title, Widget content, Widget actions,
    [dynamic leadingIcon, bool allowBackgroundDismiss = true]) {
  showDialog(
    context: context,
    barrierDismissible: allowBackgroundDismiss,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return _DynamicDialog(
            actions: actions,
            title: title,
            content: content,
            leadingIcon: leadingIcon,
          );
        },
      );
    },
  );
}

class _DynamicDialog extends StatefulWidget {
  var leadingIcon;
  var title;
  var content;
  var actions;

  _DynamicDialog(
      {Key key,
      @required this.leadingIcon,
      @required this.title,
      @required this.content,
      @required this.actions})
      : super(key: key);
  @override
  __DynamicDialogState createState() => __DynamicDialogState();
}

class __DynamicDialogState extends State<_DynamicDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: AlertDialog(
        // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widget.leadingIcon is Icon
              ? <Widget>[
                  widget.leadingIcon,
                  new Text(
                      " ${widget.title}"), // For space between icon and title
                ]
              : <Widget>[
                  new Text(widget.title), // For space between icon and title
                ],
        ),
        content: Container(child: widget.content),
        actions: [widget.actions],
      ),
    );
  }
}
