import 'package:flutter/material.dart';

class NotificationPush extends StatefulWidget {
  const NotificationPush({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  State createState() => _NotificationPushState();
}

class _NotificationPushState extends State<NotificationPush> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rewind and remember'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('You will never be satisfied.'),
            Text(widget.message),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Regret'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
