import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:twin_app/auth.dart';
import 'package:twin_app/widgets/commons/password_field.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;

class UnregisterSnippet extends StatefulWidget {
  final StreamAuth auth;
  const UnregisterSnippet({
    super.key,
    required this.auth,
  });

  @override
  State<UnregisterSnippet> createState() => _UnregisterSnippetState();
}

class _UnregisterSnippetState extends BaseState<UnregisterSnippet> {
  final TextEditingController _controller = TextEditingController();
  String password = '';
  String reason = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        reason = _controller.text.trim();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LabelTextField(
            label: 'Reason for account closing?', controller: _controller),
        PasswordField(
          onChanged: (v) {
            setState(() {
              password = v.trim();
            });
          },
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const BusyIndicator(),
            divider(horizontal: true),
            SecondaryButton(
              labelKey: 'Cancel',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            divider(horizontal: true),
            PrimaryButton(
              labelKey: 'Proceed',
              onPressed: !_canDelete() ? null : _deleteMyAccount,
            ),
          ],
        ),
      ],
    );
  }

  bool _canDelete() {
    return reason.isNotEmpty && password.isNotEmpty;
  }

  Future _deleteMyAccount() async {
    await execute(() async {
      var res = await TwinnedSession.instance.twin.unregisterAccount(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.UnregisterAccount(reason: reason, password: password));

      if (validateResponse(res)) {
        widget.auth.signOut();
      }
    });
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}
