import 'package:flutter/material.dart';
import 'package:twin_app/pages/landing.dart';
import 'package:twin_app/router.dart';
import 'package:twin_app/widgets/commons/password_field.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordPage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const ResetPasswordPage({super.key, required this.loggedInState});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  @override
  Widget build(BuildContext context) {
    if (smallSreen)
      return _ResetPasswordMobilePage(loggedInState: widget.loggedInState);
    return Row(
      children: [
        Expanded(flex: 1, child: LandingPage()),
        SizedBox(
            width: credScreenWidth,
            child:
                _ResetPasswordMobilePage(loggedInState: widget.loggedInState)),
      ],
    );
  }
}

class _ResetPasswordMobilePage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const _ResetPasswordMobilePage({super.key, required this.loggedInState});

  @override
  State<_ResetPasswordMobilePage> createState() =>
      _ResetPasswordMobilePageState();
}

class _ResetPasswordMobilePageState
    extends BaseState<_ResetPasswordMobilePage> {
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confPassController = TextEditingController();

  @override
  void setup() {
    // TODO: implement setup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        decoration: theme.getCredentialsPageDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Align(alignment: Alignment.center, child: logo),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "changePassword",
                    style: theme.getStyle().copyWith(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                  ).tr(),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Container(
                decoration: theme.getCredentialsContentDecoration(),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 50),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(225, 95, 27, .3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            PasswordField(
                              controller: _newPassController,
                            ),
                            PasswordField(
                              hintKey: 'confirmPassword',
                              controller: _confPassController,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 70),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SecondaryButton(
                            labelKey: 'cancel',
                            minimumSize: Size(125, 50),
                            onPressed: () {
                              context.pop();
                            },
                          ),
                          const BusyIndicator(),
                          PrimaryButton(
                            labelKey: 'continue',
                            minimumSize: Size(200, 50),
                            onPressed: () {
                              context.push(Routes.login);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 50),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Wrap(
                          spacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Powered By",
                              style: theme.getStyle().copyWith(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                            ),
                            poweredBy,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
