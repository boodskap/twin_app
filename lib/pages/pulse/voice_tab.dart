import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/pulse/voice.dart';
import 'package:twin_app/pages/pulse/voice_group.dart';
import 'package:twin_commons/core/base_state.dart';

class VoiceTabPage extends StatefulWidget {
  const VoiceTabPage({super.key});

  @override
  State<VoiceTabPage> createState() => _VoiceTabPageState();
}

class _VoiceTabPageState extends BaseState<VoiceTabPage> {
  bool _isVoiceLog = true;
  bool _isVoiceGroup = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
            divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: "Voice Logs",
              child: Container(
                decoration: BoxDecoration(
                  color: _isVoiceLog ? Colors.blue[200] : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.voicemail,
                    color: _isVoiceLog ? Colors.black : theme.getPrimaryColor(),
                  ),
                  onPressed: () {
                    setState(() {
                      _isVoiceLog = true;
                      _isVoiceGroup = false;
                    });
                    // _load();
                  },
                ),
              ),
            ),
            divider(horizontal: true),
            Tooltip(
              message: "Voice Group",
              child: Container(
                decoration: BoxDecoration(
                  color: _isVoiceGroup ? Colors.blue[200] : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.groups,
                    color: _isVoiceGroup ? Colors.black : theme.getPrimaryColor(),
                  ),
                  onPressed: () {
                    setState(() {
                      _isVoiceLog = false;
                      _isVoiceGroup = true;
                    });
                    // _load();
                  },
                ),
              ),
            ),
           
          ],
        ),
         if(_isVoiceLog)
            Expanded(child: VoicePage()),
            if(_isVoiceGroup)
            Expanded(child: VoiceGroupPage())
      ],
    );
  }
  
  @override
  void setup() {
    // TODO: implement setup
  }
}
