import 'package:flutter/material.dart';
import 'package:twin_app/pages/landing.dart';
import 'package:twin_app/router.dart';
import 'package:twin_app/widgets/commons/email_field.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:verification_api/api/verification.swagger.dart' as vapi;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    if (smallScreen || landingPages.isEmpty) return _ForgotPasswordMobilePage();
    return Row(
      children: [
        Expanded(flex: 1, child: LandingPage()),
        SizedBox(width: credScreenWidth, child: _ForgotPasswordMobilePage()),
      ],
    );
  }
}

class _ForgotPasswordMobilePage extends StatefulWidget {
  const _ForgotPasswordMobilePage();

  @override
  State<_ForgotPasswordMobilePage> createState() =>
      _ForgotPasswordMobilePageState();
}

class _ForgotPasswordMobilePageState
    extends BaseState<_ForgotPasswordMobilePage> {
  final TextEditingController _emailController = TextEditingController();
  bool _canSignUp = false;

  @override
  void setup() async {
    await execute(() async {
      var uRes = await TwinnedSession.instance.twin
          .getUsageByDomainKey(domainKey: config.twinDomainKey);
      if (validateResponse(uRes)) {
        var usage = uRes.body!.entity!;
        if (config.signUpAsClient) {
          _canSignUp = usage.availableClients > usage.usedClients;
        } else {
          _canSignUp = usage.availableUsers > usage.usedUsers;
        }
      }
    });

    refresh();
  }

  void _showForgotOtpPage() {
    context.push(Routes.otp);
  }

  Future<void> _doChangePassword() async {
    try {
      var userEmail = _emailController.text.trim();
      var body = vapi.ForgotPassword(
        userId: userEmail,
        subject: config.emailSubject,
        template: config.resetPswdTemplate,
      );
      var res = await config.verification.forgotPassword(
        body: body,
        dkey:
            config.isTwinApp() ? config.twinDomainKey : config.noCodeDomainKey,
      );

      if (validateResponse(res)) {
        localVariables['userId'] = userEmail;
        localVariables['pinToken'] = res.body!.pinToken;

        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('OTP Sent'),
              content: Text(
                'Reset Password OTP has been sent to your email.\nPlease check it.',
              ),
              actions: <Widget>[
                PrimaryButton(
                    minimumSize: Size(20, 20),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showForgotOtpPage();
                    },
                    labelKey: 'OK'),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while processing your request. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: smallScreen ? null : credScreenWidth,
              decoration: theme.getCredentialsPageDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 100, child: logo),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "resetPassword",
                          style: theme.getStyle().copyWith(
                                color: theme.getPrimaryColor(),
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                        ).tr(),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                    child: Container(
                      width: double.infinity,
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
                                    color: theme.getSecondaryColor(),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: <Widget>[
                                  EmailField(
                                    onSubmitted: (value) {
                                      _doChangePassword();
                                    },
                                    controller: _emailController,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 50),
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
                                  labelKey: 'generateOtp',
                                  minimumSize: Size(200, 50),
                                  onPressed: () {
                                    _doChangePassword();
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            if (_canSignUp)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "noAccountYet",
                                    style: theme.getStyle().copyWith(),
                                  ).tr(),
                                  TextButton(
                                    onPressed: () {
                                      GoRouter.of(context).push(Routes.signup);
                                    },
                                    child: Text(
                                      "signUp",
                                      style: theme.getStyle().copyWith(
                                            fontSize: 16,
                                            color: theme.getPrimaryColor(),
                                          ),
                                    ).tr(),
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
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
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
          ],
        ),
      ),
    );
  }
}
