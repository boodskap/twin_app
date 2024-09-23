import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/pulse/sms.dart';
import 'package:twin_app/pages/pulse/sms_group.dart';
import 'package:twin_commons/core/base_state.dart';

class SMSTabPage extends StatefulWidget {
  const SMSTabPage({super.key});

  @override
  State<SMSTabPage> createState() => _SMSTabPageState();
}

class _SMSTabPageState extends BaseState<SMSTabPage> {
  bool _isSMSLog = true;
  bool _isSMSGroup = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
            divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: "SMS Logs",
              child: Container(
                decoration: BoxDecoration(
                  color: _isSMSLog ? Colors.blue[200] : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.sms,
                    color: _isSMSLog ? Colors.black : theme.getPrimaryColor(),
                  ),
                  onPressed: () {
                    setState(() {
                      _isSMSLog = true;
                      _isSMSGroup = false;
                    });
                    // _load();
                  },
                ),
              ),
            ),
            divider(horizontal: true),
            Tooltip(
              message: "SMS Group",
              child: Container(
                decoration: BoxDecoration(
                  color: _isSMSGroup ? Colors.blue[200] : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.groups,
                    color: _isSMSGroup ? Colors.black : theme.getPrimaryColor(),
                  ),
                  onPressed: () {
                    setState(() {
                      _isSMSLog = false;
                      _isSMSGroup = true;
                    });
                    // _load();
                  },
                ),
              ),
            ),
           
          ],
        ),
         if(_isSMSLog)
            Expanded(child: SmsPage()),
            if(_isSMSGroup)
            Expanded(child: SmsGroupPage())
      ],
    );
  }
  
  @override
  void setup() {
    // TODO: implement setup
  }
}
