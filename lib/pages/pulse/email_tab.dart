import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/pulse/email.dart';
import 'package:twin_app/pages/pulse/email_group.dart';
import 'package:twin_commons/core/base_state.dart';

class EmailTabPage extends StatefulWidget {
  const EmailTabPage({super.key});

  @override
  State<EmailTabPage> createState() => _EmailTabPageState();
}

class _EmailTabPageState extends State<EmailTabPage> {
  bool _isEmailLog = true;
  bool _isEmailGroup = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
            divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: "Email Logs",
              child: Container(
                decoration: BoxDecoration(
                  color: _isEmailLog ? Colors.blue[200] : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.email,
                    color: _isEmailLog ? Colors.black : theme.getPrimaryColor(),
                  ),
                  onPressed: () {
                    setState(() {
                      _isEmailLog = true;
                      _isEmailGroup = false;
                    });
                    // _load();
                  },
                ),
              ),
            ),
            divider(horizontal: true),
            Tooltip(
              message: "Email Group",
              child: Container(
                decoration: BoxDecoration(
                  color: _isEmailGroup ? Colors.blue[200] : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.groups,
                    color: _isEmailGroup ? Colors.black : theme.getPrimaryColor(),
                  ),
                  onPressed: () {
                    setState(() {
                      _isEmailLog = false;
                      _isEmailGroup = true;
                    });
                    // _load();
                  },
                ),
              ),
            ),
           
          ],
        ),
         if(_isEmailLog)
            Expanded(child: EmailPage()),
            if(_isEmailGroup)
            Expanded(child: EmailGroupPage())
      ],
    );
  }
}
