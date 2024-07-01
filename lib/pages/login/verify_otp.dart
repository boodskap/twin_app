import 'package:flutter/material.dart';
import 'package:twin_app/pages/landing.dart';
import 'package:twin_app/router.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:pinput/pinput.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:verification_api/api/verification.swagger.dart' as vapi;

class VerifyOtpPage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const VerifyOtpPage({super.key, required this.loggedInState});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  @override
  Widget build(BuildContext context) {
    if (smallSreen)
      return _VerifyOtpMobilePage(loggedInState: widget.loggedInState);
    return Row(
      children: [
        Expanded(flex: 1, child: LandingPage()),
        SizedBox(
            width: credScreenWidth,
            child: _VerifyOtpMobilePage(loggedInState: widget.loggedInState)),
      ],
    );
  }
}

class _VerifyOtpMobilePage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const _VerifyOtpMobilePage({super.key, required this.loggedInState});

  @override
  State<_VerifyOtpMobilePage> createState() => _VerifyOtpMobilePageState();
}

class _VerifyOtpMobilePageState extends BaseState<_VerifyOtpMobilePage> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void setup() {
    // TODO: implement setup
  }

  void _doShowResetPassword() {
    context.push(Routes.reset);
  }

  Future<void> _doVerifyPin() async {
    debugPrint('VARIABLES: $localVariables');
    String pinToken = localVariables['pinToken'] ?? '';
    if (pinToken.isEmpty) {
      alert("", "Pin token is missing");
      return;
    }

    try {
      String pin = _pinController.text;
      var body = vapi.VerificationReq(
        pin: pin,
        pinToken: pinToken,
      );
      var res = await config.verification
          .verifyPin(body: body, dkey: config.twinDomainKey);
      if (validateResponse(res)) {
        localVariables['authToken'] = res.body!.authToken;
        localVariables['pin'] = pin;
        _doShowResetPassword();
      }
    } catch (e) {
      alert("", "Error: $e");
    }
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
                    "verifyOtp",
                    style: theme.getStyle().copyWith(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
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
                      const SizedBox(
                        height: 50,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(225, 95, 27, .3),
                                  blurRadius: 20,
                                  offset: Offset(0, 10))
                            ]),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 40,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Pinput(
                                controller: _pinController,
                                length: 6,
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SecondaryButton(
                            labelKey: 'cancel',
                            onPressed: () {
                              context.pop();
                            },
                          ),
                          const BusyIndicator(),
                          PrimaryButton(
                            labelKey: 'verify',
                            minimumSize: Size(200, 50),
                            onPressed: () async {
                              if (_pinController.text.length == 6) {
                                _doVerifyPin();
                              } else {
                                alert("", "Pin Required");
                              }
                            },
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
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
                                    fontSize: 16,
                                  ),
                            ),
                            poweredBy,
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
